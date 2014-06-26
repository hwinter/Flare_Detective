;+
; NAME:
;
;    aia_rebinmanyfiles
;
; PURPOSE:
;
;    reads in many AIA FITS files and returns a structure containing summary
;    header information and rebinned data
;
; CATEGORY:
;
;    AIA, or how to deal with the data flood
;
; CALLING SEQUENCE:
;
;    summarystuct=aia_rebinmanyfiles(directory=directory,pattern=pattern,rebinsize=rebinsize)
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
; Paolo Grigis, pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; circa may 2010 written
; 07-OCT-2010 modified reader of files from mrdfits to read_sdo
;
;-


FUNCTION aia_rebinmanyfiles,directory=directory,pattern=pattern,rebinsizeX=rebinsizeX,rebinSizeY=rebinSizeY,flip=flip

;set defaults
pattern=fcheck(pattern,'AIA20100501_*_0193.fits')
directory=fcheck(directory,'/home/pgrigis/machd2/aia_data_forflaredet/level0/')
rebinSizeX=fcheck(RebinSizeX,256)
rebinSizeY=fcheck(RebinSizeY,RebinSizeX)
despikeNPass=fcheck(despikeNPass,2)


print,'Now searching for files matching '+pattern
files=file_search(directory,pattern)
nfiles=n_elements(files)
print,'Found '+strtrim(nfiles,2)+' files'

mreadfits,files[0],header

dummyimage=fltarr(rebinSizeX,rebinSizeY)


improvedHeader=add_tag(header,dummyimage,'DespikedImage')
improvedHeader=add_tag(improvedHeader,dummyimage,'BinnedImage')

DataStruct=replicate(improvedHeader,nfiles)

;nfiles=2

FOR i=0,nfiles-1 DO BEGIN

   print,'Reading file # '+string(i,format='(I05)')+' : '+files[i]
   ;mreadfits,files[i],header,data
   read_sdo,files[i],header,data

   IF keyword_set(flip) THEN data=rotate(data,7)

   thisStruct=DataStruct[i]
   struct_assign,header,thisStruct
   thisStruct.BinnedImage=congrid(data,rebinSizeX,rebinSizeY)

;    totalnspikes=0
;    FOR j=0,despikeNPass-1 DO BEGIN 
;       data = sdcfd_despike(data,nspikes=nspikes,/quiet)
;       totalnspikes+=nspikes
;    ENDFOR 
;
;   thisStruct.despikedImage=congrid(data,rebinSizeX,rebinSizeY)

   DataStruct[i]=thisStruct

ENDFOR

   
 
return, DataStruct



END


