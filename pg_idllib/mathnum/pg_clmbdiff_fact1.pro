;+
; NAME:
;      pg_clmbdiff_fact1
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      returns the coefficient for the linear term in the
;      fokker-planck equation in energy space as given by Miller
;      (1996) in the dimensionless and energy-logarithmic form
;
; EXPLICATION:
;      
;
;
; CALLING SEQUENCE:
;     
;
; INPUTS:
;      y: energy (or energies) of the test particle, in units of log_10(E/mc^2)
;      yt: thermal energy of the field plasma, in units of
;          log_10(Etherm/mc^2)
;      dtime: basic time unit in seconds
;   
; OUTPUTS:
;      
;      
; KEYWORDS:
;
;
; HISTORY:
;       17-JUN-2005 written PG
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

FUNCTION pg_clmbdiff_fact1,y,yt,dtime

   cconv=pg_clmbconv_dimless(y,yt,dtime)
   cdiff=pg_clmbdiff_dimless(y,yt,dtime)

   res=-1*10^(-y)/alog(10)
 
   RETURN,res

END
