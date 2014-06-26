;+
; NAME:
;
; pg_probit
;
; PURPOSE:
;
; implement the probit function= sqrt(2)*erf^-1(2x-1)
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
; AUTHOR: 
;
; Paolo Grigis
; pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 28-AUG-2008
;
;-

FUNCTION pg_pgif_erf,x
RETURN,0.5d*erf(x/sqrt(2d))+0.5d
END

FUNCTION pg_probit,x

y=pg_invertfunction(x,'pg_pgif_erf',pgif_range=[-8.0,8.0],pgif_ytol=1d-9)

RETURN,y

END 
