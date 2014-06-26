;+
; PROJECT: SPEX
; NAME:   drm_albedo
;
;
; PURPOSE:  To include photospheric albedo into DRM
;
;
; CATEGORY: SPEX, spectral analysis
;
;
; CALLING SEQUENCE:
;
;   drm_albedo,90.,1.,'rapp_idl/shilaire/spex/'
;
;
;
; INPUTS:
;	 theta (degrees) - heliocentric agngle of the flare (default is theta =45 degrees)
;    anisotropy      - a coeficient showing the ratio of the flux in observer direction
;                       to the flux downwards
;                      if anisotropy=1 (default) the source is isotropic
;
; USES precomputed green functions from files green_compton_mu***.dat, where *** is cos(theta)
;
; OUTPUTS:
;	drm	    - detector response matrix per input photon/cm2 in cnts/cm2/keV with albedo
;             correction
;             changes drm in
; SIDE EFFECTS:
;	none
;
; RESTRICTIONS:
;	works only for integer binning of edges and E_in
;
; PROCEDURE:
;	none
;
; MODIFICATION HISTORY:
;	eduard@astro.gla.ac.uk, 5-July-2004
;	PSH 2004/08/04: added datadir entry...

;-

pro drm_albedo,angle,anisotropy, datadir


angle=fcheck(angle,45.)
anisotropy=fcheck(anisotropy,1.)
; the value that mimics anisotropy of the source

mu=cos(angle*!PI/180.)

Print,'Correction for an source at ',acos(mu)*180./!PI,' degrees', '  cos(theta) =',mu

IF ((mu GT 0.05) AND (mu LT 0.95)) THEN BEGIN
print,'reading data from files ..............................................'
file1=datadir+'green_compton_mu'+string(format='(I3.3)',5*FLOOR(mu*20.),/print)+'.dat'
file2=datadir+'green_compton_mu'+string(format='(I3.3)',5*CEIL(mu*20.),/print)+'.dat'
restore,file1
p1=p
restore,file2
p2=p
a=p1.albedo+(p2.albedo-p1.albedo)*(mu - float(floor(mu*20))/20.)
END ELSE BEGIN

IF (mu LT 0.05) THEN BEGIN
print,'Warning! Assuming heliocentric angle  =',acos(0.05)*180./!PI
file=datadir+'green_compton_mu'+string(format='(I3.3)',5*FLOOR(0.05*20.),/print)+'.dat'
restore,file
a=p.albedo
ENDIF

IF (mu GT 0.95) THEN BEGIN
print,'Warning! Assuming heliocentric angle  =',acos(0.95)*180./!PI
file=datadir+'green_compton_mu'+string(format='(I3.3)',5*FLOOR(0.95*20.),/print)+'.dat'
restore,file
a=p.albedo
ENDIF

ENDELSE

a=transpose(a)


@spex_commons

ph_edges=e_in; edges in photon domain

Nc =N_elements(drm(*,0))
Nph=N_elements(drm(0,*))

Anew=fltarr(Nph,Nph)
; rebinning of green matrix

for i=0, Nph-1 do begin
irange=round([ph_edges(0,i)-3.,ph_edges(1,i)-4.])
for j=i, Nph-1 do begin
jrange=round([ph_edges(0,j)-3.,ph_edges(1,j)-4.])
IF (ph_edges(1,j) LT round(max(p.edges))) AND (ph_edges(1,i) LT round(max(p.edges))) THEN BEGIN
Anew(i,j)=total($
total(A(irange(0):irange(1),jrange(0):jrange(1)),1)$
)/anisotropy/(ph_edges(1,j)-ph_edges(0,j))
;/float(irange(1)-irange(0)+1.
ENDIF
end
end

Anew=transpose(Anew)
one=fltarr(Nph,Nph)
for k=0, Nph-1 do one(k,k)=1.

;inverted albedo correction

e =(ph_edges(0,*)+ph_edges(1,*))/2.
de=transpose(ph_edges(1,*)-ph_edges(0,*))


drm_albedo=one+Anew
drm_old=drm
drm=drm_old#transpose(drm_albedo)

; test albedo correction in count space
;ftest=e^(-2)
;old=drm#(transpose(ftest)*de)
;window,8
;plot_oo,edges(0,*),old
;new=drm#(transpose(ftest)*de)
;oplot,edges(0,*),new,line=1
;new2=drm_old#(transpose(drm_albedo##(ftest*de)))
;oplot,edges(0,*),new2,line=2


print, 'DRM without albedo correction :',min(drm_old),max(drm_old)
print, 'DRM with     albedo correction:',min(drm),max(drm)

print,'Photospheric albedo included into DRM'
print,'SPEX> read_drm to load original DRM'

end