;+
; NAME:
;
;  aia_getdiffspikespar
;
; PURPOSE:
;
;
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
;   aia_getdiffspikespar,meshangle211=meshangle211
;
; INPUTS:
;
;
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
; MODIFICATION HISTORY:
;
;-

PRO aia_getdiffspikespar,meshangle211=meshangle211


meshangle_temp={channel:'', $
                image:'',$
                refimage:'', $
                solarnorth:'', $;up or down, in the image
                angle1:0.0, $
                delta1:0.0, $
                angle2:0.0, $
                delta2:0.0, $
                angle3:0.0, $
                delta3:0.0, $
                angle4:0.0, $
                delta4:0.0, $
                spacing:0.0,$
                dspacing:0.0}



;channel: 211

meshangle211=meshangle_temp
meshangle211.channel='211'
meshangle211.image='AIA20101016_191038_0211.fits'
meshangle211.refimage='AIA20101016_190902_0211.fits'
meshangle211.angle1=49.78
meshangle211.delta1=0.02 
meshangle211.angle2=40.08
meshangle211.delta2=0.02 
meshangle211.angle3=-40.34
meshangle211.delta3=0.02 
meshangle211.angle4=-49.95
meshangle211.delta4=0.02 
meshangle211.spacing=19.97
meshangle211.dspacing=0.09
meshangle211.solarnorth='UP'


END

