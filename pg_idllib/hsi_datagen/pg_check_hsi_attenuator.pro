;+
; NAME:
;
; pg_check_hsi_attenuator
;
; PURPOSE:
;
; checks whether the RHESSI attenuator was on a particular state
; during a time interval (0:open,1:thin in,2:thick in,3: both in)
;
; CATEGORY:
;
; RHESSI automatic data processing
;
; CALLING SEQUENCE:
;
; pg_check_hsi_attenuator,time_intv,min=min,max=max,avg=avg,first=first
;                        ,last=last,constant=constant,error=error
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
;
;
; OUTPUTS:
;
; min:   minimum value of the attenuators
; max:   max value of the attenuators
; avg:   average value of the attenuators
; first: first value of the attenuators
; last:   last value of the attenuators
; constant: 1/0 if state was constant/not ocnstant during time_intv
; error: 1 if an error occurred, 0 otherwise
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
;   pg_check_hsi_transmitter,'21-FEB-2004 '+['0','2'],min=min,max=max $
;   ,avg=avg,first=first,last=last,constant=constant,error=error
;
;
; AUTHOR:
;
; Paolo Grigis, Institute for Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
;
; MODIFICATION HISTORY:
;
;  11-FEB-2004 written P.G. based on pg_check_hsi_transmitter
;
;-

PRO pg_check_hsi_attenuator,time_intv,min=min,max=max,avg=avg $
               ,first=first,last=last,constant=constant,error=error


time_intv=anytim(time_intv)

osumm=obj_new('hsi_obs_summary')
osumm->set,obs_time_interval=time_intv

flagdata=osumm->getdata(class_name='obs_summ_flag')
flaginfo=osumm->get(class_name='obs_summ_flag')
flagtimes=osumm->getdata(class_name='obs_summ_flag',/time)


;check if obs summ data is found
error=0
IF (size(flagdata))[0] EQ 0 THEN BEGIN
   error=1
   RETURN
ENDIF


;attenuator flag is 14
;IDL> print,flaginfo.flag_ids[14]
;ATTENUATOR_STATE

attflag=float(flagdata.flags[14,*])

min=min(attflag)
max=max(attflag)
avg=total(attflag)/n_elements(attflag)
first=attflag[0]
last=attflag[n_elements(attflag)-1]
constant=(min EQ max)

RETURN


END
