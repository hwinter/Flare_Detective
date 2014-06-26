;+
; NAME:
;
; pg_xrtflareflag_readlist
;
; PURPOSE:
;
; Read the text flare list
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
; AUTHOR:
;
; Paolo Grigis
; pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 12-FEB-2008 written
; 02-MAR-2010 added XRTResponse output PG
;   
;
;-

FUNCTION pg_xrtflareflag_readlist,FlareFlagList,XRTResponse=XRTResponse

FlareFlagList=fcheck(FlareFlagList,'~/FlareFlagList.txt')


IF file_exist(FlareFlagList) EQ 0 THEN RETURN, -1


data=rd_ascii(FlareFlagList)

IF n_elements(data) LE 7 THEN RETURN, -1

time_string=data[7:*]

ind=where(strlen(time_string) GT 0,count)

IF count EQ 0 THEN RETURN, -1

time_string=time_string[ind]

ntimes=n_elements(time_string)

time_out=dblarr(ntimes,2)
XRTResponse=intarr(ntimes)
XRTResponse[*]=-1

FOR i=0,ntimes-1 DO BEGIN
   DataString=strsplit(time_string[i],' ',/extract)
   time_out[i,*]=anytim(DataString[0:1])

   IF n_elements(DataString) GT 2 THEN BEGIN 

      CASE DataString[2] OF 
         'YES' : XRTResponse[i]=1
         'NO'  : XRTResponse[i]=0
         ELSE :  XRTResponse[i]=-1
      ENDCASE 

   ENDIF

ENDFOR
 
return,time_out

END
 
