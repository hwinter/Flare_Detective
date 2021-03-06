;+
; NAME:
;      pg_multiplot_ospex
;
; PURPOSE: 
;      plot a multiple series of spectra from an input OSPEX object
;
; INPUTS:
;     
;      osp: a SPEX object
; 
;  
; OUTPUTS:
;      none
;      
; KEYWORDS:
;      nspmin: index of the first spectrum
;      nspmax: index of the last spectrum to plot
;      plotpos: the plot with fit in this dimension box
;               default [0.05,0.05,0.95,0.95]
;      mulfactor: factor with which a plot should be multiplied
;      yrange: yrange for the firs plot --> this is automatically
;              extended by the mulfactor
;
;
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
;       16-FEB-2005 converted to use a spex object as input, since it
;          is too dangerous to assume anything about the internals of the
;          FITS files generated by the software, this could change at a
;          moment notice!!!
;       11-MAR-2005 added a few options
;       -------------------------------------------------------------------
;       11-MAY-2005 rewrite to pg_multiplot_ospex
;
;
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

;
;example
;pg_plotospextrum,ospex_obj,yrange=[1d-3,1d6],/ystyle


PRO pg_multiplot_ospex,osp,nspmin=nspmin,nspmax=nspmax,psym=psym $
   ,modthick=modthick,modcolor=modcolor,modstyle=modstyle,color=color $
   ,spthick=spthick,xtitle=xtitle,title=title,ytitle=ytitle,overplot=overplot $
   ,erebin=erebin,nrebin=nrebin,noberr=noberr,xlog=xlog,ylog=ylog,xrange=xrange $
   ,modlinestyle=modlinestyle,bcolor=bcolor,bthick=bthick,residuals=residuals $
   ,yrange=yrange,ystyle=ystyle,xstyle=xstyle,resyrange=resyrange,resthick=resthick $
   ,showmodel=showmodel,_extra=_extra,mulfactor=mulfactor0,noerr=noerr,plotpos=plotpos $
   ,charsize=cs


IF NOT exist(osp) THEN BEGIN
   print,'Please input a SPEX object!'
   RETURN
ENDIF

IF NOT exist(yrange) THEN setyrange=1 ELSE setyrange=0

summdata=osp->get(/spex_summ)

nenergy=n_elements(summdata.spex_summ_energy)/2

maxcomp=10
nspmin=fcheck(nspmin,0)
nspmax=fcheck(nspmax,n_elements(summdata.spex_summ_niter)-1)
nplots=nspmax-nspmin+1

plotpos=fcheck(plotpos,[0.1,0.1,0.9,0.9])


xrange=fcheck(xrange,[3,30])

xlog=fcheck(xlog,1)
ylog=fcheck(ylog,1)
xstyle=fcheck(xstyle,1)
ystyle=fcheck(xstyle,1)

xtitle=fcheck(xtitle,'Energy (keV)')
ytitle=fcheck(ytitle,'Photon flux (photons s!A-1!N cm!A-2!N keV!A-1!N)')
modthick=fcheck(modthick,2);replicate(2,maxcomp))
modcolor=fcheck(modcolor,0);[7,5,4,12,1,8,9,11,10])
modstyle=fcheck(modstyle,0);
modlinestyle=fcheck(modlinestyle,0);replicate(modstyle,maxcomp))
;showmodel=fcheck(showmodel,replicate(1,maxcomp))
psym=fcheck(psym,3)
resthick=fcheck(resthick,2.)
spthick=fcheck(spthick,2.)

cs=fcheck(cs,1.5)

mulfactor0=fcheck(mulfactor0,10.)
mulfactor=1.

IF keyword_set(residuals) THEN BEGIN
   resyrange=fcheck(resyrange,[-2,2])
ENDIF

;spex_summ_params=summdata.spex_summ_params
apar=summdata.spex_summ_params


title=fcheck(title,' ');strjoin(string(apar,format='(e9.2)')))

;energy binning & rebinning
energy_edges=summdata.spex_summ_energy

edge_products,energy_edges,mean=energybins,edges_2=energyedges
enbinsize=energyedges[1,*]-energyedges[0,*]



detarea=summdata.spex_summ_area

;fitted model
ph_model=summdata.spex_summ_ph_model
;observed counts -->photons
count_rate=summdata.spex_summ_ct_rate
error_rate=summdata.spex_summ_ct_error
bk_count_rate=summdata.spex_summ_bk_rate
bk_error_rate=summdata.spex_summ_bk_error

;conversion of photons
conversion=summdata.spex_summ_conv

;residuals
fitresiduals=summdata.spex_summ_resid


emask=summdata.spex_summ_emask



;--------------------------------------------
;in loop!!!
phflux=fltarr(nenergy,nplots)
errflux=fltarr(nenergy,nplots)
bflux=fltarr(nenergy,nplots)
berrflux=fltarr(nenergy,nplots)
berrflux=fltarr(nenergy,nplots)
;emaskind=lonarr(nenergy,nplots)
;countemask=lonarr(nplots)

;stop

FOR i=0,nplots-1 DO BEGIN 
    j=nspmin+i
    convfact=1/(conversion[*,j]*detarea*enbinsize)
    phflux[*,i]=count_rate[*,j]*convfact
    errflux[*,i]=error_rate[*,j]*convfact
    bflux[*,i]=bk_count_rate[*,j]*convfact
    berrflux[*,i]=bk_error_rate[*,j]*convfact
    ind=where(emask[*,j] EQ 0,dummy)
    IF dummy GT 0 THEN fitresiduals[ind,i]=!values.f_nan
ENDFOR




;MISSING somewhere      


;------------------------------------------------


;IF keyword_set(histo) THEN psym=10.

;IF NOT((keyword_set(overplot)) OR (keyword_set(nodata))) THEN BEGIN 
;   IF NOT keyword_set(residuals) THEN BEGIN 
;      plot, energybins, phflux*mulfactor,xlog=xlog,ylog=ylog,psym=psym,color=color $
;         ,title=title,xtitle=xtitle,ytitle=ytitle,xstyle=xstyle,yrange=yrange $
;         ,ystyle=ystyle,_extra=_extra
;   ENDIF $
;   ELSE BEGIN

;      ind=where(residuals EQ 0)


;plot position in normalized coordinates

IF NOT keyword_set(residuals) THEN BEGIN 
    newposup=plotpos
    actualxtitle=xtitle
ENDIF ELSE BEGIN 
    llc=plotpos[[0,1]]
    urc=plotpos[[2,3]]
    newposup=[llc[0],urc[1]-2./3*(urc[1]-llc[1]),urc[0],urc[1]]
    newposdown=[llc[0],llc[1],urc[0],llc[1]+1./3*(urc[1]-llc[1])]

    actualxtitle=' '
    xtickname=replicate(' ',30)

ENDELSE




FOR i=0,nplots-1 DO BEGIN 


   ;parse model string...
    model=osp->get(/spex_summ_fit_function) ;st3.fit_function
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

    FOR j=0,nmod-1 DO BEGIN
        yspec[j,*]=call_function('f_'+modcomponents[j],earr2, $
                                 apar[modparinfo[j,0]:modparinfo[j,1],i])
        yspec[nmod,*]=yspec[nmod,*]+yspec[j,*]
    ENDFOR



    ;plot data and model
    IF i EQ 0 THEN BEGIN 

        IF setyrange THEN BEGIN
            yrange=[min(phflux)*0.9,max(phflux)*1.1]
            setyrange=0
        ENDIF


        yrange[1]=yrange[1]*double(mulfactor0)^(nplots)

        plot,energybins,phflux[*,i],xlog=xlog,ylog=ylog,psym=psym $;,color=color $
             ,yrange=yrange,position=newposup,xtickname=xtickname $
             ,title=title,xtitle=actualxtitle,ytitle=ytitle,xstyle=xstyle,ystyle=ystyle $
             ,_extra=_extra,charsize=cs,xrange=xrange

        print,xrange



    ENDIF 


    oplot,earrmean,yspec[nmod,*]*mulfactor,thick=modthick
             ;,linestyle=modlinestyle

;    ENDELSE

    ;oplot errors...
    FOR k = 0, nenergy-1 DO BEGIN 
        oplot,energyedges[*,k],mulfactor*[phflux[k,i],phflux[k,i]] $
              ,thick=spthick
        oplot,energybins[[k,k]],mulfactor*[phflux[k,i],phflux[k,i]+errflux[k,i]] $
              ,thick=spthick          
        oplot,energybins[[k,k]],mulfactor*[phflux[k,i],(phflux[k,i]-errflux[k,i]) $
              > (machar()).xmin],thick=spthick
    ENDFOR

    mulfactor=mulfactor*mulfactor0



ENDFOR


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


IF keyword_set(residuals) THEN BEGIN
    
    deltares=3
    maxres=2
    minres=-2

    FOR i=0,nplots-1 DO BEGIN 
        IF i EQ 0 THEN BEGIN
            plot,energybins,fitresiduals[*,i],yrange=[minres,maxres+(nplots-1)*deltares] $
                ,/xstyle,/ystyle,xtitle=xtitle,position=newposdown,xrange=xrange $
                ,psym=10,/noerase,xlog=xlog,charsize=cs,thick=resthick

            oplot,xrange,[0,0],linestyle=2

            print,xrange

        ENDIF 

        oplot,energybins,fitresiduals[*,i]+i*deltares,psym=10,thick=resthick
        oplot,xrange,i*deltares*[1,1],linestyle=2


    ENDFOR

    


ENDIF



;plot residuals

; FOR i=0,nplots-1 DO BEGIN 
; ENDFOR




;       plot,energybins,residuals,position=newposdown,/device,xtitle=xtitle $
;           ,ytitle='Norm. Res.',xrange=xrange,_extra=_extra,/noerase $
;           ,yrange=resyrange,psym=10,xlog=xlog,xstyle=xstyle+8,xticklen=0.02*2 $
;           ,thick=resthick
;       oplot,10^!x.crange,[0,0],linestyle=2

;       plot,energybins, phflux*mulfactor,xlog=xlog,ylog=ylog,psym=psym,color=color $
;          ,title=title,xtitle=' ',ytitle=ytitle,position=newposup,/device $
;          ,_extra=_extra,/NOERASE,xstyle=xstyle,xtickname=replicate(' ',30) $
;          ,yrange=yrange,ystyle=ystyle

; ;   ENDELSE 
; ;ENDIF



; firstmodel=1
; i=0


; WHILE i LE nmod DO BEGIN 

; IF showmodel[i] AND firstmodel THEN BEGIN
;    firstmodel=0
;    IF (NOT keyword_set(overplot)) AND keyword_set(nodata) THEN $
;      plot,earrmean,mulfactor*yspec[i,*],color=modcolor[i],thick=modthick[i] $
;          ,linestyle=modlinestyle[i],xlog=xlog,ylog=ylog,psym=psym $
;          ,title=title,xtitle=xtitle,ytitle=ytitle,_extra=_extra $
;    ELSE $
;      oplot,earrmean,mulfactor*yspec[i,*],color=modcolor[i],thick=modthick[i] $
;          ,linestyle=modlinestyle[i]

; ENDIF ELSE IF showmodel[i] THEN BEGIN 
  
;    oplot,earrmean,mulfactor*yspec[i,*],color=modcolor[i],thick=modthick[i] $
;       ,linestyle=modlinestyle[i]
; ENDIF  

; i=i+1

; ENDWHILE


; IF NOT keyword_set(nodata) THEN BEGIN 

; ;   oplot,energyedges[*, i],mulfactor*[phflux[i],phflux[i]],color=color,psym=psym
;    oplot,energybins, phflux*mulfactor,psym=psym,color=color



;     IF NOT keyword_set(noerr) THEN BEGIN 
        


;     IF exist(bcolor) THEN BEGIN
;        bthick=fcheck(bthick,spthick)
;        berr=1-keyword_set(noberr)

;     FOR i = 0, n_elements(bflux)-1 DO $
;        oplot,energyedges[*, i],mulfactor*[bflux[i],bflux[i]],color=bcolor,thick=bthick

;        IF berr THEN BEGIN 
;           FOR i=0,n_elements(bflux)-1 DO $
;              oplot,[energybins[i], energybins[i]], mulfactor*[bflux[i], bflux[i]+ $
;                 berrflux[i]],color=bcolor,thick=bthick
    
;           FOR i=0,n_elements(bflux)-1 DO $
;              oplot,[energybins[i],energybins[i]],mulfactor*[bflux[i],(bflux[i]-berrflux[i])$
;                 > (machar()).xmin],color=bcolor,thick=bthick
;        ENDIF
      
;     ENDIF

;     ENDIF 

; ENDIF


END



