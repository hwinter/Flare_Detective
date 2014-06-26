FUNCTION xrt_get_hk_value,hktag, $
                          start_time, $
                          end_time, $
                          hkfiledir=hkfiledir, $
                          hkfileprefix=hkfileprefix, $
                          loud=loud

; =========================================================================
;		
;+
; PROJECT:
;       Solar-B / XRT
;
; NAME:
;
;       XRT_GET_HK_VALUE
;
; CATEGORY:
;
;       XRT Housekeping info
;
;
; PURPOSE:
;
;       Return housekeeping values in a given time interval, reading the
;       housekeeping FITS files.
;
;
; CALLING SEQUENCE:
;
;       hkdata=xrt_get_hk_value,hktag,start_time,end_time 
;                              [,hkfiledir=hkfiledir]
;                              [,/loud]
;
; INPUTS:
;
;       hktag:      (string) definition of the housekeeping variable to be
;                   returned (e.g. "TMP11C"). Accepts arrays, but this works
;                   only if all the tags are in the same file.
;       start_time: (string or double) start of the time
;                   interval that is checked for missing images. Can be in 
;                   any format accepeted by ANYTIM.
;       end_time:   (string or double) end of the time
;                   interval that is checked for missing images. Can be in 
;                   any format accepeted by ANYTIM.
;
; OPTIONAL INPUTS:
;
;       hkfiledir:  (string) Root of the directory trees where HK FITS reside. The default
;                   is '/archive/hinode/cmn/'. 
;       hkfileprefix: selects which HK status file to read from (normally, one
;                      of 'XRT_STS', 'MDP_STS','XRTD_STS','XRTE_STS'.
;                      Default is 'XRT_STS'. Scalar only. If hktag is given as
;                      an array, make sure all the tags are in the same file.
;
;       loud:       (0 or 1) If set, debugging output is shown.
;
;
; OUTPUT:
;       hkdata: a structure with tags TIME (double, in anytime format), VALUE
;       (flat) and NAME (string, housekeeping variable name)
;
;
;
; EXAMPLE:
;
;       Retrieve all HK values of TMP 11 between 2008/10/03 10:00 UT and 2008/10/04 10:00 UT
;       hkdata=xrt_get_hk_value('TMP11C','03-OCT-2008 10:00','04-OCT-2008 10:00')
;
; COMMON BLOCKS:
;
;       none
;
; PROCEDURE:
;
;       This routine reads in the two column housekeeping text files.
;
;
; KNOWN PROBLEMS:
;
; 
;
; NOTES:
;       
;      Warning: requesting a large number of tags over a large time interval
;      will be slow.
;
; CONTACT:
;
;       Comments, feedback, and bug reports regarding this routine may be
;       directed to this email address:
;                xrt_manager ~at~ head.cfa.harvard.edu
;
;
;
; MODIFICATION HISTORY:
; 
progver='v2008.Nov.13'  ;--- P. Grigis written
progver='v2008.Nov.17'  ;--- PG made more robust against input corruption, as the two column files with
                        ;    the HK data can contains very badly corrupted data!
progver='v2009.May.22'  ;--- PG converted to read FITS files instead
;
;
;-
; =========================================================================




  ; define archive directory
  dir = fcheck(hkfiledir,'/archive/hinode/cmn/')

  ; OS dependent path separator
  ps=path_sep()

  ;HK type specification
  hkfileprefix=fcheck(hkfileprefix,'XRT_STS')

  dir=dir+hkfileprefix+ps

  ;convert inputs to anytim format: external representation
  s_time = anytim(start_time)
  e_time = anytim(end_time)

  ;compute how many hours there are in the interval
  n_hours=ceil((e_time-s_time)/3600.+1)

  ;check how many tags are requested
  ntags=n_elements(hktag)

  time=0d
  value=0.0
  trackvalue=-1
  ;print,n_hours
  
  first=1

  ;hunt for files in the archive tree
  FOR i=0L,n_hours-1 DO BEGIN 

     ;this hour
     thistime=anytim(s_time+3600.*i,/ex)

     ;create dir path and filename

     thisyear=strtrim(thistime[6],2)
     thismonth=string(thistime[5],format='(i2.2)')
     thisday=string(thistime[4],format='(i2.2)')
     thishour=string(thistime[0],format='(i2.2)')
     

     thisdir=dir+ps+thisyear+'_'+thismonth+ps
     thisfile=thisdir+hkfileprefix+'-'+thisyear+thismonth+thisday+thishour+'0000.fits.gz'
 

     IF keyword_set(loud) THEN print,' Reading: '+thisfile

     IF file_exist(thisfile) THEN BEGIN 

   

        ;read content of file
        data=mrdfits(thisfile,1,header,/silent)        

        IF first EQ 1 THEN BEGIN 
           IF hktag[0] EQ 'ALL' THEN BEGIN 
              hktag=tag_names(data)
              ntags=n_elements(hktag)
           ENDIF
           first=0
        ENDIF


        time=[time,str_tagval(data,'PACKET_EDITION_TIME')]
        
        FOR j=0L,ntags-1 DO BEGIN 
           IF have_tag(data,hktag[j]) THEN BEGIN 
              newvalue=str_tagval(data,hktag[j])
              value=[value,newvalue]
              trackvalue=[trackvalue,replicate(j,n_elements(newvalue))]
           ENDIF 
        ENDFOR

        
       

     ENDIF 
  
  ENDFOR


  IF n_elements(value) EQ 1 THEN RETURN,-1

  ;timezero=anytim('01-JAN-2000')
  timezero=662688000.0d

  time=time[1:*]+timezero
  value=value[1:*]
  trackvalue=trackvalue[1:*]

  ;keep only times in range
  ind=where(time GT s_time AND time LT e_time,count)

  IF count GT 0 THEN BEGIN
     IF ntags EQ 1 THEN $     
        res={time:time[ind],value:value[ind],name:hktag} $
     ELSE BEGIN
        res=replicate({time:time[ind],value:value[ind],name:'NAME'},ntags)
        valindex=lindgen(n_elements(value))/ntags
        FOR k=0L,ntags-1 DO BEGIN
           indtag=where(trackvalue EQ k)
           res[k].value=(value[indtag])[ind]
           res[k].name=hktag[k]
        ENDFOR 
     ENDELSE 
  ENDIF $
  ELSE res=-1


  RETURN,res

 
END
     
