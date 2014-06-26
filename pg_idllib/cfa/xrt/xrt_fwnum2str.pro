;+
; NAME:
;
; xrt_fwnum2str
;
; PURPOSE:
;
; Convert XRT filter numbers to their string representation
;
; CATEGORY:
;
; XRT/Hinode
;
; CALLING SEQUENCE:
;
; filtername=xrt_fwnum2str(number,fw=fw)
;
; INPUTS:
;
; number: the integer filter number(s), can be an array
; fw: either 1 or 2, designating the required filter wheel (deafults to 1) [not an array]
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
; a string with the filtername
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
; pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
; 
; 12-SEP-2007 written
;
;-

;.comp xrt_fwnum2str

FUNCTION xrt_fwnum2str,number,fw=fw

fw=fcheck(fw,1)

fw1names=['Open','Al_poly','C_poly','Be_thin','Be_med','Al_med']
fw2names=['Open','Al_mesh','Ti_poly','Gband','Al_thick','Be_thick']

ind=where(number LT 0 OR number GT 5,count_invalid)
IF count_invalid GT 0 THEN BEGIN 
   print,'Some FW numbers are invalid, must lie in 0 to 5 range'
   return,' '
ENDIF

IF fw EQ 1 THEN RETURN,fw1names[number]
IF fw EQ 2 THEN RETURN,fw2names[number]

print,'Invalid Filter wheel, must be 1 or 2!'
RETURN,-1


END


