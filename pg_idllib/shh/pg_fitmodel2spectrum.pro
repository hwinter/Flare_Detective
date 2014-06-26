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

;.comp pg_fitmodel2spectrum

FUNCTION pg_fitmodel2spectrum,spectrum=spectrum,espectrum=espectrum $
                             ,bspectrum=bspectrum,bespectrum=bespectrum $
                             ,matrix=matrix,geom_area=geom_area $
                             ,cntedges=cntedges,fitrange=fitrange $
                             ,photedges=photedges $
                             ,thermal=thermal,bpow=bpow,tripow=tripow $
                             ,varbackground=varbackground $
                             ,temp=temp,em=em,delta=delta,fnorm=fnorm $
                             ,dh=dh,dl=dl,ebreakl=ebreakl,ebreakh=ebreakh $
                             ,lambdaback=lambdaback,enorm=enorm $
                             ,chisq=chisq,mpfitstatus=mpfitstatus,quiet=quiet $
                             ,fittemp=fittemp,fitem=fitem,fitdelta=fitdelta $
                             ,fitdh=fitdh,fitdl=fitdl,fitfnorm=fitfnorm $
                             ,fitebreakl=fitebreakl,fitebreakh=fitebreakh $
                             ,fitlambdaback=fitlambdaback,parinfo=parinfo

;several cases...


enorm=fcheck(enorm,50.)

temp=fcheck(temp,1.)
em=fcheck(em,1.)
delta=fcheck(delta,3.)
dh=fcheck(dh,1.5)
dl=fcheck(dl,1.5)
fnorm=fcheck(fnorm,1.)
ebreakh=fcheck(ebreakh,150.)
ebreakl=fcheck(ebreakl,15.)
lambdaback=fcheck(lambdaback,1.)

parinfo=replicate({value:0.,fixed:1.,limited:[0,0],limits:[0d ,0.],parname:' '},9)

parinfo[0].limited=[1,1];delta
parinfo[0].limits=[1d,25]
parinfo[0].value=delta
parinfo[0].parname='DELTA_MAIN'
parinfo[1].limited=[1,0];delta below low break
parinfo[1].limits=[1.,25]
parinfo[1].value=dh
parinfo[1].parname='DELTA_LOW'
parinfo[2].limited=[1,1];delta above high break
parinfo[2].limits=[1.,2]
parinfo[2].value=dl
parinfo[2].parname='DELTA_HIGH'
parinfo[3].limited=[1,1];fnorm
parinfo[3].limits=[0.,1d10]
parinfo[3].value=fnorm
parinfo[3].parname='FLUX_NORM'
parinfo[4].limited=[1,1];ebreak low
parinfo[4].limits=[3.,60.]
parinfo[4].value=ebreakl
parinfo[4].parname='EBREAK_LOW'
parinfo[5].limited=[1,1];ebreak high
parinfo[5].limits=[30.,500.]
parinfo[5].value=ebreakh
parinfo[4].parname='EBREAK_HIGH'
parinfo[6].limited=[1,1];em in 10^49 units
parinfo[6].limits=[0.,1d10]
parinfo[6].value=em
parinfo[6].parname='EM'
parinfo[7].limited=[1,1];temp in keV
parinfo[7].limits=[0.1,50.]
parinfo[7].value=temp
parinfo[7].parname='TEMP'
parinfo[8].limited=[1,1];lambda background
parinfo[8].limits=[0.4,3.]
parinfo[8].value=lambdaback
parinfo[8].parname='LAMBDA_BACK'

IF keyword_set(thermal) THEN BEGIN 

   parinfo[6].fixed=0
   parinfo[7].fixed=0

ENDIF

IF keyword_set(bpow) THEN BEGIN 

   parinfo[0].fixed=0
   parinfo[1].fixed=0
   parinfo[3].fixed=0
   parinfo[4].fixed=0

ENDIF

IF keyword_set(tpow) THEN BEGIN 


   parinfo[0].fixed=0
   parinfo[1].fixed=0
   parinfo[2].fixed=0
   parinfo[3].fixed=0
   parinfo[4].fixed=0
   parinfo[5].fixed=0

ENDIF

IF keyword_set(varbackground) THEN BEGIN 

   parinfo[8].fixed=0

ENDIF

fitrange=fcheck(fitrange,[min(cntedges),max(cntedges)])

cntrange=where(cntedges[*,0] GE fitrange[0] AND cntedges[*,1] LE fitrange[1])

;stop

fitpar=mpfitfun('pg_modfit',replicate(1,n_elements(cntrange)),spectrum[cntrange] $
             ,sqrt(espectrum[cntrange]^2+bespectrum[cntrange]^2) $
             ,functargs={photedges:photedges,drm:matrix,geom_area:geom_area $
                        ,cntrange:cntrange,enorm:enorm,background:bspectrum} $
             ,bestnorm=bn,yfit=yfit,dof=dof,status=mpfitstatus,quiet=quiet $
             ,parinfo=parinfo)


chisq=bn/dof

fittemp=      fitpar[7]
fitem=        fitpar[6]
fitdelta=     fitpar[0]
fitdl=        fitpar[1]
fitdh=        fitpar[2]
fitfnorm=     fitpar[3]
fitebreakl=   fitpar[4]
fitebreakh=   fitpar[5]
fitlambdaback=fitpar[8]


RETURN,fitpar




END
