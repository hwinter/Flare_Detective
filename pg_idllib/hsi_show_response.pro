; HSI_SHOW_RESPONSE.PRO
;
; Informal procedure to display key response parameters for a given energy (keV),
;		radial offset (deg) and attenuation state.
;
; 31-oct-02 gh	First version
; 18-Dec-02 gh	Added modampl and gm display
; 19-Dec-02 gh	Renamed from SHOW_GRIDTRAN
;				Added drm display.
;
PRO HSI_SHOW_RESPONSE, energy, radial_offset, atten_state
;
detector_label 		= ['1f', '2f', '3f', '4f', '5f', '6f', '7f', '8f', '9f', $
						'1r', '2r', '3r', '4r', '5r', '6r', '7r', '8r', '9r']
naz 		= 360							; number of azimuth points over which to average
gridtran 	= FLTARR(9)
modampl		= FLTARR(9)
gm			= FLTARR(9)
azimuth 	= FINDGEN(360)
drm			= FLTARR(9,2)
;
energy_edges = energy + [-.1, +.1]
FOR i = 0,8 DO BEGIN
	hessi_grm, energy_edges, i, grm, 0, radial_offset, azimuth
	gridtran[i] = MEAN(grm.gridtran[0,*])
	modampl[i] 	= MEAN(grm.modampl [0,*,0])		; at h=1
	gm[i]		= MEAN(grm.modampl[0,*,0] * grm.gridtran[0,*])
	hessi_drm_4image, drmf, energy_edges, detector_label[i], atten_state, $
					  OFFAX_POSITION=radial_offset
	hessi_drm_4image, drmr, energy_edges, detector_label[i+9], atten_state, $
					  OFFAX_POSITION=radial_offset
	drm[i,0] 	= drmf
	drm[i,1] 	= drmr
ENDFOR
;
PRINT, energy, radial_offset, atten_state, $
	FORMAT='("HSI_SHOW_RESPONSE for", F7.1, " keV", F7.3, " degree offset, atten_state=", I1)' ; , $
PRINT, '      SC#    <GRIDTRAN>  <MODAMPL>     <G*M>    DRMfront     DRMrear'
FOR i=0,8 DO PRINT, i+1, gridtran[i], modampl[i], gm[i], drm[i,*], FORMAT='(I8, 5F12.3)'
END

