;+
; PROJECT:
;
;    SDO Feature Finding Team
;
; NAME:
;
;    SDCFD_TRIG_UPDATE_FLARELIST
;
; PURPOSE:
;
;    This program add a new line to the flare list (or create a new file
;    if the input file is missing) based on information from a VOEvent structure
;
; CATEGORY:
;
;    SDO FFT - Flare Detective - Trigger
;
; CALLING SEQUENCE:
;
;    sdcfd_trig_update_flarelist,FlareListFileName,FlareVStructList
;
; INPUTS:
; 
;    FlareListFileName: flare list filename
;    FlareVStructList: VOEvent like structure
;
; OPTIONAL INPUTS:
;
;   
; KEYWORD PARAMETERS: 
;
;    verbose: if set, outputs diagnostics
;
;
; OUTPUTS:
;
;    
;
; OPTIONAL OUTPUTS:
;
;    NONE
;
; COMMON BLOCKS:
;
;    NONE
; 
; SIDE EFFECTS:
;
;    NONE
;
; RESTRICTIONS:
;
;    
;
; PROCEDURE:
;
;     Create new file if not present with Header information.
;     Adda line with the flare info.    
;
; EXAMPLE:
;
;    
;
; VERSION CONTROL SYSTEM STRING:
;
;   $Id: sdcfd_trig_update_flarelist.pro 55 2009-07-08 19:56:35Z pgrigis $
;
; AUTHOR:
;
;    Paolo C. Grigis, pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;  
;    07-MAy-2008 written PG
;    23-SEP-2009 added bounding box PG
;    
;-

COMPILE_OPT idl2

PRO sdcfd_trig_update_flarelist,FlareListFileName,FlareVStruct,verbose=verbose

IF NOT file_exist(FlareListFileName) THEN BEGIN 
   ;create HEADER
   
   header=['This is the AIA flare list...', $
           'FLARE ID                START TIME                PEAK TIME                 END TIME                  SOLAR X  SOLAR Y  PEAK FLUX   BBOX LLX BBOX LLY BBOX URX BBOX URY', $
           '------------------------------------------------------------------------------------------------------------------------------------------------------------------------']


   openw,FileUnit,FlareListFileName,/get_lun
   FOR i=0,n_elements(header)-1 DO printf,FileUnit,header[i]
   close,FileUnit
   free_lun,FileUnit
ENDIF 

;stop

FlareEntry=FlareVStruct.FL_ID+'  '+ $
           anytim(FlareVStruct.required.Event_StartTime,/vms)+'  '+ $
           anytim(FlareVStruct.required.Event_PeakTime, /vms)+'  '+ $
           anytim(FlareVStruct.required.Event_EndTime,  /vms)+'   '+ $
           string(round(FlareVStruct.required.Event_Coord1),format='(I5)')+'   '+$
           string(round(FlareVStruct.required.Event_Coord2),format='(I5)')+'   '+$
           string(FlareVStruct.optional.FL_PeakFlux,format='(E10.3)')+'     '+$ 
           string(round(FlareVStruct.required.BoundBox_C1LL),format='(I5)')+'    '+$
           string(round(FlareVStruct.required.BoundBox_C2LL),format='(I5)')+'    '+$
           string(round(FlareVStruct.required.BoundBox_C1UR),format='(I5)')+'    '+$
           string(round(FlareVStruct.required.BoundBox_C2UR),format='(I5)')

openu,FileUnit,FlareListFileName,/get_lun,/append
printf,FileUnit,FlareEntry
close,FileUnit
free_lun,FileUnit


END


