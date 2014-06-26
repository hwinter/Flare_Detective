;+
; NAME:
;
; pg_keep_valid_fittings
;
; PURPOSE:
;
; check a list of fittings and eliminate the unvalid ones
;
; CATEGORY:
;
; shs utilities
;
; CALLING SEQUENCE:
;
; out_ptr=pg_keep_valid_fittings(in_ptr)
;
; INPUTS:
;
; in_ptr: array of pointers to spex fit results structures
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
; out_ptr: array of pointer to kept spex fit results 
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
; out_ptr=pg_keep_valid_fittings(stp1)
; 
; AUTHOR:
;
; Paolo Girgis, Institute of astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
; 
;
; MODIFICATION HISTORY:
;
; 5-JAN-2003 written
; 
;-

FUNCTION pg_keep_valid_fittings,in_ptr,eref=eref,thresh_flux=thresh_flux

   eref=fcheck(eref,25)
   thresh_flux=fcheck(thresh_flux,0.1)

   out_ptr=in_ptr

   ;list of tags to crop...
   taglist1=['CHI']; array N
   taglist2=['XSELECT' $ ;array X*N
            ,'APAR_ARR' $
            ,'APAR_SIGMA' $
            ,'CONVI' $
            ,'OBSI' $
            ,'EOBSI' $
            ,'BACKI' $
            ,'EBACKI' $
            ,'FLOAT' $
            ,'ISELECT']


   FOR i=0,n_elements(in_ptr)-1 DO BEGIN
      
      ;undefines out_ptr if needed
      IF n_elements(out_str) GT 0 THEN dummy=temporary(out_str)

      IF in_ptr[i] NE ptr_new() THEN BEGIN

         
         str=*in_ptr[i]
         out=pg_apar2flux_fmultispec(str,eref)
         ind=where(out.flux GE thresh_flux,count)

         ;cropped_str={n_flare:str.n_flare}

         IF count GT 0 THEN BEGIN
           
            tagnames=tag_names(str)
            ntags=n_elements(tagnames)
            first=1
         
            FOR j=0,ntags-1 DO BEGIN
               tmp=where(tagnames[j] EQ taglist1,count1)
               tmp=where(tagnames[j] EQ taglist2,count2)

               
 
               IF count1 GT 0 THEN BEGIN
                  inarr=str.(j)
                  outarr=inarr[ind]
                  out_str=add_tag(out_str,outarr,tagnames[j])
               ENDIF ELSE $               
                   IF count2 GT 0 THEN BEGIN
                      inarr=str.(j)
                      outarr=inarr[*,ind]
                      out_str=add_tag(out_str,outarr,tagnames[j])                 
                   ENDIF ELSE $
                      out_str=add_tag(out_str,str.(j),tagnames[j])

               
            ENDFOR
            
            out_ptr[i]=ptr_new(out_str)
            
         ENDIF $
         ELSE BEGIN
            out_ptr[i]=ptr_new()
         ENDELSE


      ENDIF

   ENDFOR

  

RETURN,out_ptr
END
