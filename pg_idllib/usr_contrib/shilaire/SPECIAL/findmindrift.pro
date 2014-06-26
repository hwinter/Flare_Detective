;	Pascal Saint-Hilaire	2001/10/24
;			psainth@hotmail.com OR shilaire@astro.phys.ethz.ch
;

;------------------------------------------------------------------------------
SolarRadius = 696000.D		; km
DistanceES  = 150000000.D 	; km
T=2000000.D					; K
nu=430.D					; MHz
c=299792.458				; km/s
;------------------------------------------------------------------------------

Hn=0.05*T	;km

;------------------------------------------------------------------------------
;ITERATIONS....

Ndelta=36
Ngamma=36
Nbeta=100

;Z is nu_dot_over_nu
Z=DBLARR(Ndelta,Ngamma,Nbeta)

FOR i=0,Ndelta-1 DO BEGIN
	FOR j=0,Ngamma-1 DO BEGIN
		FOR k=0,Nbeta-1 DO BEGIN
			beta=DOUBLE(k)/Nbeta
			Z[i,j,k]=-c/(2*Hn)*beta*cos(i*360./Ndelta*!PI/180.)/(1-beta*cos(j*360./Ngamma*!PI/180.))
		ENDFOR
	ENDFOR
ENDFOR

print,min(Z(0:Ndelta/4,0:Ngamma/4,*))
pos=max3d(-Z(0:Ndelta/4,0:Ngamma/4,*))
pos(0)=pos(0)
pos(1)=pos(1)
print,pos
END


