;+
; NAME:
;      pg_accel_dimless
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      returns the value of the "systematic acceleration" diffusion term
;      in dimensionless format and as a function of logarithmic energy
;      the acceleration is provided by waves as in Benz (1977)
;
; EXPLICATION:
;      
;
;
; CALLING SEQUENCE:
;     
;
; INPUTS:
;      y:  energy (or energies) of the test particle, in units of log_10(E/mc^2)
;      dtime: basic time unit in seconds
;   
; OUTPUTS:
;      
;      
; KEYWORDS:
;
;
; HISTORY:
;       11-JUL-2005 written PG
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

FUNCTION pg_accel_dimless,y,ycutoff=ycutoff,w0=w0,dtime

   ycutoff=fcheck(ycutoff,0.)
   dtime=fcheck(dtime,2.09d-7)
   w0=fcheck(w0,2d-6)

   ;x=10^(y-yt)
 
   elcharge=4.8032d-10;electron charge
   ;lnlambda=18.;coulomb logarithm
   ;nh=1d10;density of protons in the field plasma
   ;nu_0=4*!DPi*elchrg^4*lnlambda*nh/elmass^2
   c=2.9979246d10;speed of light
   ;mc2=elmass*c*c;factor mc^2

   elmass=9.1093826d-28;electron mass
   ;nu_0=1.4508709d29; factor nu_0 in Miller without the v^-3 term
   ;mc2=8.1871048d-7 ; electron mass times c^2

   ;ee=e*mc2;transform e --> ee=e*m*c^2 in ergs

   ;stop

   indexlist=where(y GE ycutoff,count)
   IF count EQ 0 THEN BEGIN 
      res=replicate(0.,n_elements(y))
   ENDIF

   maxindex=(min(indexlist)-1)
   
   res=dtime*!Dpi*!Dpi*elcharge*elcharge/(2.*sqrt(2.)*elmass*elmass*c*c*c)*10^(-0.5*y)*w0

   IF maxindex GE 0 THEN res[0:maxindex]=res[0:maxindex]*exp(-(findgen(maxindex+1)/(maxindex)-1)^2/0.05) ;(!)

   RETURN,res

END
