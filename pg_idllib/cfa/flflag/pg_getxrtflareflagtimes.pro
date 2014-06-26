;+
; NAME:
;
;  pg_getxrtflareflagtimes
;
; PURPOSE:
;
; retrieves the times when the XRT flare flag was set in the input time interval
;
; CATEGORY:
;
; XRT housekeeping stuff
;
; CALLING SEQUENCE:
;
; data=pg_getxrtflareflagtimes(TimeInterval=TimeInterval)
;
; INPUTS:
;
; TimeInterval: 2-elements areay with desired time interval
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
; XRTReponse: an array of 0s and 1s. 0 means XRT DID NOT respond to the flare
;             flag, 1 means XRT DID respond.
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
; AUTHOR
;
; Paolo Grigis
; pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 12-FEB-2010 written PG
; 02-MAR-2010 added XRTResponse output PG
; 
;-


FUNCTION pg_getxrtflareflagtimes,TimeInterval=TimeInterval,XRTResponse=XRTResponse

TimeInterval=fcheck(TimeInterval,['05-FEB-2010 0:00','12-FEB-2010 00:00'])


hkdata=xrt_get_hk_value(['PACKET_EDITION_TIME','MDP_XRT_FLD_FLG','MDP_XRT_OBS_MODE'],TimeInterval[0],TimeInterval[1])

IF size(hkdata,/tname) NE 'STRUCT' THEN BEGIN 
   RETURN,-1
ENDIF

time=hkdata[0].value+anytim('01-JAN-2000')
val=hkdata[1].value

ind=where(val EQ 1,countflags)

IF countflags EQ 0 THEN BEGIN 
   RETURN,-1
ENDIF

valshifted=shift(val,-1)
;wrap around properly
valshifted[n_elements(val)-1]=val[n_elements(val)-1]

FLstartIndices=where(val EQ 0 and valshifted EQ 1)
FLendIndices=where(val EQ 1 and valshifted EQ 0)

IF FLstartIndices[0] EQ -1 || FLendIndices[0] EQ -1 THEN BEGIN 
   RETURN,-1
ENDIF

IF FLendIndices[0] LT FLstartIndices[0] THEN FLendIndices=FLendIndices[1:*]

nStartFlares=n_elements(FLstartIndices)
nEndFlares=n_elements(FLendIndices)

IF nStartFlares GT nEndFlares THEN FLstartIndices=FLstartIndices[0:nEndFlares-1]

XRTResponse=intarr(nEndFlares)
XRTResponse=round((hkdata[2].value)[(FLStartIndices+1)<n_elements(hkdata[2].value)])
ind=where(XRTResponse LT 0 OR XRTResponse GT 1,count)
IF count GT 0 THEN XRTResponse[ind]=-1

RETURN,[[time[FLstartIndices]],[time[FLendIndices]]]


END


