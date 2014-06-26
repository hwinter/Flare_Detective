;+
; NAME:
;
;    pg_readAIA
;
; PURPOSE:
;
;    reads in many AIA FITS files with options to avoid drowning in data
;
; CATEGORY:
;
;    AIA, or how to deal with the data flood
;
; CALLING SEQUENCE:
;
;    data=pg_readaia(time_intv,channel=channel,FitsPath=FitsPath,BinFactor=BinFactor $
;                             ,Xselection=Xselection,Yselection=Yselection)
;
;
; INPUTS:
;
;   time_intv: the time interval, a 2-element array in any format accepted by ANYTIM   
;   channel: list of AIA channels as integers or strings. Example: channel=['304','131','211']
;
; OPTIONAL INPUTS:
;
;   FitsPath: [string] path to the root of the tree containing AIA files.
;             Dafault: '/data/SDO/AIA/level1/'
;             The files are assumed to live in FitsPath/YYYY/MM/DD/HNN00/
;   BinFactor: [integer] binning to be applied to teh images (default:1, no
;               binning). Should be between 1 and 2048.
;   Xselection: the X-coordinates of the subarea of the image to extract
;               (will be rounded to a multiple of the binning)
;   Yselection: the Y-coordinates of the subarea of the image to extract. 
;               (will be rounded to a multiple of the binning)
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
; 01-DEC-2010 totally rehauled version
;-


PRO pg_readaiatest

time_intv='06-NOV-2010 '+['15:10:01','15:10:28']
channel=['304','131','211']
;=['304','131','411']

d=pg_readaia(time_intv,channel=channel)

END 

FUNCTION pg_readaia,time_intv,channel=channel,FitsPath=FitsPath,BinFactor=BinFactor $
                             ,Xselection=Xselection,Yselection=Yselection

IF n_elements(time_intv) NE 2 THEN BEGIN 
   print,'Need an input time interval.'
   return ,-1
ENDIF 


;RebinFactor=fcheck(rebin,256)

IF n_elements(Xselection) NE 2 THEN Xselection=[0,4095] 
IF n_elements(Yselection) NE 2 THEN Yselection=[0,4095] 

BinFactor=round(fcheck(BinFactor>1<2048,1))
FinalSize=4096/BinFactor

Xsize=round((Xselection[1]-Xselection[0]+1)/BinFactor)
Ysize=round((Yselection[1]-Yselection[0]+1)/BinFactor)

Xrange=[(Xselection[0]/BinFactor)>0 , ((Xselection[0]/BinFactor)+Xsize-1)<(FinalSize-1)]
Yrange=[(Yselection[0]/BinFactor)>0 , ((Yselection[0]/BinFactor)+Ysize-1)<(Finalsize-1)]

XrangeOriginal=Xrange*BinFactor+[0,BinFactor-1]
YrangeOriginal=Yrange*BinFactor+[0,BinFactor-1]



ChannelList=fcheck(channel,'171')

IF size(ChannelList,/tname) NE 'STRING' THEN ChannelList=string(ChannelList,format='(I03)')

nChannels=n_elements(ChannelList)

;validate channels

ValidChannelSet=['094','131','171','193','211','304','335']

FOR i=0,nChannels-1 DO BEGIN 
   res=cmset_op(ChannelList[i],'AND',ValidChannelSet)
   IF res[0] LT 0 THEN BEGIN 
      print,'Invalid channel ID: '+ChannelList[i] + ' Use one or more of '
      pritn,ValidChannelSet
      RETURN,-1
   ENDIF 
ENDFOR 



;build directory list

dir=fcheck(FitsPath,'/data/SDO/AIA/level1/')
                                
s_time = anytim(time_intv[0])
e_time = anytim(time_intv[1])

alldir=pg_timeintv_2dirst(time_intv,dir=dir)


DefineOutputStructure=1
ImageCounter=0

FOR k=0,nChannels-1 DO BEGIN

   
 
   ;OutputStructure[k].Channel=ChannelList[k]

   pattern='*_0'+ChannelList[k]+'.fits'
   Result = FILE_SEARCH(alldir,pattern)

   IF result[0] EQ '' THEN BEGIN 
      print,'No files matching pattern: '+pattern+' found in '
      pritn,alldir
   ENDIF $
   ELSE BEGIN 


      ;select time

      timestring=strmid(result,24,15,/reverse_offset)

      timestring2=strmid(timestring,0,4)+'/'+strmid(timestring,4,2)+'/'+strmid(timestring,6,2)+' '+strmid(timestring,9,2) $
                  +':'+strmid(timestring,11,2)+':'+strmid(timestring,13,2)


      theImageTime=anytim(timestring2)
      ind=where(theImageTime GE s_time AND theImageTime LE e_time,count)


      ;check if images were found

      IF count EQ 0 THEN BEGIN 
         print,'No valid images found in channel '+ChannelList[k]
      ENDIF $
      ELSE BEGIN 

         ;only take images in the time interval
         theImageFiles=Result[ind]
         nImageFiles=n_elements(theImageFiles)


         ;first time we do this, we need to define the structure
         IF DefineOutputStructure EQ 1 THEN BEGIN 
            read_sdo,theImageFiles[0],header,data,/uncomp_delete

            OutputStructureDefinition={Image:fltarr(Xsize,Ysize), $
                                       Header:header, $
                                       FileName:theImageFiles[0], $
                                       XrangeOriginal:XrangeOriginal, $
                                       YrangeOriginal:YrangeOriginal, $
                                       Xrange:Xrange, $
                                       Yrange:Yrange, $
                                       BinFactor:BinFactor}

            DefineOutputStructure=0
            OutputStructure=replicate(OutputStructureDefinition,nImageFiles)
         ENDIF $
         ELSE BEGIN 
            ;add space for the new images
            OutputStructure=[OutputStructure,replicate(OutputStructureDefinition,nImageFiles)]
         ENDELSE 


         FOR j=0,nImageFiles-1 DO BEGIN 
            print,j,theImageFiles[j]

            ;need to check what happens if the file is not accessible anymore in the meantime
            read_sdo,theImageFiles[j],index,data,/uncomp_delete

            myheader=header
            struct_assign,index,myheader

            FinalSize=4096/BinFactor
            imdata=rebin(data[0:Finalsize*BinFactor-1,0:Finalsize*BinFactor-1],FinalSize,Finalsize)
            outData=imdata[Xrange[0]:Xrange[1],Yrange[0]:Yrange[1]]

         
            OutputStructure[ImageCounter].Image=outData
            OutputStructure[ImageCounter].Header=myheader    
            OutputStructure[ImageCounter].FileName=theImageFiles[j]
            ImageCounter++  

         ENDFOR 

      ENDELSE 

   ENDELSE 

ENDFOR 

RETURN,OutputStructure[0:ImageCounter-1]

END 


 
