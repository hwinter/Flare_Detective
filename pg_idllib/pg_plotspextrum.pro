;+
; NAME:
;      pg_plotspextrum
;
; PURPOSE: 
;      plot a spectrum from an input spex_structure
;
; INPUTS:
;      spst: spex structure, defined as:
;  spex_st = {xselect:xselect, apar_arr:apar_arr, apar_sigma:apar_sigma $
;  ,chi:chi, convi:convi, obsi:obsi, eobsi:eobsi, backi :backi, ebacki:ebacki $
;  ,f_model:f_model, free: free, erange:erange, tb:tb, ut:ut $
;  ,iselect:iselect, date:anytim(uts,/date_only), edges:edges, apar:apar $
;  ,ifirst:ifirst, ilast:ilast, epivot:epivot, back_order:back_order}
;
; 
;  
; OUTPUTS:
;      none
;      
; KEYWORDS:
;      n_spec: in case of multiple spectra, choose the one to plot
;              0 or greater--> number  
;              undefined : take ifirst
;              -1 : there is only one spectrum (use apar instead
;              of apar_arr)
;      xlog,ylog: if set to 0 inhibits the log plot (which is default)
;      psym: is ignored
;      modthick: thickness of model lines (2 is default)
;
; HISTORY:
;       23-OCT-2003 written PG
;       05-NOV-2003 made more general in scope PG
;       19-NOV-2003 improved, now works on a different concept... PG
;       12-JAN-2004 added model dependent bahviour, but only for a few
;                   selected model (not yet "general") PG 
;       17-MAY-2004 added background plot capabilities (keyword
;                   bcolor) and extapar keyword PG 
;
; TO_DO: -- update documentation, polish up
;        -- future: let it works for arbitrary model... (->taking
;           input from spec model_component.pro)
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

PRO pg_plotspextrum, spst,n_spec= n_spec, xlog=xlog, ylog=ylog,psym=psym $
                   , modthick=modthick, modcolor=modcolor, modstyle=modstyle $
                   , color=color, spthick=spthick, xtitle=xtitle, title=title $
                   , ytitle=ytitle, overplot=overplot, histo=histo $
                   , nodata=nodata, erebin=erebin,nrebin=nrebin,noberr=noberr $
                   , modlinestyle=modlinestyle,bcolor=bcolor,bthick=bthick $
                   , extapar=extapar, _extra=_extra



xlog=fcheck(xlog,1)
ylog=fcheck(ylog,1)
xtitle=fcheck(xtitle,'Energy (keV)')
ytitle=fcheck(ytitle,'Photon flux (photons s!A-1!N cm!A-2!N keV!A-1!N)')
modthick=fcheck(modthick,2)
modcolor=fcheck(modcolor,[7,5,4,12,1,8,9,11,10])
modstyle=fcheck(modstyle,0)
modlinestyle=fcheck(modlinestyle,replicate(modstyle,10))

psym=3

IF n_elements(n_spec) LT 1 THEN n_spec=spst.ifirst

IF n_spec LT 0 THEN BEGIN
    useapar=1
    n_spec=0
    ENDIF $
ELSE useapar=0


IF exist(extapar) THEN apar=extapar ELSE BEGIN
   IF useapar THEN  apar=spst.apar ELSE apar=spst.apar_arr[*,n_spec]
ENDELSE


title=fcheck(title,strjoin(string(apar,format='(e9.2)')))



edge_products,spst.edges,mean=energybins,edges_2=energyedges
IF keyword_set(erebin) AND keyword_set(nrebin) THEN BEGIN

    energyedges_rebin=pg_edges_rebin(energyedges,erebin,nrebin)
    edge_products,energyedges_rebin,mean=energybins

    IF NOT keyword_set(nodata) THEN BEGIN
        phflux = (spst.obsi[*,n_spec]-spst.backi[*,n_spec])/spst.convi[*,n_spec]

        errflux = sqrt(spst.eobsi[*,n_spec]^2 + spst.ebacki[*,n_spec]^2)/spst.convi[*,n_spec]

        bflux=spst.backi[*,n_spec]/spst.convi[*,n_spec]
        berrflux =spst.ebacki[*,n_spec]/spst.convi[*,n_spec]

        phflux=pg_rebin(energyedges,phflux,energyedges_rebin)
        errflux=pg_rebin(energyedges,errflux,energyedges_rebin)
 
        bflux=pg_rebin(energyedges,bflux,energyedges_rebin)
        berrflux=pg_rebin(energyedges,berrflux,energyedges_rebin)

        energyedges=energyedges_rebin
    
    ENDIF
   
ENDIF ELSE $
IF NOT keyword_set(nodata) THEN BEGIN
phflux = (spst.obsi[*,n_spec]-spst.backi[*,n_spec])/spst.convi[*,n_spec]

errflux = sqrt(spst.eobsi[*,n_spec]^2 + spst.ebacki[*,n_spec]^2)/spst.convi[*,n_spec]

bflux =spst.backi[*,n_spec]/spst.convi[*,n_spec]

berrflux = spst.ebacki[*,n_spec]/spst.convi[*,n_spec]


ENDIF




IF keyword_set(histo) THEN psym=10.

IF NOT((keyword_set(overplot)) OR (keyword_set(nodata))) THEN $
  plot, energybins, phflux[*],xlog=xlog,ylog=ylog,psym=psym,color=color,title=title $
                             ,xtitle=xtitle,ytitle=ytitle,_extra=_extra



;new version: use different models

;known models for now
;1) f_multi_spec
;2) f_vth_bpow_cutoff

n_el=n_elements(energyedges)/2.

CASE spst.f_model OF

   'f_multi_spec' : BEGIN 
      model_par={name:'f_multi_spec',components:4,comp_names:['temp1','temp2','nonthermal','total']}
      yspec=fltarr(model_par.components,n_el)

      yspec[0,*]=f_multi_spec(energyedges, [apar[0] $
                ,apar[1], 0, 1, 0, 0, 0, 0, 0, 0])

      yspec[1,*]=f_multi_spec(energyedges, [0,1,apar[2] $
                ,apar[3], 0, 1, 0, 0, 0, 0])

      yspec[2,*]=f_multi_spec(energyedges, [ 0, 1, 0, 1, apar[4:9]])
      yspec[3,*]=f_multi_spec(energyedges, apar[*])
   END 

   'f_vth_pow_cutoff' : BEGIN


      model_par={name:'f_vth_pow_cutoff',components:3,comp_names:['temp','nonthermal','total']}
      yspec=fltarr(model_par.components,n_el)

      yspec[0,*]=f_vth_pow_cutoff(energyedges,[apar[0], apar[1] $
                          , 0, 0, 0])
      yspec[1,*]=f_vth_pow_cutoff(energyedges, [ 0, 1,apar[2:4]])
      yspec[2,*]=f_vth_pow_cutoff(energyedges, apar[*])

   END



   ELSE : RETURN 

ENDCASE




IF (NOT keyword_set(overplot)) AND keyword_set(nodata) THEN $
  plot,  energybins, yspec[0,*], color = modcolor[0],thick=modthick,linestyle=modlinestyle[0],xlog=xlog,ylog=ylog,psym=psym $
                             ,title=title,xtitle=xtitle,ytitle=ytitle,_extra=_extra $
ELSE $
  oplot,  energybins, yspec[0,*], color = modcolor[0],thick=modthick,linestyle=modlinestyle[0]


FOR i=1,model_par.components-1 DO BEGIN 
   oplot,  energybins, yspec[i,*], color = modcolor[i],thick=modthick,linestyle=modlinestyle[i]
ENDFOR 

;oplot, energybins, f_multi_spec(energyedges, spst.apar_arr[*,n_spec]), color = modcolor[3],thick=modthick,linestyle=modlinestyle[3]

IF NOT keyword_set(nodata) THEN BEGIN 

    FOR i = 0, n_elements(phflux)-1 do $
      oplot, energyedges[*, i], [phflux[i], phflux[i]],color=color,thick=spthick

    FOR i = 0, n_elements(phflux)-1 do $
      oplot, [energybins[i], energybins[i]], [phflux[i], phflux[i]+errflux[i]],color=color,thick=spthick
    
    FOR i = 0, n_elements(phflux)-1 do $
      oplot, [energybins[i], energybins[i]], [phflux[i], (phflux[i]-errflux[i]) > (machar()).xmin],color=color,thick=spthick


    IF exist(bcolor) THEN BEGIN

       ;bcolor=background
       bthick=fcheck(bthick,spthick)
       berr=1-keyword_set(noberr)

    FOR i = 0, n_elements(bflux)-1 do $
      oplot, energyedges[*, i], [bflux[i], bflux[i]],color=bcolor,thick=bthick

    IF berr THEN begin
       FOR i = 0, n_elements(bflux)-1 do $
         oplot, [energybins[i], energybins[i]], [bflux[i], bflux[i]+berrflux[i]],color=bcolor,thick=bthick
    
       FOR i = 0, n_elements(bflux)-1 do $
         oplot, [energybins[i], energybins[i]], [bflux[i], (bflux[i]-berrflux[i]) > (machar()).xmin],color=bcolor,thick=bthick
    ENDIF


      
    ENDIF

ENDIF




END











