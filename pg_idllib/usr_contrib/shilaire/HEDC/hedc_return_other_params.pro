; PSH, 2001/05/12

; This simple function returns all (supposedly) interesting parameters
;from images/lightcurves/spectra that are not already included in the
;schema search fields. The output of this routine is supposed to go
;directly to the txt_ana_algParameter "free-text" field.

; In the end, if one truly wants ALL parameters, one will have to download
;	the associated fits file.


; CALL:
;	txt_info=hedc_return_params(in_struct)

;INPUT:
;	in_struct: an info & control structure as given by obj->get(), where 'obj' 
;			is a Hessi image, lightcurve or spectrum object

;OPTIONAL INPUT KEYWORDS:
;	/NL		 : text lines are separated by the NEWLINE (ASCII 10) cahracter
;				intead of the " //" code.

;OUTPUT:
;	txt_info: the info that is deemed relevant. 
;				Shouldn't be longer than 500 characters.

;EXAMPLE:
;	an_analysis_struct.txt_ana_algParameter=hedc_return_other_params(obj->get())


; Modified 2001/05/17 : lines are separated by the " //" character set.
; Modified 2001/05/29 : added the /NL keyword
; Modified 2001/09/06 : removed /verbose keyword, cuts txt to a max. of 500 chars. 

;*******************************************************************************
;*******************************************************************************
;*******************************************************************************
;*******************************************************************************
;*******************************************************************************



FUNCTION hedc_return_other_params,in_struct,NL=NL

NEWLINE=' //'
if keyword_set(NL) then NEWLINE=STRING(10B)

; some lightweight error checking...
if datatype(in_struct) ne 'STC' then begin
							print,'........... Input to hedc_return_other_params.pro is not even a structure !!!'
							return,'NOT A STRUCTURE !'
									 endif
; initialize...
txt=''

; list of tags to be checked for. -> easy to update !

tl=['DET_INDEX_MASK','SEG_INDEX_MASK',			$
	'FLATFIELD','WEIGHT','NATURAL_WEIGHTING','UNIFORM_WEIGHTING','SPATIAL_FREQUENCY_WEIGHT',	$
	'TAPER','MODPAT_SKIP','R0_OFFSET','RMAP_DIM','N_MODPAT','TIME_BIN_DEF','TIME_BIN_MIN',		$
	'SASZERO','N_EVENT',																		$
	'LTC_ENERGY_BAND',																			$
	' SP_CHAN_BINNING','SP_SEMI_CALIBRATED','SP_DATA_UNIT'	]

tnames=TAG_NAMES(in_struct)
for i=0,n_elements(tl)-1 do begin
	ss=WHERE(tnames eq tl(i))
	if ss(0) ne -1 then begin
				txt=txt+tl(i)+': '
				for j=0,n_elements(in_struct.(ss(0)))-1 do txt=txt+strn(in_struct.(ss(0))(j))+' '
				txt=txt+NEWLINE	; those are the set of characters that mean NEWLINE to the import JAVA routines.
						endif							
							endfor
;if txt ne '' then txt=txt+string(10B)
if strlen(txt) gt 500 then begin
	print,'.............text output longer then 500 characters !!!!'
	print,'...........cutting off the part above the first 500 characters...'
	txt=STRMID(txt,0,500)
endif
RETURN,txt
END
