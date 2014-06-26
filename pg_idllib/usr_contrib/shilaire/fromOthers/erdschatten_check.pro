  pro erdschatten_check,time,RA,Dec

;if not keyword_set(time) then begin
;      phi_hsi=-46.3514
;      theta_hsi=35.9833
;      r_hessi=6946.44
;endif

phi_burst=RA
theta_burst=Dec

;if keyword_set(time ) then begin
   ort=rhessi_ephem(time)
   r_hessi=ort[0]
   phi_hsi=ort[1]
   theta_hsi=ort[2]
   print,' '
   print,'RA_hsi  =  ', phi_hsi
   print,'Dec_hsi =  ', theta_hsi
   print,'r_hsi   =  ', r_hessi
   print,' '
;endif
; else begin
;   theta_hsi=0.0
;   phi_hsi=0.0
;   print,' '
;   print,' RA_hsi  = ? '
;   read,phi_hsi
;   print,' Dec_hsi = ? '
;   read,theta_hsi
;   print,' '
;   r_hessi=6378.+585.
;endelse


; Winkel zwischen Burst und HESSI berechnen, vom Erdmittelpunkt aus
; gesehen.
; 0 Grad < Winkel < 180 Grad
; Winkel=0 ist gleiche Richtung wie HESSI

thh=theta_hsi*!pi/180.
thb=theta_burst*!pi/180.
phh=phi_hsi*!pi/180.
phb=phi_burst*!pi/180.
thsum=thh+thb
thdiff=thh-thb
phdiff=phh-phb

cosa=(cos(thsum)*(cos(phdiff)-1)+cos(thdiff)*(cos(phdiff)+1))*0.5
winkel=acos(cosa)/!pi*180.

print,' '
print,' Winkel (in Grad)     = ',winkel
print,' (zwischen HESSI - Erdmittelbunkt - Burst)
print,' '

; Maximaler Winkel, der noch sichtbar ist :
; (Man erwartet, maxink etwas groesser als 90 Grad.)
maxwink1=180.-asin( 6356.7/r_hessi )/!pi*180.
print,' max. Blickwinkel (in Grad)= ',maxwink1
maxwink2=180.-asin( 6378.3/r_hessi )/!pi*180.
;maxwink2=180.-asin( 6400./r_hessi )/!pi*180.
print,' max. Blickwinkel (in Grad)= ',maxwink2
print,' '

if maxwink1 gt maxwink2 then maxwink=maxwink1 else maxwink=maxwink2

; Checken, ob sichtbar oder nicht
if (winkel ge maxwink) then print,' Nicht sichtbar !'

end
