;start this file from a shell with the following command line:
;	/global/pandora/home/shilaire/HEDC/bin/hedc_ssw_batch hedc_cron_test > /dev/null
;	/global/hercules/data1/rapp_idl/shilaire/psh_ssw_exec hedc_cron_test
;		(might want to switch to a TEMP dir first...)
;

	resolve_routine,'mpfit',/EITHER,/COMPILE_FULL_FILE,/NO_RECOMPILE
	
;	set_plot,'Z'
;	hedc_tepgen, '2002/02/26 '+['10:26','10:27'],[925,-225],newdatadir='~/TEMP/',imgalg='back',deltat=30.,ebands=[[6,12],[12,25],[25,50]]

;	psh_win,512
;	hessi_ct,/QUICK	
;	!P.MULTI=[8,3,3,0,1]	
;	plot_map,{data: DIST(100), xc:0, yc:0, dx:1, dy:1, time:anytim(/TAI,'2000/02/26 01:00:00'), id:'DUMMY'}
;	!P.MULTI=[0,1,3]
;	PLOT,FINDGEN(100)	
;	!P.MULTI=[8,3,3,0,1]	
;	plot_map,{data: 1d/(1+DIST(100)), xc:0, yc:0, dx:1, dy:1, time:anytim(/TAI,'2000/02/26 01:00:00'), id:'DUMMY'}
;	TVLCT,r,g,b,/GET
;	WRITE_PNG,'test1.png',TVRD(),r,g,b	
;	DEVICE,/CLOSE

;	fil='~/TEMP/tesseract.fits'
;	hedc_imspec, -1, [0,1,2],fitsfile=fil,SKIP=2, pngfile='test.png'

	
	
;2004/08/06	
	;obs_summ_page,'2002/02/26 '+['10:20','10:40']
	PRINT,hsi_dec_chan2en([1,2,3],time_intv='2002/02/26 '+['10:20','10:40'])


	
END
;==============================================================================================


