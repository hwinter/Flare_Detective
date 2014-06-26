;+
; PROJECT:
;
;    SDO Feature Finding Team
;
; NAME:
;
;    SDCFD_EXPRUNAVG
;
; PURPOSE:
;
;    Computes the exponential running average of a lightcurve
;
; CATEGORY:
;
;    SDO science center/ Flare detection
;
; CALLING SEQUENCE:
;
;    y=sdcfd_exprunavg(x,gamma=gamma)
;
; INPUTS:
; 
;    x: array of data
;    gamma: the control parameter for the exponential running averag
;
; OPTIONAL INPUTS:
;
;   
;
; KEYWORD PARAMETERS: 
;
;    NONE
;
;
; OUTPUTS:
;
;    y: the exponentially weighted running average
;
; OPTIONAL OUTPUTS:
;
;    NONE
;
; COMMON BLOCKS:
;
;    NONE
; 
; SIDE EFFECTS:
;
;    NONE
;
; RESTRICTIONS:
;
;    
;
; PROCEDURE:
;
;   y[0] is set equal x[0]. y[n] is gamma*x[n]+(1-gamma)*y[n-1]
;
; EXAMPLE:
;
;    
;
; VERSION CONTROL SYSTEM STRING:
;
;   $Id:$
;
; AUTHOR:
;
;    Paolo C. Grigis, pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;  
;    15-MAR-2008 written PG 
;    
;    
;-

FUNCTION sdcfd_exprunavg,x,gamma=gamma

gamma=fcheck(gamma,0.1)

y=x

FOR i=1,n_elements(x)-1 DO BEGIN 
   y[i]=gamma*x[i]+(1-gamma)*y[i-1]
ENDFOR

RETURN,y

END



