;+
; NAME:
;
; pg_hsi_get_att
;
; PURPOSE:
;
; returns the attenuator state at the input time
;
; CATEGORY:
;
; RHESSI automatic data processing
;
; CALLING SEQUENCE:
;
; ans=pg_hsi_get_att(time)
;
; INPUTS:
;
; time: time in anytim compatible format
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
; ans: attenuatoir state (0,1,2,3)
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
; print,pg_hsi_check_attdec('21-APR-2002 00:33:32')
;
; AUTHOR:
;
; Paolo Grigis, Institute for Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
;
; MODIFICATION HISTORY:
;
; 21-APR-2004 written PG
;
;-

FUNCTION pg_hsi_get_att,time

time=anytim(time)

time_intv=time+[-1.,1.]

osumm=obj_new('hsi_obs_summary')
osumm->set,obs_time_interval=time_intv

flagdata=osumm->getdata(class_name='obs_summ_flag')
;flaginfo=osumm->get(class_name='obs_summ_flag')
;flagtimes=osumm->getdata(class_name='obs_summ_flag',/time)


;check if obs summ data is found
IF (size(flagdata))[0] EQ 0 THEN BEGIN
   RETURN,-1
ENDIF


;attenuator flag is 14
;IDL> print,flaginfo.flag_ids[14]
;ATTENUATOR_STATE
;decimation flags are 18,19
; IDL> print,flaginfo.flag_ids[18]
; DECIMATION_ENERGY
; IDL> print,flaginfo.flag_ids[19]
; DECIMATION_WEIGHT
;gap flag is 17
;IDL> print,flaginfo.flag_ids[17]
;GAP_FLAG
;saa flag is 0
;IDL> print,flaginfo.flag_ids[0]
;SAA_FLAG
attflag=flagdata.flags[14,*]




RETURN,attflag[0]


END
