;+
; NAME:
;
; aia_vsoquery2filepath
;
; PURPOSE:
;
; convert a VSO query array into an array of filenames of FITS files
; corresponding to the VSO query results in a local archive. Assumes
; the standard naming & path convention for convention AIA
; [rootpath]/YYYY/MM/DD/HXXXX/AIAYYYYMMDD_HHMMSS_CCCC.fits
; where CCCC is the channel identifier
;
; CATEGORY:
;
; AIA & VSO utilities
;
; CALLING SEQUENCE:
;
; fileList=aia_vsoquery2filepath(VSOQueryResult,
;                                [NumberOfMissingFiles=NumberOfMissingFiles,
;                                FullFileList=FullFileList,
;                                ErrorStatus=ErrorStatus,
;                                PathRoot=PathRoot])
;
; INPUTS:
;
; VSOQueryResult: the result from a vso_search command
;
; OPTIONAL INPUTS:
;
; PathRooot: root of the path into which to look for files. Defaults to 'data/SDO/AIA/level1/'
;
; KEYWORD PARAMETERS:
;
; None
;
; OUTPUTS:
;
; fileList: list of FITS files (existing locally)
;
; OPTIONAL OUTPUTS:
;
; NumberOfMissingFiles: Number of files in the VSO query missing from the local
;                       archive. O means that the local archive has all the
;                       files the VSO query returned information about.
;
; FullFileList: List of all the filenames constructed from the VSO query result.
;               Will contain NumberOfMissingFiles more elements then fileList
; ErrorStatus: 0 means success, 1 means an error occurred, 2 means no files found
;
; COMMON BLOCKS:
;
; None
;
; SIDE EFFECTS:
;
; None
;
; RESTRICTIONS:
;
; None known
;
; PROCEDURE:
;
; create strings from the structure channels and times, then checks for file existence
;
; EXAMPLE:
;
; ;build VSO query
; time_intv=['21-JUN-2010 18:20','21-JUN-2010 18:30'] 
; vso_query_result=vso_search(time_intv[0],time_intv[1],instrument='aia',wave=94,/url)
; AIAFiles=aia_vsoquery2filepath(vso_query_result)
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
; 29-JUN-2010 written PG
;
;-

FUNCTION  aia_vsoquery2filepath,VSOQueryResult, $
                                NumberOfMissingFiles=NumberOfMissingFiles, $
                                FullFileList=FullFileList, $
                                ErrorStatus=ErrorStatus, $
                                PathRoot=PathRoot

ErrorStatus=1

;check input - only VSO query results allowed
IF size(VSOQueryResult,/sname) NE 'VSORECORD' THEN BEGIN 
   print,'Invalid Input!'
   RETURN, '' 
ENDIF 

;this is the base of the path structure
PathRooot=fcheck('/data/SDO/AIA/level1/')

;path separator (OS dpendent)
ps=path_sep()

;number of images found in query
NumberOfImages=n_elements(VSOQueryResult)

;list of filenames
FullFileList=strarr(NumberOfImages)

FOR i=0,NumberOfImages-1 DO BEGIN
   ;convert image time to external representation (hour,min,sec,msec,day,month,year)
   ImageTime=anytim(VSOQueryResult[i].time._end,/external)

   ;transform time into useful format
   year =string(ImageTime[6],format='(I04)')
   month=string(ImageTime[5],format='(I02)')
   day  =string(ImageTime[4],format='(I02)')
   hour =string(ImageTime[0],format='(I02)')
   min  =string(ImageTime[1],format='(I02)')
   sec  =string(ImageTime[2],format='(I02)')

   ;get image channel
   channel=string(round(VSOQueryResult[i].wave.min),format='(I04)')

   ;build filename
   ImageFile=PathRooot+ps+year+ps+month+ps+day+ps+'H'+hour+'00'+ps+'AIA'+year+month+day+'_'+hour+min+sec+'_'+channel+'.fits'
  
   ;store result in full list
   FullFileList[i]=ImageFile
 
ENDFOR 

ind=where(file_exist(FullFileList) EQ 1,CountValidFiles)

IF CountValidFiles EQ 0 THEN BEGIN 
   ErrorStatus=1
   print,'No files found!'
   NumberOfMissingFiles=NumberOfImages
   return,''
ENDIF

FileList=FullFileList[ind]
NumberOfMissingFiles=NumberOfImages-CountValidFiles

ErrorStatus=0

return,FileList

END 

