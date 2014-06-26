;+
; NAME:
;
; pg_compchi
;
; PURPOSE:
;
; calculates vertical chi square from the fitting of a model to some data
;
; CATEGORY:
;
; shs project util, spex util
;
; CALLING SEQUENCE:
;
; chisq=pg_compchi(x,y,par,model,dof=dof)
;
; INPUTS:
;
; x,y: points
; par: model parameter
; model: model name
;
; KEYWORDS:
;
; dof: number of degrees of freedom of the model (default:2)
; 
; OUTPUTS:
;
; chi square
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
; computes total[(y-ymodel)^2]/[N-DOF], N=number of elemnts of x,y
;
; EXAMPLE:
;
;
;
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.pyhs.ethz.ch
; 
; MODIFICATION HISTORY:
;
; 24-AUG-2004 written P.G.
;
;-

FUNCTION pg_compchi,x,y,par,model,dof=dof

dof=fcheck(dof,2)

ymodel=call_FUNCTION(model,x,par)

chisq=total((y-ymodel)^2)/(n_elements(y)-dof)

return, chisq

END
