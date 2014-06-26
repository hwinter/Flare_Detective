;=====================================================================
; From "Astrophysical Formulae" by Kenneth R. Lang, 3rd Ed., Springer
;=====================================================================


; The change in electron kinetic energy due to both GYROsynchroton radiation 
;and to collisions with thermal electrons is given by Takakura, 1967:
;
;	Bfield:  [Gauss]
;	gamma: Lorentz factor of electron
;	Ne	: electron number density [cm^-3]
;	phi : [degrees] pitch angle, i.e. angle between direction of electron motion and direction of B field
;
;	result is d(gamma)/dt, OR (1/mc^2) dE/dt


FUNCTION f4_387,Bfield,gamma,N=N,phi=phi
	IF NOT EXIST(N) THEN N=1e10
	IF NOT EXIST(phi) THEN phi=90
	
	B=DOUBLE(Bfield)
	g=DOUBLE(gamma)
	nelectron=DOUBLE(N)
	pa=DOUBLE(phi)*!PI/180
	
	res=-3.8e-9 * B^2 * sin(phi) * ((g^2)/2 + g)  -  1.5e-16 * nelectron * g^(-1.5)
	RETURN,res
END



; Some comments:
;	- only in B fields of about 10 Gauss are the losses similar for gamma=2 (for Ne = 1e10 cm^-3)
;	- At higher B, gyrosynchroton losses quickly dominate.
;
 
