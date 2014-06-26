;+
; NAME:
;      pg_getspreadofdata
;
; PURPOSE: 
;      input a series of N measurements of M values as a float NxM
;      array x, returns the average and spread of the data. Missing
;      measurements are allowed, and should be given as NaN in x.
;
; CALLING SEQUENCE:
;
;      pg_getspreadofdata,x,avg=avg,stddev=stddev      
;
; INPUTS:
;            
;      x: float or double array N by M
;
; OUTPUTS:
;      avg: average
;      stdev: standard deviation
;      
; KEYWORDS:
;      keepmissing: by default, the routine does not output avg
;      positions in the case where no measurements was done, if this
;      keyword is set, then the position is given as a NaN     
;
;
; HISTORY:
;
;      05-JAN-2005 written
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-


;test
;.comp pg_getspreadofdata
;nan=!values.f_nan
;x=[[1.,2.,1.],[1,nan,nan],[3.,4,6],[8,nan,9],[nan,nan,nan],[4,nan,5]]
;pg_getspreadofdata,x,avg=avg,stdev=stdev,/keepmissing & print,avg,stdev
;pg_getspreadofdata,x,avg=avg,stdev=stdev & print,avg,stdev

PRO pg_getspreadofdata,x,avg=avg,stdev=stdev,keepmissing=keepmissing

N=n_elements(x[*,0])
M=n_elements(x[0,*])

avg=fltarr(M)
stdev=fltarr(M)

nan=!values.f_nan

avg[*]=nan
stdev[*]=nan


FOR i=0,M-1 DO BEGIN
   mes=x[*,i]

   ind=where(finite(mes),count)
   IF count EQ 1 THEN BEGIN 
      avg[i]=x[ind,i]
      stdev[i]=nan
   ENDIF $
   ELSE BEGIN 
     IF count GT 1 THEN BEGIN
        mom=moment(mes[ind])
        avg[i]=mom[0]
        stdev[i]=sqrt(mom[1])
     ENDIF   
   ENDELSE 
ENDFOR

IF NOT keyword_set(keepmissing) THEN BEGIN
   ind=where(finite(avg),count)
   IF count GE 1 THEN BEGIN 
      avg=avg[ind]
      stdev=stdev[ind]
   ENDIF $
   ELSE BEGIN 
      print,'WARNING: no valid elements in x!'
      avg=-1
      stdev=-1
   ENDELSE
ENDIF

END
