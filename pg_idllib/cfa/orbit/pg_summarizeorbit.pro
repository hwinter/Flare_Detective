;+
; NAME:
;
; pg_summarizeorbit
;
; PURPOSE:
;
; prints on the screen a summary of the orbit of a satellite, given
; the orbital elements in an IDL structure (such as the one returned
; by the pg_read2elementorbit function)
;
;
; CATEGORY:
;
; orbits
;
; CALLING SEQUENCE:
;
; pg_summarizeorbit,OrbitalElements
;
; INPUTS:
;
; OrbitalElements: IDL structure with the orbital elements (such as the one returned
;                  by the pg_read2elementorbit function)
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
; Paolo Grigis
; pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 09-MAR-2010 written PG
;
;-

PRO pg_summarizeorbit,OrbitalElements


period=24d/OrbitalElements.MeanMotion
hourperiod=floor(period)
minutesperiod=(period-hourperiod)*60
secondsperiod=minutesperiod-floor(minutesperiod)
minutesperiod=floor(minutesperiod)

;compute axis length (approximatively)
mu=398600.442;km^3 s^-2 earth grav parameter
SemiMajorAxisLength=(mu*(period*3600.d)^2/(4*!Dpi^2))^(1d/3d)
ecc=OrbitalElements.Eccentricity
SemiMinorAxisLength=SemiMajorAxisLength*sqrt(1d -ecc^2)
EarthRadius=6371
FocusDistance=sqrt(SemiMajorAxisLength^2-SemiMinorAxisLength^2)

print,' *** Orbital data for Satellite '+OrbitalElements.SatelliteName+' *** '
print,' The orbital elements are for '+anytim(OrbitalElements.EpochTime,/vms)
print,' The inclination is '+string(OrbitalElements.Inclination,format='(d8.4)')+' degrees'
print,' The orbital period is '+string(round(hourperiod),format='(I02)')+'H '+string(round(minutesperiod),format='(I02)')+'M '+string(round(secondsperiod),format='(I02)')+'S'
print,' The height of the  apogee is '+strtrim(round(SemiMajorAxisLength-EarthRadius+FocusDistance),2)+' km above the surface '
print,' The height of the perigee is '+strtrim(round(SemiMinorAxisLength-EarthRadius-FocusDistance),2)+' km above the surface '
print,' The eccentricty is '+strtrim(ecc,2)
print,' The RAAN is '+strtrim(OrbitalElements.RightAscensionOfAscendingNode,2)

;OrbitalElements={$
;               Line1:'', $
;               Line2:' ',$
;               CheckSumLine1:255B, $
;               CheckSumLine2:255B, $
;               CatalogNumber:-1L, $
;               SecurityClassification:' ', $
;               InternationalDesignator:'00000AAA',$
;               EpochTimeString:'YYDOY.FFFFFFF', $
;               EpochTime:0.0d, $
;               NDot:0.0d, $
;               NDoubleDot:0.0d, $
;               BStar:0.0d, $
;               EphemerisType:255B, $ 
;               ElementSetNumber:-1, $               
;               Inclination:0.0d, $
;               RightAscensionOfAscendingNode:0.0d, $
;               Eccentricity:-1d, $
;               ArgumentOfPerigee:0.0d, $ 
;               MeanAnomaly:0.0d, $                  
;               MeanMotion:0.0d, $
;               RevolutionNumber:-1L}


END


