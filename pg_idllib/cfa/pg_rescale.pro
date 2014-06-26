;+
; NAME:
;
; pg_rescale
;
; PURPOSE:
;
; rescales data in some range with different prescriptions (linear, log, etc.)
;
; CATEGORY:
;
; data manip utils
;
; CALLING SEQUENCE:
;
; pg_rescale,data,min=min,max=max,method_number=method_number
;
; INPUTS:
;
; data: any array
; max,min: limits for rescaled array, if not present they defaults to max,min of data
; method_number: one of the followings
;                   0: linear
;                   1: logarithmic (default)
;                   2: quadratic (bent downwards)
;                   etc. TBD
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
;
; Paolo Grigis, CfA
; pgrigis@cfa.haravrd.edu
;
; MODIFICATION HISTORY:
;
; 7-SEP-2007 written PG (based on imseq_manip, originally written in 2003 and 2004)
;
;-

;.comp pg_rescale.pro


FUNCTION pg_rescale,x,min=min,max=max,dmin=dmin,dmax=dmax,scale_gamma=scale_gamma,method_number=method_number


scale_gamma=fcheck(scale_gamma,1.)

dmin=fcheck(dmin,min(x))
dmax=fcheck(dmax,max(x))
din=dmax-dmin

min=fcheck(min,dmin)
max=fcheck(max,dmax)
dout=max-min

IF dout EQ 0 THEN RETURN,x*0+min

delta=dout/din

method_number=fcheck(method_number,0)

CASE method_number OF 

   0: BEGIN ;linear

      out=(delta*x-dmin*delta+min)>min<max

   END

   1: BEGIN ;logarithmic

      out=pg_rescale(alog(pg_rescale(x,min=exp(-scale_gamma)<(1d -1d-8),dmin=dmin,dmax=dmax $
                                      ,max=exp( scale_gamma)>(1d +1d-8),method_number=0)) $
                    ,min=min,max=max,method_number=0)

   END


   2: BEGIN ;quadratic

      scale_gamma=scale_gamma>0.5

      out=pg_rescale(pg_rescale(x,min=0.,max=1.,method_number=0,dmin=dmin,dmax=dmax)^(0.5/scale_gamma) $
                    ,min=min,max=max,method_number=0)

   END


   ELSE : BEGIN 

      print,'Unknown method!'

   ENDELSE

ENDCASE

RETURN,out

END


