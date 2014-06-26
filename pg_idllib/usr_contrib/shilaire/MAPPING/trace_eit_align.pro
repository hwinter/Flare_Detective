; PURPOSE:
; 	Properly finds TRACE's pointing, given a TRACE and EIT maps or fits files.
; 	Done according to P. Gallagher's webpage.
;	Actually returns corrected TRACE map
;
; INPUTS:
;	trace_thingy: TRACE map or fits file
;	trace_thingy: EIT map or fits file
;	xrange and yrange are regions (arcsecs) where there are relevant features to use for correlation...
; 	If /OFFSET is set, returns the offsets instead of corrected TRACE map (in arcsecs).
;
; EXAMPLE:
;	;;;;;RESTORE,'camp1/eit_trace_maps.dat',/VERB
;	corrected_trace_map=trace_eit_align('camp1/TRACE/tri20020226.1000_0074.pl', eitmap, [850,1000],[-300,-150])
;
;
; HISTORY:
;	PSH 2003.07.28 written.
;


FUNCTION trace_eit_align, trace_thingy, eit_thingy, xrange,yrange, SHOW=SHOW,OFFSET=OFFSET
	IF datatype(trace_thingy) EQ 'STR' THEN BEGIN
		;fits2map,trace_thingy,trace_map 
		mreadfits,trace_thingy,index, data
		trace_prep, index, data, trace_index, trace_data, /wave2point
		index2map, trace_index, trace_data, trace_map
	ENDIF ELSE trace_map=trace_thingy
	IF datatype(eit_thingy) EQ 'STR' THEN BEGIN
		eit_prep, eit_thingy, eit_index, eit_data
		index2map, eit_index, eit_data, eit_map
		eit_map = map2earth( eit_map ) ; SOHO @ L1 -> Earth
	ENDIF ELSE eit_map=eit_thingy
	
	sub_map, eit_map, sub_eit, xrange = xrange, yrange = yrange
	sub_map, trace_map, sub_trace, xrange = xrange, yrange = yrange

	IF KEYWORD_SET(SHOW) THEN BEGIN
		eit_colors, 195
		!P.MULTI = [ 0, 2, 1 ]
		plot_map, sub_eit, /log
		plot_map, sub_trace, /log
		!P.MULTI=0
	ENDIF

	trace_image = sub_trace.data
	sz = size(trace_image,/dim)
	cube = fltarr( sz[0], sz[1], 2 )
	rsub_eit = coreg_map(sub_eit,sub_trace)
	cube[*,*,0] = rsub_eit.data
	cube[*,*,1] = sub_trace.data

	offsets = get_correl_offsets(cube)
	PRINT,'Offsets: '
	PRINT,offsets
	
	arcsec_offset=[offsets[0,1] * trace_map.dx,offsets[1,1] * trace_map.dy]
	correct_trace_map = shift_map( trace_map, arcsec_offset[0], arcsec_offset[1] )

	IF KEYWORD_SET(OFFSET) THEN RETURN,arcsec_offset ELSE RETURN,correct_trace_map	
END


