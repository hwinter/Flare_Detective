;+
;NAME:
;
;   pg_hsi_find_obstime
; 
;PURPOSE:
;
;   given a time interval, return the effective solar observation times
;   of RHESSI (that is, no saa, night, data gap)
;
;CALLING SEQUENCE:
;
;   rhessi_obs_times=pg_hsi_find_obstime(time_intv) 
;
;INPUT:
;   time_intv = a 2-element array,in a format accepted by ANYTIM
;
;OPTIONAL INPUT:	
;
;
;OUTPUT:
;
;   an array with RHESSI observation times, in anytim format (double, seconds
;   after 01-jan-1979)
;
;KEYWORDS:
;
;   loud: verbose
;
;EXAMPLE:
;
;   time_array=hsi_obs_time('26-FEB-2002 '+['06:00','12:00'])
;
;HISTORY:
;   03-SEP-02 written, based on PSH's obs_summ_page
;   04-OCT-02 imported in rapp_idl tree, added loud keyword
;   12-JUN-07 renamed & changed slightly for hsiorbitinfo project
;
;AUTHOR:
;
;   Paolo Grigis, Institute of Astronomy, ETH Zurich 
;   pgrigis@astro.phys.ethz.ch
;
;-

FUNCTION pg_hsi_find_obstime,time_intv,loud=loud

  time_intv=anytim(time_intv)
  time_intv[1]=time_intv[1]+4   ; not really needed, but the output looks better

  osumm=obj_new('hsi_obs_summary')
  osumm->set,obs_time_interval=time_intv

  flagdata=osumm->getdata(class_name='obs_summ_flag')
  flaginfo=osumm->get(class_name='obs_summ_flag')
  flagtimes=osumm->getdata(class_name='obs_summ_flag',/time)


  ;check if obs summ data is found
  IF (size(flagdata))[0] EQ 0 THEN return,-2
  IF n_elements(flagtimes) LT 2 THEN return,-2


  flags=flagdata.flags

  w=where( flags[0,*] EQ 0 AND $
           flags[1,*] EQ 0 AND $
           flags[17,*]EQ 0 )
; finds where RHESSI observes: requires
; no SAA flag (flag 0)
; no ECLIPSE flag (flag 1)
; no GAP flag (flag 17)


  IF (size(w))[0] NE 0 THEN BEGIN

; --------------------------------------------------------
; We know when RHESSI observed, but we need to convert the 
; indices to intervals that we store in edges
; --------------------------------------------------------

     edge=lonarr((size(w))[1],2)
     j=0
     tmp=w[j]
     edge[j]=[w[j],w[j]]

     FOR i=1L,((size(w))[1]-1) DO BEGIN
        IF (w[i]-tmp)EQ 1 THEN tmp=w[i] $
        ELSE BEGIN
           edge[j,1]=tmp
           tmp=w[i]
           j=j+1
           edge[j]=[w[i],w[i]]
           IF keyword_set(loud) THEN BEGIN
              print,j
              print,w[i]
           ENDIF
        ENDELSE
     ENDFOR
     edge[j,1]=tmp

; ---------------------------------------------------------
; Now we convert from indices intervals to time intervals
; ---------------------------------------------------------

     w=where(edge[*,1]GT 0)
     rettime=dblarr((size(w))[1],2)
     FOR i=0L,(size(rettime))[1]-1 DO $
        rettime[i,*]=[flagtimes[edge[i,0]],flagtimes[edge[i,1]]]

     RETURN,transpose(rettime)
     
ENDIF ELSE RETURN,-1 

END
