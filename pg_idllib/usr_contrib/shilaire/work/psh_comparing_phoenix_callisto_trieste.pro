; time_intv='2003/10/28 '+['11:00','11:01']
; psh_comparing_phoenix_callisto_trieste, time_intv, 1
;
;triestechannel is between 1 and 6
;

PRO psh_comparing_phoenix_callisto_trieste, time_intv, triestechannel, XS=XS

	trieste_freq=[237,327,408,610,1420,2695]

	;get phoenix data
	ph_spg=phoenix_spg_get(time_intv,/DECOMPRESS)
	ph_lc=ph_spg.spectrogram[*,where_nearest(ph_spg.y,trieste_freq[triestechannel-1])]
	
	;get  Callisto data
	setenv,'RAG_ARCHIVE=/ftp/pub/rag/callisto/observations/'
	cal_data=rapp_get_spectrogram(time_intv,xax=cal_x,yax=cal_y,/ANYTIM)
	cal_lc=cal_data[*,where_nearest(cal_y,trieste_freq[triestechannel-1])]
	
	;get Trieste data
	trieste1='/ftp/pub/hedc/fs/data3/users/shilaire/trieste/trst_radio_ms_20031028_074000.fts'
	trieste2='/ftp/pub/hedc/fs/data3/users/shilaire/trieste/trst_radio_xs_20031028_074000.fts'
	IF KEYWORD_SET(XS) THEN fil=trieste2 ELSE fil=trieste1
	rapp_read_trieste, fil, triestechannel, tr_times,tr_lc	;,/REMOVE
	
	;PLOT the whole business
	clear_utplot
	!p.multi=[0,1,3]
	charsize=2.0
	utplot,ph_spg.x,ph_lc,ytit='Phoenix '+strn(ph_spg.y[where_nearest(ph_spg.y,trieste_freq[triestechannel-1])],format='(f10.0)')+' MHz',charsize=charsize, xmar=[10,1],ymar=[1,1],xtit=''
	utplot,cal_x,cal_lc,ytit='Callisto '+strn(cal_y[where_nearest(cal_y,trieste_freq[triestechannel-1])],format='(f10.0)')+' MHz',charsize=charsize, xmar=[10,1],ymar=[1,1],xtit=''
	utplot,tr_times,tr_lc,timerange=time_intv,ytit='Trieste '+strn(trieste_freq[triestechannel-1],format='(f10.0)')+' MHz',charsize=charsize, xmar=[10,1],ymar=[2,1],xtit=''
END

