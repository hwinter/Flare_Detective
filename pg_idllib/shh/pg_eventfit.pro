;+
; NAME:
;
; pg_eventfit
;
; PURPOSE:
;
; apply fitting to an event
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
; 09-NOV-2006 pg written
;-

;.comp pg_eventfit

FUNCTION pg_eventfit,spg=spg,drm=drm,fitinterval=fitinterval $
                    ,bspectrum=bspectrum,bespectrum=bespectrum $
                    ,doplot=doplot,quiet=quiet,enorm=enorm $
                    ,thermrange=thermrange,nonthermrange=nonthermrange $
                    ,erange=erange,delay=delay,verbose=verbose





npar=9
parnames=['DELTA_MAIN','DELTA_LOW','DELTA_HIGH','FLUX_NORM','EBREAK_LOW','EBREAK_HIGH' $
         ,'EM','TEMP','LAMBDA_BACK']



;sets fitting interval
t=spg.x
fitinterval=fcheck(fitinterval,[min(spg.x),max(spg.x)])
fitind=where(t GE anytim(fitinterval[0]) AND t LE anytim(fitinterval[1]))
time=spg.x[fitind]
nint=n_elements(time)

;plot settings
IF keyword_set(doplot) THEN BEGIN 

   linecolors
   spposition=[0.1,0.4,0.95,0.98]
   resposition=[0.1,0.1,0.95,0.4]
   window,0,xsize=1024,ysize=1024

   pg_setplotsymbol,'circle',SIZE=2.5

ENDIF

;input variables needed
matrix=drm.matrix
geom_area=drm.geom_area
cntedges=drm.cntedges
photedges=drm.photedges
cntmean=sqrt(cntedges[*,0]*cntedges[*,1])

cntbins=n_elements(cntedges[*,0])
;photbins=n_elements(photedges[*,0])

;fitting settings
enorm=fcheck(enorm,50.)
erange=fcheck(erange,[12,500])
thermrange=fcheck(thermrange,[12,25])
nonthermrange=fcheck(nonthermrange,[50,100])

;warning for no background situation
IF NOT exist(bspectrum) THEN BEGIN 
   print,'Warning! No background spectrum given!'
   bspectrum=replicate(0d,cntbins)
   bespectrum=replicate(0d,cntbins)
ENDIF

IF NOT exist(bespectrum) THEN BEGIN 
   print,'Warning! No background error spectrum given!'
   bespectrum=replicate(0d,cntbins)
ENDIF


;results array
respar=dblarr(9,nint)
respar[*]=!values.d_nan
allchisq=replicate(!values.d_nan,nint)
residuals=replicate(!values.d_nan,cntbins,nint)
allmodels=replicate(!values.d_nan,cntbins,nint)
alltherm=replicate(!values.d_nan,cntbins,nint)
allnont=replicate(!values.d_nan,cntbins,nint)
allspectra=replicate(!values.d_nan,cntbins,nint)
allespectra=replicate(!values.d_nan,cntbins,nint)
parinfoarr=ptrarr(nint)

;setup correct dealing with atten states
allfilters=drm.filter_state
attindex=bytarr(4)-1
FOR i=0,n_elements(allfilters)-1 DO attindex[allfilters[i]]=i

;fitting loop
FOR i=0,nint-1 DO BEGIN 

   spectrum=spg.spectrogram[fitind[i],*]
   espectrum=spg.espectrogram[fitind[i],*]

   allspectra[*,i]=spectrum
   allespectra[*,i]=espectrum

   attstate=spg.filter_state[fitind[i]]
   attuncert=spg.filter_uncert[fitind[i]]

   ;check if spectrum seems to be ok
   ok_spectrum=total(spectrum) GT 1.

   IF (attuncert NE 1) AND (ok_spectrum) THEN BEGIN
   ;near attenuator state changes no fitting is done
   ;also in times where the spectrum consits only of zeros
   ;the fit par will be NANs

      thisattstateind=attindex[attstate]


      par=pg_fitmodel2spectrum(spectrum=spectrum,espectrum=espectrum $
                             ,bspectrum=bspectrum,bespectrum=bespectrum $
                             ,matrix=matrix[*,*, thisattstateind] $
                             ,geom_area=geom_area[thisattstateind] $
                             ,cntedges=cntedges,fitrange=thermrange $
                             ,photedges=photedges,fnorm=0.,enorm=enorm $
                             ,/thermal,fittemp=fittemp,fitem=fitem,/quiet) 

      par=pg_fitmodel2spectrum(spectrum=spectrum,espectrum=espectrum $
                             ,bspectrum=bspectrum,bespectrum=bespectrum $
                             ,matrix=matrix[*,*,thisattstateind] $
                             ,geom_area=geom_area[thisattstateind] $
                             ,cntedges=cntedges,fitrange=nonthermrange,enorm=enorm $
                             ,photedges=photedges,ebreakl=20,ebreakh=500,em=fitem,temp=fittemp $
                             ,/bpow,fitdelta=fitdelta,fitfnorm=fitfnorm,/quiet) 
 
      par=pg_fitmodel2spectrum(spectrum=spectrum,espectrum=espectrum $
                             ,bspectrum=bspectrum,bespectrum=bespectrum $
                             ,matrix=matrix[*,*,thisattstateind] $
                             ,geom_area=geom_area[thisattstateind] $
                             ,cntedges=cntedges,fitrange=erange,enorm=enorm $
                             ,photedges=photedges,/thermal,/varbackground $
                             ,/bpow,temp=fittemp,em=fitem,delta=fitdelta,fnorm=fitfnorm $
                             ,ebreakh=500,ebreakl=fitebreakl,/quiet,chisq=chisq $
                             ,mpfitstatus=status,parinfo=parinfo) 
 
      allchisq[i]=chisq
      respar[*,i]=par
      parinfoarr[i]=ptr_new(parinfo)

      resulttot=pg_modfit(dummy,par,photedges=photedges,drm=matrix[*,*,thisattstateind] $
                         ,geom_area=geom_area[thisattstateind],enorm=enorm $
                         ,background=bspectrum)

      residuals[*,i]=(spectrum-resulttot)/espectrum
      allmodels[*,i]= resulttot

 
      IF NOT keyword_set(quiet) THEN $ 
         print,'Interval '+strtrim(i,2)+' ATT: '+strtrim(fix(attstate),2) $
              +' MPFIT status '+strtrim(status,2)+' CHISQ: '+strtrim(chisq,2)

      IF keyword_set(verbose) THEN BEGIN 

         fittemp=      par[7]
         fitem=        par[6]
         fitdelta=     par[0]
         fitdl=        par[1]
         fitdh=        par[2]
         fitfnorm=     par[3]
         fitebreakl=   par[4]
         fitebreakh=   par[5]
         fitlambdaback=par[8]

         print,'Delta: '+strtrim(fitdelta,2)+' Fnorm: '+strtrim(fitfnorm,2)
         print,'Ebreak low: '+strtrim(fitebreakl,2)+' Delta low: '+strtrim(fitdl,2)
         print,'Temp: '+strtrim(fittemp,2)+' EM: '+strtrim(fitem,2)
         print,'Lambda Back: '+strtrim(fitlambdaback,2)

      ENDIF
 
      tpar=par
      tpar[0:5]=0.
      tpar[8]=0.
      resulttherm=pg_modfit(dummy,tpar,photedges=photedges,drm=matrix[*,*,thisattstateind] $
                           ,geom_area=geom_area[thisattstateind],enorm=enorm $
                           ,background=bspectrum)

      alltherm[*,i]= resulttherm


      nontpar=par
      nontpar[6:8]=0.
      resultnont=pg_modfit(dummy,nontpar,photedges=photedges,drm=matrix[*,*,thisattstateind] $
                          ,geom_area=geom_area[thisattstateind],enorm=enorm $
                          ,background=bspectrum)

      allnont[*,i]= resultnont


      IF keyword_set(doplot) THEN BEGIN 

 

         pg_plotsp,cntedges,spectrum,espectrum=espectrum,/xlog,/ylog,xstyle=1 $
                   ,yrange=[0.1,1d4],position=spposition,xtickname=replicate(' ',30)
         pg_plotsp,cntedges,resulttot,/xlog,/ylog,/xstyle,color=2,/overplot
         pg_plotsp,cntedges,resulttherm,/xlog,/ylog,/xstyle,color=7,/overplot ;green thermal
         pg_plotsp,cntedges,resultnont,/xlog,/ylog,/xstyle,color=12,/overplot ;purple non thermal
         pg_plotsp,cntedges,bspectrum,espectrum=bespectrum,/xlog,/ylog,/xstyle,color=5,/overplot


         ;show the breaks...
         fitebreakl=par[4]
         fitebreakh=par[5]
         dummy=min(abs(cntmean-fitebreakl),indl)
         dummy=min(abs(cntmean-fitebreakh),indh)

         plots,cntmean[indl],resultnont[indl],psym=8,color=12
         plots,cntmean[indh],resultnont[indh],psym=8,color=12
         

         pg_plotspres,cntedges,spectrum=spectrum,modspectrum=resulttot,espectrum=espectrum $
                     ,/xlog,/xstyle,yrange=[-4,4],/noerase,position=resposition

         IF exist(delay) THEN wait,delay

      ENDIF 

   ENDIF

ENDFOR


fitsresults={time:time,chisq:allchisq,fitpar:respar,residuals:residuals $
            ,cntspectra:allspectra,cntespectra:allespectra,cntmodels:allmodels $
            ,cnttherm:alltherm,cntnontherm:allnont $
            ,atten_state:spg.filter_state[fitind],atten_uncert:spg.filter_uncert[fitind] $
            ,bspectrum:bspectrum,bespectrum:bespectrum,enorm:enorm $
            ,erange:erange,thermrange:thermrange,nonthermrange:nonthermrange $
            ,parinfo:parinfoarr,cntedges:cntedges,photedges:photedges,modtype:'THERM+BPOW' $
            ,parnames:parnames}

return,fitsresults

END
