;PSH 2001/09/23

;This functions takes a temperature [C] and a wind speed [km/h]
;and returns the effective temperature felt by someone 
;standing naked in the wind. This vary A LOT with clothing (dampness ...), 
;physical characteristics, etc...
;
;EXAMPLE:
;	print,wind_chill(20,20)


;OLD VERSION (BUGGY):
;FUNCTION wind_chill_formula,T,V
;;formula accurate to within 1C for -50<=T<=20 C.
;;found at: http://www.capgo.com/Developer/Sensors/Temperature/Stories/Chill/Chill.htm
;if V lt 8 then c = -0.4488*V else c = 14.81 - 2.682*V + 0.055041*V^2 - 0.000575*V^3 + 0.000002402*V^4
;newT = T + c*(33.3 - T) / 73.3  
;; for high temperatures, modify preceding line to: newT = T + c*(40. - T) / 80.
;return,newT
;END

;NEWEST VERSION:
; from http://www.islandnet.com/~see/weather/life/windchill.htm#b	-- there are pretty good explanations, there!!!
FUNCTION wind_chill_formula,Ta,V	; Ta: ambiant [C], V : wind velocity [km/h]
Ta=DOUBLE(Ta)
V=DOUBLE(V)
Twc = 13.112 + 0.6215*Ta -13.37*V^0.16 + 0.3965*Ta*V^0.16
return,Twc
END

FUNCTION wind_chill,T,V
out=fltarr(n_elements(V))
for i=0,n_elements(V)-1 do out(i)=wind_chill_formula(T,V(i))
return,out
END
