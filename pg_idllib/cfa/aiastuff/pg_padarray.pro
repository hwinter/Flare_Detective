;+
; NAME:
;
; pg_padarray
;
; PURPOSE:
;
;
;
; CATEGORY:
;
;
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
; MODIFICATION HISTORY:
;
;-

FUNCTION pg_padarray,x,npad=npad

npad=fcheck(npad,526)

s=size(x)

nx=s[1]

last=x[nx-1]
first=x[0]

padx=findgen(npad)/(npad-1)*12-6.0

sigma=2.5
pady=exp(-padx^2/sigma)
pady=total(pady/total(pady),/cumulative)

paddedarray=[first*pady,x,last*reverse(pady)]

RETURN,paddedarray

END


