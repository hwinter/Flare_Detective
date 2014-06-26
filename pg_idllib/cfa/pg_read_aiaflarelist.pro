;+
; NAME:
;
; pg_read_aiaflarelist
;
; PURPOSE:
;
; erads the AIA flare list produced by the flare module
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
;
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

FUNCTION pg_read_aiaflarelist,FlareListFileName


FlareListFileName=fcheck(FlareListFileName,'/home/pgrigis/machd/newflarelist40/flarelist.txt')

IF file_exist(FlareListFileName) EQ 0 THEN BEGIN 
   print,'please input a valid file. Returning.'
   retunr,-1
ENDIF 

data=rd_ascii(FlareListFileName)

nflares=n_elements(data)-3

FlareTemplate= { $
   FlareID:'', $
   StartTime:0.0d, $
   PeakTime:0.0d, $
   EndTime:0.0d, $
   SolarX:0.0, $
   SolarY:0.0, $
   PeakFlux:0.0, $
   BoundBoxLLX:0.0, $
   BoundBoxLLY:0.0, $
   BoundBoxURX:0.0, $
   BoundBoxURY:0.0 $
   }

FlareList=replicate(FlareTemplate,nflares)

FOR i=0,nflares-1 DO BEGIN 
   thisdata=strsplit(data[i+3],' ',/extract)
   FlareList[i].FlareID=thisdata[0]
   FlareList[i].StartTime=anytim(thisdata[1]+' '+thisdata[2])
   FlareList[i].PeakTime =anytim(thisdata[3]+' '+thisdata[4])
   FlareList[i].EndTime  =anytim(thisdata[5]+' '+thisdata[6])
   FlareList[i].SolarX =float(thisdata[7])
   FlareList[i].SolarY =float(thisdata[8])
   FlareList[i].PeakFlux=float(thisdata[9])
   FlareList[i].BoundBoxLLX=float(thisdata[10])
   FlareList[i].BoundBoxLLY=float(thisdata[11])
   FlareList[i].BoundBoxURX=float(thisdata[12])
   FlareList[i].BoundBoxURY=float(thisdata[13])

ENDFOR

return,FlareList

END

