;	Pascal Saint-Hilaire	2001/10/24
;			psainth@hotmail.com OR shilaire@astro.phys.ethz.ch
;

;------------------------------------------------------------------------------
beta=0.999999D

SolarRadius = 696000.D		; km
DistanceES  = 150000000.D 	; km
T=2000000.D					; K
nu=430.D					; MHz
c=299792.458				; km/s
;------------------------------------------------------------------------------

beta=DOUBLE(beta)

Hn=0.05*T	;km


;------------------------------------------------------------------------------
;ITERATIONS....

delta=FINDGEN(361)*!PI/180.
gamma=delta
;Z is nu_dot_over_nu
Z=DBLARR(361,361)

FOR i=0,360 DO BEGIN
	FOR j=0,360 DO BEGIN
		Z[i,j]=-c*beta*cos(i*!PI/180.)/(2*Hn*(1-beta*cos(j*!PI/180.)))
	ENDFOR
ENDFOR

SURFACE,Z,/UPPER,MIN=2.34,XRANGE=[90,270],YRANGE=[90,270],AX=30,AZ=30

ss=WHERE(Z(90:270,90:270) ge 2.32)
help,ss
find_arrmax,Z(90:270,90:270),pos
print,pos+90
END


