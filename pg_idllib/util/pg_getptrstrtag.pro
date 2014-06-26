;+
; NAME:
;
; pg_getptrstrtag
;
; PURPOSE:
;
; input an array of pointer to structures, this routine returns an
; array with the values of a user specified tag for all the structures
; in the array
;
; CATEGORY:
;
; various utoilities
;
; CALLING SEQUENCE:
;
; out=pg_getptrstrtag(arr_ptr,tagname)
;
; INPUTS:
;
; arr_ptr: an array of pointers to structures
; tagname: a tagname
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
; out: an array with tha values of tagname concatenated together
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
; none
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
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.pyhs.ethz.ch
; 
; MODIFICATION HISTORY:
;
; 8-DEC-2003 written P.G.
;
;-

FUNCTION pg_getptrstrtag,ptr_arr,tagname,transpose=transpose

   tot_el=n_elements(ptr_arr)
   first=1

   FOR i=0,tot_el-1 DO BEGIN  

      IF ptr_arr[i] NE ptr_new() THEN BEGIN
         tmpst=*ptr_arr[i]
         taglist=tag_names(tmpst)
         ind=where(taglist EQ tagname,count)

         IF count EQ 1 THEN BEGIN
            IF first THEN BEGIN
               IF keyword_set(transpose) THEN $
                 arr=transpose(tmpst.(ind)) ELSE $
                 arr=tmpst.(ind)
               first=0
            ENDIF $
            ELSE BEGIN
               IF keyword_set(transpose) THEN $
               arr=[arr,transpose(tmpst.(ind))] ELSE $
               arr=[arr,tmpst.(ind)]
            ENDELSE
         ENDIF
         
      ENDIF

   ENDFOR

   IF first THEN RETURN, -1 $ ; error occurred
   ELSE $ ;at least one non null pointer with tag tagname found!     
     IF keyword_set(transpose) THEN $
         RETURN, transpose(arr) ELSE $
         RETURN, arr
                     
END
