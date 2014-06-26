
; this file is called via cronjob


;=====================================================================================================================================================================================

CD,'~/LOGS/rapp_for_sdac'	; this should prevent ragfitsreadtmp.fit conflicts with other processes...

today=systim2anytim()	; in anytim double units

time_intv=anytim(today,/date)-86400D*4.+[0.,86399.]
PRINT,time_intv
rapp_spg_for_hessi_flarelist, time_intv

time_intv=anytim(today,/date)-86400D*12.+[0.,86399.]
PRINT,time_intv
rapp_spg_for_hessi_flarelist, time_intv

PRINT,'IDL-OK'

IDLversion=float(strmid(!version.release,0,3))
IF IDLversion EQ 5.4 THEN FLUSH,-1

END
;=====================================================================================================================================================================================
