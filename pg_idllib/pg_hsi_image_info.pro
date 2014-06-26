;+
; NAME:
;
; pg_hsi_image_info 
;
; PURPOSE:
;
; prints relevant information of rhessi image FITS files
;
; CATEGORY:
;
; rhessi spectral analysis util
;
; CALLING SEQUENCE:
;
; pg_hsi_image_info,imfile
;
; INPUTS:
;
; imfile: rhessi image FITS file
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
; 16-SEP-2004 written,based on pg_hsi_sp_info PG
;
;-

PRO pg_hsi_image_info,imfile

;data0=mrdfits(imfile,0,silent=0)
data=mrdfits(imfile,1,/silent)

time_intv=data.absolute_time_range
segment=[data.det_index_mask[*,0],data.det_index_mask[*,1]]
eb=data.im_energy_binning

pixsize=data.pixel_size
imdim=data.image_dim

imalg=data.image_algorithm

print,'Image algorithm: '+imalg

print,'Time Range    :'+anytim(time_intv[0],/vms)+' /'+anytim(time_intv[1],/vms)
print,'Duration:'+string(time_intv[1]-time_intv[0])+' s'

print,'Segment used  : '+hsi_seg2str(segment)

print,'Pixel size :('+strtrim(string(pixsize[0],format='(f6.2)'),2)+'",' $
     +strtrim(string(pixsize[1],format='(f6.2)'),2)+'")'

print,'Image dimension : '+strtrim(string(imdim[0]),2) $
     +' by '+strtrim(string(imdim[1]),2)+' pixels'

;print,'Position used : ('+strtrim(string(data3.used_xyoffset[0]),2)+'",' $
;      +strtrim(string(data3.used_xyoffset[1]),2)+'")'

;print,'Pileup correction was '+ppar+'abled with a threshold of ' $
;      +strtrim(string(round(100*data3.pileup_threshold)),2)+'%'

print,'Energy bands  : '
print,eb

END



