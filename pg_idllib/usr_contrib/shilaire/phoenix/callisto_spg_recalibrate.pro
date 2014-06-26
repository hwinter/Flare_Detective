;+
;NAME:
; 	callisto_spg_recalibrate.pro
;
;PROJECT:
; 	ETHZ Radio Astronomy
;CATEGORY:
; 	Utility
;PURPOSE:
;	This routine, given a Callisto spectrogram (in original LOG scale), will recalibrate it to yield proper values: either in the usual 
;	Phoenix-2 45*LOG10(SFU+10) format, or in linear SFU values (when keyword /SFU is set).
;	Recalibration data is in the file callisto_recalibrate.fits in the dbase section of the ETH SSW software.
;	callisto_recalibrate.fits was derived by H. Perret from comparision with recalibrated Phoenix spectrograms.
;
;
;CALLING SEQUENCE:
;	newspg=callisto_spg_recalibrate(spg)
;	-OR-
;	newdata=callisto_spg_recalibrate(data,freq_axis)
;
;INPUT:
; 	spg: an Callisto spectrogram structure 
;		-OR-
;	data,freq : the data array and the frequency axis.
;
;KEYWORD INPUT:
;	/SFU: if set, will return result in linear SFU scale. Otherwise, in Phoenix-2's usual 45*LOG10(SFU+10) format...
;	/TWO: if set, will take the second (smoother) calibration...
;
;OUTPUT:
;	newspg: the newly calibrated spectrogram structure
;	-OR-
;	newdata
;
;KEYWORD OUTPUT:
;
;
;RESTRICTIONS:
;	Because we use the INTERPOL IDL routine, the values in the freq array must be monotonic (increasing or decreasing).
;
;EXAMPLES:
;
;
;
;HISTORY:
;	Pascal Saint-Hilaire, 2004/04/16 written.
;		shilaire@astro.phys.ethz.ch
;-
;===================================================================================================================================================================================================================
FUNCTION callisto_spg_recalibrate, spg, freq, SFU=SFU
	IF N_PARAMS() EQ 1 THEN BEGIN
		data=spg.spectrogram
		freq=spg.y
	ENDIF ELSE data=spg

	IF KEYWORD_SET(TWO) THEN calibfile=GETENV('SSW')+'/radio/ethz/dbase/callisto_recalibration2.fits' ELSE calibfile=GETENV('SSW')+'/radio/ethz/dbase/callisto_recalibration.fits'
	calibtable=mrdfits(calibfile,1)
	
	;Now, interpolate for all frequencies...
	a=INTERPOL(calibtable.CONSTANT,calibtable.FREQ,freq,/SPLINE)	
	b=INTERPOL(calibtable.SLOPE,calibtable.FREQ,freq,/SPLINE)
  
	newdata=data
	FOR i=0L,N_ELEMENTS(freq)-1 DO newdata[*,i]=a[i]+b[i]*data[*,i]
	
	IF KEYWORD_SET(SFU) THEN newdata=10^(newdata/45.)-10.

	IF N_PARAMS() EQ 1 THEN BEGIN
		newspg=spg
		newspg.spectrogram=newdata
		RETURN,newspg
	ENDIF ELSE RETURN,newdata
END

