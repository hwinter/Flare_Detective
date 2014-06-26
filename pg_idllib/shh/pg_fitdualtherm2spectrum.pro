;+
; NAME:
;
; pg_fitmodel2spectrum
;
; PURPOSE:
;
; fits a model spectrum to observed hard X-ray spectrum
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
; 08-NOV-2006 pg written
;-

;.comp pg_fitdualtherm2spectrum

FUNCTION pg_fitdualtherm2spectrum,spectrum=spectrum,espectrum=espectrum $
                             ,bspectrum=bspectrum,bespectrum=bespectrum $
                             ,matrix=matrix,geom_area=geom_area $
                             ,cntedges=cntedges,fitrange=fitrange $
                             ,photedges=photedges $
                             ,thermlow=thermlow $
                             ,thermhigh=thermhigh $
                             ,varbackground=varbackground $
                             ,templow=templow,emlow=emlow $
                             ,temphigh=temphigh,emhigh=emhigh $
                             ,lambdaback=lambdaback $
                             ,chisq=chisq,mpfitstatus=mpfitstatus,quiet=quiet $
                             ,fittemplow=fittemplow,fitemlow=fitemlow $
                             ,fittemphigh=fittemphigh,fitemhigh=fitemhigh $
                             ,fitlambdaback=fitlambdaback,parinfo=parinfo

;several cases...


enorm=-1

templow=fcheck(templow,1.)
emlow=fcheck(emlow,1.)
temphigh=fcheck(temphigh,5.)
emhigh=fcheck(emhigh,0.01)
lambdaback=fcheck(lambdaback,1.)

parinfo=replicate({value:0.,fixed:1.,limited:[0,0],limits:[0d ,0.],parname:''},5)

parinfo[0].limited=[1,1];emlow
parinfo[0].limits=[0d,1d10]
parinfo[0].value=emlow
parinfo[0].parname='EM_LOW'

parinfo[1].limited=[1,1];templow in keV
parinfo[1].limits=[0.1,50.]
parinfo[1].value=templow
parinfo[1].parname='TEMP_LOW'

parinfo[2].limited=[1,1];emhigh
parinfo[2].limits=[0d,1d10]
parinfo[2].value=emhigh
parinfo[2].parname='EM_HIGH'

parinfo[3].limited=[1,1];temphigh in keV
parinfo[3].limits=[0.1,500.]
parinfo[3].value=temphigh
parinfo[3].parname='TEMP_HIGH'

parinfo[4].limited=[1,1];lambda background
parinfo[4].limits=[0.4,3.]
parinfo[4].value=lambdaback
parinfo[4].parname='LAMBDA_BACK'

IF keyword_set(thermlow) THEN BEGIN 

   parinfo[0].fixed=0
   parinfo[1].fixed=0

ENDIF 

IF keyword_set(thermhigh) THEN BEGIN 

   parinfo[2].fixed=0
   parinfo[3].fixed=0

ENDIF 


IF keyword_set(varbackground) THEN BEGIN 

   parinfo[4].fixed=0

ENDIF

fitrange=fcheck(fitrange,[min(cntedges),max(cntedges)])

cntrange=where(cntedges[*,0] GE fitrange[0] AND cntedges[*,1] LE fitrange[1])

;stop

fitpar=mpfitfun('pg_modfitdualtherm',replicate(1,n_elements(cntrange)),spectrum[cntrange] $
             ,sqrt(espectrum[cntrange]^2+bespectrum[cntrange]^2) $
             ,functargs={photedges:photedges,drm:matrix,geom_area:geom_area $
                        ,cntrange:cntrange,enorm:enorm,background:bspectrum} $
             ,bestnorm=bn,yfit=yfit,dof=dof,status=mpfitstatus,quiet=quiet $
             ,parinfo=parinfo)


chisq=bn/dof

fittemplow=   fitpar[1]
fitemlow=     fitpar[0]
fittemphigh=  fitpar[3]
fitemhigh=    fitpar[2]
fitlambdaback=fitpar[4]


RETURN,fitpar




END
