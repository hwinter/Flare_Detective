;+
; NAME:
;       merge_spg
;
; PURPOSE: 
;       merge two spectrograms
;
; CALLING SEQUENCE:
;       spg=merge_spg(spg1,spg2)
;
; INPUTS:
;       spg2,spg2: two spg structures
;
; HISTORY:
;       17-DEC-2002 written
;
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION merge_spg,spg1,spg2

IF total(where(spg1.y NE spg2.y)) LT 0  THEN BEGIN

    totimage=[spg1.spectrogram,spg2.spectrogram]
    totx=[spg1.x,spg2.x]

    spg={spectrogram:totimage,x:totx,y:spg1.y}
    
    RETURN,spg
ENDIF $
ELSE RETURN,-1

END
