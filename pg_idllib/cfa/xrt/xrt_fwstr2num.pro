;+
; NAME:
;
; xrt_fwstr2num
;
; PURPOSE:
;
; Convert XRT filter names to their numeric representation
;
; CATEGORY:
;
; XRT/Hinode
;
; CALLING SEQUENCE:
;
; filtername=xrt_fwnum2str(name,fw=fw)
;
; INPUTS:
;
; name: string with the filter name (can be an array)
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
; the filter number(s) for the selected FW
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
; 19-SEP-2007 written
;
;-

;.comp xrt_fwstr2num

FUNCTION xrt_fwstr2num,name,fw=fw

fw=fcheck(fw,1)

n=n_elements(name)

fw1names=['Open','Al_poly','C_poly','Be_thin','Be_med','Al_med']
fw2names=['Open','Al_mesh','Ti_poly','Gband','Al_thick','Be_thick']

IF fw EQ 1 THEN fwnames=['Open','Al_poly','C_poly','Be_thin','Be_med','Al_med']
IF fw EQ 2 THEN fwnames=['Open','Al_mesh','Ti_poly','Gband','Al_thick','Be_thick']

num=intarr(n)

error=0

FOR i=0,n-1 DO BEGIN 
   ind=where(name[i] EQ fwnames,count)
   IF count NE 1 THEN BEGIN 
      error=1
      BREAK
   ENDIF
   num[i]=ind
ENDFOR

IF error THEN BEGIN 
   print,"Invalid filter name, must be one of"
   print,"'Open','Al_poly','C_poly','Be_thin','Be_med','Al_med' for FW1"
   print,"or"
   print,"'Open','Al_mesh','Ti_poly','Gband','Al_thick','Be_thick' for FW2"
   RETURN,-1
ENDIF ELSE RETURN,num


END


