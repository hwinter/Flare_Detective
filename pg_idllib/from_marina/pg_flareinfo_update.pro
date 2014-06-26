;+
; NAME:
;
; pg_flareinfo_update
;
; PURPOSE:
;
; updates the event info structure with information from the observing summary
; etc. 
;
; CATEGORY:
;
; RHESSI automatic data processing
;
; CALLING SEQUENCE:
;
; flarr=pg_flareinfo_update(flarr,gbin=gbin)
;
; INPUTS:
;
; flarr: array of structures of type flare
;
; OPTIONAL INPUTS:
;
; gbin: goes binning class
;
; KEYWORD PARAMETERS:
;
; time_intv: if set, computes the extended "good" time interval for the flare
; (that is, maximal connected time interval with sunlight, no gaps, no saa)
; spin_period: if set, compute the RHESSI spin period at peak time
; transmitter: if set, check whether the transmitter was active during 
; flare.time_intv
; attenuator_peak: if set, find the attenuators value at peak time
;
; OUTPUTS:
;
; uodated flare array structure
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
; EXAMPLE:
;
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
;  20-APR-2004 written P.G. 
;  21-APR-2004 added transmitter & attenuator_peak keyword P.G.
;-

FUNCTION pg_flareinfo_update,flarr,gbin=gbin,time_intv=time_intv $
                            ,spin_period=spin_period,transmitter=transmitter $
                            ,attenuator_peak=attenuator_peak


IF keyword_set(gbin) THEN BEGIN
    binlist=flarr.gbin

    ind=where(binlist EQ gbin,count)

    IF count EQ 0 THEN RETURN,-1

ENDIF ELSE ind=findgen(n_elements(flarr))

FOR i=0,n_elements(ind)-1 DO BEGIN
    act_flare=flarr[ind[i]]

    IF keyword_set(time_intv) THEN BEGIN

        overall_time_intv=anytim(act_flare.peak_time)+[-3600.,3600]
        tottime=hsi_obs_time(overall_time_intv)
        ;gibt gute Zeitintervalle, dh, sunlight, keine gaps, kein saa

        def_time_intv=[0d,0]
        IF n_elements(tottime) EQ 2 THEN def_time_intv=anytim(tottime)

        IF n_elements(tottime) GT 2 THEN BEGIN 
            tottime=anytim(tottime) 
            index=where(tottime[0,*] LT anytim(act_flare.peak_time) AND $
                      tottime[1,*] GT anytim(act_flare.peak_time),count) 
            IF count EQ 1 THEN def_time_intv=tottime[*,index] 
        ENDIF

        act_flare.time_intv=anytim(def_time_intv+[-300.,300],/vms)
        
    ENDIF

                         
    IF keyword_set(spin_period) THEN BEGIN
        spin_period=rhessi_get_spin_period(act_flare.peak_time)
        ;herausfinden der umlaufperiode des teleskops
        act_flare.spin_period=spin_period       
    ENDIF

    IF keyword_set(transmitter) AND act_flare.time_intv[0] NE '' THEN BEGIN
        act_flare.transmitter=pg_check_hsi_transmitter(act_flare.time_intv)
    ENDIF

    IF keyword_set(attenuator_peak) THEN BEGIN
        peak_time=act_flare.peak_time
        act_flare.attenuator_peak=pg_hsi_get_att(peak_time)
    ENDIF


    flarr[ind[i]]=act_flare
    
ENDFOR


RETURN,flarr


END
