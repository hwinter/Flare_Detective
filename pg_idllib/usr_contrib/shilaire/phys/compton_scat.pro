;+
;NAME:
; 	compton_scat.pro
;
;PROJECT:
;	HESSI at ETHZ
;
;CATEGORY:
; 
;PURPOSE:
; For an incident photon of energy epsilon (= h_\nu / mc^2, m is the mass of the scattering particle, most likely an electron),
; and scatter angle theta, computes the scattered photon energy (again in units of mc^2), particle energy (in units of mc^2),
; and the particle's direction (angle phi).
; The scattering particle is supposed initially at rest. 
;
;CALLING SEQUENCE:
;	compton_scat,epsilon_i,theta, epsilon_f, gamma_f, phi_f
;
;INPUT:
;	epsilon		incoming photon energy, in units of mc^2
;	theta: 		outgoing photon angle, in radians
;
;OPTIONAL INPUT:	
;
;OUTPUT:
;	epsilon_f	scattered photon energy, in units of mc^2
;	gamma_f		total particle energy after scattering, in units of mc^2 (= Lorentz factor)
;	phi_f:		outgoing particle direction, in radians
;
; OUTPUT KEYWORDS:
;	beta_f		particle speed (after scattering), in units of c.
;
;	
;EXAMPLES:
;
;	compton_scat, 1., 0., e,g,phi,beta=beta
;	compton_scat, 1., 3*!PI/4, e,g,phi,beta=beta
;	compton_scat, 1., 4*!PI/4, e,g,phi,beta=beta
;	print,e,g,phi,beta
;	0.33333333       1.6666667   2.1855695e-08      0.80000000
;
;HISTORY:
;	Pascal Saint-Hilaire (Saint-Hilaire@astro.phys.ethz.ch), 2003/02/18 written.
;
;-



PRO compton_scat, epsilon_i, theta_f, epsilon_f, gamma_f, phi_f, beta_f=beta_f

	epsilon_f= DOUBLE(epsilon_i)/(1+epsilon_i*(1-cos(theta_f)))
	gamma_f=1D + (1-cos(theta_f))*(epsilon_i^2)/(1D + epsilon_i*(1-cos(theta_f)))
	beta_f=gamma2beta(DOUBLE(gamma_f))
	phi_f=asin(-epsilon_f*sin(DOUBLE(theta_f))/sqrt(gamma_f^2 - 1D))

END
