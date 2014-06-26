;+
; NAME:
;
; aia_headers2cat
;
; PURPOSE:
;
; read headers from AIA FITS files and return a structure with some basic info
; in it
;
; CATEGORY:
;
; AIA FITS utils
;
; CALLING SEQUENCE:
;
; info=aia_headers2cat(directory=directory,pattern=pattern)
;
; INPUTS:
;
; directory: directory where the files are located
; pattern: search pattern (e.g "*.fits")
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
; hinfo=aia_headers2cat(directory='/home/pgrigis/machd2/aia_data_forflaredet/level0/')
;
; AUTHOR:
;
; Paolo Grigis
; pgrigis@cfa.haravrd.edu
;
; MODIFICATION HISTORY:
;
; 04-MAY-2010 written PG
;
;-

FUNCTION aia_headers2cat,directory=directory,pattern=pattern,quiet=quiet


;source and destination direcotry
directory=fcheck(directory,'.')
PathSep=path_sep()
directory=directory+path_sep()

;pattern: which files to look for?

;pattern=fcheck(pattern,'aia.lev0.*.fits');only JSOC level0 files
pattern=fcheck(pattern,'*.fits')

;finds files matching pattern
FitsFileList=file_search(directory,pattern)


IF FitsFileList[0] EQ '' THEN BEGIN 
   print,'No FITS files found in dir: '+directory
   print,'Returning.'
   RETURN,-1
ENDIF 


nfiles=n_elements(FitsFileList)



alltime=replicate(0d,nfiles)
allchannel=replicate('',nfiles)
allfiles=replicate('',nfiles)

FOR i=0,nfiles-1 DO BEGIN 

   p=string(float(i)/nfiles*100,format='(f6.2)')
   IF keyword_set(quiet) EQ 0 THEN BEGIN 
      print,'Now reading file '+FitsFileList[i]+' ('+p+'% done)'
   ENDIF 

   mreadfits,FitsFileList[i],h

   alltime[i]=anytim(h.t_obs)
   allchannel[i]=string(h.wavelnth,format='(I04)')
   allfiles[i]=FitsFileList[i]

ENDFOR

TimeSortIndex=sort(alltime)

HeaderInfo={ImageTime:alltime[TimeSortIndex],Channel:allchannel[TimeSortIndex],FileNames:allfiles[TimeSortIndex]}

RETURN,HeaderInfo

END

