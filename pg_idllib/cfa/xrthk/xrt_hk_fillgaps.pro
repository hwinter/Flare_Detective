;+
; NAME:
;
; xrt_hk_fillgaps
;
; PURPOSE:
;
; if a nearly regular data series has some gaps, a plot of this will show a straight
; line across the gaps, which is in general not nice. The behavior of plot can be
; improved by inserting a NAN value in the gap. This routines does so.
;
; CATEGORY:
;
; array manipulation tool
;
; CALLING SEQUENCE:
;
; yout=pg_fillnaningaps(xin,yin,gaplength=gaplength)
;
; INPUTS:
;
; xin: array of "times"
; yin: array of "values"
; gaplength: x values spearted by more than this are considered to form a gap
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
;
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
; Need to improve documentation.
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
; 
; Written circa 2004 Paolo C Grigis
; 17-NOV-2008 adapted for XRT HK plotting
;
;-


PRO xrt_hk_fillgaps,xin,yin,xout=xout,yout=yout,gaplength=gaplength,twonans=twonans

  gaplength=fcheck(gaplength,(max(xin)-min(xin))/10.)

  dx=(xin-shift(xin,1))[1:n_elements(xin)-1]

  ind=where(dx GE gaplength,count)

  IF count EQ 0 THEN BEGIN 
     xout=xin
     yout=yin
  ENDIF $
  ELSE BEGIN 
     
     IF NOT keyword_set(twonans) THEN BEGIN 

        yout=make_array(n_elements(yin)+count,type=size(yin,/type),value=!values.f_nan)
        xout=yout

        yout[0:ind[0]]=yin[0:ind[0]]
        xout[0:ind[0]]=xin[0:ind[0]]
        xout[ind[0]+1]=0.5*total(xin[ind[0]+[0,1]])

        FOR i=1,count-1 DO BEGIN 
           yout[ind[i-1]+i+1:ind[i]+i]=yin[ind[i-1]+1:ind[i]]
           xout[ind[i-1]+i+1:ind[i]+i]=xin[ind[i-1]+1:ind[i]]
           xout[ind[i]+i+1]=0.5*total(xin[ind[i]+[0,1]])
        ENDFOR

        yout[ind[count-1]+count+1:n_elements(yout)-1]=yin[ind[count-1]+1:n_elements(yin)-1]
        xout[ind[count-1]+count+1:n_elements(xout)-1]=xin[ind[count-1]+1:n_elements(xin)-1]

     ENDIF $
     ELSE BEGIN 

        yout=make_array(n_elements(yin)+2*count,type=size(yin,/type),value=!values.f_nan)
        xout=yout

        yout[0:ind[0]]=yin[0:ind[0]]
        xout[0:ind[0]]=xin[0:ind[0]]
        xout[ind[0]+1]=xin[ind[0]]+gaplength
        xout[ind[0]+2]=xin[ind[0]+1]-gaplength

        FOR i=1,count-1 DO BEGIN 
           yout[ind[i-1]+2*i+1:ind[i]+2*i]=yin[ind[i-1]+1:ind[i]]
           xout[ind[i-1]+2*i+1:ind[i]+2*i]=xin[ind[i-1]+1:ind[i]]
           xout[ind[i]+2*i+1]=xin[ind[i]]+gaplength
           xout[ind[i]+2*i+2]=xin[ind[i]+1]-gaplength
        ENDFOR

        yout[ind[count-1]+2*count+1:n_elements(yout)-1]=yin[ind[count-1]+1:n_elements(yin)-1]
        xout[ind[count-1]+2*count+1:n_elements(xout)-1]=xin[ind[count-1]+1:n_elements(xin)-1]
        
     ENDELSE
   

  ENDELSE

END


