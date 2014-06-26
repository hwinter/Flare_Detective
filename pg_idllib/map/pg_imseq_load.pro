;+
;
; NAME:
;        pg_imseq_load
;
; PURPOSE: 
;
;        repeatedly calls fits2map from a list of file names and build
;        a pointer array to the maps
;
; CALLING SEQUENCE:
;
;        res=pg_imsewq_load(filelist, [err=err])
; 
; INPUTS:
;
;        filelist: array of filenames
;
;                
; OUTPUT:
;        err: optionla error code, 0: success
;
;
; VERSION HISTORY:
;       
;       04-APR-2005 written PG
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;-

FUNCTION pg_imseq_load,filelist,err=err

   err=0
   
   IF size(filelist,/tname) NE 'STRING' THEN BEGIN
      err=1
      print,'Please input a string of file names!'
      RETURN,ptr_new()
   ENDIF

   n=n_elements(filelist)
   res=ptrarr(n)

   FOR i=0,n-1 DO BEGIN
      IF file_exist(filelist[i]) THEN BEGIN 
         fits2map,filelist[i],map,err=errfits2map
         IF errfits2map EQ '' THEN res[i]=ptr_new(map)
      ENDIF
   ENDFOR

   RETURN,res

END
