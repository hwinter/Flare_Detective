PRO approx_clean_beam,det_index_mask,taperpsf=taperpsf,$
     clean_beam=clean_beam,fwhm_beam=fwhm_beam,silent=silent

if not keyword_set(taperpsf) then taperpsf = [1,1,1,1,1,1,1,1,1]
wi=[0.44203603,0.25473261,0.14734535,0.084910877,0.049115110,0.028357029, 0.016371707,0.0094523448,0.0054572406]
;wi=o->get( /SPATIAL_FREQUENCY_WEIGHT,class_name='hsi_bproj'  ) 
wi=wi*det_index_mask(0:8)*taperpsf
w=total(wi)
ri=(hsi_grid_parameters()).pitch/2.
s=total(wi/(ri^2))

sigma_clean_beam=0.45*sqrt(w/s)
if not keyword_set(silent) then begin 
  print,'2*sigma:'
  print,2*sigma_clean_beam
  print,'FWHM:'
  print,sqrt(2.*alog(2.))*2*sigma_clean_beam
endif

clean_beam=2*sigma_clean_beam
fwhm_beam=sqrt(2.*alog(2.))*2*sigma_clean_beam

END