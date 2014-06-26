;+
; NAME:
;
; pg_hsi_update_orbitfile
;
; PURPOSE:
;
; update a file with info on RHESSI observation periods with all the new
; observations since the last entry. Assumes that entries already present are
; sorted. If the file does not exist, creates it and put all observation since
; RHESSI start, or an optional later starting time.
;
; CATEGORY:
;
; RHESSI util @ ETH
;
; CALLING SEQUENCE:
;
; pg_hsi_update_orbitfile,filename [,starttime]
;
; INPUTS:
;
; filename: the file to update with the new observation times [orbits]
;
; OPTIONAL INPUTS:
;
; starttime: time of first observation required [default: 15-FEB-2002].
;            If set generates a new file instead of reading from the old one.
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
; none (on file)
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
; The format of the output file is:
; 
; 2007/06/11 00:00:00Z,   2007/06/11 00:09:18Z,     9.3
; 2007/06/11 00:36:43Z,   2007/06/11 01:45:09Z,    68.4
; 2007/06/11 02:12:41Z,   2007/06/11 03:21:01Z,    68.3
; 2007/06/11 03:48:40Z,   2007/06/11 03:54:50Z,     6.2
; 2007/06/11 03:57:38Z,   2007/06/11 04:56:52Z,    59.2
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
; Paolo Grigis, 12-JUN-2007 written (upon request by C. Monstein)
; pgrigis@astro.phys.ethz.ch
;
;
;-


PRO pg_hsi_update_orbitfile,filename,starttime=in_starttime,endtime=endtime

  IF size(filename,/tname) NE 'STRING' THEN BEGIN  
     print,'ERROR: Please input a valid filename!'
     RETURN
  ENDIF 

  ;test
  ;filename='~/hsiorbits/test.txt'

  ;find current time
  get_utc,ctime

  IF exist(endtime) THEN ctime=anytim(endtime)

  
  IF ~exist(in_starttime) AND file_exist(filename) THEN BEGIN 

     ;file exist --> need to get last line
      
     ;read last line of file
     openr, unit, filename, /GET_LUN  
     str = ''  

     WHILE ~ EOF(unit) DO BEGIN  
        READF, unit, str  
     ENDWHILE  

     free_lun, unit  

     ;parse last line to get time

     ;print,str
     starttime=anytim((strsplit(str,',',/extract))[1])+4
     ;ptim,timeinfo

     openu, unit, filename, /GET_LUN ,/append 

  ENDIF ELSE BEGIN 

     openw, unit, filename, /GET_LUN  

     ;convert starttime to anytim format, sets default
     starttime=anytim(fcheck(in_starttime,'15-FEB-2002 '))

  ENDELSE 



  ;get RHESSI obs time and write them
  
  time_intv=[starttime,anytim(ctime)]
  
  rhessi_obs_times=pg_hsi_find_obstime(time_intv) 

  ;stop

  ;update file...

  IF rhessi_obs_times[0] GT 0 THEN BEGIN 

     FOR i=0,n_elements(rhessi_obs_times)/2-1 DO BEGIN 


        orbit= rhessi_obs_times[*,i]

        outstring=strmid(anytim(orbit[0],/ecs),0,19) $
                 +'Z,   ' $
                 +strmid(anytim(orbit[1],/ecs),0,19)+'Z'
        
        printf,unit,outstring
        
     ENDFOR


     free_lun, unit  


  ENDIF


END
