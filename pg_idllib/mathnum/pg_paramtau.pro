;+
; NAME:
;      pg_paramtau
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      return a function for tau escape as a function of input parameters
;
;
; CALLING SEQUENCE:
;      tau=pg_paramtau(inputpar=inputpar,...?)
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
;       06-FEB-2005 written PG
;       
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-


FUNCTION pg_paramtau,inputpar,doplot=doplot $
   ,ttrap=ttrap,estep=estep,escslope=escslope,tmin=tmin,tinf=tinf

;
;tau min should be continous for all E with the exception of Estep
;

ttrap=fcheck(ttrap,inputpar.esc_ttrap);tau escape constant for at E<Estep
estep=fcheck(estep,inputpar.esc_estep);step energy in keV
escslope=fcheck(escslope,inputpar.esc_slope);d(ln tau esc)/d(ln E) at energy > Estep, positive
                                ;straight line in log log plot, merges
                                ;with tauinf
tmin=fcheck(tmin,inputpar.esc_taumin);minimal value of tauescape at E=Estep
tinf=fcheck(tinf,inputpar.esc_tauinf);tau at energies >> Estep, constant



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


N=inputpar.steps_per_decade*(inputpar.maxen-inputpar.minen) ; total number of grid points
y=dindgen(N)/(N-1)*(inputpar.maxen-inputpar.minen)+inputpar.minen ; location in eergy of the grid points
                                ; distribuited uniformly in log scale
                                ; new variable y instead of E!
E=(10d^y)*511.                  ; linear energy grid, old variable E (dimensionless, in units of mc^2)


;boundaries for tau
mintau=alog10(inputpar.dt*inputpar.dimless_time_unit);logtau should excede min (logtau)
mintau=mintau+abs(mintau*0.05)
maxtau=4.

array_tauescape=fltarr(N)

indleft=where(e LE estep,countleft,complement=indright,ncomplement=countright)
;this are the points to the left & right of the step

IF countleft GT 0 THEN array_tauescape[indleft]=ttrap

IF countright GT 0 THEN array_tauescape[indright]=tmin*(e[indright]/estep)^escslope < tinf

array_tauescape=array_tauescape > mintau < maxtau

IF keyword_set(doplot) THEN $
  plot,e,array_tauescape,/xlog,/ylog,yrange=[1d-5,1d1],xrange=[0.5,500],/xstyle,/ystyle,psym=-6

RETURN,array_tauescape

END 



