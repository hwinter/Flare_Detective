;+
; NAME:
;      pg_plotospextrum
;
; PURPOSE: 
;      plot a spectrum from an input fit-results FITS file
;
; INPUTS:
;     
;      pg_plotospextrum,fitsfile
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
;      and many others...
;
; HISTORY:
;       23-OCT-2003 pg_plotspextrum written PG
;       05-NOV-2003 made more general in scope PG
;       19-NOV-2003 improved, now works on a different concept... PG
;       12-JAN-2004 added model dependent bahviour, but only for a few
;                   selected model (not yet "general") PG
;       17-MAY-2004 added background plot capabilities (keyword
;                   bcolor) and extapar keyword PG
;       05-OCT-2004 CONVERTED TO OSPEX FITS OUTPUT RESULT AND RENAMED PG 
;       06-OCT-2004 corrected photon conversion factors, started to
;                   work on residuals
;       08-OCT-2004 fixed yrange problem w and w/o residuals
;
;
; TO_DO: 
;
;      improve documantation
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

;
;example
;pg_plotospextrum,fitsfile,yrange=[1d-3,1d6],/ystyle


PRO pg_plotospextrum, fitsfile,n_spec= n_spec, xlog=xlog,ylog=ylog,psym=psym $
   ,modthick=modthick,modcolor=modcolor,modstyle=modstyle,color=color $
   ,spthick=spthick,xtitle=xtitle,title=title,ytitle=ytitle,overplot=overplot $
   ,histo=histo,nodata=nodata,erebin=erebin,nrebin=nrebin,noberr=noberr $
   ,modlinestyle=modlinestyle,bcolor=bcolor,bthick=bthick,residuals=residuals $
   ,yrange=yrange,ystyle=ystyle,xstyle=xstyle,resyrange=resyrange $
   ,showmodel=showmodel,spex_area=spex_area,_extra=_extra
;, extapar=extapar


IF NOT exist(fitsfile) THEN BEGIN
   print,'I cannot find any file named '+fitsfile
   RETURN
ENDIF

st1=mrdfits(fitsfile,1,header,status=status1,/silent)
st2=mrdfits(fitsfile,2,status=status2,/silent)
st3=mrdfits(fitsfile,3,status=status3,/silent)
IF min([status1,status2,status3]) NE 0 THEN BEGIN
   print,'ERROR READING FILE '+fitsfile
   RETURN 
ENDIF

hs=fitshead2struct(header)

spex_area=fcheck(spex_area,hs.geoarea)

maxcomp=10
n_spec=fcheck(n_spec,0)
xlog=fcheck(xlog,1)
ylog=fcheck(ylog,1)
xstyle=fcheck(xstyle,0)
xtitle=fcheck(xtitle,'Energy (keV)')
ytitle=fcheck(ytitle,'Photon flux (photons s!A-1!N cm!A-2!N keV!A-1!N)')
modthick=fcheck(modthick,replicate(2,maxcomp))
modcolor=fcheck(modcolor,[7,5,4,12,1,8,9,11,10])
modstyle=fcheck(modstyle,0)
modlinestyle=fcheck(modlinestyle,replicate(modstyle,maxcomp))
showmodel=fcheck(showmodel,replicate(1,maxcomp))

IF keyword_set(residuals) THEN BEGIN
   resyrange=fcheck(resyrange,[-2,2])
ENDIF


psym=3

;IF exist(extapar) THEN apar=extapar ELSE BEGIN
;   IF useapar THEN  apar=spst.apar ELSE apar=spst.apar_arr[*,n_spec]
;ENDELSE

apar=st1[n_spec].params

title=fcheck(title,strjoin(string(apar,format='(e9.2)')))

;energy binning & rebinning
energy_edges=transpose([[st2.e_min],[st2.e_max]]);,2,n_elements(st2))
edge_products,energy_edges,mean=energybins,edges_2=energyedges
enbinsize=energyedges[1,*]-energyedges[0,*]


;old code for use with keyword erebin,nrebin --> not implemented yet
;IF keyword_set(erebin) AND keyword_set(nrebin) THEN BEGIN

;    energyedges_rebin=pg_edges_rebin(energyedges,erebin,nrebin)
;    edge_products,energyedges_rebin,mean=energybins

 ;   IF NOT keyword_set(nodata) THEN BEGIN

 ;       phflux=st1[n_spec].rate/st1.convfac
 ;       errflux=sqrt(st1[n_spec].stat_err^2+st1[n_spec].bk_error^2)/st1.convfac
 ;       bflux=st1[n_spec].bk_rate/st1.convfac
 ;       berrflux=st1[n_spec].bk_error/st1.convfac

; phflux = (spst.obsi[*,n_spec]-spst.backi[*,n_spec])/spst.convi[*,n_spec]
; errflux = sqrt(spst.eobsi[*,n_spec]^2 + spst.ebacki[*,n_spec]^2)/spst.convi[*,n_spec]
;        bflux=spst.backi[*,n_spec]/spst.convi[*,n_spec]
;        berrflux =spst.ebacki[*,n_spec]/spst.convi[*,n_spec]

 ;       phflux=pg_rebin(energyedges,phflux,energyedges_rebin)
 ;       errflux=pg_rebin(energyedges,errflux,energyedges_rebin)
 
;        bflux=pg_rebin(energyedges,bflux,energyedges_rebin)
;        berrflux=pg_rebin(energyedges,berrflux,energyedges_rebin)

 ;       energyedges=energyedges_rebin
    
  ;  ENDIF
   
;ENDIF ELSE $



IF NOT keyword_set(nodata) THEN BEGIN

   phflux=st1[n_spec].rate/st1[n_spec].convfac/enbinsize/spex_area
   errflux=sqrt(st1[n_spec].stat_err^2+st1[n_spec].bk_error^2) $
      /st1[n_spec].convfac/enbinsize/spex_area
   bflux=st1[n_spec].bk_rate/st1[n_spec].convfac/enbinsize/spex_area
   berrflux=st1[n_spec].bk_error/st1[n_spec].convfac/enbinsize/spex_area
   phflux=phflux-bflux

;res2=(phflux-st1[n_spec].phmodel)(/pherrflux)
;res=((st.rate)/st.convfac/277.13*3-st.phmodel)/(st.stat_err/st.convfac/277.13*3)

ENDIF


IF keyword_set(histo) THEN psym=10.

IF NOT((keyword_set(overplot)) OR (keyword_set(nodata))) THEN BEGIN 
   IF NOT keyword_set(residuals) THEN BEGIN 
      plot, energybins, phflux,xlog=xlog,ylog=ylog,psym=psym,color=color $
         ,title=title,xtitle=xtitle,ytitle=ytitle,xstyle=xstyle,yrange=yrange $
         ,ystyle=ystyle,_extra=_extra
   ENDIF $
   ELSE BEGIN

      residuals=st1[n_spec].residual
      ind=where(residuals EQ 0)
      residuals[ind]=!values.f_nan

      plot,energybins, phflux,xlog=xlog,ylog=ylog,psym=psym,color=color $
         ,yrange=yrange $
         ,title=title,xtitle=xtitle,ytitle=ytitle,/nodata,xstyle=4,ystyle=4+ystyle $
         ,_extra=_extra

      ;get plot position in normalized coordinates
      llc=[!p.clip[0],!p.clip[1]];,/device,/to_normal)
      urc=[!p.clip[2],!p.clip[3]];,/device,/to_normal)

      newposup=[llc[0],urc[1]-2./3*(urc[1]-llc[1]),urc[0],urc[1]]
      newposdown=[llc[0],llc[1],urc[0],llc[1]+1./3*(urc[1]-llc[1])]


      plot,energybins,residuals,position=newposdown,/device,xtitle=xtitle $
          ,ytitle='Norm. Res.',xrange=xrange,_extra=_extra,/noerase $
          ,yrange=resyrange,psym=10,xlog=xlog,xstyle=xstyle+8,xticklen=0.02*2
      oplot,10^!x.crange,[0,0],linestyle=2

      plot,energybins, phflux,xlog=xlog,ylog=ylog,psym=psym,color=color $
         ,title=title,xtitle=' ',ytitle=ytitle,position=newposup,/device $
         ,_extra=_extra,/NOERASE,xstyle=xstyle,xtickname=replicate(' ',30) $
         ,yrange=yrange,ystyle=ystyle

   ENDELSE 
ENDIF


;parse model string...

model=st3.fit_function
modparinfo=fit_function_query(model,/param_index)
modcomponents=strsplit(model,'+',/extract)

N=1001
emin=min(energyedges)
emax=max(energyedges)
earr=exp(findgen(N)/(N-1)*alog(emax/emin)+alog(emin))

edge_products,earr,edges_2=earr2
edge_products,earr2,mean=earrmean



n_el=n_elements(earrmean)
nmod=n_elements(modcomponents)

yspec=fltarr(nmod+1,n_el)

FOR i=0,nmod-1 DO BEGIN
   yspec[i,*]=call_function('f_'+modcomponents[i],earr2, $
      apar[modparinfo[i,0]:modparinfo[i,1]])
   yspec[nmod,*]=yspec[nmod,*]+yspec[i,*]
ENDFOR


firstmodel=1
i=0


WHILE i LE nmod DO BEGIN 

IF showmodel[i] AND firstmodel THEN BEGIN
   firstmodel=0
   IF (NOT keyword_set(overplot)) AND keyword_set(nodata) THEN $
     plot,earrmean,yspec[i,*],color=modcolor[i],thick=modthick[i] $
         ,linestyle=modlinestyle[i],xlog=xlog,ylog=ylog,psym=psym $
         ,title=title,xtitle=xtitle,ytitle=ytitle,_extra=_extra $
   ELSE $
     oplot,earrmean,yspec[i,*],color=modcolor[i],thick=modthick[i] $
         ,linestyle=modlinestyle[i]

ENDIF ELSE IF showmodel[i] THEN BEGIN 
  
   oplot,earrmean,yspec[i,*],color=modcolor[i],thick=modthick[i] $
      ,linestyle=modlinestyle[i]
ENDIF  

i=i+1

ENDWHILE


IF NOT keyword_set(nodata) THEN BEGIN 

   stop

    FOR i = 0, n_elements(phflux)-1 DO $
       oplot,energyedges[*, i],[phflux[i],phflux[i]],color=color,thick=spthick

    FOR i = 0, n_elements(phflux)-1 DO $
       oplot,[energybins[i],energybins[i]],[phflux[i],phflux[i]+errflux[i]] $
          ,color=color,thick=spthick
    
    FOR i = 0, n_elements(phflux)-1 DO $
       oplot,[energybins[i],energybins[i]],[phflux[i],(phflux[i]-errflux[i]) $
          > (machar()).xmin],color=color,thick=spthick

    IF exist(bcolor) THEN BEGIN
       bthick=fcheck(bthick,spthick)
       berr=1-keyword_set(noberr)

    FOR i = 0, n_elements(bflux)-1 DO $
       oplot,energyedges[*, i],[bflux[i],bflux[i]],color=bcolor,thick=bthick

    IF berr THEN BEGIN 
       FOR i=0,n_elements(bflux)-1 DO $
          oplot,[energybins[i], energybins[i]], [bflux[i], bflux[i]+ $
             berrflux[i]],color=bcolor,thick=bthick
    
       FOR i=0,n_elements(bflux)-1 DO $
          oplot,[energybins[i],energybins[i]],[bflux[i],(bflux[i]-berrflux[i])$
             > (machar()).xmin],color=bcolor,thick=bthick
    ENDIF
      
    ENDIF

ENDIF


END



