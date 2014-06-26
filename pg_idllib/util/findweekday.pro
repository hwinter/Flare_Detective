;+
; NAME:
;   findweekday
;
; CALLING SEQUENCE:
;
;   dow=findweekday(time)
;
; PURPOSE:
;   find the day of week of a time given in a format accepted by anytim
;
; INPUT: 
;   time
;
; OUTPUT:
;   dow: string
;
; CALLS:
;   anytim
;
; HISTORY:
;   written by Paolo Grigis, ETH Zurich
;   
;-


FUNCTION findweekday,time

ex=anytim(time,/ex)

y=ex[6]
m=ex[5]
d=ex[4]

last2y=y mod 100

monthvalues=[1,4,4,0,2,5,0,3,6,1,4,6]
centvalues=[6,4,2,0]
dow=['Sat','Sun','Mon','Tue','Wed','Thu','Fri']

val=last2y/4+d+monthvalues[m-1]+last2y+centvalues[(y/100) mod 4]

IF ((m EQ 1) OR (m EQ 2)) AND ((y MOD 4) EQ 0) AND $
   (NOT((y mod 100 EQ 0) AND (y mod 400 NE 0))) THEN val=val-1
    
result=dow[val mod 7]

RETURN,result

END

