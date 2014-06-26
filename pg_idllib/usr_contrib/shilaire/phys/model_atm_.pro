;made by Gunnar Paesold
; modified 2000/12/14 by Pascal Saint-Hilaire : 
;	added the 'form' optional input: 
;		possible plots are density (form=0),
;			electron plasma frequency (form=1)
;					wavelength (form=2)
;	added the 'range' optional input


PRO model_atm_,form=form,range=range

if not exist(range) then range=[1.,2.]
if not exist(form) then form=0

m=9.10939e-28		; electron mass in g
e=4.803206e-10		;elementary charge in esu
c=299792458.		;speed of light, in m/s

DEFSYSV, '!SOL_RAD',6.96e10           ; in cm
!P.POSITION = 0
t3d,/RESET

n_0  = 1.50000e+08                     ; in 1/cm^3
h_0  = 1.00000e+10                     ; in cm
temp = 1.5e6                           ; in K
H_n  = 5.00e3*temp                     ; in cm

h   = FINDGEN(1000)*1.e9+1.e8
h_2 = FINDGEN(1000)/60.
n_1 = n_0*exp(-(h-h_0)/H_n)

n_2 = 1.55e8*(h_2)^(-6.)*(1+1.93*(h_2)^(-10.))

h_3 = h+!SOL_RAD

n_4 = n_0*exp(-(h_3-(h_0+!SOL_RAD))/H_n)

n_5 = n_0*(h_3/(h_0+!SOL_RAD))^(-2./7.)*exp(-7./5.*(h_0+!SOL_RAD)/H_n*$
      (1-(h_3/(h_0+!SOL_RAD))^(-5./7.)))


nbr_1=n_1
nbr_2=n_2
nbr_5=n_5
ytitle='Density in 1/cm^3'

if form ge 1 then begin 
	nbr_1 = sqrt(4*!pi*e*e*n_1/m)/(2*!pi)
	nbr_2 = sqrt(4*!pi*e*e*n_2/m)/(2*!pi)
	nbr_5 = sqrt(4*!pi*e*e*n_5/m)/(2*!pi)
	ytitle='Plasma frequency in Hz'	
		end
	
if form ge 2 then begin
	nbr_1=c/nbr_1
	nbr_2=c/nbr_2
	nbr_5=c/nbr_5
	ytitle='Plasma wavelength in m'
		end

PLOT,h/!SOL_RAD+1,nbr_1,/YLOG,XTITLE='Distance in solar radii',$
	   YTITLE=ytitle,XRANGE=range,CHARSIZE=1.5

OPLOT,h_2,nbr_2,LINESTYLE=2
OPLOT,h_3/!SOL_RAD,nbr_5,LINESTYLE=4
OPLOT,[1.05,1.1],[2.e4,2.e4]
OPLOT,[1.32,1.37],[2.e4,2.e4],LINESTYLE=2
OPLOT,[1.65,1.7],[2.e4,2.e4],LINESTYLE=4
XYOUTS,1.11,1.8e4,'Exponential'
XYOUTS,1.38,1.8e4,'Baumbach-Allen'
XYOUTS,1.71,1.8e4,'Thermal Conducting'

;OPLOT,h/!SOL_RAD+1,n_3,LINESTYLE=4


END;
