;+
; NAME:
;
; pg_winnow_lightcurve
;
; PURPOSE:
;
; From an input function given by two vectors x,y, returns an input constructed
; in the following way: the highest point is selected. From there, propgating
; both left and right, points that are closer in y than threshold are removed.
; If a point outside the threshold is found, this becomes the new basis for the
; threshold. The process continues untill all the array is winnowed.
;
; CATEGORY:
;
;
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
; MODIFICATION HISTORY:
;
;-

PRO pg_winnow_lightcurve,x,y,threshold=threshold,xout=xout,yout=yout,winnowind=winnowind

IF n_elements(threshold) EQ 0 THEN threshold=1

nx=n_elements(x)
ny=n_elements(y)

IF nx NE ny OR nx EQ 0 THEN RETURN 

;i=0

y2=y
x2=x

xout=-1
yout=-1

done=0
winnowind=-1



WHILE n_elements(y2) GT 0 AND done EQ 0  DO BEGIN 

   yt=max(y2,index)
   nnx=n_elements(y2)
   IF index EQ 0 THEN left=0 ELSE left=1
   IF index EQ nnx-1 THEN right=0 ELSE right=1

   leftcounter=0
   rightcounter=0

   print,index,nnx


   IF left EQ 1 THEN BEGIN 
      i=index-1
      WHILE (i-leftcounter GE 1) && abs(y2[i-leftcounter]-yt) GT threshold DO BEGIN
         yout=[yout,y2[i-leftcounter]]
         xout=[xout,x2[i-leftcounter]]
         winnowind=[winnowind,i-leftcounter]
         yt=y2[i-leftcounter]
         leftcounter++
      ENDWHILE
   ENDIF
   
   yt=y2[index]

   IF right EQ 1 THEN BEGIN 
      i=index+1
      WHILE (i+rightcounter LT nnx-1) && abs(y2[i+rightcounter]-yt) GT threshold DO BEGIN
         yout=[yout,y2[i+rightcounter]]
         xout=[xout,x2[i+rightcounter]]
         winnowind=[winnowind,i+leftcounter]
         yt=y2[i-rightcounter]
         rightcounter++
      ENDWHILE
   ENDIF

   IF leftcounter+rightcounter EQ 0 THEN done=1 ELSE BEGIN 

   ;stop
 
      y2=[y2[0:index-leftcounter-1],y2[index+rightcounter+1:*]]
      x2=[x2[0:index-leftcounter-1],x2[index+rightcounter+1:*]]
      
   ENDELSE


   ;stop


  
      
;   ENDIF
;   IF rightcounter GT 0 THEN BEGIN 
;   ENDIF



;;         yt=y[i]
;;         xout=[x[i],xout]
;;         yout=[yt,yout]
;;         winnowind=[i,winnowind]
;;      ENDIF 
;;      i--
;;   ENDWHILE
;;ENDIF
;;yt=ymax


ENDWHILE

winnowind=winnowind[1:*]
xot=xout[1:*]
yot=yout[1:*]


sind=sort(xout)
yout=yout[sind]
xout=xout[sind]
winnowind=winnowind[sind]

;;IF right EQ 1 THEN BEGIN 
;; i++
;; WHILE i LT nx DO BEGIN 
;;    IF abs(y[i]-yt) GT threshold THEN BEGIN 
;;       yt=y[i]
;;       xout=[xout,x[i]]
;;       yout=[yout,yt]
;;       winnowind=[winnowind,i]
;;    ENDIF 
;;    i++
;; ENDWHILE
;;ENDIF


END


