;+
; NAME:
;      pg_load_ims_id
;
; PURPOSE: 
;      loads an image sequence to a pointer, using an image unique ID as input
;
; INPUTS:
;      
;
;  
; OUTPUTS:
;      
;      
; KEYWORDS:
;      quiet: suppress info messages  
;
; HISTORY:
;
;      15-NOV-2004 written PG
;      
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

FUNCTION pg_load_ims_id,id,imids,quiet=quiet

idlist=imids[*].id

ind =where( idlist EQ id,count)

IF count EQ 0 THEN BEGIN
   print,'No corresponding image ID dound!'
   RETURN,-1
ENDIF

filename=imids[ind[0]].filename

print,'Loading image cube with ID: '+id
print,imids[ind[0]].comment

return,pg_load_imseq(filename,id=id)

END

