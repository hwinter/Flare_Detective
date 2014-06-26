;+
; NAME:
;
;    pg_aia_getmeshinfo
;
; PURPOSE:
;
;    returns the measured angles of the AIA PSF pattern and
;    as mesh information as a function of wavelength
;
; CATEGORY:
;
;    AIA calibration
;
; CALLING SEQUENCE:
;
;    meshinfo=pg_aia_getmeshinfo(wavelength)
;
; INPUTS:
; 
;    wavelength: a string with the wavelength, one of '94','131','171','193','211','304','335'
;
; OPTIONAL INPUTS:
;
;    none
;
; KEYWORD PARAMETERS:
;
;    none
;
; OUTPUTS:
;
;    a structure with following tags
;      CHANNEL:    channel name
;      IMAGE:      image thatw as used to perform the measurements
;      REFIMAGE:   background image
;      SOLARNORTH: up or down, in the image
;      ANGLE1:     first angle
;      DELTA1:     error in first angle
;      ANGLE2:     etc.
;      DELTA2:
;      ANGLE3:
;      DELTA3:
;      ANGLE4:
;      DELTA4:
;      SPACING:    distance between diffraction spikes (from entrance filter)
;      DSPACING:   delta spacing
;      MESHPITCH:  pitch of the mesh in micrometers
;      MESHWIDTH:  width of the mesh in micrometers
;      FP_SPACING: distance between diffraction spikes (from focal plane filters)
;
;
; OPTIONAL OUTPUTS:
;
;    none
;
; COMMON BLOCKS:
;
;    none
;
; SIDE EFFECTS:
;
;    none
;
; RESTRICTIONS:
;
;    none
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
; written 2010/06/16 Paolo Grigis
; 2011/07/13 updated fp_spacing fields
;
;-

FUNCTION pg_aia_getmeshinfo,wavelength

meshangle     ={channel:'', $
                image:'',$
                refimage:'', $
                solarnorth:'', $
                angle1:0.0, $
                delta1:0.0, $
                angle2:0.0, $
                delta2:0.0, $
                angle3:0.0, $
                delta3:0.0, $
                angle4:0.0, $
                delta4:0.0, $
                spacing:0.0,$
                dspacing:0.0, $
                meshpitch:0.0, $
                meshwidth:0.0, $
                fp_spacing:0.0}


CASE wavelength OF 

   '211': BEGIN 

      meshangle.channel='211'
      meshangle.image='AIA20101016_191038_0211.fits'
      meshangle.refimage='AIA20101016_190902_0211.fits'
      meshangle.angle1=49.78
      meshangle.delta1=0.02
      meshangle.angle2=40.08
      meshangle.delta2=0.02
      meshangle.angle3=-40.34
      meshangle.delta3=0.02
      meshangle.angle4=-49.95
      meshangle.delta4=0.02
      meshangle.spacing=19.97
      meshangle.dspacing=0.09
      meshangle.solarnorth='UP'
      meshangle.meshpitch=363.0
      meshangle.meshwidth=34.0
      meshangle.fp_spacing=0.465
     

   END 


   '171': BEGIN 

      meshangle.channel='171'
      meshangle.image='AIA20101016_191037_0171.fits'
      meshangle.refimage='AIA20101016_190901_0171.fits'
      meshangle.angle1=49.81
      meshangle.delta1=0.02
      meshangle.angle2=39.57
      meshangle.delta2=0.02
      meshangle.angle3=-40.13
      meshangle.delta3=0.02
      meshangle.angle4=-50.38
      meshangle.delta4=0.02
      meshangle.spacing=16.26
      meshangle.dspacing=0.10
      meshangle.solarnorth='UP'
      meshangle.meshpitch=363.0
      meshangle.meshwidth=34.0
      meshangle.fp_spacing=0.377

   END 


   '193' : BEGIN 
      
      meshangle.channel='193'
      meshangle.image='AIA20101016_191056_0193.fits'
      meshangle.refimage='AIA20101016_190844_0193.fits'
      meshangle.angle1=49.82
      meshangle.delta1=0.02
      meshangle.angle2=39.57
      meshangle.delta2=0.02
      meshangle.angle3=-40.12
      meshangle.delta3=0.03
      meshangle.angle4=-50.37
      meshangle.delta4=0.04
      meshangle.spacing=18.39
      meshangle.dspacing=0.20
      meshangle.solarnorth='UP'
      meshangle.meshpitch=363.0
      meshangle.meshwidth=34.0
      meshangle.fp_spacing=0.425


   END 

   '335' : BEGIN 
      
      meshangle.channel='335'
      meshangle.image='AIA20101016_191041_0335.fits'
      meshangle.refimage='AIA20101016_190905_0335.fits'
      meshangle.angle1=50.40
      meshangle.delta1=0.02
      meshangle.angle2=39.80
      meshangle.delta2=0.02
      meshangle.angle3=-39.64
      meshangle.delta3=0.02
      meshangle.angle4=-50.25
      meshangle.delta4=0.02
      meshangle.spacing=31.83
      meshangle.dspacing=0.07
      meshangle.solarnorth='UP'
      meshangle.meshpitch=363.0
      meshangle.meshwidth=34.0
      meshangle.fp_spacing=0.738

     END 

   '304' : BEGIN 
      
      meshangle.channel='304'
      meshangle.image='AIA20101016_191021_0304.fits'
      meshangle.refimage='AIA20101016_190845_0304.fits'
      meshangle.angle1=49.76
      meshangle.delta1=0.02
      meshangle.angle2=40.18
      meshangle.delta2=0.02
      meshangle.angle3=-40.14
      meshangle.delta3=0.02
      meshangle.angle4=-49.90
      meshangle.delta4=0.02
      meshangle.spacing=28.87
      meshangle.dspacing=0.05
      meshangle.solarnorth='UP'
      meshangle.meshpitch=363.0
      meshangle.meshwidth=34.0
      meshangle.fp_spacing=0.670

      END 

    '131' : BEGIN 
      
      meshangle.channel='131'
      meshangle.image='AIA20101016_191035_0131.fits'
      meshangle.refimage='AIA20101016_190911_0131.fits'
      meshangle.angle1=50.27
      meshangle.delta1=0.02
      meshangle.angle2=40.17
      meshangle.delta2=0.02
      meshangle.angle3=-39.70
      meshangle.delta3=0.02
      meshangle.angle4=-49.95
      meshangle.delta4=0.02
      meshangle.spacing=12.37
      meshangle.dspacing=0.16
      meshangle.solarnorth='UP'
      meshangle.meshpitch=363.0
      meshangle.meshwidth=34.0
      meshangle.fp_spacing=0.289

      END 

    '94' : BEGIN 
      
      meshangle.channel='94'
      meshangle.image='AIA20101016_191039_0094.fits'
      meshangle.refimage='AIA20101016_190903_0094.fits'
      meshangle.angle1=49.81
      meshangle.delta1=0.02
      meshangle.angle2=40.16
      meshangle.delta2=0.02
      meshangle.angle3=-40.28
      meshangle.delta3=0.02
      meshangle.angle4=-49.92
      meshangle.delta4=0.02
      meshangle.spacing=8.99
      meshangle.dspacing=0.13
      meshangle.solarnorth='UP'
      meshangle.meshpitch=363.0
      meshangle.meshwidth=34.0
      meshangle.fp_spacing=0.207
     
      END

ENDCASE 

RETURN, meshangle

END 

