;+
; NAME:
;
; sdcfd_writeXMLfilesfromstring
;
; PURPOSE:
;
; writes XML files of VOEvents from a string with the contents
; of the files - building filenames from the VOEvent information
;
; CATEGORY:
;
; SDO event detection - HPKB - I/O
;
; CALLING SEQUENCE:
;
; sdcfd_writeXMLfilesfromstring,VOEventString,OutputDirectory=OutputDirectory
;
; INPUTS:
;
; VOEventString: string or array of strings with the contents of the VOEvent(s)
; to write to disk
;
; OPTIONAL INPUTS:
;
; OutputDirectory: directory to write files to. If not given, the current dir is
; used instead.
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
;
; MODIFICATION HISTORY:
;
; 10-FEB-2008 written PG
; 11-FEB-2008 modifided filenaming convention for "open" events PG
;-

PRO sdcfd_writexmlfilesfromstring,VOEventString,OutputDirectory=OutputDirectory,error=error

error=''

;check that input is well formed
IF size(VOEventString,/tname) NE 'STRING' THEN BEGIN 
   error+='Invalid VOEventstring. No files written. '
   RETURN 
ENDIF

;sets OutputDirectory to current directory in case of no input
cd,current=CurrentDirectory
OutputDirectory=fcheck(OutputDirectory,CurrentDirectory)

;retrieves path sep - usually '/' or '\'
ps=path_sep()

;check for existence of traget directory
IF file_exist(OutputDirectory) EQ 0 THEN BEGIN
   error+='Invalid Output Directory. '+string(OutputDirectory)+' does not exist. No Files written. '
   RETURN 
ENDIF


;in XML files, the ivorn should be given in a format similar to"
;ivorn="ivo://helio-informatics.org/FL_FlareDetective-Triggermodule_20100210_214655_2001-09-16T00:07:16.569_1"
;therefore the filename starts at character 35 in that string
ivornUrlLength=35

;loops over all VOEvents
FOR i=0,n_elements(VOEventString)-1 DO BEGIN 

   ;one at a time
   thisVOEvent=VOEventString[i]

   ;identifies if event is of the "expires" kind or not
   ;if it is (that is - expiration is set) then
   ;writes it as "open" event
   ExpireStringLocation=strpos(thisVOEvent,'<Why expires=')
   IF ExpireStringLocation EQ -1 THEN $
      AdditionalString='' $
   ELSE $
      AdditionalString='Open'
   

   ;retrieves ivorn string starting character index (first occurrence)
   IvornLocation=strpos(thisVOEvent,'ivorn="ivo://')

   ;if not found, can't use a well formed filename
   IF IvornLocation EQ -1 THEN BEGIN 
      error+=' VOEvent #'+strtrim(i)+' contains no valid IVORN. '
   ENDIF $
   ELSE BEGIN 

      ;extract IvornString - assumes maximum length of Ivorn is 256 characters
      ;result is something like:
      ;ivorn="ivo://helio-informatics.org/FL_FlareDetective-Triggermodule_20100210_214655_2001-09-16T00:07:16.569_1"
      IvornString=(strsplit(strmid(thisVOEvent,IvornLocation,IvornLocation+256),/extract))[0]
      
      ;retrieve filename from ivorn (skipping the **ivorn="ivo://helio-informatics.org/**)
      ; and the **"** at the end
      IvornStringStripped=strmid(IvornString,ivornUrlLength,strlen(IvornString)-ivornUrlLength-1)

      ;build filename
      filename=OutputDirectory+ps+IvornStringStripped+AdditionalString+'.xml'
  
      ;writes file
      wrt_ascii,thisVOEvent,filename

   ENDELSE 

ENDFOR

RETURN 

END




