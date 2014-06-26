;+
; PROJECT:
;
;    SDO Feature Finding Team
;
; NAME:
;
;    SDCFD_TRIG_FLAREDETECTIVE
;
; PURPOSE:
;
;    This is the main object that performs the flare detection for the SDO
;    feature finding team. This object is normally called by its wrapper
;    sdcfd_trig_flaredet.
;    This programs works in a way similar to what Alisdair and Jonathan envision
;    for detecting flares. In particular, this program is meant to be called
;    everytime a new image is available and is based on a status file.  
;
; CATEGORY:
;
;    SDO FFT - Flare Detective - Trigger
;
; CALLING SEQUENCE:
;
;     object=obj_new('sdcfd_trig_flaredetective')
;     error=object->Run(filename)
;
; INPUTS:
; 
;    filename: FITS file with AIA image (TRACE level 1 for now) to be read in
;
; OPTIONAL INPUTS:
;
;    NOT ANYMORE **** thistime: overrides the image time from the FITS header (for testing/debugging)
;
;    'upon construction
;    nBinsX,nBinsY: size of the rebinned image (only useful when creating status,
;            otherwise read from status)
;    DerivativeThreshold: threshold of derivative to detect flares (only useful when creating status,
;            otherwise read from status)
;    EndFraction: flux level to stop flare, as fraction of peak flux minus start
;            flux (only useful when creating status, otherwise read from status)
;
;    TBD - when can this be changed?
;    verbose: control diagnostic output of the program. 1 is reccomended and is
;             the default value. O is pretty quiet but outputs error messages
;             and a few more bits. -1 is totally silent (not recomennded). 2 and
;             3 are increasingly verbose and normally are used for debugging purposes.
; 
;   
; KEYWORD PARAMETERS: 
;
;    *** still current? probably not ***
;    firstimage: if set, no flare detection is performed (not useful with only
;                one image anyway), but image data is stored into status.
;    rebin: if set, forces rebinning of the image to status.nBinsX by status.nBinsY
;    renormalize: if set, the image data is divided by the exposure time (as
;                 found in the FITS header keyword XXXX )
;    
;
;
; OUTPUTS:
;
;    ERROR message now a string!
;    error: the error status explained below
;           0 : success
;           1 : image file not found
;           5 : problem with bookkeeping of flares (likely due to a bug of the
;                  this program or corrupt status)
;           6 : problem with IsFlare tag  (likely due to a bug of the
;                  this program or corrupt status)
;          -1 : unknown error
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
;     This programs need to work incrementally: i.e. it is callled every time a
;     new image is available. Therefore, there is a very important structure
;     (the status) that keeps track of what had happened in previous runs of the
;     program. Flares are first detected when the derivative of the lightcurves
;     is larger than DerivativeThreshold. The end time is decided when the flux
;     is below the start flux increased by EndFraction of the difference between
;     start flux and peak flux.
;
;     The program keeps track of flares in neighboring pixels, because we don't
;     want them to be separated events. The logic to keep track of that is a bit
;     complex:
;
;     -if a new pixels flares, it is a "primary" flares f there are no close
;         flares active, and a "secondary" flare otherwise.
;
;     -a new primary flares cause a new event to "open"
;
;     -when a secondary flares ends, no special action is taken
;
;     -when a primary flares end, either active secondaries are promoted to
;         primary or, if there are no secondaries left, the event is "closed"
;
;     -secondaries are monitored for peak flux, if any of them has a larger peak
;         flux than the primary, it is promoted to new primary and the primary turns secondary
;
;
; EXAMPLE:
; 
;     **** OBSOLETE **** NOT RLEVANT FOR OBJECT
;     Let's assumes "files" is an array of valid FITS filenames.
;     As a first step, we can create a status structure by calling the program
;     with /first:
;
;     IDL> s=-1
;     IDL> sdcfd_trig_flaredet,filename=files[0],status=s,DerivativeThreshold=0.001,thistime=0.0,/first
;
;     then we can loop over the files to detect flares
;
;        
;     IDL>   FOR j=1,n_elements(files)-1 DO BEGIN 
;     IDL>      sdcfd_trig_flaredet,filename=files[j],status=s,thistime=float(j)
;     IDL>   ENDFOR
;
;
; VERSION CONTROL SYSTEM STRING:
;
;   $Id:$
;
; AUTHOR:
;
;    Paolo C. Grigis, pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;  
;    04-NOV-2008 written (first draft) PG
;    06-JAN-2009 improved documentation PG
;    29-APR-2009 changed to conform to pipeline environment as I understand it PG
;    05-MAY-2009 further edits to improve performance and simplify logic PG
;    06-MAY-2009 added logic to group flares in adjacents pixels PG
;    08-MAY-2009 finished debugging of grouping logic, improved documentation PG
;    12-MAY-2009 implemented VOEvent output format PG
;    18-MAY-2009 branched for dealing with TRACE data PG
;    19-MAY-2009 implement despiking PG
;    08-JUL-2009 added keyword for output directory, changed min flare duration
;                to 2 minutes, fixed typo in thistime variable PG
;                TODO: keep track of the number of images!
;    09-JUL-2009 ARD Modified code to do own status keeping using IDL save
;                    file. Now use fstatus instead of status.
;                    Replaced status variable with statusfile as input and
;                    removed. firstimage. Whether or not this is the first time
;                    through is now evaluated. Added status to return status
;                    to java bridge. 
;    22-JUL-2009 ARD Codes returned with some edits from Ryan. See text file
;                    RYANS_COMMENTS.
;    10-AUG-2009 ARD Additional edits to come into compliance with LMSAL
;                    requirements.
;                    - Don't need to save and restore status file. Status
;                      struture maintained through calling routine.
;                    - All times (not from FITS file) should be in UTC.
;                    - Added minflareduration flag - flares will not be
;                      reported until they have existed at least this long.
;                    - default event_expires to 24 hours
;                    Still need to sort errors...
;    08-12-09 ARD FlareVStruct.optional.event_expires now uses UTC+24 hours.
;                 Trick is to use /stime as argument for anytim with sys2utc()
;                 which gives time in format addtime understands.
;               - Defined restart flag
;    08-12-09 ARD Created VOEventSpecFile parameter which contains location of
;                 VOEvent_Spec.txt at LMSAL. LMSAL nodes can't see normal
;                 solarsoft installation. Value is empty in configuration file
;                 at SAO.
;    08-13-09 ARD Assume VOEventSpecFile is always defined.
;    08-13-09 ARD In discussion with Ryan will now use numActiveEvents to
;                 return the number of active events to the EDS. The variable
;                 'status' will now be used in all modules to keep track of
;                 ongoing events. (Was fstatus)
;    09-02-09 ARD Worked in Ryan's changes to export_event calls to add the
;                 flare index to the suffix, otherwise you'd get a collision
;                 if two flares were detected with the same start time.
;    03-SEP-2009 PG now outputs coordinates in solar arcseconds
;    23-SEP-2009 PG added code to establish correct bounding box for flares
;    23-SEP-2009 PG investigate issue with events not "open" or "closed" - found
;                out that we need to change the logic as follows:
;                a) new event created -> don't create VOEvent
;                b) after 3 minutes - check if event still on
;                     - if yes -> create trigger VOEvent
;                     - if no -> do nothing
;                c) when event finishes -> create final VOEvent
;                trigger and final VOEvents are distinguished by
;                expiration date: 24 hours trigger - 1492 final
;    24-SEP-2009 PG modified the code to produce "trigger" events and "final"
;                events. Trigger events are created minflareduration seconds
;                (default: 3 min) after the start and final events are created
;                when flares are finished. trigger events are not created if
;                flare finishes right after minflareduration seconds from the
;                start
;    28-SEP-2009 PG changed export of trigger events such that VOEvent struture
;                (which is modified by export_event) is saved back where it 
;                belongs
;    06-Oct-2009 ARD moved program definition to top of file. Need only change
;                it on one place now.
;                Merged Ryan's latest updates.
;    07-Oct-2009 JG? Using latest version of sdcfd_trig_flaredet from latest 
;                directory, merged changes to object oriented version
;    15-Oct-2009 PG changed logic that assigns IVORN suffixes such that in case
;                of a large number of flares starting at the same time, all get
;                a *unique* suffix
;    22-Oct-2009 JG merged with latest version (svn revision 22) of 
;                sdcfd_trig_flaredet.pro
;                PG --> *** This is the OO version now *** <--
;       OCT-2009 PG shifted sdcfd_trig_flaredet__define method at the end of the file
;                this way the other methods are automatialy compiled (it's an IDL quirk)
;    06-JAN-2010 PG allow for different RunModes in wrapper sdcfd_trig_flaredet,
;                convert errors to string format, check for image filename
;                existence
;    02-FEB-2010 PG handles FITS keywords related to image quality and versioning
;    04-FEB-2010 PG fixed bug in clearing events when no events exist - noticed by RT
;    05-FEB-2010 PG corrected handling of last image times - was confusing valid and invalid images
;    09-MAR-2010 PG updated FITS HEADER keyword usage - TRACE and AIA should work OK now
;    07-APR-2010 PG this version works with actual AIA level 1.0 data
;                - but some FITS header keywords are missing yet
;                so for now just make something up until we get level
;                1.5 data with correctly filled out keywords
;    03-JUL-2010 RPT folded together changes between my and Paolo's
;                versions, updated with standard FFT compressed data reading and
;                image rejection criteria.  
;    09-DEC-2010 PG added logic for Header validation to account for flat field
;                changes, merged header validation from 2 independent routines
;                into one, added logic to check for consecutive rejected images.
;                Changed way pointers are freed.
;    
;
;
;-


compile_opt idl2

function sdcfd_trig_flaredetective::init, verbose=verbose,nBinsX=nBinsX,nBinsY=nBinsY, $
                         derivativeThreshold=derivativeThreshold, $
                         endFraction=endFraction, $
                         resetAfterInterval=resetAfterInterval, $
                         despikeNPass=despikeNPass, $
                         tooManySpikesFraction=tooManySpikesFraction, $
                         flareXRange=flareXRange, flareYRange=FlareYRange, $
                         VOEventFileDir=VOEventFileDir, $
                         VOEventSpecFile=VOEventSpecFile, $
                         minFlareDuration=minFlareDuration, $
                         debug=debug,renormalize=renormalize, $
                         performRebin=performRebin                

   ; Define some parameters

   now=anytim(sys2ut(),/ccsds)

   self.verbose = round(fcheck(verbose,1))

   if self.verbose ge 0 then print,'Initializing object'

   ; algorithm parameters
   ; see object creation sdcfd_trig_flaredetective__define below for 
   ; description

   ; ARD - Define Program Version here - propagated throughout program where
   ; needed.

   self.programVersion ='0.51'

   self.npastimages = 16
   self.nfutureimages = 16
   self.nimages = 1+self.npastimages+self.nfutureimages
   self.smoothsigma = 2.0
   self.nBinsX = fcheck(nBinsX,16)
   self.nBinsY = fcheck(nBinsY,16)

   self.pixelXSizeArcSec = 4096/self.nBinsX*0.6
   self.pixelYSizeArcSec = 4096/self.nBinsY*0.6

   x = findgen(self.nimages)-self.npastimages
   smoothedcurve = exp(-0.5*x*x/self.smoothsigma^2)
   self.smoothedcurve = self.smoothedcurve/total(smoothedcurve)

   self.derivativeThreshold = fcheck(derivativeThreshold,0.025)
   self.endFraction = fcheck(endFraction,0.25)

   self.resetAfterInterval = fcheck(resetAfterInterval,600L)
;   self.resetAfterInterval = fcheck(resetAfterInterval,3600L)

   self.despikeNPass = round(fcheck(despikeNPass,0))
   self.tooManySpikesFrac = fcheck(tooManySpikesFrac,0.017) ; 1.7%

   self.isFirstImage = 1

   self.flareXRange = fcheck(flareXRange,3)
   self.flareYRange = fcheck(flareYRange,3)

   

                                ;TODO - RPT I don't think this gets
                                ;       into the HEK, so I don't care
                                ;       about the hardcoding.
   self.flareIdBase = 'AIAFL0171N'

   self.flareIdNumber = 0L
   self.flareIdFormat = '(I09)'
   self.flareIdString = self.flareIdBase+string(self.FlareIdNUmber,format=self.flareIdFormat)
   ; format 'AIATRFL0171N123456789'
   ; meaning: AIA Trigger Flare wavelength 171 Number: (positive integer
   ;          with 9 digits)

   ; JG - shouldn't have hard coded paths in code. This parameter will
   ;      be checked that it has been defined instead
   ;self.VOEventFileDir = fcheck(VOEventFileDir,''/home/pgrigis/machd/flarelisttest/')
   ; PG - but it's better to have a default value anyway to avoid code crashes - useful
   ;      for debugging at least
   self.VOEventFileDir = fcheck(VOEventFileDir,'UNDEFINED')
   

   ps=path_sep()
   self.flareListFileName = self.VOEventFileDir+ps+'flarelist.txt' 
   
   self.pFlareVStructBlank = self->CreateVOStruct (now)

   self.thisTime = anytim(now)
   self.lastTime = anytim(now)

   ;this will be initialized as needed when the first image is read in
   self.LastImageTime=-1    
   self.LastValidImageTime=-1 
   selfCurrentImageTime=-1 

   self.LastImageHeader=ptr_new()
   self.LastValidImageHeader=ptr_new()
   self.NumberOfRejections=0
   self.MaxRejections=8
   self.MaxFlareFraction=0.25

   self.pData = ptr_new (fltarr(self.nBinsX,self.nBinsY,self.nimages))
   self.pTime = ptr_new (dblarr(self.nimages))

   self.statusCreationTime = now
   self.statusUpdateTime = now
   self.pIsFlare = ptr_new (intarr(self.nBinsX,self.nBinsY))
   self.pStartTime = ptr_new (dblarr(self.nBinsX,self.nBinsY))
   self.pPeakTime = ptr_new (dblarr(self.nBinsX,self.nBinsY))
   self.pEndTime = ptr_new (dblarr(self.nBinsX,self.nBinsY))
   self.pPeakFlux = ptr_new (fltarr(self.nBinsX,self.nBinsY))
   self.pStartFlux = ptr_new (fltarr(self.nBinsX,self.nBinsY))
   self.pNewFlare = ptr_new (bytarr(self.nBinsX,self.nBinsY))
   self.pFlareRank = ptr_new (bytarr(self.nBinsX,self.nBinsY))
   self.pLinkPrimary = ptr_new (lonarr(self.nBinsX,self.nBinsY))
   self.pSolarCoordX = ptr_new (fltarr(self.nBinsX))
   self.pSolarCoordY = ptr_new (fltarr(self.nBinsY))
   self.pFlareId = ptr_new (lonarr(self.nBinsX,self.nBinsY))

   ;PG - set default
   self.VOEventSpecFile =fcheck(VOEventSpecFile,'UNDEFINED')

   self.minFlareDuration = fcheck(minFlareDuration,180)

   self.flareNumberOfEvents = 0

   self.debug = fcheck(debug,0)
   self.waveLength = 0

   ;PG 06-JAN-2009 additions - move parameters away from being
   ;inputs to self->run 
   self.renormalize=fcheck(renormalize,0)

   self.performRebin=fcheck(performRebin,1)

   ;Return of INIT is 1 if initialization successful, 0 otherwise
   return, 1

end


function sdcfd_trig_flaredetective::cleanup

   ptr_free, self.pData
   ptr_free, self.pTime
   ptr_free, self.pImageHeader
   ptr_free, self.pIsFlare
   ptr_free, self.pStartTime
   ptr_free, self.pPeakTime
   ptr_free, self.pEndTime
   ptr_free, self.pPeakFlux
   ptr_free, self.pStartFlux
   ptr_free, self.pNewFlare
   ptr_free, self.pFlareRank
   ptr_free, self.pLinkPrimary
   ptr_free, self.pSolarCoordX
   ptr_free, self.pSolarCoordY
   ptr_free, self.pFlareId
   ptr_free, self.pFlareVStructBlank
   ptr_free, self.pFlareVStruct
   ptr_free, self.pFlareIdList
   ptr_free, self.pFlareExportStatus

   return, 1
end


PRO sdcfd_trig_flaredetective::PrintVersion

print,self.ProgramVersion

END 

pro sdcfd_trig_flaredetective::PrintCheckPoint, point
   if self.verbose ge 3 then begin
      print, "Check Point: "+string (point)
   end
end

function sdcfd_trig_flaredetective::CreateVOStruct, now

   ; get default flare event structure from SSW routine strcut4event
   ; add a personal identification (hopefully will not break the system 
   ; too much)
   FlareVStructBlank = struct4event('FL') ;get a VOEvent flare structure
   FlareVStructBlank = add_tag(FlareVStructBlank,'N/A','FL_ID')
   FlareVStructBlank = add_tag(FlareVStructBlank,'N/A','IVORN_SUFFIX')
   pFlareVStructBlank = ptr_new (FlareVStructBlank)

   ;initialize proper settings
   (*pFlareVStructBlank).Required.Event_CoordUnit = 'arcseconds'
   (*pFlareVStructBlank).Required.Event_C1Error = 2.0
   (*pFlareVStructBlank).Required.Event_C2Error = 2.0

   (*pFlareVStructBlank).Required.FRM_Contact = 'Paolo C. Grigis - pgrigis@cfa.harvard.edu'
   (*pFlareVStructBlank).Required.FRM_ParamSet = 'DerivativeThreshold='+ $
            string(self.derivativeThreshold,format = '(e12.5)')+' '+ $
            'EndFraction='+string(self.endFraction,format = '(e12.5)') + $
            ' nBinsX='+strtrim(string(self.nBinsX),2)+' nBinsY='+strtrim(string(self.nBinsY),2)

   (*pFlareVStructBlank).Required.FRM_HumanFlag = 'F'
   (*pFlareVStructBlank).Required.FRM_Identifier = 'Feature Finding Team'
   (*pFlareVStructBlank).Required.FRM_Institute = 'SAO'
   (*pFlareVStructBlank).Required.FRM_Name = 'Flare Detective - Trigger Module'
   (*pFlareVStructBlank).Required.FRM_URL = 'http://www.cfa.harvard.edu';to be modified
   (*pFlareVStructBlank).Required.FRM_DateRun = now

   (*pFlareVStructBlank).Required.OBS_Observatory = 'SDO'
   (*pFlareVStructBlank).Required.OBS_Instrument = 'AIA' 

  
                                ; obs settings deferred to reading of
                                ; first file (to get the real
                                ; wavelength from the data)
   ;(*pFlareVStructBlank).Required.OBS_ChannelId = strtrim(self.wavelnth, 2)
   ;(*pFlareVStructBlank).Required.OBS_MeanWavel = self.wavelnth
   ;turn to angstroms
   ;(*pFlareVStructBlank).Required.OBS_WavelUnit = self.waveunit

   ; FIXME - define proper bounding box ; DONE PG - values are updated in main

   (*pFlareVStructBlank).Required.BoundBox_C1LL = -1000.0
   (*pFlareVStructBlank).Required.BoundBox_C2LL = -1000.0
   (*pFlareVStructBlank).Required.BoundBox_C1UR = +1000.0
   (*pFlareVStructBlank).Required.BoundBox_C2UR = +1000.0

;   if self.debug gt 0 then $
;      sdcfd_trig_update_flarelist,self.flareListFileName,FlareVStructList[ind]

   return, pFlareVStructBlank

end

function sdcfd_trig_flaredetective::ValidateHeader, header
   
   ; verify that expected header keywords exist

   validated = 1
   em="Reject Image - no FITS header keyword: "


   ;list of header keywords needed - if not existing will reject this image!
   ;that saves a few checks down the line
   HeaderKeywordList=['NAXIS1','NAXIS2','DATE_OBS','TELESCOP','INSTRUME'];
   ;these keywords are NOT yet available;,'XCEN','YCEN','CDELT1','CDELT2']
   
   IF tag_exist(Header,'XCEN') EQ 0 THEN header=add_tag(header,0.0,'XCEN')
   IF tag_exist(Header,'YCEN') EQ 0 THEN header=add_tag(header,0.0,'YCEN')
   IF tag_exist(Header,'CDELT1') EQ 0 THEN header=add_tag(header,0.6,'CDELT1')
   IF tag_exist(Header,'CDELT2') EQ 0 THEN header=add_tag(header,0.6,'CDELT2')


   ;loops through header keywords - if missing, invalidate the current image
   FOR i=0,n_elements(HeaderKeywordList)-1 DO BEGIN 
      IF tag_exist(Header,HeaderKeywordList[i]) EQ 0 THEN BEGIN 
         self.errorMessage+=(em+HeaderKeywordList[i])
         validated=0
      ENDIF 
   ENDFOR 

   ;reject open filters
   if tag_exist(Header, 'WAVE_STR') && strmatch(Header.wave_str, 'open', /FOLD_CASE) eq 1 then begin
       validated=0
       selferrorMessage+= " Reject image beacuse it's an open filter"
       return, validated
   endif


   ;check for darks or non -light images
   IF tag_exist(Header,'IMG_TYPE') && Header.img_type NE 'LIGHT' THEN BEGIN 
      validated=0
      self.errorMessage+= " Reject image beacuse this is not an image of the Sun" + $
                          " (i.e. it's a dark or engineering image) "
      RETURN,validated
   ENDIF 

   ; if the wave length has been initialized; make sure its
   ; constistent across files
   wavelen = ''
   if tag_exist (header, "wavelnth") eq 0 then begin
      if tag_exist (header, "wave_len") eq 0 then begin
         validated = 0
         self.errorMessage+=(em+"wavelnth or wave_len ")
      endif else $
         wavelen = header.wave_len
   endif else $
      wavelen = header.wavelnth

   if wavelen ne '' then begin
      if self.waveLength ne 0 and self.waveLength ne wavelen then begin
         validated = 0
         self.errorMessage+='Reject image because of wavelength mismatch. '
         self.errorMessage+= 'Current wavelength = '+string (wavelen)
         self.errorMessage+= 'Previous wavelength = '+string (self.waveLength)
      endif
  endif

  ;New eclipse flag
  if tag_exist (header, 'aiagp6') then begin
      if header.aiagp6 ne 0 then begin
          rejStr = 'rejecting image of time ' + header.t_obs + ' due to AIAGP6'
          print, rejStr
          validated = 0
      endif
  endif


   if tag_exist(header, "exptime") ne 0 then begin
       if header.exptime lt 1.5 then begin
           self.errorMessage += 'exptime too short, rejecting (temporary)'
           validated=0;
       end
   end


   if tag_exist(header, "aiftsid") ne 0 then begin
       if header.aiftsid ge 49152 then begin
           self.errorMessage += 'aiftsid indicates calibration image, rejecting'
           validated=0
      end
  end



;;function sdcfd_trig_flaredetective::ValidateHeader2, header

   ; check if the image contains any bad pixels and reject it
   ; works for both TRACE and AIA data
   if tag_exist (header, "percentd") then begin
      if header.percentd lt 99.9999 then BEGIN
         self.errorMessage += 'exptime too short, rejecting (temporary)'
         validated=0            ;
      endif
  endif



          

   ;Quality keyword in AIA - details TBD
   ;need to understand in more details what "quality" means
   ;as a flag - now is e.g. set to 131072=2^17
   ;just means ISS loops is open - seems to be OK for now
   ;eventually we want to reject everything but 0 - but for now just reject
   ;based on a list of forbidden bits

   IF tag_exist(Header,'QUALITY') THEN BEGIN 


      ;create an array of number such that the j-th elementh as bit j set to 1 and all others set to 0
      ;i.e. 1,2,4,8,...,2^J,...
      BitArray=2UL^ulindgen(32)
      BitSet=(Header.quality AND BitArray) NE 0

      ForbiddenBits=[0,1,2,3,4,12,13,14,15,16,17,18,20,21,31];if any of these bits is set - reject the image
      ;RPT - added bits for ISS loop (17), ACS_MODE not SCIENCE (12)
      ;RPT - 9/25/10 - bits 20, 21, below from Rock's new def file
    ;      20	(AIFCPS <= -20 or 
      ;	 AIFCPS >= 100);	AIA focus out of range 
   ;21	AIAGP6 != 0;		AIA register flag


      IF total(BitSet[ForbiddenBits]) GT 0 THEN BEGIN 
         self.errorMessage += 'Forbidden Quality Bits set'
         validated=0      
      ENDIF 
      
   ENDIF 
   
   IF tag_exist(Header,'QUALLEV0') THEN BEGIN 


      ;create an array of number such that the j-th elementh as bit j set to 1 and all others set to 0
      ;i.e. 1,2,4,8,...,2^J,...
      BitArray=2UL^ulindgen(32)
      BitSet=(Header.quallev0 AND BitArray) NE 0

      ForbiddenBits=[0,1,2,3,4,5,6,7,16,17,18,19,20,21,22,23,24,25,26,27,28];if any of these bits is set - reject the image
      ;RPT - added bits for ISS loop (17), ACS_MODE not SCIENCE (12)
      
      IF total(BitSet[ForbiddenBits]) GT 0 THEN BEGIN 
         self.errorMessage += 'Forbidden QUALLEV0 Bits set'
         validated=0      
      ENDIF 
      
   ENDIF 

;check header for flatfield changes etc.
   IF ptr_valid(self.LastValidImageHeader) THEN BEGIN

   ;compare old header with new header
      oldHeader=*self.LastValidImageHeader
   
   ;flat fields match?
      IF strcmp(oldHeader.flat_rec,Header.flat_rec) EQ 0 THEN BEGIN 

         self.errorMessage+='Reject Image: Different flat version. '

         validated=0

      ENDIF 

   ;filter match?
      IF strcmp(oldHeader.wave_str,header.wave_str) EQ 0 THEN BEGIN 

         self.errorMessage+='Reject Image: Different flat version. '
         validated=0

      ENDIF 
 
   ENDIF 
   

   RETURN, validated

end

function sdcfd_trig_flaredetective::UpdateSolarCoord, header
      ; update solar coordinates for this image
      ; please note that program assumes for now *fixed* pointing
      ; for AIA - pretty good assumption - will need to decide how to
      ; deal with changes in pointing
      ; for TRACE: works only on special datasets with fixed pointing
      ; will need to reset with pointing changes




      XCenter = header.xcen ;solar coordinate of image center: X
      YCenter = header.ycen ;solar coordinate of image center: Y
      DeltaX = header.cdelt1 ;pixel size: X (in arcsecs)
      DeltaY = header.cdelt2 ;pixel size: Y (in arcsecs)
      XSize = header.naxis1 ;number of pixels (x)
      YSize = header.naxis2 ;number of pixels (y)

      XRebinFactor = XSize/self.nBinsX
      YRebinFactor = YSize/self.nBinsY

      ; array with x and y coordinates - array indices
      ArrayX = findgen(self.nBinsX)-self.nBinsX/2+0.5
      ArrayY = findgen(self.nBinsY)-self.nBinsY/2+0.5

      ; convert x and y to solar coordinates
      *self.pSolarCoordX = XCenter+ArrayX*XRebinFactor*DeltaX
      *self.pSolarCoordY = YCenter+ArrayY*YRebinFactor*DeltaY
      self.pixelXSizeArcSec = XRebinFactor * DeltaX
      self.pixelYSizeArcSec = YRebinFactor * DeltaY

;;     ; trick to make it two dimensional
;;     self.solarCoordX = SolarX       ; (SolarY*0.1)
;;     self.solarCoordY = (SolarX*0+1) ; SolarY

   return, 1
end


function sdcfd_trig_flaredetective::GetDateObs, header

   ; get the observation date from the header
   thistime = 0

                                ; only trace data supports date_obs
;edit - RT - actually our EUVI-generated test data has date-obs, which
;       apparently is considered equivalent to date_obs, but for those
;       files we want t-obs.  So, I changed the order.

      if tag_exist (header, "t_obs") then begin
          ; convert the format -- not sure what's a good indicator to ensure the
          ; format - is checking for TAI something I need to do?
          date_time = strsplit(header.t_obs,'_',/extract)
          if size (date_time, /DIMENSIONS) ne 3 then begin
             thistime = anytim(header.t_obs)
          endif else begin
             temp_date = strsplit (date_time[0], '.', /extract)
             date_time = strjoin (temp_date, '-')+'T'+date_time[1]
             self.dateObs = date_time
             thistime = anytim(date_time)
          endelse
      endif else begin 
          if tag_exist (header, "date_obs") then begin
              self.dateObs = header.date_obs
              thistime = anytim(self.dateObs)
          endif 
      endelse


   return, thistime
end

;despiking turned off, because AIA should do it for us, and it causes
;compile errors on sdo cluster
;function sdcfd_trig_flaredetective::DespikeImage, data, naxis1, naxis2 
;todo - the despike npass parameter now vesitgial but I don't want to
;       increment the coverageID over something so minor.  
;   succeed = 1
;   if self.despikeNPass gt 0 then begin

      ; for TRACE data despiking is needed
      ; number of passes 1 or 2 normally
      ; 2 seems to work well
;      for i=0,self.despikeNPass-1 do begin
;         data = sdcfd_despike(data,nspikes=nspikes,/quiet)

         ;but if too many spikes are found, discard the image!
;         if nspikes gt self.tooManySpikesFrac*naxis1*naxis2 then begin
;            succeed = 0
;            break
;         endif
;      endfor   
;   endif

;   return, succeed
;end

pro sdcfd_trig_flaredetective::ResetInfo, updateTime

    ; reset object to default values
    ; *but* does not cancel IDs
    (*self.pData)=(*self.pData)*0
    (*self.pTime)=(*self.pTime)*0
    self.statusUpdateTime=updateTime
    (*self.pIsFlare)=(*self.pIsFlare)*0
    (*self.pStartTime)=(*self.pStartTime)*0
    (*self.pPeakTime)=(*self.pPeakTime)*0
    (*self.pEndTime)= (*self.pEndTime)*0
    (*self.pPeakFlux)=(*self.pPeakFlux)*0
    (*self.pStartFlux)=(*self.pStartFlux)*0
    (*self.pNewFlare)=(*self.pNewFlare)*0
    (*self.pFlareRank)=(*self.pFlareRank)*0
    (*self.pLinkPrimary)=(*self.pLinkPrimary)*0
    self.flareIdNumber=self.flareIdNumber+100
    (*self.pFlareId)=(*self.pFlareId)*0
    self.flareNumberOfEvents=0
    if ptr_valid (self.pFlareVStruct) then begin
       ptr_free,self.pFlareVStruct
       self.pFlareVStruct=ptr_new()
    endif
    if ptr_valid (self.pFlareIdList) then begin
       ptr_free,self.pFlareIdList
       self.pFlareIdList=ptr_new()
    endif
    self.isFirstImage=1

end

pro sdcfd_trig_flaredetective::ResetFlare, index
   (*self.pFlareRank)[index] = 0
   (*self.pLinkPrimary)[index] = 0
   (*self.pFlareId)[index] = 0
end

function sdcfd_trig_flaredetective::DetectFlares, thistime, prevtime

   ;##########################################################################
   ;
   ; The following part of the code takes care of detecting flares
   ; for all pixels but does so *independently* in each pixel.
   ;
   ;##########################################################################

   ; for TRACE, in addition to normal processing, needs to carefully watch
   ; out for "negative" flares, that happens if the exposure time is changed
   ; these are tracked by getting a status of "IsFlare" equals -1

   error = 0
   ; loops over all the lightcurves
   for ii=0,self.nBinsX-1 do begin
      for jj=0,self.nBinsY-1 do begin

    
         ; this is the smoothed lightcurve
         lc = (*self.pData)[ii,jj,*]

         ; do flare detection work
         der = (lc[self.npastimages]-lc[self.npastimages-1])/(thistime-prevtime);

         if self.verbose ge 4 then $
            print,'Derivative at time '+anytim(thistime,/ccsds)+' and position '+'X='+strtrim(ii,2)+'Y='+strtrim(jj,2)+' is '+string(der)

         flux = lc[self.npastimages]
         lastflux = lc[self.npastimages-1]
         last3fluxes=lc[self.npastimages-3:self.npastimages-1]
         medianlastflux=(last3fluxes[sort(last3fluxes)])[1]

         ; first: check if we are in a peak
         ; positive or negtive flare
         case (*self.pIsFlare)[ii,jj] of

            0 : begin ; no flare now --> this is a new flare

               ; if no flare, check if we should start a new peak
               ; [if derivative gt threshold]
               if der gt self.derivativeThreshold then begin

                  self->PrintCheckPoint, 3

                  ; we are in a peak now
                  (*self.pIsFlare)[ii,jj] = 1
                  ; this is a new flare
                  (*self.pNewFlare)[ii,jj] = 1

                  ; set flare start, peak and end times to now
                  ; that is a good start
                  (*self.pStartTime)[ii,jj] = prevtime
                  (*self.pPeakTime)[ii,jj]  = prevtime
                  (*self.pEndTime)[ii,jj]   = prevtime

                  ; set the flux at start and the peak flux to the current flux
                  (*self.pPeakFlux)[ii,jj]  = flux
                  (*self.pStartFlux)[ii,jj] = medianlastflux;lastflux ;flux
   
                  if self.verbose ge 4 then begin
                     print,'Derivative is'+string(der)+' GT threshold'+string(self.derivativeThreshold) $
                       +' at '+anytim(thistime,/ccsds)
                     print,'Level at threshold '+string(flux)
                     print,'This was pixel '+string(ii)+string(jj)
                  endif

               endif

               ; check if a negative flare should be started
               if der lt -self.derivativeThreshold then begin
   
                  self->PrintCheckPoint, 4 

                  ; we are in a negative peak now
                  (*self.pIsFlare)[ii,jj] = -1
                  ; this is a new flare
                  (*self.pNewFlare)[ii,jj] = 1

                  ; set flare start, peak and end times to  now
                  ; that is a good start
                  (*self.pStartTime)[ii,jj] = prevtime
                  (*self.pPeakTime)[ii,jj]  = prevtime
                  (*self.pEndTime)[ii,jj]   = prevtime

                  ; set the flux at start and the peak flux to the current flux
                  (*self.pPeakFlux)[ii,jj]  = flux
                  (*self.pStartFlux)[ii,jj] = lastflux

                  if self.verbose gt 1 then begin
                     print,'New Negative flare detected! At time '+anytim(prevtime,/ccsds)+' and position '+string(ii)+string(jj)
                  endif

                  if self.verbose gt 4 then begin
                     print,'Derivative is'+string(der)+' LT threshold'+string(self.derivativeThreshold) $
                        +' at '+anytim(thistime,/ccsds)
                     print,'Level at threshold '+string(flux)
                     print,'This is pixel '+string(ii)+string(jj)
                  endif
               endif
            end


            1: begin   ; this is a regular flare

               ; we are in a peak now

               (*self.pEndTime)[ii,jj] = thistime
               if self.verbose ge 3 then print,'Flux :'+string(flux)

               ; check if current value is larger than previous maximum
               if flux gt (*self.pPeakFlux)[ii,jj] then begin

                  self->PrintCheckPoint, 5

                  ; if it is, that's the new peak value
                  (*self.pPeakFlux)[ii,jj] = flux
                  (*self.pPeakTime)[ii,jj] = thistime
               endif $
               else begin
               ; if not larger than peak, check if conditions for end of peak are fulfilled
                  if flux lt (*self.pStartFlux)[ii,jj]+ self.endFraction*((*self.pPeakFlux)[ii,jj]-(*self.pStartFlux)[ii,jj]) then begin

                     self->PrintCheckPoint, 6

                     ; no longer in peak
                     (*self.pIsFlare)[ii,jj]=0

                     if self.verbose ge 1 then begin
                        print,'Peak with maximum '+anytim((*self.pPeakTime)[ii,jj],/ccsds)
                        print,'Ends at '+string(anytim(thistime,/ccsds))
                     endif

                  endif
               endelse
            end


            -1: begin ; this is a negative flare

               (*self.pFlareRank)[ii,jj] = 3 ;that's the rank of negative flares
   
               ; we are in a negative peak now

               (*self.pEndTime)[ii,jj] = thistime

               if self.verbose gt 3 then begin
                  print,'NEGFL: Flux       : '+string(flux)
                  print,'NEGFL: Start Flux : '+string((*self.pStartFlux)[ii,jj])
                  print,'NEGFL: Peak Flux  : '+string((*self.pPeakFlux)[ii,jj])
               endif

               ;check if current value is smaller than previous maximum
               if flux lt (*self.pPeakFlux)[ii,jj] then begin

                  self->PrintCheckPoint, 7

                  ; if it is, that's the new peak value
                  (*self.pPeakFlux)[ii,jj] = flux
                  (*self.pPeakTime)[ii,jj] = thistime
               endif $
               else begin
                  ; if not smaller than peak, check if conditions for end of
                  ; peak are fulfilled
                  if flux gt (*self.pStartFlux)[ii,jj]-self.endFraction*((*self.pStartFlux)[ii,jj]-(*self.pPeakFlux)[ii,jj]) then begin

                     self->PrintCheckPoint, 8

                     ; no longer in peak
                     (*self.pIsFlare)[ii,jj] = 0

                     if self.verbose gt 1 then begin
                        print,'Peak with minimum at '+anytim((*self.pPeakTime)[ii,jj],/ccsds)
                        print,'Ends at '+anytim(thistime,/ccsds)
                     endif

                  endif
               endelse

            end

            else: begin ;this should never happen
               error = 6
            end
         endcase
      endfor
   endfor
   return, error
end


function sdcfd_trig_flaredetective::AssignNewFlares, thistime, prevtime

   error = 0

   ; find location of new flares (but not negative flares)
   indnewflares = where((*self.pNewFlare) eq 1 and (*self.pIsFlare) gt 0,countnewflares)
   ivornSuffix = 0

   ; assign new flares to be primary or secondary
   if countnewflares le 0 then begin
      return, 0
   endif

   ; convert flare pos to 2 dim arrays
   ind2d = array_indices([self.nBinsX,self.nBinsY],indnewflares,/dimensions)

   ; loop over all new flares
   for ii=0, countnewflares-1 do begin
      ; get neighborhood coordinates, making sure no
      ; array out of bounds error will ever happen
      nx0 = (ind2d[0,ii]-self.flareXRange)>0
      nx1 = (ind2d[0,ii]+self.flareXRange)<(self.nBinsX-1)
      ny0 = (ind2d[1,ii]-self.flareYRange)>0
      ny1 = (ind2d[1,ii]+self.flareYRange)<(self.nBinsY-1)


      ; find primary flares in the neighborhood
      indprimary = where((*self.pFlareRank)[nx0 : nx1, ny0 : ny1] EQ 1 ,countprimary)


      if countprimary eq 0 then begin ;there is no flare of status 1 around it --> then this is a primary flare

         self->PrintCheckPoint, 9

         ; increment ID counter
         self.flareIdNumber = self.flareIdNumber+1
         self.flareIdString = self.flareIdBase+string(self.FlareIdNUmber,format=self.flareIdFormat)


         ; define it as primary and link to itself (this is important)
         ; because the secobdary retrieves the information about where
         ; the primary is by way of its linkprimary value
         ; to avoid tedious index bookkeeping
         (*self.pFlareRank)[indnewflares[ii]] = 1
         (*self.pLinkPrimary)[indnewflares[ii]] = indnewflares[ii]
         (*self.pFlareId)[indnewflares[ii]] = self.flareIdNumber

         ; New flare! Yeah!
         ; Need to create new VOEevent table!!!
         if self.verbose ge 1 then $
            print,'New flare at time '+anytim(prevtime,/ccsds)+ $
                  ' and pos ('+strtrim(ind2d[0,ii],2)+','+strtrim(ind2d[1,ii],2)+')'


         ; create new VStruct for this new flare
         FlareVStruct=*self.pFlareVStructBlank
         FlareVStruct.required.FRM_DateRun = anytim(!stime,/ccsds)

;         Uses solar coordinates now
;         FlareVStruct.required.Event_Coord1=ind2d[0,i]
;         FlareVStruct.required.Event_Coord2=ind2d[1,i]

         FlareVStruct.required.Event_Coord1 = (*self.pSolarCoordX)[ind2d[0,ii]] 
         FlareVStruct.required.Event_Coord2 = (*self.pSolarCoordY)[ind2d[1,ii]]

         ; PG 23-SEP-2009
         ; add bounding BOX coordinates - now it's just the coordinates
         ; of this pixel - however they will be updated as secondary
         ; flares are added
         FlareVStruct.required.BoundBox_C1LL = (*self.pSolarCoordX)[ind2d[0,ii]]-0.5*self.PixelXSizeArcSec
         FlareVStruct.required.BoundBox_C2LL = (*self.pSolarCoordY)[ind2d[1,ii]]-0.5*self.PixelYSizeArcSec
         FlareVStruct.required.BoundBox_C1UR = (*self.pSolarCoordX)[ind2d[0,ii]]+0.5*self.PixelXSizeArcSec
         FlareVStruct.required.BoundBox_C2UR = (*self.pSolarCoordY)[ind2d[1,ii]]+0.5*self.PixelYSizeArcSec
         ; boundbox edits end PG

         FlareVStruct.required.Event_StartTime = anytim(prevtime,/ccsds)
         FlareVStruct.required.Event_PeakTime  = anytim(thistime,/ccsds)
         FlareVStruct.required.Event_EndTime   = anytim(thistime,/ccsds)
         FlareVStruct.optional.FL_PeakFlux = (*self.pPeakFlux)[indnewflares[ii]]

         ;added version number arg
         FlareVStruct.optional.FRM_versionnumber = self.programVersion
         FlareVStruct.FL_ID = self.flareIdString
         ivornSuffix = ivornSuffix+1
         FlareVStruct.Ivorn_Suffix = FlareVStruct.required.Event_StartTime+'_'+strtrim(string(ivornSuffix),2)

         ; Insert event_expires tag - set to now + 3 hours
         ; Insert event_expires tag - set to now + 24 hours. Will be ignored
         ; other than for FFT events.
         ; rtimmons 8-11.09 - tried changing !stime to sys2ut(), but threw error
         ;                    so I changed it to an ugly PST-specific hack for
         ;                    now
         ; FlareVStruct.optional.event.expires = anytim(addtime(!stime, delta_min=600,/ccsds)
         ; ARD 08-12-09 Trick is to use /stime as argument for anytim with
         ;              sys2utc() which gives time in format addtime
         ;              understands.
         FlareVStruct.optional.event_expires = anytim(addtime(anytim(sys2ut(),/stime),delta_min=1440),/ccsds)

         ; update status for bookkeeping of flares

         ; append VStruct and ID to existing set
         if self.flareNumberOfEvents eq 0 then begin
            self.pFlareVStruct = ptr_new(FlareVStruct)
            self.pFlareIdList = ptr_new(self.flareIdNumber)
            self.pFlareExportStatus = ptr_new(0)
         endif $
         else begin
            FlareVStructList = *self.pFlareVStruct
            ptr_free,self.pFlareVStruct
            self.pFlareVStruct = ptr_new([FlareVStructList,FlareVStruct])

            FlareIdList = *(self.pFlareIdList)
            ptr_free,self.pFlareIdList
            self.pFlareIdList = ptr_new([FlareIdList,self.flareIdNumber])

            FlareExportStatus = *(self.pFlareExportStatus)
            ptr_free,self.pFlareExportStatus
            self.pFlareExportStatus = ptr_new([FlareExportStatus,0])

         endelse

         ; update number of flares (add one)
         self.flareNumberOfEvents = self.flareNumberOfEvents+1


      endif $
      else begin 
         ;there's a primary flare -> this is a secondary flare

         self->PrintCheckPoint, 10

         ; associate secondary to primary
         (*self.pFlareRank)[indnewflares[ii]] = 2
         (*self.pLinkPrimary)[indnewflares[ii]] = ((*self.pLinkPrimary)[nx0 : nx1, ny0 : ny1])[indprimary[0]]
         (*self.pFlareId)[indnewflares[ii]] = ((*self.pFlareId)[nx0 : nx1, ny0 : ny1])[indprimary[0]]

         ; there's no need to update the Vstruct (yet)
         ; PG 23-SEP-2009: update Vstruct with bounding box of this pixel

         ; get right VStruct!
         thisflareid = (*self.pFlareId)[indnewflares[ii]]

         ; find all flares with this ID
         ind = where(*self.pFlareIdList eq thisflareid,count);

         if count gt 0 then begin
            VStructList = (*self.pFlareVStruct)
            ptr_free, self.pFlareVStruct

            VStructList[ind].required.BoundBox_C1LL = min([(*self.pSolarCoordX)[ind2d[0,ii]]-0.5*self.pixelXSizeArcSec, VStructList[ind].required.BoundBox_C1LL])
            VStructList[ind].required.BoundBox_C2LL = min([(*self.pSolarCoordY)[ind2d[1,ii]]-0.5*self.pixelYSizeArcSec, VStructList[ind].required.BoundBox_C2LL])
            VStructList[ind].required.BoundBox_C1UR = max([(*self.pSolarCoordX)[ind2d[0,ii]]+0.5*self.pixelXSizeArcSec, VStructList[ind].required.BoundBox_C1UR])
            VStructList[ind].required.BoundBox_C2UR = max([(*self.pSolarCoordY)[ind2d[1,ii]]+0.5*self.pixelYSizeArcSec, VStructList[ind].required.BoundBox_C2UR])

            self.pFlareVStruct = ptr_new(VStructList)

         endif $
         else begin
            error = 5
            if self.verbose ge 0 then begin
               print,'Error #5! No matching flare ID found in the flare ID list.'
               print,'This is probably due to a bug in this program.'
               print,'Please report the error to pgrigis@cfa.harvard.edu'
            endif
         endelse

         ; end bounding box edits

      endelse

   endfor

   ; new flares have been dealt with, can be set to regular ones
   (*self.pNewFlare)[indnewflares] = 0

   return, error
end

function sdcfd_trig_flaredetective::CleanUpSecondaries, thistime, pEvents=pEvents

   ; This part of the code deals with finished flares
   ; that may be still classified as primary or secondary
   ; but they are no longer flares

   ; find all finished primaries
   indfinprimary=where((*self.pIsFlare) eq 0 and (*self.pFlareRank) eq 1,countfinprimary)

   if countfinprimary gt 0  and self.verbose ge 1 then begin
      print,'Finished Primary! At time '+anytim(thistime,/ccsds)
   endif

   error = 0

   ;clean up secondaries associated with finished primaries (if any)

   for ii=0,countfinprimary-1 do begin

      thisflareid=(*self.pFlareId)[indfinprimary[ii]]

      self->ResetFlare, indfinprimary[ii]

      ; look if secondary are around and still flaring
      secfl=where((*self.pFlareRank)   eq 2 and $
                  (*self.pLinkPrimary) eq indfinprimary[ii] and $
                  (*self.pIsFlare)     eq 1,countsecfl)

      if countsecfl gt 0 then begin

         self->PrintCheckPoint, 11

         ; assign the secondary with brightest peak flux to be the new primary
         flux = (*self.pPeakFlux)[secfl]
         maxflux = max(flux,indmax)
         (*self.pFlareRank)[secfl[indmax]] = 1
         (*self.pLinkPrimary)[secfl] = secfl[indmax]
      endif $
      else begin

         self->PrintCheckPoint, 12

         ; finished!!!
         ; this flare is done and over
         ; has consequences for VOEvents
         if self.verbose ge 1 then $
            print,'Flare finished at '+anytim(thistime,/ccsds)

         ; update VStructs
         self.flareNumberOfEvents = self.flareNumberOfEvents-1

         ; get all VOEvent structures
         FlareVStructList = *self.pFlareVStruct
         ; clean up to avoid memory leaks
         ptr_free,self.pFlareVStruct

         ; get flare IDs and clean up
         FlareIdList = *self.pFlareIdList
         ptr_free,self.pFlareIdList

         ; get flare export status and clean up
         FlareExportStatus = *self.pFlareExportStatus
         ptr_free,self.pFlareExportStatus

         ; find the flare that actually finished
         ind = where(FlareIdList eq thisflareid,count)

         ; update EndTime of finished flare to now
         FlareVStructList.required.Event_EndTime = anytim(thistime,/ccsds)

         ; Reset event_expires tag
         FlareVStructList[ind].optional.event_expires = '1492-10-12 00:00:00'

         ; compute flare duration from VOEvent parameter
         FlareDuration = anytim(FlareVStructList[ind].required.Event_EndTime)- $
                         anytim(FlareVStructList[ind].required.Event_StartTime)

  
         if FlareDuration ge self.minFlareDuration then begin

            if self.debug gt 0 then $
               sdcfd_trig_update_flarelist,self.flareListFileName,FlareVStructList[ind]

            ; write VOEvent XML file
            ; infil_params used by LMSAL
            export_event,FlareVStructList[ind], $
                       outfil_voevent=FlareVStructList[ind].FL_ID+'.xml', $
                       outdir=self.VOEventFileDir,/write_file, $
                       buff=buff, $
                       suffix=FlareVStructList[ind].Ivorn_Suffix, $
                       infil_params=self.VOEventSpecFile

            ; Populate event structure

            if ptr_valid(pEvents)  then begin 
                ;print, 'Appending event to existing array'
               *pEvents = [*pEvents, strjoin(buff,/single)] 
               endif else begin
               pEvents = ptr_new([strjoin(buff,/single)])
               ;print, 'Created brand new event array'
           endelse

         endif ; flare duration test

         if self.flareNumberOfEvents eq 0 then begin
            self.pFlareVStruct = ptr_new()
            self.pFlareIdList = ptr_new()
            self.pFlareExportStatus = ptr_new()
         endif $
         else begin

            if count eq 1 then begin

               ; output information to text file!
               ; or use any other form of output
;               if self.debug gt 0 then begin
;                  sdcfd_trig_update_flarelist,status.FlareListFileName,FlareVStruct[ind]
;               endif

               self->PrintCheckPoint, 13

               if ind eq 0 then begin
                  self.pFlareIdList = ptr_new(FlareIdList[1:*])
                  self.pFlareVStruct = ptr_new(FlareVStructList[1:*])
                  self.pFlareExportStatus = ptr_new(FlareExportStatus[1:*])
               endif $
               else begin
                  if ind eq n_elements(FlareIdList)-1 then begin
                     self.pFlareIdList = ptr_new(FlareIdList[0:ind-1])
                     self.pFlareVStruct = ptr_new(FlareVStructList[0:ind-1])
                     self.pFlareExportStatus = ptr_new(FlareExportStatus[0:ind-1])
                  endif $
                  else begin
                     self.pFlareIdList = ptr_new([FlareIdList[0:ind-1],FlareIdList[ind+1:*]])
                     self.pFlareVStruct = ptr_new([FlareVStructList[0:ind-1],FlareVStructList[ind+1:*]])
                     self.pFlareExportStatus = ptr_new([FlareExportStatus[0:ind-1],FlareExportStatus[ind+1:*]])
                  endelse
               endelse

            endif $
            else begin
               ; stop
               error = 5
            endelse
         endelse
      endelse
   endfor

   return, error
end


function sdcfd_trig_flaredetective::ReassignPrimary, thistime

  ; this part of the code reassigns the primary rank to
  ; the flare that has largest peak flux

   error = 0
   indprimary = where((*self.pIsFlare) eq 1 and (*self.pFlareRank) eq 1,countprimary)

   for ii=0,countprimary-1 do begin
      ; retrieves secondaries currently associated with this primary
      secfl = where((*self.pFlareRank)   eq 2 and $
                    (*self.pLinkPrimary) eq indprimary[ii] and $
                    (*self.pIsFlare)     eq 1,countsecfl)

      thisflareid = (*self.pFlareId)[indprimary[ii]]
      primaryflux = (*self.pPeakFlux)[indprimary[ii]]
      peaktime = (*self.pPeakTime)[indprimary[ii]]

      ; if some are found
      if countsecfl gt 0 then begin

         ; set flux to proper values
         flux = (*self.pPeakFlux)[secfl]
         maxflux = max(flux,indmax)


         if maxflux gt primaryflux then begin

            self->PrintCheckPoint, 14

            (*self.pFlareRank)[secfl[indmax]] = 1
            (*self.pFlareId)[secfl[indmax]] = (*self.pFlareId)[indprimary[ii]]
            (*self.pLinkPrimary)[secfl] = secfl[indmax]

            PeakTime = (*self.pPeakTime)[secfl[indmax]]

            (*self.pFlareRank)[indprimary[ii]] = 2
            (*self.pLinkPrimary)[indprimary[ii]] = secfl[indmax]

         endif  $
         else begin

            self->PrintCheckPoint, 15

            maxflux = primaryflux
            PeakTime = (*self.pPeakTime)[indprimary[ii]]
         endelse
      endif $
      else begin

         self->PrintCheckPoint, 16

         maxflux = primaryflux
         PeakTime = (*self.pPeakTime)[indprimary[ii]]
      endelse

      ; find all flares with this ID
      ind = where(*self.pFlareIdList eq thisflareid,count)

      if count gt 0 then begin

         self->PrintCheckPoint, 17

         VStructList = *self.pFlareVStruct
         ptr_free,self.pFlareVStruct
         if VStructList[ind].optional.FL_PeakFlux lt max([primaryflux,maxflux]) then begin
            VStructList[ind].optional.FL_PeakFlux = max([primaryflux,maxflux])
            VStructList[ind].required.Event_PeakTime = anytim(peaktime,/ccsds)
         endif
         VStructList[ind].required.Event_EndTime = anytim(thistime,/ccsds)
         self.pFlareVStruct = ptr_new(VStructList)

      endif $
      else begin
        error = 5
      endelse
   endfor

   return, error
end


pro sdcfd_trig_flaredetective::PrintError, error
   if self.verbose eq 0 then $
      return

   case error of 
      5: begin
         print,'ERROR! No matching flare ID found in the flare ID list.'
         print,'This is probably due to a bug in this program.'
         print,'Please report the error to pgrigis@cfa.harvard.edu'
      end
      6: begin
         print,'ERROR! Invalid value for IsFlare tag'
         print,'This is probably due to a bug in this program.'
         print,'Please report the error to pgrigis@cfa.harvard.edu'
      end
      else: begin
      end
   endcase
end


;this function accepts no inputs and returns all the data within the object
FUNCTION sdcfd_trig_flaredetective::GetData

;this creates an un-initialized structure with all the data of the object
objdata=create_struct(NAME=obj_class(self))

;this copies the data from the object to the output structure
struct_assign,self,objdata

;voila - we have a strcuture with the contents of the object
RETURN,objdata

END 

pro sdcfd_trig_flaredetective::WriteTriggerEvents, pEvents=pEvents

   ; check flares that are a) active (not finished) b) start time greater than
   ; minFlareDuration seconds in the past c) not written trigger event
   ; and write a trigger event for those

   if self.flareNumberOfEvents gt 0 then begin

      FlareExportStatus = (*self.pFlareExportStatus)
      ptr_free, self.pFlareExportStatus

      TriggerCandidates = where(FlareExportStatus eq 0,count)

      FlareVStructList = (*self.pFlareVStruct)

      for i=0,count-1 do begin

         FlareVStruct = FlareVStructList[TriggerCandidates[i]]

         if anytim(self.thistime)-anytim((FlareVStruct.required).event_starttime) ge self.minFlareDuration then begin

            if self.verbose ge 2 then $
               print,'WRITING TRIGGER XML FILE'  


            IF ptr_valid(self.pImageHeader) EQ 1 && size(*self.pImageHeader,/tname) EQ 'STRUCT' THEN BEGIN 
    
               header=*self.pImageHeader
                                ;RPT 11-14: not the keywords we are
                                ;looking for, temporarily disabled.  
              ; if tag_exist (header, "quality")  then FlareVStruct.optional.obs_quality = header.quality
              ; if tag_exist (header, "flat")     then FlareVStruct.optional.obs_flat = header.flat
              ; if tag_exist (header, "flat_ver") then FlareVStruct.optional.obs_flat_ver = header.flat_ver
              ; if tag_exist (header, "lvl_num")  then FlareVStruct.optional.obs_lvl_num = header.lvl_num
              ; if tag_exist (header, "rel_ver")  then FlareVStruct.optional.obs_rel_ver = header.rel_ver
              ; if tag_exist (header, "pipelnvr") then FlareVStruct.optional.obs_pipelnvf = header.pipelnvr
              ; if tag_exist (header, "scirfbsv") then FlareVStruct.optional.obs_scirfbsv = header.scrifbsv

            ENDIF 

            
            ; Generate TRIGGER type event
            ; rtimmons edit - added suffix
            ; ARD - infil_params - see above
            help, FlareVStruct, FlareVStruct.FL_ID+'.xml',self.VOEventFileDir,$
                  FlareVStruct.Ivorn_Suffix
            export_event, FlareVStruct, buff=buff, $
                          suffix=FlareVStruct.Ivorn_Suffix, $
                          infil_params=self.VOEventSpecFile

            ; Populate event structure - make buff into a single merged string
            ;        RT  --- edited to make single events still arrays


            if ptr_valid(pEvents)  then begin 
                ;print, 'Appending event to existing array'
               *pEvents = [*pEvents, strjoin(buff,/single)] 
               endif else begin
               pEvents = ptr_new([strjoin(buff,/single)])
               ;print, 'Created brand new event array'
           endelse
  
            FlareExportStatus[TriggerCandidates[i]] = 1 ;means -> trigger event generated

            ; Ryan Timmons 10-5:  Add in a "citation" to ourself, as we will be
            ; replacing this trigger event when it closes.  The EDS needs this
            ; to know whether or not to call the supercede import method (since
            ; we do not make trigger events for those that are exactly the 
            ; minimum length.)

            FlareVStruct.citations[0].eventivorn = FlareVStruct.required.kb_archivid
            FlareVStruct.citations[0].action = "supersedes"
            FlareVStruct.citations[0].description = "Closing of open event"

            ; this step is needed because export_event *modifies* the 
            ; FlareVStruct
            FlareVStructList[TriggerCandidates[i]] = FlareVStruct

         endif

      endfor

      ; saves new FlareVStruct's into self such that IVORNS created by 
      ; export_event are properly stored
      ptr_free,self.pFlareVStruct
      self.pFlareVStruct = ptr_new(FlareVStructList)

      ; save back updated version
      ptr_free,self.pFlareExportStatus
      self.pFlareExportStatus = ptr_new(FlareExportStatus)
   endif
         
end

;this function reads the FITS image and returns 1 if the image is OK, 0 if it is not OK
;image and FITS header are returned via keywords
FUNCTION sdcfd_trig_flaredetective::ReadImage,filename=filename,data=data,header=header
 
   image_rejected=0  

                                
   ;check for file existence
   IF file_exist(filename) EQ 0 THEN BEGIN 

      IF size(filename,/tname) EQ 'STRING' THEN BEGIN 
         self.errorMessage+=' Image '+filename+' not found.'
      ENDIF $
      ELSE BEGIN 
         self.errorMessage+=' No valid image filename available.'
      ENDELSE 

      image_rejected=1
      
      RETURN,image_rejected
   ENDIF 
 
   IF self.verbose GE 1 THEN  print,'Processing file '+filename

   ;read data and FITS header
   ;data = mrdfits(filename,0,header,/silent)
   ;header = fitshead2struct(header)
   read_sdo, filename, header, data, parent_out = '/cache/sdo/UncompressScratchSpace/', /uncomp_delete
   ;extra params not working...
   ;parent_out='/cache/sdo/UncompressScratchSpace/',/uncomp_delete
   

   if self->ValidateHeader(header) eq 0 then begin
      image_rejected=1
      return,image_rejected
   endif

   ptr_free,self.pImageHeader
   self.pImageHeader=ptr_new(header)

   ; get image time
   thistime = self->GetDateObs (header)

   self.CurrentImageTime=thistime


   if self.IsFirstImage EQ 0 AND thistime LT anytim(self.lastTime) then begin
      ;if self.verbose ge 2 then begin
      self.errorMessage+=' Reject Image: current image was taken before previous.'
      self.errorMessage+=' Current time '+string (thistime)
      self.errorMessage+=' Previous time '+string (anytim(self.lastTime))
         ;endif
      image_rejected=1
      return, image_rejected
      ;;self.lastTime = self.thisTime
   endif





; despike the data
;eliminated due to AIA data already being despiked
   
;   if self->DespikeImage(data,header.naxis1,header.naxis2) eq 0 then begin
         ;if self.verbose ge 2 then $
         ;   print,
;      self.errorMessage+='Reject Image: too many spikes.'
         ;self.lastTime = self.thisTime
         ;terminate = 1
;      image_rejected=1
;      return, image_rejected

            ; but if first is rejected, need to store it anyway to avoid
            ; problems with second image! (which otherwise
            ; sees a jump from 0
         ;if self.isFirstImage eq 0 then return, self.errorMessage
;   endif

   ;if here it means image is OK so far - it's OK to update the current time
   ;to the image time
   self.thisTime=thistime

   return,image_rejected

END


;
;this function frees all pointers in the object
; 
PRO sdcfd_trig_flaredetective::freePointers

   ;
   ;frees all pointers 
   ;

;   ObjectTags

   call_procedure,obj_class(self)+'__define', ObjectStructure

   ntags=n_elements(tag_names(ObjectStructure))

   FOR i=0,ntags-1 DO BEGIN 
      IF ptr_valid(self.(i)) THEN ptr_free,self.(i)
   ENDFOR 

 ;;   stop

;;    ptr_free, self.pImageHeader
;;    ptr_free, self.pData
;;    ptr_free, self.pTime

;;    ptr_free, self.pIsFlare
;;    ptr_free, self.pStartTime
;;    ptr_free, self.pPeakTime
;;    ptr_free, self.pEndTime
;;    ptr_free, self.pPeakFlux
;;    ptr_free, self.pStartFlux
;;    ptr_free, self.pNewFlare
;;    ptr_free, self.pFlareRank
;;    ptr_free, self.pLinkPrimary
;;    ptr_free, self.pSolarCoordX
;;    ptr_free, self.pSolarCoordY
;;    ptr_free, self.pFlareId
  
;for these - empty pointers is the default empty state
;;    ptr_free, self.pFlareVStruct
;;    ptr_free, self.pFlareIdList
;;    ptr_free, self.pFlareExportStatus
;;    ptr_free, self.pFlareVStructBlank
 
END 


PRO sdcfd_trig_flaredetective::CleanUp

  self->freePointers
  
  RETURN 

END 

;this function performs the following actions
; 1) closes & exports all current flares
; 2) resets all data related to the images in the object
; 3) sets isFirstImage to 1 such that the next image will
;    not worry abot past data
;RTIMMONS 2-7: changed to pro, returns error via param instead of
;function return
FUNCTION sdcfd_trig_flaredetective::ClearEvents,pEvents=pEvents

   ;(1)
   ;is there any event currently in progress?
   ;if yes - need to act

   nActiveFlares=self.flareNumberOfEvents
   success=0

   ;flare list is an empty pointer if no events are going on
   IF  nActiveFlares GT 0 THEN BEGIN 
      IF ptr_valid(self.pFlareVStruct) THEN $
         FlareVStructList = (*self.pFlareVStruct) $
      ELSE BEGIN
         self.errorMessage+='Invalid flare event list. Cannot clear events. '    
         RETURN, self.errorMessage
      ENDELSE 
   ENDIF 

   FOR i=0,nActiveFlares-1 DO BEGIN

      FlareVStruct=FlareVStructList[i]

      ; update EndTime of finished flare to now
      FlareVStruct.required.Event_EndTime = anytim(self.LastValidImageTime,/ccsds)

      ; Reset event_expires tag
      FlareVStruct.optional.event_expires = '1492-10-12 00:00:00'
      
      FlareVStruct.optional.event_clippedtemporal='ending'
      ;print, 'set clippedtemporal'

      ; compute flare duration from VOEvent parameter
      FlareDuration = anytim(FlareVStruct.required.Event_EndTime)- $
                      anytim(FlareVStruct.required.Event_StartTime)


      ; only write flare if duration longer then minimum

      if FlareDuration ge self.minFlareDuration then begin

            ; output information to text file!
            ; or use any other form of output
            ; Leave this in for debugging

            if self.debug gt 0 then $
               sdcfd_trig_update_flarelist,self.flareListFileName,FlareVStruct

            ; write VOEvent XML file
            ; infil_params used by LMSAL

            help, FlareVStruct, FlareVStruct.FL_ID+'.xml',self.VOEventFileDir,$
                  FlareVStruct.Ivorn_Suffix
            export_event,FlareVStruct, $
                       outfil_voevent=FlareVStruct.FL_ID+'.xml', $
                       outdir=self.VOEventFileDir,/write_file, $
                       buff=buff, $
                       suffix=FlareVStruct.Ivorn_Suffix, $
                       infil_params=self.VOEventSpecFile

            ; Populate event structure
            ;print, 'putting return val in clearEvents'

            if ptr_valid(pEvents)  then begin 
                ;print, 'Appending event to existing array'
               *pEvents = [*pEvents, strjoin(buff,/single)] 
               endif else begin
               pEvents = ptr_new([strjoin(buff,/single)])
               ;print, 'Created brand new event array'
           endelse
          ; print, *pEvents

         endif ; flare duration test

   ENDFOR 
 
   ;(2) free all pointers
   self->freePointers

   ;current time
   now=anytim(sys2ut(),/ccsds)

   ;get blank VOEvent
   self.pFlareVStructBlank = self->CreateVOStruct(now)


   ;fill data with 0
   ;this is because now new data will be filled in
   ;
   self.pData = ptr_new (fltarr(self.nBinsX,self.nBinsY,self.nimages))
   self.pTime = ptr_new (dblarr(self.nimages))  
   self.pIsFlare = ptr_new (intarr(self.nBinsX,self.nBinsY))
   self.pStartTime = ptr_new (dblarr(self.nBinsX,self.nBinsY))
   self.pPeakTime = ptr_new (dblarr(self.nBinsX,self.nBinsY))
   self.pEndTime = ptr_new (dblarr(self.nBinsX,self.nBinsY))
   self.pPeakFlux = ptr_new (fltarr(self.nBinsX,self.nBinsY))
   self.pStartFlux = ptr_new (fltarr(self.nBinsX,self.nBinsY))
   self.pNewFlare = ptr_new (bytarr(self.nBinsX,self.nBinsY))
   self.pFlareRank = ptr_new (bytarr(self.nBinsX,self.nBinsY))
   self.pLinkPrimary = ptr_new (lonarr(self.nBinsX,self.nBinsY))
   self.pSolarCoordX = ptr_new (fltarr(self.nBinsX))
   self.pSolarCoordY = ptr_new (fltarr(self.nBinsY))
   self.pFlareId = ptr_new (lonarr(self.nBinsX,self.nBinsY))

   ;for these - empty pointers is the default empty state
   ;no need to fill them
   ;pFlareVStruct
   ;pFlareIdList
   ;pFlareExportStatus

   ;now there's absolutely no events active 
   self.flareNumberOfEvents=0

   ; increment ID counter
   self.flareIdNumber = self.flareIdNumber+100
   self.flareIdString = self.flareIdBase+string(self.FlareIdNUmber,format=self.flareIdFormat)



   ; reset tims and:
   ;(3) - next image==first
   self.isFirstImage=1
   self.lastTime=0.
   self.thistime=0.

   self.LastImageTime=-1    
   self.LastValidImageTime=-1 
   selfCurrentImageTime=-1 


   ;;;;;;;;;;;;;;;;;;;
  
   return, self.errorMessage

END 


;this function prints to the screen a short description
;of the status that the object is in
PRO  sdcfd_trig_flaredetective::printStatus

nActiveFlares=self.flareNumberOfEvents

print,'There are '+strtrim(nActiveFlares)+' flares active.'

;;IF self.flareNumberOfEvents GE 3 THEN stop

END


;main run of flare detection program
function sdcfd_trig_flaredetective::Run, filename, $
                                events=events, $
                                numActiveEvents=numActiveEvents, $
                                imagerejected=imagerejected



   ;initialize error - if everything works OK will be an empty string
   self.errorMessage = ''
   ;debug
   

   ;pointer to events (in case some are supplied - but they shouldn't - right?)
   ;why is this here? PG
   ;RT - in normal operations within the
   ;bridge there shouldn't be - the
   ;events pointer is created anew with each call.  
   ;But in the debugging sdcfd_run_flaredetection we collect all the events in one 
   ; big array so it may be defined
   if keyword_set (events) then $
      pEvents = ptr_new (events) $
   else $
      pEvents = ptr_new ()


   ;the runtime
   now = anytim(sys2ut(),/ccsds)
   self.lastDetectionRunTime=now
 
   ;reads image & check that it is ok
   imagerejected=self->ReadImage(filename=filename,data=data,header=header)

;   IF self.currentImageTime GE anytim('16-SEP-2001 19:40') THEN stop
   
   ;in case that the image is bad - just ignore it
   IF imagerejected EQ 1 THEN BEGIN 

      self.LastImageTime=self.CurrentImageTime
      IF size(header,/tname) EQ 'STRUCT' THEN $
         self.LastImageHeader=ptr_new(header) $
      ELSE $
         self.LastImageHeader=ptr_new()

                                ; ARD Fixed numActiveEvents as per RT
      if ptr_valid(pEvents) then begin 
          events = *pEvents
      ENDIF

      self.NumberOfRejections=self.NumberOfRejections+1
      ;how many did we reject already?
      IF self.NumberOfRejections GE self.MaxRejections THEN BEGIN 

         self.ErrorMessage+='Found too many consecutive Image Rejections. Resetting Module.'
         print,'Too many Images Rejected. Now Clearing Events!!!'
         temporaryErrorMessage=self->ClearEvents(pEvents=pEvents)

         if ptr_valid(pEvents) then begin 
            events = *pEvents
         ENDIF

      ENDIF 

      RETURN,self.errorMessage

   ENDIF 

   ;this is the time of the image that has been read in
   thistime=self.thistime


                               
      ; check for gaps between images
   
      ; this section deals with gaps in the data, determined as the present
      ; image being at a time significantly later than the latest image
      ; in that case, all "old" flares need to be closed off and the status
      ; reset, making sure that IDs are preserved. They are jumped forward by 
      ; 100 such that there's space left for new events after reprocessing of
      ; the gap however, reprocessing may never happen due to the near-real time
      ; status of the trigger --> but in-depth processing requires complete
      ; coverage at the trigger level: do we have a conflict?
 

   if self.isFirstImage EQ 0 AND thistime-anytim(self.lastValidImageTime) gt self.resetAfterInterval then begin

      print,'Now Clearing Events!!!'
      temporaryErrorMessage=self->ClearEvents(pEvents=pEvents)
      ;self->ClearEvents,pEvents=pEvents,error=temporaryErrorMessage
         ; ARD Fixed numActiveEvents as per RT
      if ptr_valid(pEvents) then begin 
          events = *pEvents
      endif
      
      ;self.Thistime=thistime
      ;self.CurrentImageTime=thistime

      ;because Clear Events resets the header, here we fill it again - because we do have
      ;a valid image though is first - so not really needed - but it's cleaner this way
      ;if we need to examine the status after failure - we can see if there were problems
      ;with the header
      ;self.pImageHeader=ptr_new(header)

      RETURN,self.errorMessage

   endif


   
   ;update Solar Coordinates of this image 
   ;need to check - can this be done less often?
   if self->UpdateSolarCoord (header) eq 0 then BEGIN
      self.LastImageTime=self.CurrentImageTime
      self.LastImageHeader=ptr_new(header)
      ;print, 'returning from UpdateSolarCoord'

      self.NumberOfRejections=self.NumberOfRejections+1
      ;how many did we reject already?
      IF self.NumberOfRejections GE self.MaxRejections THEN BEGIN 

         self.ErrorMessage+='Found too many consecutive Image Rejections. Resetting Module.'
         print,'Now Clearing Events!!!'
         temporaryErrorMessage=self->ClearEvents(pEvents=pEvents)

         if ptr_valid(pEvents) then begin 
            events = *pEvents
         ENDIF

         RETURN,self.errorMessage

      ENDIF 

      return, self.errorMessage

   ENDIF

    
   ; normalize the data - this only works for trace data -
   ; unclear now if this is also needed for AIA?
;;   if self.renormalize EQ 1 and tag_exist (header, "sht_nom") then $
;;      data = data/header.sht_nom

   ;attempt to renormalize AIA
   if self.renormalize EQ 1 and tag_exist(header, "exptime") then begin
      ; print, 'doing AIA renormalization'
     data = data/header.exptime
 endif

   ; rebinning not needed for test data or possibly for real AIA data (?)
   ; but needed for TRACE and other datasets

   bindata = rebin(data,self.nBinsX,self.nBinsY)
   
   ; update current information about times and images 

   ; shift current image/time one bin toward the past
   *self.pData = shift(*self.pData,0,0,-1)
   *self.pTime = shift(*self.pTime,-1)

   ; fix cyclic nature of IDL shift function to avoid past
   ; data ending up in the future
   (*self.pData)[*,*,self.nimages-1] = 0.0
   (*self.pTime)[self.nimages-1] = 0.0

   ; update present data
   (*self.pTime)[self.npastimages] = thistime
   ;self.thisTime = anytim(thistime,/ccsds)
   prevtime = (*self.pTime)[self.npastimages-1]

   ; double check that they have the same size
   compSize = size (bindata, /dimensions) eq size ((*self.pData)[*,*,self.npastimages], /dimensions)
   if compSize[0] eq 0 or compSize[1] eq 0 then begin
      ;if self.verbose ge 2 then begin 
      binDataSize = size (bindata, /dimensions) 
      pDataSize = size ((*self.pData)[*,*,self.npastimages], /dimensions)
      sizeStr = string (binDataSize[0])+'x'+string (binDataSize[1])
      self.errorMessage+='Bin image and data are different sizes at '+string (thistime)
      self.errorMessage+='Bin data size = '+string (binDataSize[0])+'x'+string (binDataSize[1])
      self.errorMessage+='Expected size = '+string (pDataSize[0])+'x'+string (pDataSize[1])
            
         ;self.lastTime=self.thisTime
         ;terminate=1
      ;endif
      ;print, 'returning from compSize'
      ;print, self.errorMessage

      
      self.NumberOfRejections=self.NumberOfRejections+1
      ;how many did we reject already?
      IF self.NumberOfRejections GE self.MaxRejections THEN BEGIN 

         self.ErrorMessage+='Found too many consecutive Image Rejections. Resetting Module.'
         print,'Now Clearing Events!!!'
         temporaryErrorMessage=self->ClearEvents(pEvents=pEvents)

         if ptr_valid(pEvents) then begin 
            events = *pEvents
         ENDIF

         RETURN,self.errorMessage

      ENDIF 




      self.LastImageTime=self.CurrentImageTime
      self.LastImageHeader=ptr_new(header)

      return,self.errorMessage
   endif $
   else $
      ; this is the case where no smoothing needs to be performed
      (*self.pData)[*,*,self.npastimages] = bindata


   ; this is needed because we can't detect a flare based on one
   ; image only. So if it i the first image now just returns (skipping
   ; the actual detection part). Howvever note that the data has been
   ; updated such that this image can serve as reference for the next one.
   if self.isFirstImage eq 1 then begin
      self.lastTime = self.thisTime
      self.isFirstImage = 0
      ;print, 'returning because we are now the first image'
      ;self->PrintCheckPoint, 15
      self.LastImageTime=self.CurrentImageTime
      self.LastValidImageTime=self.CurrentImageTime
      self.LastValidImageHeader=ptr_new(header)
      self.LastImageHeader=ptr_new(header)


      ;set wavelength dynamically from header
      (*self.pFlareVStructBlank).Required.OBS_ChannelId = strtrim(header.wavelnth, 2)
      (*self.pFlareVStructBlank).Required.OBS_MeanWavel = header.wavelnth
                                ;turn to angstroms
      (*self.pFlareVStructBlank).Required.OBS_WavelUnit = header.waveunit

      return,self.errorMessage
      
   endif


   ; detect flares
   error = self->DetectFlares (thistime, prevtime)
   if error gt 0 then begin
      self->PrintError, error

      return, self.errorMessage
   endif


   ;self.pNewFlare=ptr_new(intarr(32,32)+1);for testing prog logic only

   ;check if too many new flares are detected - this is an indication that something
   ;is wrong with the data - in this case the module should be reset
   IF ptr_valid(self.pNewFlare) THEN BEGIN 

      NewFlareFraction=total(*self.pNewFlare)/(float(self.NbinsX)*float(self.NbinsY))

      IF NewFlareFraction GT self.MaxFlareFraction THEN BEGIN 

         self.ErrorMessage+='Found too many Flares in one image - likely bad input data.'
         print,'Now Clearing Events!!!'
         temporaryErrorMessage=self->ClearEvents(pEvents=pEvents)

         IF ptr_valid(pEvents) then begin 
            events = *pEvents
         ENDIF

         RETURN, self.errorMessage

      ENDIF 

   ENDIF 

   ; this part of the codes deals with *NEW* flares
   error = self->AssignNewFlares (thistime, prevtime)

   ; This part of the code deals with finished flares
   ; that may be still classified as primary or secondary
   ; but they are no longer flares

   ; clean up secondaries associated with finished primaries (if any)
   error = self->CleanUpSecondaries (thistime,pEvents=pEvents)

;;    if error gt 0 then begin
;;       self->PrintError, error
;;       return, 0
;;    endif

   ; find all finished secondaries
   ; if they are not primary, it's OK to close them off.
   indfinsec = where((*self.pIsFlare) eq 0 and (*self.pFlareRank) eq 2,countfinsec)

   ; clean up finished secondaries
   if countfinsec gt 0 then begin
      if self.verbose ge 1 then $
         print,'Finished Secondary! at time '+anytim(thistime, /ccsds)
      self->ResetFlare, indfinsec
   endif

   ; finished negatives do nothing
   indfinneg=where((*self.pIsFlare) eq 0 and (*self.pFlareRank) eq 3,countfinneg)

   ; clean up finished secondaries
   if countfinsec gt 0 then begin
      if self.verbose ge 2 then $
         print,'Finished Negative! At time '+anytim(thistime,/ccsds)
      self->ResetFlare, indfinsec
   endif
  
   ; this part of the code reassigns the primary rank to
   ; the flare that has largest peak flux

   ; find all primaries
   error = self->ReassignPrimary (thistime)
 ;;   if error gt 0 then begin
;;       self->PrintError, error
;;       return, 0
;;    endif

   ; write "trigger" events
   self->WriteTriggerEvents, pEvents=pEvents

   ; time stamp for update of status
   self.statusUpdateTime = anytim(sys2ut(),/ccsds)
   self.lastTime = self.thisTime

   ; ARD Fixed numActiveEvents as per RT
   if ptr_valid(pEvents) then begin 
       events = *pEvents
   endif
   numActiveEvents = self.flareNumberOfEvents


   self.LastImageTime=self.CurrentImageTime
   self.LastValidImageTime=self.CurrentImageTime
   
   ;update header of last image
   ;
   self.LastValidImageHeader=ptr_new(header)
   self.LastImageHeader=ptr_new(header)


   ;if we are here, the image was not rejected
   self.NumberOfRejections=0

   RETURN, self.errorMessage
end



pro sdcfd_trig_flaredetective__define,class

   class = {sdcfd_trig_flaredetective, $
           programVersion: '' ,       $ ;Program Version
           npastimages: 0,            $ ;number of images in the past to keep track of
           nfutureimages: 0,          $ ;additional space in data array below for future images
           nimages: 0,                $ ;total number of images
           nBinsX: 0,                 $ ;x-size of rebinned image
           nBinsY: 0,                 $ ;y-size of rebinned image
           pixelXSizeArcSec: 0.0,     $ ;x-size (in arcseconds) of one pixel of the rebinned image
           pixelYSizeArcSec: 0.0,     $ ;y-size (in arcseconds) of one pixel of the rebinned image
           flareXRange: 0,            $ ;number of macropixels on each x-side of flare position to determine that 2 flares are neighbors 
           flareYRange: 0,            $ ;number of macropixels on each y-side of flare position to determine that 2 flares are neighbours
           smoothsigma: 0.0,          $ ;sigma from smoothing gaussian
           derivativeThreshold: 0.0,  $ ;threshold of derivative for detecting a flare
           endFraction: 0.0,          $ ;flare end if flux=startflux+endfraction* (peakflux-startflux)
           despikeNPass: 0,           $ ;number of despike passes to apply (0 means no despiking)
           tooManySpikesFrac: 0.0,    $ ;fraction of pixels with spikes that leads to a rejection of the image (too noisy for useful work)
           isFirstImage: 0,           $ ;keep track whether this is the first image or not
           resetAfterInterval: 0L,    $ ;if interval between last image and now greater than this, "resets" status
           verbose: 0,                $ ;Controls diagnostic output of the program
           thisTime: 0d,              $ ;Time of this image
           lastTime: 0d,              $ ;Time of last Image
           LastImageTime:0d,          $ ;Time of last image (whether accepted or rejected)
           LastValidImageTime:0d,     $ ;Time of last valid image (not rejected)
           LastImageHeader:ptr_new(), $ ;Header of last image read
           LastValidImageHeader:ptr_new(), $ ;Header of last valid image read
           NumberOfRejections:0,      $ ;Number of image rejections one after the other
           MaxRejections:0,           $ ;Maximum number of rejections allowed
           MaxFlareFraction:0.0,      $ ;Maximum fraction of pixels that can be detected flaring at the same time (because of bad data)
           CurrentImageTime:0d,       $ ;Time of current image (whether accepted or rejected)
           pimageHeader:ptr_new(),    $ ;FITS file image header
           pData: ptr_new(),          $ ;circular storage buffer for binned images
           pTime: ptr_new(),          $ ;circular storage buffer for image time
           smoothedcurve: 0,          $ ;smoothing curve
           statusCreationTime: '',    $ ;status creation date & time
           StatusUpdateTime: '',      $ ;status update date & time (meaning - image *not* rejected)
           lastDetectionRunTime:'',   $ ;last time object method "detectflares" was run
           pIsFlare: ptr_new(),       $ ;Is this pixel in a flare?
           pStartTime: ptr_new(),     $ ;Start time of flare for this pixel
           pPeakTime: ptr_new(),      $ ;Peak time of flare for this pixel
           pEndTime: ptr_new(),       $ ;End time of flare for this pixel
           pPeakFlux: ptr_new(),      $ ;Peak flux for this pixel and this flare
           pStartFlux: ptr_new(),     $ ;Start Flux for this pixel and this flare
           pNewFlare: ptr_new(),      $ ;Indicates that a new flare has been detected in this pixel
           pFlareRank: ptr_new(),     $ ;Indicates if the flare rank. 0: no flare - 1: primary - 2: secondary, where primary means: first pixel to light up
           pLinkPrimary: ptr_new(),   $ ;Index of the primary flare associated with this flare.
           pSolarCoordX: ptr_new(),   $ ;solar position of event (x coordinate, in arcsec, positive = W)
           pSolarCoordY: ptr_new(),   $ ;solar position of event (y coordinate, in arcsec, positive = N) 
           pFlareId: ptr_new(),       $ ;flare IDs for all detected flares in the image
           flareIdNumber: 0L,         $ ;Flare ID: number
           flareIdBase: "",           $ ;Flare ID: base string
           flareIdFormat: "",         $ ;Flare ID: format
           flareIdString: "",         $ ;Flare ID: full string
           flareListFileName: "",     $ ;Text file to write the flare list to
           VOEventFileDir: "",        $ ;Directory to write VOEvent files to
           VOEventSpecFile: "",       $ ;Location of VOEvent_Spec.txt at LMSAL.
           minFlareDuration: 0,       $ ;Minimum flare duration
           pFlareVStructBlank: ptr_new(), $ ;empty version of structure for VOEvent
           flareNumberOfEvents: 0,    $ ;number of flares active right now
           pFlareVStruct:ptr_new(),   $ ;pointer to array of VStructs, one for each active flare
           pFlareIdList:ptr_new(),    $ ;pointer to array of IDs for flares currently flaring
           pFlareExportStatus:ptr_new(), $ ;pointer to array of export statuses for flares: 0 -> no event has yet been exported
           debug: 0,                  $ ; flag to indicate debugging
           waveLength: 0,             $ ; the wave length being studied
           dateObs: "",               $ ; from date_obs or t_obs of file's header
           renormalize:0,             $ ;need to divide image flux by exposure time? yes if 1, no if 0
           performRebin:0,            $ ;need to rebin the image (1) or is image already binned (0)
           errorMessage:''            $ ;error status message - reports any error in the current run 
           }
   return
end
