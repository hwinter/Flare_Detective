FUNCTION xrt_hk_getdata,hktag, $
                   start_time, $
                   end_time, $
                   hkfiledir=hkfiledir, $
                   loud=loud

; =========================================================================
;		
;+
; PROJECT:
;       Solar-B / XRT
;
; NAME:
;
;       XRT_HK_GETDATA
;
; CATEGORY:
;
;       XRT Housekeping info
;
;
; PURPOSE:
;
;       Return housekeeping values in time interval
;
;
; CALLING SEQUENCE:
;
;       hkdata=XRT_HK_GETDATA,hktag,start_time,end_time 
;                           [,hkfiledir=hkfiledir]
;                           [,/loud]
;
; INPUTS:
;
;       hktag:      (string) definition of the housekeeping variable to be
;                   returned (e.g. "TMP11C")
;       start_time: (string or double) start of the time
;                   interval that is checked for missing images. Can be in 
;                   any format accepeted by ANYTIM.
;       end_time:   (string or double) end of the time
;                   interval that is checked for missing images. Can be in 
;                   any format accepeted by ANYTIM.
;
; OPTIONAL INPUTS:
;
;       hkfiledir:  (string) Root of the directory trees where HK two column files reside. The default
;                   is '/data/solarb/XRT/hk_cron/'. Direcotry structure is assumed to
;                   be in the form xrtfiledir+'yyyy/mm/dd/'
;       loud:       (0 or 1) If set, debugging output is shown.
;
;
; OUTPUT:
;       hkdata: a structure with tags TIME (double, in anytime format), VALUE
;       (flat) and NAME (string, housekeeping varianle name)
;
;
;
; EXAMPLE:
;
;       Retrieve all HK values of TMP 11 between 2008/10/03 10:00 UT and 2008/10/04 10:00 UT
;       hkdata=xrt_hk_getdata('TMP11C','03-OCT-2008 10:00','04-OCT-2008 10:00')
;
; COMMON BLOCKS:
;
; none
;
; PROCEDURE:
;
;     This routine reads in the two column housekeeping text files.
;
;
; KNOWN PROBLEMS:
;
; 
;
; NOTES:
;    Warning: since this program reads in the files, it will be slow for
;          time intervals spanning more than a few days, where a sizable number of
;          files needs to be read in.
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
;
;
;-
; =========================================================================




  ; define archive directory
  dir = fcheck(hkfiledir,'/data/solarb/XRT/hk_cron/')

  ; OS dependent path separator
  ps=path_sep()

  ;convert inputs to anytim format: external representation
  s_time = anytim(start_time)
  e_time = anytim(  end_time)

  ;compute how many hours there are in the interval
  n_hours=ceil((e_time-s_time)/3600.+1)


  time=0d
  value=0.0
  
;;   catch,error_status
 
;;   IF Error_status NE 0 THEN BEGIN 
;;      PRINT, 'Error index: ', Error_status 
;;      PRINT, 'Error message: ', !ERROR_STATE.MSG 
;;                                 ; Handle the error by extending A: 
;;      thsitime=0d
;;      thisvalue=0.0
;;   ;   CATCH, /CANCEL 
;;   ENDIF 
  

  ;hunt for files in the archive tree
  FOR i=0L,n_hours-1 DO BEGIN 

     ;this hour
     thistime=anytim(s_time+3600.*i,/ex)

     ;create dir path and filename

     thisyear=strtrim(thistime[6],2)
     thismonth=string(thistime[5],format='(i2.2)')
     thisday=string(thistime[4],format='(i2.2)')
     thishour=string(thistime[0],format='(i2.2)')
     

     thisdir=dir+ps+thisyear+ps+thismonth+ps+thisday+ps
     thisfile=thisdir+hktag+'_'+thisyear+thismonth+thisday+'_'+thishour+'.txt'
 

     IF keyword_set(loud) THEN print,hktag+' reading '+thisfile

     IF file_exist(thisfile) THEN BEGIN 

        ;read content of file
        content=rd_ascii(thisfile)

        

        IF n_elements(content) GT 1 THEN BEGIN 

           ;parse time and value
           thisvaluestr=strmid(content[1:*],22,64)
           thistimestr=strmid(content[1:*],0,21)
           thistimeyear=strmid(content[1:*],0,4)
           thistimemonth=strmid(content[1:*],5,2)
           thistimeday=strmid(content[1:*],8,2)
           thistimehour=strmid(content[1:*],11,2)
           thistimemin=strmid(content[1:*],14,2)
           thistimesec=strmid(content[1:*],17,2)
           thistimemsec=strmid(content[1:*],20,1)
 
           ind=where(xrt_hk_valid_num(thisvaluestr) AND $
                     xrt_hk_valid_num(thistimeyear) AND $
                     xrt_hk_valid_num(thistimemonth) AND $
                     xrt_hk_valid_num(thistimeday) AND $
                     xrt_hk_valid_num(thistimehour) AND $
                     xrt_hk_valid_num(thistimemin) AND $
                     xrt_hk_valid_num(thistimesec) AND $
                     xrt_hk_valid_num(thistimemsec),count)

           IF count GT 0 THEN BEGIN 

              

              thisvalue=float(thisvaluestr[ind])

              timeexformat=transpose(long([[float(thistimehour[ind])], $
                                [float(thistimemin[ind])], $
                                [float(thistimesec[ind])], $
                                [float(thistimemsec[ind])*100], $
                                [float(thistimeday[ind])], $
                                [float(thistimemonth[ind])], $
                                [float(thistimeyear[ind])]]))
              
              
              thistime=reform(anytim(timeexformat))
      
              ;add to general file
              time=[time,thistime]
              value=[value,thisvalue]
  
           ENDIF 
  
        ENDIF

     ENDIF
  
  ENDFOR

  catch,/cancel

  IF n_elements(time) EQ 1 THEN return,-1

  ;keep only times in range
  ind=where(time GT s_time AND time LT e_time,count)

  ;build output structure
  IF count GT 0 THEN res={time:time[ind],value:value[ind],name:hktag} ELSE res=-1

  RETURN,res

 
END
     
