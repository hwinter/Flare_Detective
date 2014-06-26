;+
; NAME:
;      pg_plot_deltaflux_inner
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      plot spectral indices & fluxes for photon spectra coming
;      computed from the simulation electron spectra
;      this is a low level routine in the sense that it assumes
;      that the input values of spectral indices, fluxes etc.
;      have already been selected and/or restrained to the subset
;      of parameters to be plotted
;      This routine can be called from pg_plot_deltaflux
;
; EXPLICATION:
;      
;
;
; CALLING SEQUENCE:
;     
;
; INPUTS:
;       
;     
; OUTPUTS:
;      
;      
; KEYWORDS:
;       
;
; HISTORY:
;       25-NOV-2005 written PG
;       10-JAN-2006 separated inner from outer part as a test toward
;       greater modularity (goal: should be possible to call it from
;       routine pg_cn_dooverviewplot) & others
;       11-JAN-2006 separated the files
;       16-JAN-2006 added _extra keyword
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;-

PRO pg_plot_deltaflux_inner,res=res,spindex_thin=spindex_thin,spindex_thick=spindex_thick $
                            ,fnorm_thin=fnorm_thin,fnorm_thick=fnorm_thick,simpar=simpar $
                            ,enorm=enorm,thin=thin,thick=thick,xrange=xrange,circlesize=circlesize $
                            ,_extra=_extra

   circlesize=fcheck(circlesize,0.8)
   pg_setplotsymbol,'CIRCLE',size=circlesize
   psym=8
   xrange=fcheck(xrange,[1d-10,1d5])

   
   IF keyword_set(thick) THEN BEGIN 

      indthick=where(spindex_thick GT 2 AND spindex_thick LT 10)

      spindex_thick=spindex_thick[indthick]
      fnorm_thick=fnorm_thick[indthick]


      ;fitres_alt=pg_fitpivmodel(fnorm_thick,spindex_thick,enorm,/quiet,status=status)
      ;old method with mpfitfun
     
      sixlin,alog(fnorm_thick),spindex_thick,a,siga,b,sigb
     
      fitres=[exp(1d /b[0])^[-a[0]],enorm*exp(1d /b[0]),enorm]
     
      ;fitres is: fpiv,epiv,enormalization

      plot,fnorm_thick,spindex_thick,psym=psym,/xlog,xrange=xrange,yrange=[0,10],/xstyle,_extra=_extra

      ;stop

      N=100
      modf=10^(findgen(N)/(N-1)*(alog10(max(xrange))-alog10(min(xrange)))+alog10(min(xrange)))

      ;oplot,modf,pg_pivpoint(modf,fitres),color=12,thick=4
      oplot,modf,b[0]*alog(modf)+a[0],color=12,thick=4

      cx=1d-5*xrange[1]
      cy=7

      mc2=511.


      xyouts,cx,cy+2.0,'THICK'
      xyouts,cx,cy+1.5,'SURFACE: '+string(res.thickpar.surfacetar,format='(e12.2)')
      xyouts,cx,cy+1.0,'LN('+textoidl('\Lambda')+') : ' $
                  +string(res.thickpar.coulomblog,format='(f8.1)')
      xyouts,cx,cy+0.5,textoidl('Z^2 :')+string(res.thickpar.z^2,format='(f8.2)')
      xyouts,cx,cy,'START TEMP: '+string(1d-6*kev2kel(mc2*10d^(simpar.ytherm)), $
                                         format='(f7.2)')+' MK',/data
      xyouts,cx,cy-0.5,'EPIV: '+string(fitres[1],format='(f9.2)')+' keV',/data
      xyouts,cx,cy-1.0,'FPIV: '+string(fitres[0],format='(e12.2)')+' keV',/data

      

      IF tag_exist(simpar,'THRESHOLD') THEN BEGIN 
         xyouts,cx,cy-1.5,'THRESHOLD: '+string(simpar.threshold_escape_kev,format='(e12.2)')+' keV',/data
         cy=cy-0.5
      ENDIF

      IF tag_exist(simpar,'COLLISION_STRENGTH_SCALE') THEN BEGIN 
         xyouts,cx,cy-1.5,'COLL_STR_SCAL: '+string(simpar.collision_strength_scale,format='(e12.2)'),/data
         cy=cy-0.5
      ENDIF

      ;xyouts,cx*1d-4,cy-1.5,'DIRECTORY: '+dirarr[i]


      cx=1d-6
      cy=2.75

      xyouts,cx,cy,'FITRANGE : ['+strtrim(string(round(res.emin)),2)+',' $
                  +strtrim(string(round(res.emax)),2)+']'+' keV'
      xyouts,cx,cy-0.5,'ENORM : '+strtrim(string(round(res.enorm)),2)+' keV'
      xyouts,cx,cy-1.0,'SIM DENSITY : '+strtrim(string(simpar.density,format='(e12.2)'),2) $
                      +textoidl('cm^{-3}') 

   ENDIF

   IF keyword_set(thin) THEN BEGIN 

      indthin=where(spindex_thin GT 2 AND spindex_thin LT 10)
      spindex_thin=spindex_thin[indthin]
      fnorm_thin=fnorm_thin[indthin]
 
      ;fitres=pg_fitpivmodel(fnorm_thin,spindex_thin,enorm,/quiet,status=status)
      sixlin,alog(fnorm_thin),spindex_thin,a,siga,b,sigb
     
      fitres=[exp(1d /b[0])^[-a[0]],enorm*exp(1d /b[0]),enorm]

      plot,fnorm_thin,spindex_thin,psym=psym,/xlog,xrange=xrange,yrange=[0,10],/xstyle,_extra=_extra

      N=1000
      modf=10^(findgen(N)/(N-1)*(alog10(max(xrange))-alog10(min(xrange)))+alog10(min(xrange)))


      ;stop


      ;oplot,modf,pg_pivpoint(modf,fitres),color=12,thick=4
      oplot,modf,b[0]*alog(modf)+a[0],color=12,thick=4

      cx=1d-5*xrange[1]
      cy=7

      mc2=511.

      xyouts,cx,cy+2.0,'THIN'
      xyouts,cx,cy+1.5,'VOLUME: '+string(res.thinpar.volumetar,format='(e12.2)')
      xyouts,cx,cy+1.0,'DENSITY : ' $
                      +string(res.thinpar.densitytar,format='(e12.2)')
      xyouts,cx,cy+0.5,textoidl('Z^2 :')+string(res.thickpar.z^2,format='(f8.2)')
      xyouts,cx,cy,'START TEMP: '+string(1d-6*kev2kel(mc2*10d^(simpar.ytherm)), $
                                         format='(f7.2)')+' MK',/data
      xyouts,cx,cy-0.5,'EPIV: '+string(fitres[1],format='(f9.2)')+' keV',/data
      xyouts,cx,cy-1.0,'FPIV: '+string(fitres[0],format='(e12.2)')+' keV',/data
      ;xyouts,cx*1d-4,cy-1.5,'DIRECTORY: '+dirarr[i]
 
      IF tag_exist(simpar,'THRESHOLD') THEN BEGIN 
         xyouts,cx,cy-1.5,'THRESHOLD: '+string(simpar.threshold_escape_kev,format='(e12.2)')+' keV',/data
         cy=cy-0.5
      ENDIF

      IF tag_exist(simpar,'COLLISION_STRENGTH_SCALE') THEN BEGIN 
         xyouts,cx,cy-1.5,'COLL_STR_SCAL: '+string(simpar.collision_strength_scale,format='(e12.2)'),/data
         cy=cy-0.5
      ENDIF
 
      cx=1d-6
      cy=2.75

      xyouts,cx,cy,'FITRANGE : ['+strtrim(string(round(res.emin)),2)+',' $
                  +strtrim(string(round(res.emax)),2)+']'+' keV'
      xyouts,cx,cy-0.5,'ENORM : '+strtrim(string(round(res.enorm)),2)+' keV'
      xyouts,cx,cy-1.0,'SIM DENSITY : '+strtrim(string(simpar.density,format='(e12.2)'),2) $
                      +textoidl('cm^{-3}') 
   
   ENDIF

END


