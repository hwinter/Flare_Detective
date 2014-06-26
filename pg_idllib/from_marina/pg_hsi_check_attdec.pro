;+
; NAME:
;
; pg_hsi_check_attdec
;
; PURPOSE:
;
; checks whether the RHESSI attenuator and decimation were constant during a
; time interval, and optionally that no gap was present
;
; CATEGORY:
;
; RHESSI automatic data processing
;
; CALLING SEQUENCE:
;
; ans=pg_hsi_check_attdec(time_intv)
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
; gap: if set, check that no gap was present during the interval
; saa: if set, check that no saa was present during the interval
;
; OUTPUTS:
;
; ans: 1/0 if constant/not constant
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
; print,pg_hsi_check_attdec('21-APR-2002 '+['0','2'])
;
; AUTHOR:
;
; Paolo Grigis, Institute for Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
;
; MODIFICATION HISTORY:
;
;  14-APR-2004 written P.G. based on pg_check_hsi_attenuator
;  15-APR-2004 added gap and saa keyword P.G.
;-

FUNCTION pg_hsi_check_attdec,time_intv,gap=gap,saa=saa

;time_intv=anytim(time_intv)

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
decwflag=flagdata.flags[19,*]
deceflag=flagdata.flags[18,*]


if keyword_set(gap) then begin
    gapflag=flagdata.flags[17,*]
    if max(gapflag) gt 0 then gapok=0 else gapok=1
endif else gapok=1

if keyword_set(saa) then begin
    saaflag=flagdata.flags[0,*]
    if max(saaflag) gt 0 then saaok=0 else saaok=1
endif else saaok=1

min=min(attflag)
max=max(attflag)
attconstant=(min EQ max)

min=min(decwflag)
max=max(decwflag)
decwconstant=(min EQ max)

min=min(deceflag)
max=max(deceflag)
dececonstant=(min EQ max)


RETURN,attconstant*decwconstant*dececonstant*gapok*saaok


END
