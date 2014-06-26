;+
; NAME:
;	F_VTH_DEFAULTS
;
; PURPOSE: Function to return default values for
;   parameters, minimum and maximum range, and free parameter mask when
;   fitting to f_vth function.
;
; CALLING SEQUENCE: defaults = f_vth_defaults()
;
; INPUTS:
;	None
; OUTPUTS:
;	Structure containing default values
;
; MODIFICATION HISTORY:
; Kim Tolbert, February 2004
;
;-
;------------------------------------------------------------------------------

FUNCTION F_GTEST_DEFAULTS

defaults = { $
  fit_comp_params:       [1e0,   2], $
  fit_comp_minima:           [1e-20, 5e-1], $
  fit_comp_maxima:           [1e20,  5e1], $
  fit_comp_free_mask:        1B+Bytarr(2) $
  }

RETURN, defaults

END
