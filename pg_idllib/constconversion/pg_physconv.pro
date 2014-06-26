;+
; NAME:
;
; pg_physconv
;
; PURPOSE:
;
; convert physical constants
;
; CATEGORY:
;
; various utilities
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
; OUTPUT:
;
;
; OPTIONAL OUTPUTS:
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
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
;-

;.comp ~/pand_rapp_idl/constconversion/pg_getphyscons.pro

function pg_getphyscons,name,codata_file=codata_file

codata_file=fcheck(codata_file, $
   '~/pand_rapp_idl/constconversion/const_values.txt')


template={version:1.,datastart:12L,delimiter:0B,missingvalue:!Values.f_NAN, $
   commentsymbol:'',fieldcount:4L,fieldtypes:[7L,7,7,7], $
   fieldnames:['Quantity','Value','Uncertainty','Unit'], $
   fieldlocations:[0L,55,77,99],fieldgroups:[0L,1,2,3]}

res=read_ascii(codata_file,template=template)


 
END
