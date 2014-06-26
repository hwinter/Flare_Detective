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
;   wiritten 05-DEC-2002 by Paolo Grigis
;
; $Id: tickgoes.pro 5 2007-12-04 21:15:49Z pgrigis $
;                        
;-


FUNCTION tickgoes,axis,index,value

RETURN,togoes(value)

END

