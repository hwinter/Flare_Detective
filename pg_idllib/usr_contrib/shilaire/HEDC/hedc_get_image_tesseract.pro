;--------------------------------------------------------------------------------------
; Will get an image tesseract from HEDC, and put the file into the directory outdir.
;	-If the tesseract from the PTN panel is available, will return path to it (not create a new one!).
;	-Otherwise, looks for F+ movies...
;	-Otherwise, looks fro A+ movies...
;
; SIDE EFFECTS:
;	outfil might be changed.
;	If outfil is '', then no file are available/were made.
;
; EXAMPLE:
;	outfil='TEMP/hsi_tesseract.fits'
;	hedc_get_image_tesseract('HXS202261026', outfil)
;	IF hedc_get_image_tesseract('HXS202261026', outfil) THEN PRINT,'YES'
;
;	OK=hedc_get_image_tesseract('HXS208220152', outfil)
;
;
;;--------------------------------------------------------------------------------------
FUNCTION hedc_get_image_tesseract, eventcode, outfil
	; check whether an image tesseract is already available...if it is, change outfil appropriately.
	tmp=FINDFILE('/global/hercules/data2/archive/fil/*/HEDC_DP_pte*'+eventcode+'.fits')	
	IF tmp[0] EQ '' THEN BEGIN
		hedc_mk_imagetesseract, eventcode, outfile=outfil, OK=OK,/F
		IF NOT OK THEN RETURN,0
	ENDIF ELSE outfil=tmp[0]
RETURN,1
END
;--------------------------------------------------------------------------------------
