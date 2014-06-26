;+
; NAME:
;       hsi_imageserie_info
;
; PURPOSE: 
;       print some info about an image
;
; CALLING SEQUENCE:
;       hsi_imageserie_plot,filename
;
; INPUTS:
;        filename: name of the fits file
;
; OUTPUT:
; 
;
; HISTORY:
;       24-JAN-2002 written
;
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

PRO hsi_imageserie_info,filename

data=mrdfits(filename,1,header)

print,'Image center : ('+strtrim(data.xyoffset[0],2)+ $
                 ','+strtrim(data.xyoffset[1],2)+')'

print,'Pixel size   : ('+strtrim(data.pixel_size[0],2)+ $
                 ','+strtrim(data.pixel_size[1],2)+')'

print,'Energy band  : ',strtrim(data.energy_band[0],2), $
                 ' - ',strtrim(data.energy_band[1],2),' keV'

print,'Segments used: '+hsi_seg2str([data.det_index_mask[*,0],data.det_index_mask[*,1]])

print,'Time interval: '+anytim(data.time_range[0],/yohkoh)+' / '+ $
                        anytim(data.time_range[1],/yohkoh)

END

