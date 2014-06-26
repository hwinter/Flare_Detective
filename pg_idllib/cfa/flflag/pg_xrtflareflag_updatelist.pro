;+
; NAME:
;
; pg_xrtflareflag_updatelist.pro
;
; PURPOSE:
;
; Updates the RT flare flag list
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
; AUTHOR:
;
; Paolo Grigis
; pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 12-FEB-2008 written PG
; 02-MAR-2010 now also writes if XRT actually *responded* to the flare flag PG
;-

PRO pg_xrtflareflag_updatelist,TimeInterval=TimeInterval,FlareFlagList=FlareFlagList

TimeInterval=fcheck(TimeInterval,['05-FEB-2010 0:00','12-FEB-2010 00:00'])
FlareFlagList=fcheck(FlareFlagList,'~/FlareFlagList.txt')
 
header=['# This is the XRT flare triggers list', $
           '# Please report problems with this list to xrt_manager at head.cfa.harvard.edu', $
           '# Last updated at '+!stime+' EST',$
           '#',$
           '#  FLARE FLAG START    FLARE FLAG END       XRT RESPONDED', $
           '# -------------------------------------------------------', $
           '#']

YesNoArray=['NO ','YES ','N/A']

FlareFlagTimes=round(pg_getxrtflareflagtimes(TimeInterval=TimeInterval,XRTResponse=XRTResponse))

IF n_elements(FlareFlagTimes) LE 1 THEN BEGIN

   oldFlareFlagTimes=pg_xrtflareflag_readlist(FlareFlagList,XRTResponse=OldXRTResponse)

   IF n_elements(oldFlareFlagTimes) LE 1 THEN BEGIN 
      wrt_ascii,header,FlareFlagList
   ENDIF $
   ELSE BEGIN 

      ind=where(OldXRTResponse EQ -1,count)
      IF count GT 0 THEN OldXRTResponse[ind]=2

      allstarttimes=oldFlareFlagTimes[*,0] 
      allendtimes=oldFlareFlagTimes[*,1]
      allResponseStatuses=OldXRTResponse
   
      data=anytim(allstarttimes,/ccsds,/trunc)+'   '+anytim(allendtimes,/ccsds,/trunc)+'   '+YesNoArray[allResponseStatuses]

      wrt_ascii,[header,data],FlareFlagList
   ENDELSE 
   
   RETURN 

ENDIF



ind=where(XRTResponse EQ -1,count)
IF count GT 0 THEN XRTResponse[ind]=2

IF file_exist(FlareFlagList) EQ 0 THEN BEGIN 

   ;need to write a new flare list

   data=anytim(FlareFlagTimes[*,0],/ccsds,/trunc)+'   '+anytim(FlareFlagTimes[*,1],/ccsds,/trunc)+'   '+YesNoArray[XRTResponse]


ENDIF $
ELSE BEGIN 
   oldFlareFlagTimes=pg_xrtflareflag_readlist(FlareFlagList,XRTResponse=OldXRTResponse)
   
   IF n_elements(oldFlareFlagTimes) LE 1 THEN BEGIN 
      allstarttimes=FlareFlagTimes[*,0]
      allendtimes=FlareFlagTimes[*,1]
      allResponseStatuses=XRTResponse

      data=anytim(allstarttimes,/ccsds,/trunc)+'   '+anytim(allendtimes,/ccsds,/trunc)+'   '+YesNoArray[allResponseStatuses]

      wrt_ascii,[header,data],FlareFlagList
      RETURN 
   ENDIF

;   IF n_elements(OldXRTResponse) GE 1 THEN BEGIN 
      ind=where(OldXRTResponse EQ -1,count)
      IF count GT 0 THEN OldXRTResponse[ind]=2
;   ENDIF 

   addindex=-1
   FOR i=0,n_elements(FlareFlagTimes)/2-1 DO BEGIN 
      ind=where(abs(oldFlareFlagTimes[*,0]-FlareFlagTimes[i,0]) LT 1.5,count)
      IF count EQ 0 THEN addindex=[addindex,i]
   ENDFOR
   IF n_elements(addindex) GT 1 THEN BEGIN 
      addindex=addindex[1:*]
      allstarttimes=[oldFlareFlagTimes[*,0],FlareFlagTimes[addindex,0]]
      allendtimes=[oldFlareFlagTimes[*,1],FlareFlagTimes[addindex,1]]
      timeSortIndex=sort(allstarttimes)
      allstarttimes=allstarttimes[timeSortIndex]
      allendtimes=allendtimes[sort(allendtimes)]

      allResponseStatuses=[OldXRTResponse,XRTResponse[addindex]]
      allResponseStatuses=allResponseStatuses[timeSortIndex]

   ENDIF $
   ELSE BEGIN
      allstarttimes=oldFlareFlagTimes[*,0] 
      allendtimes=oldFlareFlagTimes[*,1]
      allResponseStatuses=OldXRTResponse
   ENDELSE 


   data=anytim(allstarttimes,/ccsds,/trunc)+'   '+anytim(allendtimes,/ccsds,/trunc)+'   '+YesNoArray[allResponseStatuses]


ENDELSE 

wrt_ascii,[header,data],FlareFlagList


END


