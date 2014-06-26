;+
; NAME:
;
; pg_hsi_sp_info 
;
; PURPOSE:
;
; prints relevant information for rhessi spectrum files
;
; CATEGORY:
;
; rhessi spectral analysis util
;
; CALLING SEQUENCE:
;
; pg_hsi_sp_info,spfile
;
; INPUTS:
;
; spfile: rhessi spectrum file
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
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 16-APR-2004 written PG
;
;-

PRO pg_hsi_sp_info,spfile

data1=mrdfits(spfile,1,/silent)
data2=mrdfits(spfile,2,/silent)
data3=mrdfits(spfile,3,/silent)

time_intv=data3.obs_time_interval
seg=data3.seg_index_mask
eb=data3.sp_energy_binning
IF data3.pileup_correct THEN ppar='en' ELSE ppar='dis'

print,'Time Range    :'+anytim(time_intv[0],/vms)+' /'+anytim(time_intv[1],/vms)
print,'Time bin width:'+string(data3.sp_time_interval)

print,'Segment used  : '+hsi_seg2str(seg)

print,'Position used : ('+strtrim(string(data3.used_xyoffset[0]),2)+'",' $
      +strtrim(string(data3.used_xyoffset[1]),2)+'")'

print,'Pileup correction was '+ppar+'abled with a threshold of ' $
      +strtrim(string(round(100*data3.pileup_threshold)),2)+'%'

print,'Energy bands  : '
print,eb

END



