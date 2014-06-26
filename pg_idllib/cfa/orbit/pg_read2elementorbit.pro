;+
; NAME:
;
; pg_read2elementorbit
;
; PURPOSE:
;
; reads an 2-line orbital element file into an IDL structure
; The input file should be in the standard NORAD format:
; SDO                     
; 1 36395U 10005A   10064.68174854 -.00000054  00000-0  00000-0 0   267
; 2 36395  28.2366 189.5657 2251583  44.0210  61.5629  1.37211406   412
;
;
; CATEGORY:
;
; file I/O, orbits
;
; CALLING SEQUENCE:
;
; OrbitalElements=pg_read2elementorbit(SatelliteName=SatelliteName,OrbitalElementsFile=OrbitalElementsFile,ErrorMessage=ErrorMessage)
;
; INPUTS:
;
; SatelliteName: satellite designator in orbital elemnets file (e.g. 'SDO')
; OrbitalElementsFile: filen containing the 2-line orbital elements
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
; ErrorMessage: string with error message (empty string '' in case of no error)
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
; Parses the file to extract the 2 lines with the orbiral elements, which are
; then inserted into an IDL structure
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
; 08-MAR-2010 written PG
;
;-

FUNCTION pg_read2elementorbit,OrbitalElementsFile=OrbitalElementsFile $
                             ,SatelliteName=SatelliteNameIn $
                             ,ErrorMessage=ErrorMessage $
                             ,Quiet=Quiet,Line1=Line1,Line2=Line2

ErrorMessage=''
OrbitalElementsFile=fcheck(OrbitalElementsFile,'/home/pgrigis/myidllib/cfa/orbit/orbitalelements.txt')

SatelliteName=strtrim(strupcase(fcheck(SatelliteNameIn,'SDO')),2)


;if no orbotal element file, returns -1
IF file_exist(OrbitalElementsFile) EQ 0 THEN BEGIN 

   ErrorMessage+='File '+OrbitalElementsFile+' not found. Returning.'

   IF NOT keyword_set(Quiet) THEN print,ErrorMessage

   RETURN, -1

ENDIF

;read orbital elements file as string
FileContent=rd_ascii(OrbitalElementsFile)

;looks for the wanted satellite
NumberOfSatellites=n_elements(FileContent)/3
Done=0
i=0

WHILE done EQ 0 && i LT NumberOfSatellites*3 DO BEGIN 
   ThisSatelliteName=strtrim(FileContent[i],2)
   ;print,strtrim(strupcase(ThisSatelliteName))
   IF ThisSatelliteName EQ SatelliteName THEN done=1 ELSE i=i+3
ENDWHILE



;if wanted satellite not found, returns -1
IF done EQ 0 THEN BEGIN 

   ErrorMessage+='No Orbital Elements for satellite '+SatelliteName+' were found. Returning.'

   IF NOT keyword_set(Quiet) THEN print,ErrorMessage

   RETURN, -1

ENDIF 

OrbitalElements={$
               SatelliteName:SatelliteName, $
               Line1:'', $
               Line2:' ',$
               CheckSumLine1:255B, $
               CheckSumLine2:255B, $
               CatalogNumber:-1L, $
               SecurityClassification:' ', $
               InternationalDesignator:'00000AAA',$
               EpochTimeString:'YYDOY.FFFFFFF', $
               EpochTime:0.0d, $
               NDot:0.0d, $
               NDoubleDot:0.0d, $
               BStar:0.0d, $
               EphemerisType:255B, $ 
               ElementSetNumber:-1, $               
               Inclination:0.0d, $
               RightAscensionOfAscendingNode:0.0d, $
               Eccentricity:-1d, $
               ArgumentOfPerigee:0.0d, $ 
               MeanAnomaly:0.0d, $                  
               MeanMotion:0.0d, $
               RevolutionNumber:-1L}


Line1=FileContent[i+1]
Line2=FileContent[i+2]

IF NOT keyword_set(Quiet) THEN BEGIN 
   print,'The orbital elemnts for '+SatelliteName+' are:'
   print,Line1
   print,Line2
ENDIF



;parses line 1
Line1Id=strmid(Line1,0,1)
Line2Id=strmid(Line2,0,1)

IF Line1Id NE '1' || Line2Id NE '2' THEN BEGIN 
   ErrorMessage+='There was a problem reading the orbital elements. Wrong Line ID. Returning.'

   IF NOT keyword_set(Quiet) THEN print,ErrorMessage

   RETURN, -1

ENDIF


;fill up structure
OrbitalElements.Line1=Line1
OrbitalElements.CatalogNumber=long(strmid(Line1,2,5))
OrbitalElements.SecurityClassification=strmid(Line1,7,1)
OrbitalElements.InternationalDesignator=strmid(Line1,9,8)
OrbitalElements.EpochTimeString=strmid(Line1,18,14)
OrbitalElements.NDot=double(strmid(Line1,33,10))
OrbitalElements.NDoubleDot=double(strmid(Line1,44,6)+'E'+strmid(Line1,50,2))
OrbitalElements.BStar=double(strmid(Line1,53,6)+'E'+strmid(Line1,59,2))
OrbitalElements.EphemerisType=byte(fix(strmid(Line1,62,1)))
OrbitalElements.ElementSetNumber=fix(strmid(Line1,64,4))
OrbitalElements.CheckSumLine1=byte(fix(strmid(Line1,68,1)))

OrbitalElements.Line2=Line2
OrbitalElements.Inclination=double(strmid(Line2,8,8))
OrbitalElements.RightAscensionOfAscendingNode=double(strmid(Line2,17,8))
OrbitalElements.Eccentricity=double('0.'+strmid(Line2,26,7))
OrbitalElements.ArgumentOfPerigee=double(strmid(Line2,34,8))
OrbitalElements.MeanAnomaly=double(strmid(Line2,43,8))
OrbitalElements.MeanMotion=double(strmid(Line2,52,11))
OrbitalElements.RevolutionNumber=long(strmid(Line2,63,5))
OrbitalElements.CheckSumLine2=byte(fix(strmid(Line2,68,1)))

;convert Epehemeris Time in anytim format
;%TwoDigitYear=strmid(Line1,18,2)
;%DOY=strmid(Line1,20,3)
;DayFraction=strmid(Line1,23,9)
OneDay=24d *3600d
AnytimFormatTime=yydoy_2_ut(strmid(Line1,18,5))+double(strmid(Line1,23,9))*oneday
OrbitalElements.EpochTime=AnytimFormatTime

RETURN,OrbitalElements

END


