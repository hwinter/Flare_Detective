; Quick and dirty routine to plot a 3s-integrated spectrogram from Potsdam.
; spg are obtained at ftp://ooo.aip.de/osra/fits/
;
; EXAMPLE:
;	plot_osro_spg,'osra_radio_3s_20020220_1100.fts'
;

PRO plot_osra_spg,filename
	starttime=STRMID(filename,16,4,/REVERSE)+'/'+STRMID(filename,12,2,/REVERSE)+'/'+STRMID(filename,10,2,/REVERSE)+' '+STRMID(filename,7,2,/REVERSE)+':'+STRMID(filename,5,2,/REVERSE)+':00'
	spg=mrdfits(filename,0)	
	bla=mrdfits(filename,1)
	yaxis=bla.FREQUENCY/1e6
	xaxis=anytim(starttime)+3*DINDGEN(1200)
	show_image,TRANSPOSE(spg),xaxis,yaxis,/HMS,xpos=40
END
