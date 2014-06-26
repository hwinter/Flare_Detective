;+
; NAME:
;      argos_intspg
;
; PURPOSE: 
;      integrates (average!) a spectrogram to produce a single spectrum
;
; PROCEDURE:
;      
;
; CALL SEQUENCE:
;      out_spg=argos_intspg(spg)
;
;
; INPUTS:
;     spf: ARGOS observed spectrogram
; 
;  
; OUTPUTS:
;     out_spg:an integrated spectrogram
;     err: set to 1 if an error happened, otherwise to 0 
;
;
; HISTORY:
;     15-MAR-2004 written PG
;     
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-

FUNCTION argos_intspg,spg

err=0

;check if input is a spectrum or a spectrogram
IF size(spg,/tname) EQ 'STRUCT' THEN BEGIN


    time=spg.x
    ntime=n_elements(spg.x)

    ;replace tag values by averages
    out_spg=rep_tag_value(spg,transpose(total(spg.spectrogram,1)/ntime),'SPECTROGRAM')
    out_spg=rep_tag_value(out_spg,total(time)/ntime,'X')

ENDIF ELSE BEGIN

    print,'Please input a valid spectrogram structure!'
    err=1
    RETURN,-1
    
ENDELSE


RETURN,out_spg

END



