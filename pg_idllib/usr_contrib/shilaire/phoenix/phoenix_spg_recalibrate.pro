;+
;NAME:
; 	phoenix_spg_recalibrate.pro
;
;PROJECT:
; 	ETHZ Radio Astronomy
;CATEGORY:
; 	Utility
;PURPOSE:
;	This routine, given a Phoenix spectrogram in LINEAR SCALE, will recalibrate its values to have closer to reality SFU values.
;	Recalibration data is in the file phoenix_recalibrate.fits in the dbase section of the ETH SSW software.
;	phoenix_recalibrate.fits was derived by H. Perret from comparision with Trieste and RSTN radiometry data.
;
;
;CALLING SEQUENCE:
;	newspg=phoenix_spg_recalibrate(spg)
;	-OR-
;	newdata=phoenix_spg_recalibrate(data,freq_axis)
;
;INPUT:
; 	spg: an Phoenix spectrogram structure 
;		-OR-
;	data,freq : the data array and the frequency axis.
;
;KEYWORD INPUT:
;
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
;	Pascal Saint-Hilaire, 2004/04/06 written.
;		shilaire@astro.phys.ethz.ch
;-
;===================================================================================================================================================================================================================
FUNCTION phoenix_spg_recalibrate, spg, freq
	IF N_PARAMS() EQ 1 THEN BEGIN
		data=spg.spectrogram
		freq=spg.y
	ENDIF ELSE data=spg

	calibfile=GETENV('SSW')+'/radio/ethz/dbase/phoenix_recalibration.fits'
	calibtable=mrdfits(calibfile,1)
	
	;Now, interpolate for all frequencies...
	a=INTERPOL(calibtable.CONSTANT,calibtable.FREQ,freq,/SPLINE)	
	b=INTERPOL(calibtable.SLOPE,calibtable.FREQ,freq,/SPLINE)
  
	newdata=data
	FOR i=0L,N_ELEMENTS(freq)-1 DO newdata[*,i]=a[i]+b[i]*data[*,i]

	IF N_PARAMS() EQ 1 THEN BEGIN
		newspg=spg
		newspg.spectrogram=newdata
		RETURN,newspg
	ENDIF ELSE RETURN,newdata
END

