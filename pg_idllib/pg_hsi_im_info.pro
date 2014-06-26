;+
; NAME:
;
; pg_hsi_im_info 
;
; PURPOSE:
;
; prints relevant information for rhessi images from rhessi par structure
;
; CATEGORY:
;
; rhessi imaging util
;
; CALLING SEQUENCE:
;
; pg_hsi_im_info,par_st
;
; INPUTS:
;
; par_st: rhessi parameter structure
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 23-MAR-2004 written PG
;
;-

PRO pg_hsi_im_info,par_st

time_intv=par_st.obs_time_interval
time_range=par_st.time_range
IF time_range[1] NE 0 THEN time_intv=time_intv[0]+time_range

eband=par_st.im_energy_binning

seg=reform(par_st.det_index_mask[*,0:1],18)
alg=par_st.image_algorithm

xyoffset=par_st.xyoffset
pixelsize=par_st.pixel_size
imdim=par_st.image_dim

print,'Time Interval:'+anytim(time_intv,/vms)
print,'Energy Band  : '+strtrim(string(eband[0]),2)+'-' $
                       +strtrim(string(eband[1]),2)+' keV'

print,'Segment used : '+hsi_seg2str(seg)

print,'Algorithm    : '+alg

print,'Center       : '+'('+strtrim(string(xyoffset[0]),2)+'",'+ $
                             strtrim(string(xyoffset[1]),2)+'")'

print,'Pixel size   : '+'('+strtrim(string(pixelsize[0]),2)+','+ $
                            strtrim(string(pixelsize[1]),2)+')'

print,'Dimensions   : '+'('+strtrim(string(imdim[0]),2)+','+ $
                            strtrim(string(imdim[1]),2)+')'


END
