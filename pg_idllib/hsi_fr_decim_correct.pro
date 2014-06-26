;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;NOT ready now...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;+
; NAME:
;       HSI_FR_DECIM_CORRECT
;
; PURPOSE: 
;       correct a count spectrogram for front decimation
;
; CALLING SEQUENCE:
;       hsi_fr_decim_correct,sp_struct,seg_index_mask
;
; INPUTS:
;
;       sp_struct: a spectrum data structure, as generated by the
;       spectrum object if sp_data_structure is set
;
;       seg_index_mask: segments used, an byte array of 18 elements
;
; OUTPUTS:
;
;       corr_sp_struct: the corrected spectrum data structure
;       
; KEYWORDS:
;       
;
; EXAMPLE:
;       
;
;
; VERSION
;       
; HISTORY
;       06-JUN-2003 begin to write it
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION hsi_fr_decim_correct,sp_struct,seg_index_mask

corr_sp_struct=sp_struct
spg=sp_struct.counts
obs_time_intv=[min(sp_struct.ut),max(sp_struct.ut)]
print,anytim(obs_time_intv,/vms)

seg_index_mask[9:17]=0
wh=where(seg_index_mask NE 0,count)
IF count GT 0 THEN $
    seg_index_mask[where(seg_index_mask NE 0) ]=1 $
ELSE $
    RETURN,-1

dim=size(spg)

IF dim[0] EQ 2 THEN BEGIN

    ndet=1
    ntim=dim[2]

ENDIF $
ELSE BEGIN

    ndet=total(seg_index_mask)
    ntim=dim[3]

ENDELSE

oso=obj_new('hsi_obs_summary')
 

FOR j=0,ntim-1 DO BEGIN
  
    oso->set,obs_time_interval=sp_struct[j].ut
   
    flagdata_struct=oso->getdata(class_name='obs_summ_flag')
        

    weight=average(flagdata_struct.flags[19])
    channel=average(flagdata_struct.flags[18])
     

    IF weight EQ 0 THEN BEGIN
        corr_sp_struct[j].counts=sp_struct[j].counts
        
    ENDIF ELSE BEGIN

        IF abs(weight-floor(weight)) LT 1e-4 THEN BEGIN
 
            FOR k=0,ndet DO BEGIN

                ;get energy from channel

                ;convert it!

                ;done!


            ENDFOR
            
        ENDIF ELSE BEGIN

            corr_sp_struct[j].counts[*,*]=0
 
        ENDELSE
    ENDELSE
    


    

;    print,anytim(flagtimes,/vms)
;     print,flaginfo.flag_ids[18];DECIMATION_ENERGY 
;     print,flaginfo.flag_ids[19];DECIMATION_WEIGHT 

        
    ;flaginfo=oso->get(class_name='obs_summ_flag')
    ;flagtimes=oso->getdata(class_name='obs_summ_flag',/time)
    ;rates_struct=oso->getdata()
      
        
 

ENDFOR

RETURN,corr_sp_struct

END

;testing


;energy_range=[8,10]

;hsi_chan_ranges, energy_range, chan_ranges,a2d_index=0,time_wanted='02-MAY-2002 06:00',/new_gain

;print,chan_ranges

; time_intv='06-MAY-2002 '+['00:50','01:35']

; oso=obj_new('hsi_obs_summary')
; oso->set,obs_time_interval=time_intv
        
; ;rates_struct=oso->getdata()
      
        
; flagdata_struct=oso->getdata(class_name='obs_summ_flag')
        
; flagdata=flagdata_struct.FLAGS
        
; flaginfo=oso->get(class_name='obs_summ_flag')
        
; flagtimes=oso->getdata(class_name='obs_summ_flag',/time)

; print,flaginfo.flag_ids[18]
; print,flagdata[18,*]

; ;63




;energy_edges = hsi_get_e_edges(a2d_index=0, time_wanted='02-MAY-2002' ,$
;                               /new_gain)
;energy_edges = hsi_get_e_edges(a2d_index=2, time_wanted='26-FEB-2002' ,$
;                               /new_gain)
;energy_edges = hsi_get_e_edges(a2d_index=8,time_wanted='26-FEB-2002' ,$
;                               /new_gain)
;energy_edges = hsi_get_e_edges(a2d_index=7,time_wanted='26-FEB-2002' ,$
;                               /new_gain)

; datchan=fltarr(9,2)
; .run
; FOR i=0,8 do begin
; energy_edges = hsi_get_e_edges(a2d_index=i,time_wanted=time_intv ,$
;                                /new_gain,/twod)

; datchan[i,*]=energy_edges[0,*,63]

; energy_edges = hsi_get_e_edges(a2d_index=i,time_wanted=time_intv ,$
;                                /new_gain,/twod)

; datchan[i,*]=energy_edges[0,*,63]

; print,'Channel 63 is for det '+strtrim(string(i+1),2)+' : ',datchan[i,*]
; ENDFOR
; end




; more decimation testing...

; time_intv='06-MAY-2002 '+['01:13','01:17']
; obs_summ_page,time_intv

; time_intv='03-MAY-2002 '+['09:48','09:52']
; obs_summ_page,time_intv

; time_bin=4.
; segment=replicate(1B,18)
; segment[5]=1
; energy_band=findgen(100)/5.+3

;      sp=hsi_spectrum()

;      sp->set,obs_time_interval=time_intv
;      sp->set,sp_time_interval=time_bin
;      sp->set,seg_index_mask=segment 
;      sp->set,sp_energy_binning=energy_band
;      sp->set,sp_semi_calibrated=0
;      sp->set,sp_data_units='Counts'; means total counts in the energy-time bin
;      sp->set,sp_data_structure=1
;      sp->set,sum_flag=0
     

;      sp_struct=sp->getdata()
;      sp_par=sp->get()


; spg=sp_struct.counts
; tim=0.5*(sp_struct.ut[1]+sp_struct.ut[1])

; utplot,tim,reform(total(spg[0:30,0,*],1)),0

; utplot,tim,spg[10,0,*],psym=10

; print,energy_band(30)

; check time  == 20 <> time == 26

; det=8
; plot,energy_band,spg[*,det,20],/xlog,/ylog,yrange=[1e-1,1e2],/xst,/yst,psym=10
; oplot,energy_band,spg[*,det,26],color=155,psym=10

; plot,energy_band,total(spg[*,2:8,20],2),/xlog,/ylog,yrange=[1e-1,1e3],/xst,/yst,psym=10
; oplot,energy_band,total(spg[*,2:8,26],2),color=155,psym=10


; , $
;            rate_corrections, use_a2d=use_a2d, $
;            a2d_index=a2d_index, new_gain=new_gain,  $
;            time_wanted=time_wanted, powerlaw=powerlaw, $
;            pl_literal=pl_literal,gain_generation=gain_generation

; RETURN,energy
   
; END






; obs_summ_page,'02-MAY-2002 '+['0','24']







