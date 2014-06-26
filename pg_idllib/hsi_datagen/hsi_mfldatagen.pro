;+
; NAME:
;      hsi_mfldatagen
;
; PURPOSE: 
;      generate a standard data set for use in microflares research
;      From the input time interval search for RHESSI observations
;      (RHESSI not in night, saa), then for each ininterrupted interval
;      generate a spectrogram (plot, idl save file, ragfits)
;      
;
; CALLING SEQUENCE:
;      hsi_mfldatagen,time_intv [ ,optional keywords]
;
; INPUTS:
;      time_intv: time_interval for the plot (any format accepted by anytim)
;
;      directory: the directory for writing data
;      delay: supplementary time at the beginning & end of the
;             observation, in seconds.  default: 300 sec
;
; KEYWORDS:
;      loud: print the RHESSI observation time intervals
;      high_energy: compute the spectrogram up to higher energies
;      noobssumm: inhibit checking RHESSI observation time using the
;      obs summary, to use for data without obs summary, like in the
;      beginnning of the mission      
;
; COMMENT:
;    
;
; HISTORY:
;      
;       04-OCT-2002 written
;       09-OCT-2002 added some keyword for more general use
;       17-OCT-2002 added noobssumm keyword
;
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-


PRO hsi_mfldatagen,time_intv,directory=directory,loud=loud,$
                   high_energy=high_energy,delay=delay,noobssumm=noobssumm

;----------------------------------------------------
;data initialization
;----------------------------------------------------

base_dir='/global/tethys/data1/pgrigis/'
IF NOT exist(directory) THEN directory='autodata'
base_dir=base_dir+directory+'/'

energy_band=findgen(98)+3
segment=[1,0,1,1,1,1,0,1,1,0,0,0,0,0,0,0,0,0]
loadct,5

IF keyword_set(high_energy) THEN energy_band=findgen(398)+3
IF not exist(delay) THEN delay=300

;-----------------------------------------------------
;get RHESSI observation times
;-----------------------------------------------------

IF keyword_set(noobssumm) THEN hsiobs=anytim(time_intv) ELSE $
  hsiobs=hsi_obs_time(time_intv)

IF keyword_set(loud) THEN print,anytim(hsiobs,/yohkoh)

;-----------------------------------------------------
;data generation through hsi_spg_ragfitswrite
;-----------------------------------------------------
IF n_elements(hsiobs) GT 1 THEN BEGIN

    IF n_elements(hsiobs) EQ 2 THEN BEGIN

        time=anytim(hsiobs) 
        time[0]=time[0]-delay
        time[1]=time[1]+delay
        spgpngfile=base_dir+'hsi_spg_'+anytim(time[0],/ccsds)+'.png'
        spgfitfile=base_dir+'hsi_spg_'+anytim(time[0],/ccsds)+'.fts'
        spgidlfile=base_dir+'hsi_spg_'+anytim(time[0],/ccsds)+'.dat'
        scspgpngfile=base_dir+'hsi_spgsc_'+anytim(time[0],/ccsds)+'.png'
        scspgfitfile=base_dir+'hsi_spgsc_'+anytim(time[0],/ccsds)+'.fts'
        scspgidlfile=base_dir+'hsi_spgsc_'+anytim(time[0],/ccsds)+'.dat'

        hsi_spg_ragfitswrite,time,spg=spg,scspg=scspg,filename=spgfitfile,$
        energy_band=energy_band,segment=segment,scfilename=scspgfitfile
        
        save,spg,filename=spgidlfile
        save,scspg,filename=scspgidlfile

        plot_hsi_spg,spg
        img=tvrd(/true)
        tvlct,r,g,b,/get 
        write_png,spgpngfile,img,r,g,b
        plot_hsi_spg,scspg
        img=tvrd(/true)
        tvlct,r,g,b,/get 
        write_png,scspgpngfile,img,r,g,b
        heap_gc

    ENDIF $
    ELSE BEGIN

        dim=(size(hsiobs))[2]

        FOR i=0,dim-1 DO BEGIN
            time=dblarr(2)
            time[*]=anytim(hsiobs[*,i])
            time[0]=time[0]-delay
            time[1]=time[1]+delay

            spgpngfile=base_dir+'hsi_spg_'+anytim(time[0],/ccsds)+'.png'
            spgfitfile=base_dir+'hsi_spg_'+anytim(time[0],/ccsds)+'.fts'
            spgidlfile=base_dir+'hsi_spg_'+anytim(time[0],/ccsds)+'.dat'
            scspgpngfile=base_dir+'hsi_spgsc_'+anytim(time[0],/ccsds)+'.png'
            scspgfitfile=base_dir+'hsi_spgsc_'+anytim(time[0],/ccsds)+'.fts'
            scspgidlfile=base_dir+'hsi_spgsc_'+anytim(time[0],/ccsds)+'.dat'

            hsi_spg_ragfitswrite,time,spg=spg,scspg=scspg,filename=spgfitfile,$
            energy_band=energy_band,segment=segment,scfilename=scspgfitfile
            
            save,spg,filename=spgidlfile
            save,scspg,filename=scspgidlfile

            plot_hsi_spg,spg
            img=tvrd(/true)
            tvlct,r,g,b,/get 
            write_png,spgpngfile,img,r,g,b
            plot_hsi_spg,scspg
            img=tvrd(/true)
            tvlct,r,g,b,/get 
            write_png,scspgpngfile,img,r,g,b
            heap_gc
        ENDFOR
    ENDELSE
ENDIF $
ELSE return

END




