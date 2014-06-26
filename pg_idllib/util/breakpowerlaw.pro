;+
; NAME:
;      breakpowerlaw
;
; PURPOSE: 
;     produce a broken power law funtion
;
; CALLING SEQUENCE:
;      ans=breakpowerlaw(x,delta1,delta2,xbreak,ybreak)
;
; INPUTS:
;      x: array of x values
;      delta1: power index before break
;      delta2: power index after break
;      xbreak: x coord of break
;      ybreak: y coord of break
;
; OUTPUT:
;      ans: a vector, same size as x       
;       
; RESTRICTIONS:
;      
;
; KEYWORDS:
;        
;
; HISTORY:
;       08-JAN-2003 written
;       
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION breakpowerlaw,x,delta1,delta2,xbreak,ybreak

a1=double(ybreak*xbreak^(-delta1))
a2=double(ybreak*xbreak^(-delta2))

ans=x
indices1=where(x LE xbreak)
indices2=where(x GT xbreak)
IF indices1[0] NE -1 THEN ans[indices1]=a1*x[indices1]^(delta1)
IF indices2[0] NE -1 THEN ans[indices2]=a2*x[indices2]^(delta2)

RETURN,ans

END

