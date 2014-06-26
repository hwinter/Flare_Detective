;+
; NAME:
;   tickgoes
;
; PURPOSE:
;   for plotting goes value instead of numbers, used by
;   plot,...,ytickformat='tickgoes'    
;  
;
; HISTORY:
;   written 05-DEC-2002 by Paolo Grigis
;    2003/09/05: adapted for HEDC usage, PSH                    
;-


FUNCTION hedc_tickgoes,axis,index,value

RETURN,hedc_togoes(value)

END

