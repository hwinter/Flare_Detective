;+
; NAME:
;      pg_hsi_intv_info
;
; PURPOSE: 
;      get info on attenuator states and decimation for the input time interval
;
; INPUTS:
;      time_intv: time interval (in anytim compatible format)
;  
; OUTPUTS:
;      info_str: info_str
;      
; KEYWORDS:
;      quiet: no screen output  
;
; EXAMPLE:
;      time_intv='26-FEB-2002 '+['10:15','10:45']
;      pg_hsi_intv_info,time_intv
;
; HISTORY:
;       
;       14-NOV-2003 made more general in scope
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

PRO pg_hsi_intv_info,time_intv,info_str=info_str,quiet=quiet

;get observing summary flags
  oso=obj_new('hsi_obs_summary')
  oso->set,obs_time_interval=time_intv
;  IF keyword_set(quiet) THEN oso->set,verbose=0; has no effect!

  flagdata_struct=oso->getdata(class_name='obs_summ_flag')
  flagdata=flagdata_struct.FLAGS
  flaginfo=oso->get(class_name='obs_summ_flag')
  flagtimes=oso->getdata(class_name='obs_summ_flag',/time)


;attenuator info

att_flag=14
att_min=min(flagdata[att_flag,*])
att_max=max(flagdata[att_flag,*])
att_change=att_min NE att_max

;front decimation (weight)info

fdecw_flag=19
fdecw_min=min(flagdata[fdecw_flag,*])
fdecw_max=max(flagdata[fdecw_flag,*])
fdecw_change=fdecw_min NE fdecw_max

info_str={att_min:att_min,att_max:att_max, $
          fdecw_min:fdecw_min,fdecw_max:fdecw_max, $
          att_change:att_change,fdecw_change:fdecw_change}

;screen output


IF NOT keyword_set(quiet) THEN BEGIN
    IF att_change EQ 0 AND fdecw_change EQ 0 THEN BEGIN
        print,'No changes in front decimation weight and attenuation'
        print,'Attenuator: '+strtrim(fix(att_min),2)
        print,'Front decimation weight: '+strtrim(fix(fdecw_min),2)
    ENDIF $
    ELSE BEGIN
        print,'Not constant decimation and/or atteunation'
        print,'Attenuator in range             '+strtrim(fix(att_min),2)+'-'+strtrim(fix(att_max),2)
        print,'Frpnt decimation weight in range '+strtrim(fix(fdecw_min),2)+'-'+strtrim(fix(fdecw_max),2)
    ENDELSE
ENDIF

END











