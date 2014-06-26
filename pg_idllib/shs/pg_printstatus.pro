;+
; NAME:
;
; pg_printstatus
;
; PURPOSE:
;
; print a list with the fititng exit status for all the models
;
; CATEGORY:
;
; shs project util
;
; CALLING SEQUENCE:
;
;
; INPUTS:
;
;               
; 
; OUTPUTS:
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
; 2-SEP-2004 written P.G.
;
;-

;pg_printstatus,['pg_pivpoint','pg_fixedn','pg_fixede','pg_brown']

PRO pg_printstatus,model 


;load all model parameters

totnmod=n_elements(model)
modpar=ptrarr(totnmod)

FOR i=0,totnmod-1 DO BEGIN 
  
   dir='~/work/shs2/diffmodfit/'
   filename=dir+model[i]+'_fitresults.fits'
   fpar=mrdfits(filename,1,/silent)
   modpar[i]=ptr_new(fpar)

ENDFOR

print,'--------------------------------------------------------------------------------'
print,' '


FOR i=0,n_elements(fpar.flare_chisq)-1 DO BEGIN

   print,'FLARE NR. '+strtrim(string(i),2)

   outstr=''
   FOR j=0,totnmod-1 DO BEGIN
      fpar=*modpar[j]
      outstr=outstr+strupcase(string(fpar.model,format='(A13)'))+ $
            ' STAT '+strtrim(string(fpar.flare_status[i]),2)
   ENDFOR
   print,outstr

ENDFOR

print,' '
print,'--------------------------------------------------------------------------------'
print,' '

FOR i=0,n_elements(fpar.r_chisq)-1 DO BEGIN

   print,'RISE PHASE NR. '+strtrim(string(i),2)

   outstr=''
   FOR j=0,totnmod-1 DO BEGIN
      fpar=*modpar[j]
       outstr=outstr+strupcase(string(fpar.model,format='(A13)'))+ $
            ' STAT '+strtrim(string(fpar.r_status[i]),2)
   ENDFOR
   print,outstr

ENDFOR

print,' '
print,'--------------------------------------------------------------------------------'
print,' '

FOR i=0,n_elements(fpar.d_chisq)-1 DO BEGIN

   print,'DECAY PHASE NR. '+strtrim(string(i),2)

   outstr=''
   FOR j=0,totnmod-1 DO BEGIN
      fpar=*modpar[j]
      outstr=outstr+strupcase(string(fpar.model,format='(A13)'))+ $
            ' STAT '+strtrim(string(fpar.d_status[i]),2)

   ENDFOR
   print,outstr

ENDFOR

print,' '
print,'--------------------------------------------------------------------------------'

END
