;+
; NAME:
;
; pg_check_hsi_transmitter
;
; PURPOSE:
;
; checks whether the RHESSI transmitter was on durng a time interval
;
; CATEGORY:
;
; RHESSI automatic data processing
;
; CALLING SEQUENCE:
;
; result=pg_check_hsi_transmitter(time_intv)
;
; INPUTS:
;
; time_intv: time interval
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
; result: 1/0 if transmitter was/was not active during time_intv
;        -1 if an error occurred
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
; uses the observing summary info
;
; EXAMPLE:
;
; print,pg_check_hsi_transmitter('26-FEB-2002 '+['10:20','10:40'])
;
; AUTHOR:
;
; Paolo Grigis, Institute for Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;;  
;
; MODIFICATION HISTORY:
;
;  11-FEB-2004 written P.G. based on hsi_obs_time
;  21-APR-2004 slightly modified checking algorithm P.G.
;-

FUNCTION pg_check_hsi_transmitter,time_intv

time_intv=anytim(time_intv)
;time_intv[1]=time_intv[1]+4; not really needed, but the output looks better

osumm=obj_new('hsi_obs_summary')
osumm->set,obs_time_interval=time_intv

flagdata=osumm->getdata(class_name='obs_summ_flag')
flaginfo=osumm->get(class_name='obs_summ_flag')
flagtimes=osumm->getdata(class_name='obs_summ_flag',/time)


;check if obs summ data is found
IF (size(flagdata))[0] EQ 0 THEN RETURN,-1

;transmitter flag is 11
;IDL> print,flaginfo.flag_ids[11]
;SC_TRANSMITTER

transflag=flagdata.flags[11,*]

;ind=where(transflag NE 0,count)
out=max(transflag)
RETURN, (out GT 0)
;RETURN, (count GT 0)

END
