;+
; NAME:
;
; pg_strip_spexst
;
; PURPOSE:
;
; keeps only selected time intervals of the time dependent elements of the
; spex structure
;
; CATEGORY:
;
; util for shs project
;
; CALLING SEQUENCE:
;
; stripped_spexst=pg_strip_spexst(spexst,time_intv)
;
; INPUTS:
;
; spexst: a spex output structure, or an array of pointers to such
; structure (null pointers allowed)
; time_intv: a list of time intervals
;
; OPTIONAL INPUTS:
;
;
;
; OUTPUTS:
;
; stripped spex structure
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
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 17-FEB-2004 written
; 01-MAR-2004 now pointer array allowed as input
; 
;-
FUNCTION pg_strip_spexst,spexst,time_intv,gftst=gftst

   siz=size(spexst);check if spexst is a pointer array
                   ;in this case call itself recursively
                   ;for each element of the pointer array
   IF siz[n_elements(siz)-2] EQ 10 THEN BEGIN 
      IF NOT exist(gftst) THEN RETURN,-1
      stp=spexst
      FOR i=0,n_elements(stp)-1 DO BEGIN
         IF stp[i] NE ptr_new() THEN BEGIN 
            spexstt=*stp[i]
            time_intv=gftst[i].good_fit_time
            outst=pg_strip_spexst(spexstt,time_intv)
            IF (size(outst))[0] EQ 0 THEN $
              stp[i]=ptr_new() ELSE $
              stp[i]=ptr_new(outst)
         ENDIF         
      ENDFOR
      RETURN,stp
   ENDIF 


   ;from here on spexst is a structure

   s=size(time_intv)
   IF s[0] NE 2 AND s[1] NE 2 THEN RETURN,-1

   ;if time intv has a void string '' or ' ' there may be a problem with
   ;anytim because of its "feature" that: anytim(['26-FEB-2002','']) return the
   ;current date for the second element while anytim('') return 0 (not very consistent)
                          
   ok=s[2]
   IF s[n_elements(s)-2] EQ 7 THEN BEGIN
      ok=0
      FOR i=0,s[2]-1 DO $
         IF time_intv[0,i] NE '' AND time_intv[0,i] NE ' ' THEN ok=ok+1
   ENDIF
   
   
   time_intv=anytim(time_intv)

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

 
   date=anytim(spexst.date)     
 
   FOR i=0,ok-1 DO BEGIN 
      tintv=time_intv[*,i]+0.1d*[-1,1]
      tmpind=where(date+spexst.xselect[0,*] GT tintv[0] AND $
                   date+spexst.xselect[1,*] LT tintv[1],count)
      
      
      IF i EQ 0 AND count GT 0 THEN BEGIN
         IF count GT 0 THEN ind=tmpind
      ENDIF $
      ELSE BEGIN
         IF count GT 0 THEN ind=[ind,tmpind]
      ENDELSE
   ENDFOR


   tagnames=tag_names(spexst)
   ntags=n_elements(tagnames)
   first=1

   IF n_elements(ind) GT 0 THEN BEGIN
          
   FOR j=0,ntags-1 DO BEGIN
      tmp=where(tagnames[j] EQ taglist1,count1)
      tmp=where(tagnames[j] EQ taglist2,count2)
         
      IF count1 GT 0 THEN BEGIN
         inarr=spexst.(j)
         outarr=inarr[ind]
         out_str=add_tag(out_str,outarr,tagnames[j])
      ENDIF ELSE $               
        IF count2 GT 0 THEN BEGIN
         inarr=spexst.(j)
         outarr=inarr[*,ind]
         out_str=add_tag(out_str,outarr,tagnames[j])                 
      ENDIF ELSE $
        out_str=add_tag(out_str,spexst.(j),tagnames[j])

   ENDFOR

ENDIF ELSE out_str=-1
  
   RETURN,out_str

END

