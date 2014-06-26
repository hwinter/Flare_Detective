;+
; NAME:
;
; pg_plot_spfitres
;
; PURPOSE:
;
; plot a spectral fit
;
; CATEGORY:
;
; rhessi spectrograms/fitting util
;
; CALLING SEQUENCE:
;
; 
;
; INPUTS:
;
; 
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
; 
;
; OUTPUTS:
;
; 
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; AUTHOR:
; Paolo Grigis, Institute for Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch 
;
; MODIFICATION HISTORY:
;
; 20-NOV-2006 pg written
; 24-NOV-2006 added /new keyword to account for new format of tis results
; 15-JAN-2007 added resystyle,resytitle, overplot keywords
; 02-APR-2007 made more robust for the case where /residual is not set
;-

;.comp pg_plot_spfitres

PRO pg_plot_spfitres,fitres,intv=intv,position=position,xtickname=newxtickname $
                    ,xtickv=xtickv,xticks=xticks,modcolor=modcolor,bcolor=bcolor,residuals=residuals $
                    ,xrange=xrange,title=title,resrange=resrange,_extra=_extra $
                    ,new=new,resystyle=resystyle,resytitle=resytitle,overplot=overplot $
                    ,resyticks=resyticks,resytickv=resytickv,resytickname=resytickname $
                    ,resthick=resthick,xtitle=xtitle,datalast=datalast,resxticklen=resxticklen $
                    ,modcontline=modcontline,model_exclude=model_exclude,noback=noback

intv=fcheck(intv,0)

modcolor=fcheck(modcolor,[12,7,2])
bcolor=fcheck(bcolor,5)
resrange=fcheck(resrange,[-4,4])
xtitle=fcheck(xtitle,' ')

IF NOT exist(position) THEN spposition=[0.1,0.1,0.95,0.95] ELSE spposition=position

IF keyword_set(residuals) THEN BEGIN

   dypos=spposition[3]-spposition[1]

   xtickname=replicate(' ',30)

   resposition=[spposition[0],spposition[1],spposition[2],spposition[1]+dypos/4.]
   spposition=[spposition[0],spposition[1]+dypos/4.,spposition[2],spposition[3]]

   newxtitle=' '

ENDIF ELSE BEGIN 
   newxtitle=xtitle
   IF exist(newxtickname) THEN xtickname=newxtickname
ENDELSE




cntedges=fitres.cntedges
spectrum=fitres.cntspectra[*,intv]
espectrum=fitres.cntespectra[*,intv]
resulttot=fitres.cntmodels[*,intv]

IF keyword_set(new) THEN BEGIN 
   resultpart=fitres.cntpart[*,*,intv]
ENDIF ELSE BEGIN 
   resulttherm=fitres.cnttherm[*,intv]
   resultnont=fitres.cntnontherm[*,intv]
ENDELSE

bspectrum=fitres.bspectrum
bespectrum=fitres.bespectrum

noerase=keyword_set(overplot)
pg_plotsp,cntedges,spectrum,espectrum=espectrum $
         ,position=spposition ,xrange=xrange,xtickname=xtickname $
         ,_extra=_extra,title=title,noerase=noerase,xtitle=newxtitle


pg_plotsp,cntedges,resulttot,color=modcolor[0],/overplot

IF keyword_set(new) THEN BEGIN 

   IF NOT keyword_set(modcontline) THEN BEGIN 
      FOR ipart=0,n_elements(resultpart[0,*])-1 DO BEGIN 
         IF ~exist(model_exclude) THEN $
            pg_plotsp,cntedges,resultpart[*,ipart],color=modcolor[1+ipart],/overplot $
         ELSE BEGIN 
            ;print,'exclude mode'
            IF model_exclude[ipart] EQ 0 THEN $
               pg_plotsp,cntedges,resultpart[*,ipart],color=modcolor[1+ipart],/overplot
         ENDELSE
         
      ENDFOR
   ENDIF ELSE BEGIN
      FOR ipart=0,n_elements(resultpart[0,*])-1 DO BEGIN 
         pg_plotsp,cntedges,resultpart[*,ipart],color=modcolor[1+ipart],/overplot,/continuous     
      ENDFOR
   ENDELSE


ENDIF ELSE BEGIN 
   pg_plotsp,cntedges,resulttherm,color=modcolor[1],/overplot 
   pg_plotsp,cntedges,resultnont,color=modcolor[2],/overplot 
ENDELSE

IF NOT keyword_set(noback) THEN $
   pg_plotsp,cntedges,bspectrum,espectrum=bespectrum,color=bcolor,/overplot 

IF keyword_set(datalast) THEN pg_plotsp,cntedges,spectrum,espectrum=espectrum,/overplot

;plot residuals
IF keyword_set(residuals) THEN BEGIN
   ystyle=keyword_set(resystyle)
   pg_plotspres,cntedges,spectrum=spectrum,modspectrum=resulttot,espectrum=espectrum $
               ,xrange=xrange,/xlog,/xstyle,yrange=resrange,/noerase,position=resposition $
               ,ystyle=ystyle,ytitle=resytitle,xtickv=xtickv,xticks=xticks,xtickname=newxtickname $
               ,yticks=resyticks,ytickv=resytickv,ytickname=resytickname,thick=resthick,xtitle=xtitle $
               ,xticklen=resxticklen

ENDIF


END
