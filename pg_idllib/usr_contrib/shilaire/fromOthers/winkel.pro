pro winkel,time,phi_burst,theta_burst,grad=grad

; time in 'dd-mmm-yyy hh:mm'
; phi_burst   : RA of burst in degree
; theta_burst : Dec. of burst in degree

; get solar ephemeris
t0=anytim(time)
ee=hsi_ras_rdeph(t0+findgen(5)*3600.*24.,/deg)

; RA(sun)
phi_sonne=ee[0,0]
theta_sonne=ee[0,1]
print,''
print,' RA Sonne : ', phi_sonne mod 360.
print,'Dec Sonne : ', theta_sonne
print,' '

ths=theta_sonne*!pi/180.
phs=phi_sonne*!pi/180.


if keyword_set(grad) then begin
; Umrechnung von Grad in Radians
   thb=theta_burst*!pi/180.
   phb=phi_burst*!pi/180.
endif else begin
   phb=(phi_burst[0]+(phi_burst[1]+phi_burst[2]/60.)/60.)/12.*!pi
   thb=(theta_burst[0]+(theta_burst[1]+theta_burst[2]/60.)/60.)/180.*!pi
endelse
print,'R.A._GRB =',phb/!pi*180.
print,'Dec._GRB =',thb/!pi*180.
print,' '


; Berechnung des Winkels

thsum=ths+thb
thdiff=ths-thb
phdiff=phs-phb

cosa=(cos(thsum)*(cos(phdiff)-1)+cos(thdiff)*(cos(phdiff)+1))*0.5


; Winkel printen

print,'Angle (theta) between HESSI axis and burst : '
print, acos(cosa)/!pi*180, ' degrees'
print,' '
      
end
