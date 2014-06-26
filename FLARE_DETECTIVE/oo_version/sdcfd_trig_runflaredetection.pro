
;+
; NAME:
;
; pg_timeintv_2dirst
;
; PURPOSE:
;
; convert a time interval to directory structures in form
; /path/to/file/2010/12/11/H1200 /path/to/file/2010/12/11/H1300
;
; CATEGORY:
;
; utils
;
; CALLING SEQUENCE:
;
; dir=pg_timeintv_2dirst(time_intv,dir=dir)
;
; INPUTS:
;
; time_intv: time interval
;
; OPTIONAL INPUTS:
;
; 
;
; KEYWORD PARAMETERS:
;
; dir: base dir for path
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
; time_intv=['14-DEC-2010 21:35','15-DEC-2010 02:14']
; d=pg_timeintv_2dirst(time_intv)                    
;
;
; AUTHOR:
;
; Paolo Grigis pgrigis@gmail.com
;
; MODIFICATION HISTORY:
;
; 2010/12/14 PG written (based on older material)
;-

FUNCTION pg_timeintv_2dirst,time_intv,dir=dir


t0=anytim(time_intv[0],/external)
t1=anytim(time_intv[1],/external)

;build directory list
dir=fcheck(dir, '/data/SDO/AIA/level1/')
                                
; OS dependent path separator
ps=path_sep()

;convert inputs to anytim format: external representation
s_time = anytim(time_intv[0])
e_time = anytim(time_intv[1])

;compute how many hours there are in the interval
n_hours=ceil((e_time-s_time)/3600.+1)
  
time=0d
value=0.0
trackvalue=-1
  
first=1

alldir=strarr(n_hours)

;hunt for files in the archive tree
FOR i=0L,n_hours-1 DO BEGIN 

     ;this hour
     thistime=anytim(s_time+3600.*i,/ex)

     ;create dir path and filename

     thisyear =strtrim(thistime[6],2)
     thismonth=string(thistime[5],format='(i2.2)')
     thisday  =string(thistime[4],format='(i2.2)')
     thishour =string(thistime[0],format='(i2.2)')
     
     thisdir=dir+ps+thisyear+ps+thismonth+ps+thisday+ps+'H'+string(thishour,format='(I02)')+'00'
     alldir[i]=thisdir

ENDFOR 

RETURN,alldir 

END
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


PRO sdcfd_trig_runflaredetection,Wave_ind, $
                                 allBinnedImagesRegular= allBinnedImagesRegular,allBinnedImagesSmooth= allBinnedImagesSmooth ;;;;;;;;;;;
;This file has been modified for use in HDWIII's directories


;
; This program runs the flare detection program (the "flare Detective")
; of the Feature Finding Team on the TRACE dataset in 171 A for
; 16-SEP-2001 from 00 to 24 UT that can be found in the file 
; TRACE_LEV1_20010916.zip distributed with th
;



; This directory is used to write the XML OUTPUT files
;;VOEventFileDir='/Network/Servers/sdo1.cfa.harvard.edu/Users/Shared/ard/FFT/flare_module/ard_working/xml_files'

VOEventFileDir='/Volumes/scratch_2/Users/hwinter/programs/Flare_Detective/Saturated_Pixel_Detections/FD_XML_files/20110809'
VOEventFileAltDir=VOEventFileDir

;Path to AIA data.  Defaults to '/data/SDO/AIA/level1/'
AIA_FITS_DIR='/Volumes/scratch_2/Users/hwinter/AIA/Saturated_Pixel_Detections/'

time_intv=['09-AUG-2011 07:30','09-AUG-2011 08:59']

wavelengths=['94','131','171','193','211','304','335' ]
;Choose which wavelength you are going to use
if n_elements(Wave_ind) le 0 then Wave_ind=3


thresholds=[0.3, 0.75, 2.0, 3.0, 0.83, 2.0, 0.2] 

pattern='AIA*'+wavelengths[Wave_ind]+'.fits'
; Make sure VOBS and ONTOLOGY are in SSW_INSTR (Also GEN, TRACE)

; USER CUSTOMIZATION part

; In order to run the code correctly, the following directories
; should be set:

;;paolo edit
; Change for LMSAL (Or use config File)
;VOEventSpecFile='/proj/DataCenter/ssw/vobs/ontology/data/VOEvent_Spec.txt'
;VOEventSpecFile='/home/pgrigis/sdodocs_svnrep/trunk/modules/oo_version/VOEvent_Spec.txt'


;
; Run the code proper:
;
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;

;; pattern='AIA*_0131.fits'
;; threshold=0.75

;; pattern='AIA*_0094.fits'
;; threshold=0.3


;; duration=[120.,120.,120.,120.,120.,120.,120.]


;; AIALev1Dir='/data/SDO/AIA/level1/2010/06/13/'
;; AIALev1Dir='/data/SDO/AIA/level1/2010/06/13/'

;; AIALev1Dir=['/data/SDO/AIA/level1/2010/06/12/', $
;;             '/data/SDO/AIA/level1/2010/06/13/', $
;;             '/data/SDO/AIA/level1/2010/06/14/']

;; hours='H00'+string(findgen(24),format='(I02)')
;; hours=hours;[2:15]



;for kk=0,n_elements(pattern)-1 DO BEGIN 

kk=0;2

;; print,'Now searching for files matching '+pattern
;; ;files=file_search(AIALev1Dir,pattern[kk])
;; files=[file_search(AIALev1Dir[0],pattern[kk]),file_search(AIALev1Dir[1],pattern[kk])];,file_search(AIALev1Dir[2],pattern[kk])]
;; nfiles=n_elements(files)
;; print,'Found '+strtrim(nfiles,2)+' files'


;get data

;; d1='/data/SDO/AIA/level1/2010/11/06/H1500/'
;; d2='/data/SDO/AIA/level1/2010/11/06/H1600/'

;; pattern='AIA*_0171.fits'

;; f1=file_search(d1,pattern)
;; f2=file_search(d2,pattern)

;; files=[f1,f2]


;time_intv=['05-NOV-2010 00:00','10-NOV-2010 00:00']
;Manually add the path to Paolo's old programs.  I will have to
;add the important routines into the main program at a later date
paolos_programs=getenv('PROGRAMS')+'Flare_Detective/pg_idllib/'
add_path,paolos_programs,/expand,/append

;Gets the proper AIA fits directory from the specified time interval.
help, AIA_FITS_DIR
d=pg_timeintv_2dirst(time_intv, DIR=AIA_FITS_DIR)    
print, D 
files=file_search(d,pattern)
help, files

;dir='/home/pgrigis/machd/aiatempdata/'

;new setting for 131 
;threshold=0.02
;too low
;threshold=0.06
;threshold=0.015
;threshold=0.05
;threshold=0.02


;mreadfits,files,headers

;wavelength=171
;ind=where(headers.wavelnth EQ wavelength,count)

;IF count EQ 0 THEN BEGIN 
;   print,'No images in '+wavelength+' A found. Returning.'
;  RETURN 
;ENDIF 

;files=files[ind]

; ;initialization - construction + detection with first image
; sdcfd_trig_flaredet,filename=files[0],statfile='sdcfd_trig_flaredet.sav', $
;		       verbose=1,/rebin,/renormalize, DerivativeThreshold=0.02, $
;		       DespikeNpass=2,flareXRange=3, FlareYrange=3, $
;		       VOEventFileDir=VOEventFileDir, event=event, $ 
;		       VOEventSpecFile=VOEventSpecFile, status=status,debug=1, $
;                      RunMode='Construct'


;; ;initialization - construction + detection with first image
;; sdcfd_trig_flaredet,filename=files[0], outputStatusFilename='sdcfd_trig_flaredet.sav', $
;; 		       verbose=1,/rebin,/renormalize, DerivativeThreshold=0.02, $
;; 		       DespikeNpass=2,flareXRange=3, FlareYrange=3, $
;; 		       VOEventFileDir=VOEventFileDir, event=event, $ 
;; 		       VOEventSpecFile=VOEventSpecFile, status=status,debug=1, $
;;                     RunMode='Construct'


;kk=0

;PG 10-MAY-2010 this is the level0 version
;initialization - construction + detection with first image
sdcfd_trig_flaredet,filename=files[0], outputStatusFilename='sdcfd_trig_flaredet.sav', $
		       verbose=1,/rebin,/renormalize, DerivativeThreshold=thresholds[Wave_ind],nx=32,ny=32, $
		       DespikeNpass=0,flareXRange=3, FlareYrange=3, $
		       VOEventFileDir=VOEventFileDir, event=event, $ 
		       VOEventSpecFile=VOEventSpecFile, status=status,debug=3, $
                       RunMode='Construct',flipImage=0,minflareduration=200.0;duration[kk]


;PG 10-MAY-2010 this stores temporary info for the purpose of fine tuning the
;algorithm
debug=1
;debug=0

;; thisStatus=status->getdata()
;; thisBinnedImageRegular=(* thisStatus.pBinnedCurrentImage)
;; thisBinnedImageSmooth=(* thisStatus.pData)[*,*,16]

;; allBinnedImagesRegular=thisBinnedImageRegular
;; allBinnedImagesSmooth=thisBinnedImageSmooth

;process rest of images
FOR i=1,n_elements(files)-1 DO begin

   ;print,'Now processing file '+files[i]

   sdcfd_trig_flaredet,filename=files[i], RunMode='Normal',status=status,verbose=3, $
                       outputStatusFilename='sdcfd_trig_flaredet.sav',events=events, $
                       imagerejected=imagerejected


   sdcfd_writexmlfilesfromstring,events,OutputDirectory=VOEventFileAltDir


;;    IF debug EQ 1 THEN BEGIN 
;;       ;stop
;;       IF imagerejected EQ 1 THEN BEGIN
;;          print,'Image rejected: '+files[i]
;;       ENDIF $
;;       ELSE BEGIN 
;;          ;stop
;;          thisStatus=status->getdata()
;;          thisBinnedImageRegular=(*thisStatus.pBinnedCurrentImage)
;;          thisBinnedImageSmooth=(*thisStatus.pData)[*,*,16]

;;          allBinnedImagesRegular=[[[allBinnedImagesRegular]],[[thisBinnedImageRegular]]]
;;          allBinnedImagesSmooth =[[[allBinnedImagesSmooth]], [[thisBinnedImageSmooth]]]

;;       ENDELSE  
;;    ENDIF 


ENDFOR 

;endfor

;cleanup at the end
;sdcfd_trig_flaredet,status=s,/cleanup


END 

