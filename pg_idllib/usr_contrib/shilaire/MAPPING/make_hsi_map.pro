;
; EXAMPLE:
;	map=make_hsi_map(imo)
;	map=make_hsi_map(im,infoctrl)
;
; HISTORY:
; 	PSH 2002/02/28
; 	Modified 2003/12/15: returns -1 if image generation failed.
; 	Modified 2004/01/19: now accepts an image array+infoctrl struct. 
; 	Modified 2004/08/29: if infoctrl struct does not have all necessary tags, assumes certain values instead of crashing.
; 	Modified 2005/04/07: corrected a bug where the time entered was not correct. Important because the Earth is someties much closer to the Sun (20" or more)
;



FUNCTION make_hsi_map, in1, in2

IF N_PARAMS() EQ 1 THEN BEGIN
	;I have an image object or a file name
	IF datatype(in1) EQ 'OBJ' THEN BEGIN
		;I have a HESSI object...
		image=in1->getdata()
		info=in1->get()
	ENDIF ELSE BEGIN
		;I have a filename...
		fits2map,in1,map,err=err
		IF err NE '' THEN RETURN,-1 ELSE RETURN,map
	ENDELSE
ENDIF ELSE BEGIN
	;We have an image AND and infoctrl structure...
	image=in1
	info=in2
ENDELSE

IF N_ELEMENTS(image) EQ 1 THEN RETURN,-1
IF NOT tag_exist(info,'xyoffset',/QUIET) THEN info=add_tag(info,[0.,0.],'xyoffset')
IF NOT tag_exist(info,'pixel_size',/QUIET) THEN info=add_tag(info,[1.,1.],'pixel_size')
IF tag_exist(info,'time_range',/QUIET) THEN BEGIN
	time=info.TIME_RANGE[0]
	dur=anytim(info.TIME_RANGE[1])-anytim(info.TIME_RANGE[0])
ENDIF ELSE BEGIN
	IF tag_exist(info,'ut_ref',/QUIET) THEN BEGIN 
		PRINT,'make_hsi_map.pro WARNING: Using ut_ref!'
		time=info.ut_ref
		dur=0.	
	ENDIF 
ENDELSE

map =  make_map( image, $
                 xc=info.xyoffset[0], $
                 yc=info.xyoffset[1], $
                 dx=info.pixel_size[0], $
                 dy=info.pixel_size[1], $
                 time=anytim(time,/tai),$ 
		 dur=dur,$
		 xunits='arcsecs',$ 
		 yunits='arcsecs',$
		 id='HESSI')

RETURN, map
END
