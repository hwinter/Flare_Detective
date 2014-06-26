;============================================================================
;+
; PROJECT:  PSH's PhD studies
;
; NAME:  plot_vel_map.pro
;
; PURPOSE:  does exactly as plot_map, but a velocity map is done.
;
; CALLING SEQUENCE:  plot_vel_map, map1,  _extra=_extra
;
; INPUTS:
;   _extra - any other parameters to be passed into plot_map
;
; OUTPUTS:  Plots image in currently selected window
;
; OPTIONAL OUTPUTS:  None
;
; Calls:
;
; COMMON BLOCKS: None
;
; PROCEDURE:
;
; RESTRICTIONS: None. 
;
; SIDE EFFECTS: None.
;
; EXAMPLES:
;
; HISTORY:
;	Written Pascal Saint-Hilaire, 2002/02/28.
;
; MODIFICATIONS:
;
;-
;============================================================================

pro plot_vel_map, map, _extra=_extra

;hessi_ct
maxval = max(abs(map.data))
drange = [-maxval, maxval]
; make sure plot_map doesn't ever rescale the image when using hessi colors.
; This seems backward, but if rescale_image = 0 then plot_map will use full range of image to scale instead
; of dmin and dmax, so set rescale_image to 1, but pass in dmin,dmax to force it to use dmin,dmax in zoom
if size(_extra,/tname) eq 'STRUCT' then if tag_exist(_extra, 'rescale_image') then _extra.rescale_image=1
;print,'rescale_image = ', _extra.rescale_image

plot_map, map, $
	_EXTRA=_extra, drange=drange
END
