;+
; NAME:
;
; pg_getphyscons
;
; PURPOSE:
;
; returns the value of a physical constants based on CODATA recommeneded
; values
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
; ??? written PG
; 17-OCT-2005 added quiet keyword PG
;
;-

;.comp ~/pand_rapp_idl/constconversion/pg_getphyscons.pro

function pg_getphyscons,name,codata_file=codata_file,quiet=quiet

codata_file=fcheck(codata_file, $
   '~/pand_rapp_idl/constconversion/const_values.txt')

name1=fcheck(name,'speed of light in vacuum') 
name1=strupcase(strcompress(name1,/remove_all))

template={version:1.,datastart:12L,delimiter:0B,missingvalue:!Values.f_NAN, $
   commentsymbol:'',fieldcount:4L,fieldtypes:[7L,7,7,7], $
   fieldnames:['Quantity','Value','Uncertainty','Unit'], $
   fieldlocations:[0L,55,77,99],fieldgroups:[0L,1,2,3]}

res=read_ascii(codata_file,template=template)

notfound=1B
i=0L
n=n_elements(res.value)

WHILE notfound AND i LT n DO BEGIN
   quantity=strupcase(strcompress(res.quantity[i],/remove_all))
   IF name1 EQ quantity THEN notfound=0B ELSE i=i+1 
ENDWHILE

IF i EQ n THEN BEGIN
   print,'NO CONSTANT NAMED '+name+' FOUND'
   RETURN,-1
ENDIF

vstring=res.value[i]
value=double(strcompress(strjoin(strsplit(vstring,'\.{3}',/regex,/extract)) $
   ,/remove_all))   

IF NOT keyword_set(quiet) THEN $
print,res.quantity[i]+' is equal to '+string(value)+' '+res.unit[i]

RETURN,value
 
END
