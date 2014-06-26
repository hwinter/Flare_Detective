;+
; NAME:
;       HSI_DEC_CHAN2EN
;
; PURPOSE: 
;       returns the energy for a given channel, averaged over
;       detectors 1F 3F 4F 5F 6F 7F 8F 9F
;
; CALLING SEQUENCE:
;
;       energy=hsi_dec_chan2en(chan,time_intv=time_intv)      
;
; INPUTS:
;       chan: channel number
;       time_intv: a time interval
;
; OUTPUTS:
;       the averaged energy
;       
; KEYWORDS:
;
; EXAMPLE:
;
;        energy=hsi_dec_chan2en([50,60,70],time_intv='26-FEB-2002 '+['10:25','10:30'])
;       
; CALLS: hsi_get_e_edges
;       
; HISTORY
;       12-JUN-2003 written
;       13-JUN-2003 replaced total with average (as suggested by
;       Pascal)
;       25-JUN-2003 replaced average with total, as average won't work
;                   if chan is a scalar!
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION hsi_dec_chan2en,chan,time_intv=time_intv

IF NOT keyword_set(time_intv) THEN time_intv='26-FEB-2002 '+['10:25','10:30']

;get energy edges
energy_edges = hsi_get_e_edges(a2d_index=[0,2,3,4,5,6,7,8] $
                               ,time_wanted=time_intv,/new_gain,/twod)



;f.a.q. suggested method: (seems to be equivalent to previous)
;edges_kev = hsi_get_e_edges(gain_generation=1000, gain_time_wanted=time_intv, a2d_index=[0,2,3,4,5,6,7,8])

;averages over detectors

energy=total(total(energy_edges[*,*,chan],1),1)/16.

;simpler using ssw 'average'
;energy=average(energy_edges[*,*,chan],[1,2])
;BUT does not work if chan is a scalar!

RETURN,energy>0

END



