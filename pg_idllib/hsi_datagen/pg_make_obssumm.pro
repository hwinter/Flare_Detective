;+
; NAME:
;
; pg_make_obssumm
;
; PURPOSE:
;
; automatically make a rhessi PSH observing summary page of an event, given
; a peak time, choosing an ok obs time interval
;
; CATEGORY:
;
; rhessi quick data generation
;
; CALLING SEQUENCE:
;
; pg_make_obssumm,ptime [,pngfile=pngfile]
;
; INPUTS:
;
; ptime: event (peak) time
;
; OPTIONAL INPUTS:
;
; pngfile: set it if you want to save the image to a png file
; offset: time in seconds before and after end of observation interval to plot
; (default: 300 seconds)
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
;  Paolo Grigis, Institute of Astronomy, ETH Zurich
;
;
; MODIFICATION HISTORY:
;
;  11-FEB-2004 written
;
;
;-

PRO pg_make_obssumm,ptime,pngfile=pngfile,offset=offset

wdef,1,1024,1024

reftime=anytim(ptime)
delta_t=3600.
offset=fcheck(offset,5*60.)


obs_time_intervals=hsi_obs_time(reftime+delta_t*[-1.,1]) ;find out when RHESSI
                                ;observed around ptime
obs_time_intervals=anytim(obs_time_intervals)

okind=where(reftime GE obs_time_intervals[0,*] AND $
            reftime LE obs_time_intervals[1,*],count)

IF count GT 0 THEN BEGIN
   time_intv=obs_time_intervals[*,okind[0]]

   obs_summ_page,time_intv+offset*[-1,1],/goes,/old_window

   IF n_elements(pngfile) EQ 1 THEN BEGIN

      im=tvrd(/true)
      print,pngfile
      write_png,pngfile,im

   ENDIF

ENDIF 


END








