;+
;
;*NAME:
;	HXRSVIEW
;
;*PURPOSE:
;	1. Simple HXRS Data Viewer, widget UI version
;
;*CATEGORY:
;	PLOT
;
;*CALLING SEQUENCE:
;	HXRSVIEW
;
;*INPUTS:
;	Filename of HXRS data file, format: fits
;
;*OUTPUTS:
;	Plot graph on screen
;
;*NOTES:
;	Filenames and other parameters are specified interactively using widgets.
;
;	Time from, Time to ..... updated automatically after file is loaded
;	Det. S(N) .............. whole detector S(N) on/off
;	Summa .................... summa of all channels of probe S(N) on/off
;	0..8 ................... channel 0 .. 8 of probe S(N) on/off
;	Offset has this meaning:
;	  log (default) scale is set ... displayed_value = data_value * 10^offset
;	  lin scale is set ............. displayed_value = data_value + 10*offset
;
;	Please mind that genius do'nt fall from the sky.
;	I wrote this piece of sw in several weeks without any previous
;	knowlegde of IDL
;
;*PROCEDURES USED:
;	SXPAR, FITS_OPEN, FITS_CLOSE, UTPLOT, OUTPLOT, UTIME, ATIME,
;	MRDFITS, ANYTIM, UTC2STR
;
;*HISTORY:
;	Written by:	Martin Cupak (cupak@asu.cas.cz)	May, 1999
;	Version 0.99	 7-May-1999
;		Tested on IDL, version SPARC SUNOS UNIX 4.0.1,
;		with SPEX and other astron libraries
;	Version 0.99.1	11-May-1999
;		Automatic conversion when loading *.bin file using external call
;		of bin2fits (UNIX only, bin2fits must be in $PATH)
;		FITS - formated *.fit file is placed in the same directory as *.bin
;		Note: conversion still not functionning, must be debugged on Sun, 'cause
;		      on my MS Windows version of IDL doesn't function command SPAWN
;	Version 1.0		26-May-1999
;		Time resolution bug repaired
; 		With adapted libraries ( all names of files and functions externally
;		called are shorten to 8 chars, 'cause the version I'm using cannot work
;		with longer filenames ) are all features except of automatic conversion
;		functionnig also on PC/MS Windows
;	Version 2.0		14-March-2000
;		Should be final release.
;		Rewritten file read routine for new HXRS FITS data format
;		using binary table extension.
;		Old FITS format is now not supported.
;		Removed "Write Converted" function, resp. changed to
; 		"Save Converted" function, which saves part of converted data
;		of specified time range into a file using IDL function SAVE.
;		Saved variables: bt ... double float, base time for utplot
;		                 cd ....... data array (array of struct)
;		PC/MS Windows with IDL 4.0.X (8.3 filenemes) is not supported.
;	Version 2.01.1		26-July-2000
;		Test version of improved 2.X
; 		NSUM Summing in plots added
;		Saving selected data in FITS format in work
;	Version 2.01.2		9-August-2000
;		Another test version of improved 2.X
;		Saving selected data in FITS format test version 
;	Version 2.01.3		9-August-2000
;		Another test version of improved 2.X
;		Removed residua of MS-DOS 8.3 files compatibility
;		Not supported any more.
;	Version 2.02.0		14-august-2000
;		Should be final release of improved version.
;		New functions added: NSUM in plots,
;		and "Save FITS" - saves selacted data
;		interval in FITS format.
;		Full version is now renamed to "HXRSEDIT".
;		This public, view-only version created ("HXRSVIEW").
;		In public version are save functions and 
;		raw data view disabled.
;
;-----------------------------------------------------------------------------

;=============================================================================
;      Func 'unix2ut'
;        converts unix-style time (which is given in seconds since 70/1/1)
;        to IDL-style time (seconds since 79/1/1)
;=============================================================================

function unix2ut,unix_time
return, unix_time - 2.8399680d+08
end

;=============================================================================
;      Func 'ut2unix'
;        converts IDL-style time (seconds since 79/1/1)
;        to unix-style time (which is given in seconds since 70/1/1)
;=============================================================================

function ut2unix,ut_time
return, ut_time + 2.8399680d+08
end

;=============================================================================
;      Proc 'set_hxrs_view_color_table'
;=============================================================================

pro set_hxrs_view_color_table

common data_tables, read_data, raw_data, raw_time, bt, primary_header, secondary_header, $
			cd, mwrfits_data, $
 			conv_time, conv_base_time, num_of_blocks, y_scale, loaded, $
			num_of_normal_blocks, num_of_flare_blocks, num_of_conv_blocks, $
			ct_red, ct_green, ct_blue, overwrite, last_file_name, $
			time_from, time_to, conv_time_from, conv_time_to, old_time_from, old_time_to

	ct_red = [28,255,255,255,200,230,0,0,141,168,$
		2,179,187,194,110,172,3,0,80,110]
	ct_green = [80,152,37,129,80,190,178,224,143,168,$
		12,112,5,110,3,132,127,112,80,62]
	ct_blue = [255,0,0,130,255,10,255,34,100,40,$
		160,2,4,120,180,15,166,0,60,19]

	if( !D.n_colors le 255 ) then tvlct, ct_red, ct_green, ct_blue, 118
end

;=============================================================================
;      Proc 'hxrsview_convert'
;=============================================================================

pro hxrsview_convert

common widgets_shared, log_text, file_text, time_from_text, time_to_text, $
			y_range_min_text, y_range_max_text, y_scale_text, n_sum_text, $
			s_det_button, s_all_button, s_0_button, s_1_button, $
			s_2_button, s_3_button, s_4_button, s_5_button, $
			s_6_button, s_7_button, s_8_button, $
			n_det_button, n_all_button, n_0_button, n_1_button, $
			n_2_button, n_3_button, n_4_button, n_5_button, $
			n_6_button, n_7_button, n_8_button, $
			s_det_text, s_all_text, s_0_text, s_1_text, $
			s_2_text, s_3_text, s_4_text, s_5_text, $
			s_6_text, s_7_text, s_8_text, $
			n_det_text, n_all_text, n_0_text, n_1_text, $
			n_2_text, n_3_text, n_4_text, n_5_text, $
			n_6_text, n_7_text, n_8_text, $
			dets_ch_arr, detn_ch_arr, $
			yes_no_dialog, yes_no_message, yes_button, no_button

common data_tables, read_data, raw_data, raw_time, bt, primary_header, secondary_header, $
			cd, mwrfits_data, $
 			conv_time, conv_base_time, num_of_blocks, y_scale, loaded, $
			num_of_normal_blocks, num_of_flare_blocks, num_of_conv_blocks, $
			ct_red, ct_green, ct_blue, overwrite, last_file_name, $
			time_from, time_to, conv_time_from, conv_time_to, old_time_from, old_time_to

if( (old_time_from ne time_from(0)) or (old_time_to ne time_to(0)) ) then begin
    old_time_from = time_from(0)
    old_time_to = time_to(0)

    widget_control, log_text, set_value='Converting data for plot/save from ' + time_from + " to " + time_to + ' ...', /append

    conv_data_member={ conv_struct, TIME: 0.0D, BLOCKTYPE: 0B, BDIV_S: 0B, BDIV_N: 0B, COUNTS_S: FLTARR(10), COUNTS_N: FLTARR(10) }
    utime_from = utime(time_from, ERROR=ERROR)
    if ( ERROR eq 1 ) then begin
      widget_control, log_text, set_value='Invalid time from specified : ' + time_from, /append
      return
    endif
    utime_to = utime( time_to, ERROR=ERROR)
    if ( ERROR eq 1 ) then begin
      widget_control, log_text, set_value='Invalid time to specified : ' + time_to, /append
      return
    endif

    reltime_from = double( utime_from - utime( bt ) )
    ;print, 'Relative time from : ', reltime_from
    reltime_to = double( utime_to - utime( bt ) )
    ;print, 'Relative time to : ', reltime_to

    from_i = 0L
    for i=0L, num_of_blocks-1 do begin
    	if( raw_time(from_i) lt reltime_from(0) ) then begin
    		from_i = from_i + 1
    	endif else i=num_of_blocks
	endfor
    to_i = from_i
    for i=from_i, num_of_blocks-1 do begin
    	if( raw_time(to_i) le reltime_to(0) ) then begin
    		to_i = to_i + 1
    	endif else i=num_of_blocks
    endfor
    ;num_of_conv_blocks = to_i - from_i + 1
    to_i = to_i -1

    i=from_i
    while ( read_data(i).BLOCKTYPE ne 0 ) and ( read_data(i).BLOCKTYPE ne 8 ) do begin
      case read_data(i).BLOCKTYPE of
	1: i = i+69
	else: i = i+1
      endcase

    endwhile	 	
    conv_time_from = atime( raw_time( i ) + utime( bt ) )
	;help, i
	;print, "i = ", i
	;  print, "conv_time_from = ", conv_time_from

    num_of_conv_blocks = 0L
    for i=from_i, to_i do begin
      case read_data(i).BLOCKTYPE of
	1: i = i+68
	0: begin
	     num_of_conv_blocks = num_of_conv_blocks + 1
	     j=i
	   end
	8: begin
	     num_of_conv_blocks = num_of_conv_blocks + 1
	     j=i
	   end
	else: 
      endcase

     endfor

    cd = replicate( {conv_struct}, num_of_conv_blocks )
 
    conv_time_to = atime( raw_time( j ) + utime( bt ) )
	;help, j
	;print, "conv_time_to = ", conv_time_to

    num_of_conv_blocks = 0L
     for i=from_i, to_i do begin
        case read_data(i).BLOCKTYPE of
	1: i = i+68
        0: begin
	     cd(num_of_conv_blocks).TIME = raw_time(i)
	     cd(num_of_conv_blocks).BLOCKTYPE = read_data(i).BLOCKTYPE
	     cd(num_of_conv_blocks).BDIV_S = read_data(i).BDIV_S
	     cd(num_of_conv_blocks).BDIV_N = read_data(i).BDIV_N
	     cd(num_of_conv_blocks).COUNTS_S = read_data(i).COUNTS_S
	     cd(num_of_conv_blocks).COUNTS_N = read_data(i).COUNTS_N
	     num_of_conv_blocks = num_of_conv_blocks + 1
           end
        8: begin
	     cd(num_of_conv_blocks).TIME = raw_time(i)
	     cd(num_of_conv_blocks).BLOCKTYPE = read_data(i).BLOCKTYPE
	     cd(num_of_conv_blocks).BDIV_S = read_data(i).BDIV_S
	     cd(num_of_conv_blocks).BDIV_N = read_data(i).BDIV_N
	     cd(num_of_conv_blocks).COUNTS_S(*) = read_data(i).COUNTS_S(*) * 5L
	     cd(num_of_conv_blocks).COUNTS_N(*) = read_data(i).COUNTS_N(*) * 5L
 	     num_of_conv_blocks = num_of_conv_blocks + 1
           end
	else: 
      endcase

    endfor
	;print, "After conv: num_of_conv_blocks = ", num_of_conv_blocks

    widget_control, log_text, set_value=string(num_of_conv_blocks) + ' data blocks done.', /append 
  endif else begin
    widget_control, log_text, set_value = "Selected interval allready converted.", /append
  endelse
end


;=============================================================================
;      Proc 'hxrsview_event, ev' event handler
;=============================================================================

pro hxrsview_event, ev

common widgets_shared, log_text, file_text, time_from_text, time_to_text, $
			y_range_min_text, y_range_max_text, y_scale_text, n_sum_text, $
			s_det_button, s_all_button, s_0_button, s_1_button, $
			s_2_button, s_3_button, s_4_button, s_5_button, $
			s_6_button, s_7_button, s_8_button, $
			n_det_button, n_all_button, n_0_button, n_1_button, $
			n_2_button, n_3_button, n_4_button, n_5_button, $
			n_6_button, n_7_button, n_8_button, $
			s_det_text, s_all_text, s_0_text, s_1_text, $
			s_2_text, s_3_text, s_4_text, s_5_text, $
			s_6_text, s_7_text, s_8_text, $
			n_det_text, n_all_text, n_0_text, n_1_text, $
			n_2_text, n_3_text, n_4_text, n_5_text, $
			n_6_text, n_7_text, n_8_text, $
			dets_ch_arr, detn_ch_arr, $
			yes_no_dialog, yes_no_message, yes_button, no_button

common data_tables, read_data, raw_data, raw_time, bt, primary_header, secondary_header, $
			cd, mwrfits_data, $
 			conv_time, conv_base_time, num_of_blocks, y_scale, loaded, $
			num_of_normal_blocks, num_of_flare_blocks, num_of_conv_blocks, $
			ct_red, ct_green, ct_blue, overwrite, last_file_name, $
			time_from, time_to, conv_time_from, conv_time_to, old_time_from, old_time_to


  widget_control, ev.id, get_uvalue=value
  if (n_elements(value) eq 0) then value = ''
  name = strmid(tag_names(ev, /structure_name), 7, 4)
  case (name) of
  "BUTT": begin
;-------------------------
	if (value eq "QUIT") then begin
	  WIDGET_CONTROL, /destroy, ev.top
	  return
	endif
;-------------------------
	if (value eq "LOAD") then begin
	  widget_control, /hourglass
	  num_of_normal_blocks = 1L
	  num_of_flare_blocks = 1L
	  str_file_name = strarr(100)
	  WIDGET_CONTROL, file_text, get_value=str_file_name
	  if ((strlen( str_file_name ))(0) eq 0) then begin
		widget_control, log_text, set_value='Fileneme not specified.', /append
	  endif else begin
	   
	    fits_open, str_file_name(0), fcb, /no_abort, message=message
	    if !err lt 0 then begin
	      widget_control, log_text, set_value='Load error: ' + message, /append
	      return
	    endif else begin
	      widget_control, log_text, set_value='Loading file ' + str_file_name + '...', /append
	      fits_close, fcb
	
	      read_data = mrdfits( str_file_name(0), 0, primary_header )
	      widget_control, log_text, set_value = "File content: " + sxpar( primary_header, 'CONTENT' ) + ' created by ' + sxpar( primary_header, 'AUTHOR' ), /append

	      print, "File content: ", sxpar( primary_header, 'CONTENT' )
	      print, "File created by: ", sxpar( primary_header, 'AUTHOR' )

	      read_data = mrdfits( str_file_name(0), 1, secondary_header, /FSCALE )
	      last_file_name = str_file_name(0)
	    
;===================================
	    num_of_blocks = LONG( (SIZE(read_data))(1) )
	  	widget_control, log_text, set_value = string(num_of_blocks) + ' data blocks done.', /append
	  	widget_control, log_text, set_value = 'Converting time...', /append
	    raw_time =  dblarr( LONG(num_of_blocks) )
	    bt = atime( unix2ut( double( read_data(0).TIME ) $
				+ double( read_data(0).FINETIME / 1000.0 ) ) )

	    for i=0L, num_of_blocks-1 do begin
  	      raw_time(i) = double( read_data(i).TIME ) - double( read_data(0).TIME ) $
				+ double( read_data(i).FINETIME / 1000.0 )

		  if( read_data(i).BLOCKTYPE eq 0 ) then num_of_normal_blocks = num_of_normal_blocks + 1
		  if( read_data(i).BLOCKTYPE eq 8 ) then num_of_flare_blocks = num_of_flare_blocks + 1
	    endfor
	    widget_control, log_text, set_value= "Time range is " + atime( ( raw_time(0) + utime(bt) ), /Yohkoh ) + " to " + atime( ( raw_time(num_of_blocks-1) + utime(bt) ), /Yohkoh ), /append
	endelse
	endelse
	  loaded = 1
	widget_control, time_from_text, set_value = atime( ( raw_time(0) + utime(bt) ), /Yohkoh )
	widget_control, time_to_text, set_value = atime( ( raw_time(num_of_blocks-1) + utime(bt) ), /Yohkoh )
	;return
      endif
;===================== PLOT ============================
	if( value eq "PLOT" ) then begin
	  widget_control, /hourglass
	  if( !D.n_colors le 255 ) then tvlct, ct_red, ct_green, ct_blue, 118
	  WIDGET_CONTROL, time_from_text, get_value=time_from
	  WIDGET_CONTROL, time_to_text, get_value=time_to
	  WIDGET_CONTROL, y_range_min_text, get_value=y_range_min
	  WIDGET_CONTROL, y_range_max_text, get_value=y_range_max
	  s_offsets=dblarr(10)
      	  WIDGET_CONTROL, s_all_text, get_value=off_txt
          s_offsets(0) = double( off_txt )
	  WIDGET_CONTROL, s_0_text, get_value=off_txt
          s_offsets(1) = double( off_txt )
	  WIDGET_CONTROL, s_1_text, get_value=off_txt
          s_offsets(2) = double( off_txt )
	  WIDGET_CONTROL, s_2_text, get_value=off_txt
          s_offsets(3) = double( off_txt )
	  WIDGET_CONTROL, s_3_text, get_value=off_txt
          s_offsets(4) = double( off_txt )
	  WIDGET_CONTROL, s_4_text, get_value=off_txt
          s_offsets(5) = double( off_txt )
	  WIDGET_CONTROL, s_5_text, get_value=off_txt
          s_offsets(6) = double( off_txt )
	  WIDGET_CONTROL, s_6_text, get_value=off_txt
          s_offsets(7) = double( off_txt )
	  WIDGET_CONTROL, s_7_text, get_value=off_txt
          s_offsets(8) = double( off_txt )
	  WIDGET_CONTROL, s_8_text, get_value=off_txt
          s_offsets(9) = double( off_txt )
	  n_offsets=dblarr(10)
          WIDGET_CONTROL, n_all_text, get_value=off_txt
          n_offsets(0) = double( off_txt )
	  WIDGET_CONTROL, n_0_text, get_value=off_txt
          n_offsets(1) = double( off_txt )
	  WIDGET_CONTROL, n_1_text, get_value=off_txt
          n_offsets(2) = double( off_txt )
	  WIDGET_CONTROL, n_2_text, get_value=off_txt
          n_offsets(3) = double( off_txt )
	  WIDGET_CONTROL, n_3_text, get_value=off_txt
          n_offsets(4) = double( off_txt )
	  WIDGET_CONTROL, n_4_text, get_value=off_txt
          n_offsets(5) = double( off_txt )
	  WIDGET_CONTROL, n_5_text, get_value=off_txt
          n_offsets(6) = double( off_txt )
	  WIDGET_CONTROL, n_6_text, get_value=off_txt
          n_offsets(7) = double( off_txt )
	  WIDGET_CONTROL, n_7_text, get_value=off_txt
          n_offsets(8) = double( off_txt )
	  WIDGET_CONTROL, n_8_text, get_value=off_txt
          n_offsets(9) = double( off_txt )

	  v1 = (long(time_from))(0)
	  v2 = (long(time_to))(0)
	  if( !D.n_colors gt 255 ) then begin
	  	axis_color=0+ 256L * ( 0+ 256L * 0)
	  	block_type_color=100 + 256L * ( 100 + 256L * 100)
	  	background_color=255 + 256L * ( 255 + 256L * 255)
	  endif else begin
	  	axis_color=0
	  	block_type_color=100
	  	background_color=255
	  endelse

	  WIDGET_CONTROL, n_sum_text, get_value=n_sum_txt
	  n_sum = long( n_sum_txt )

	 if( loaded ge 1 ) then begin
	  if (((strlen(time_from))(0) gt 0) and ((strlen(time_to))(0) gt 0)) then begin
	      
	      hxrsview_convert

	      widget_control, log_text, set_value='Plot converted blocks from ' + conv_time_from + " to " + conv_time_to, /append

		if( y_scale eq 'log' ) then begin
		      utplot, cd.TIME, cd.BLOCKTYPE, bt, TIMERANGE=[conv_time_from, conv_time_to], BACKGROUND=background_color, color=axis_color, /YLOG, YRANGE=[(FLOAT(y_range_min))(0), (FLOAT(y_range_max))(0)], ytitle="Count Rate"
		endif else begin
			  utplot, cd.TIME, cd.BLOCKTYPE, bt, TIMERANGE=[conv_time_from, conv_time_to], BACKGROUND=background_color, color=axis_color, YRANGE=[(FLOAT(y_range_min))(0), (FLOAT(y_range_max))(0)], ytitle="Count Rate"
		endelse

		outplot, cd.TIME, cd.BLOCKTYPE, color=block_type_color

	      if( dets_ch_arr(10) ne 0 ) then begin
	       	if( dets_ch_arr(0) ne 0 ) then begin
		  	  if( !D.n_colors gt 255 ) then all_color = ct_red(10) + 256L*( ct_green(10) + 256L*ct_blue(10) ) else all_color=128
	    	  if( y_scale eq 'log' ) then begin
	    	    outplot, cd.TIME, cd.COUNTS_S(0)*(10^s_offsets(0)), color=all_color, nsum=n_sum(0)
	    	  endif else begin
		    outplot, cd.TIME, cd.COUNTS_S(0)+(10*s_offsets(0)), color=all_color, nsum=n_sum(0)
	    	  endelse
	        endif
	    for i=1, 9 do begin
	      if( dets_ch_arr(i) ne 0 ) then begin
	            if( !D.n_colors gt 255 ) then channel_color = ct_red(10+i) + 256L*( ct_green(10+i) + 256L*ct_blue(10+i) ) else channel_color=128+i
	            if( y_scale eq 'log' ) then begin
			outplot, cd.TIME, cd.COUNTS_S(i)*(10^s_offsets(i)), color=channel_color, nsum=n_sum(0)
	    	    endif else begin
			outplot, cd.TIME, cd.COUNTS_S(i)+(10*s_offsets(i)), color=channel_color, nsum=n_sum(0)
	    	    endelse
              endif
            endfor
          endif

	      if( detn_ch_arr(10) ne 0 ) then begin
	       	if( detn_ch_arr(0) ne 0 ) then begin
	          if( !D.n_colors gt 255 ) then all_color = ct_red(0) + 256L*( ct_green(0) + 256L*ct_blue(0) ) else all_color=118
	    	  if( y_scale eq 'log' ) then begin
	    	    outplot, cd.TIME, cd.COUNTS_N(0)*(10^n_offsets(0)), color=all_color, nsum=n_sum(0)
	    	  endif else begin
		    outplot, cd.TIME, cd.COUNTS_N(0)+(10*n_offsets(0)), color=all_color, nsum=n_sum(0)
	    	  endelse
	        endif
	    for i=1, 9 do begin
	      if( detn_ch_arr(i) ne 0 ) then begin
	          if( !D.n_colors gt 255 ) then channel_color = ct_red(i) + 256L*( ct_green(i) + 256L*ct_blue(i) ) else channel_color=118+i
	            if( y_scale eq 'log' ) then begin
			outplot, cd.TIME, cd.COUNTS_N(i)*(10^n_offsets(i)), color=channel_color, nsum=n_sum(0)
	    	    endif else begin
			outplot, cd.TIME, cd.COUNTS_N(i)+(10*n_offsets(i)), color=channel_color, nsum=n_sum(0)
	    	    endelse
              endif
            endfor
          endif

      endif else widget_control, log_text, set_value='Block range not specified.', /append
	 endif else begin
	  if ( loaded eq 0 ) then begin
	    widget_control, log_text, set_value = "Huh, data not loaded." , /append
	  endif else widget_control, log_text, set_value = "Huh, data not converted." , /append
	 endelse
	set_hxrs_view_color_table
	endif
;===================== HELP ============================
	if( value eq "HELP" ) then begin
	    widget_control, log_text, set_value = "-----------------------------------", /append
	    widget_control, log_text, set_value = "Help for HXRSVIEW 2.0", /append
	    widget_control, log_text, set_value = "-----------------------------------", /append
	    widget_control, log_text, set_value = "LOAD ... load HXRS data file", /append
	    widget_control, log_text, set_value = "PLOT ... plot data of specified time range (Time from, Time to)", /append
	    widget_control, log_text, set_value = "QUIT ... quit Hxrsview", /append
	    widget_control, log_text, set_value = "HELP ... display this help", /append
	    widget_control, log_text, set_value = "Y-axis min, max ... Y-axis setup", /append
	    widget_control, log_text, set_value = "Y-axis scale ... logaritmic/linear scale, log is default", /append
	    widget_control, log_text, set_value = "NSUM ... averaging window for plot (makes plot stepless)", /append
	    widget_control, log_text, set_value = "Det. S - On/Off ... whole shielded detector data plot On/Off", /append
	    widget_control, log_text, set_value = "Det. N - On/Off ... whole non-shielded detector data plot On/Off", /append
	    widget_control, log_text, set_value = "Summa - On/Off, 0 - On/Off .. 8 - On/Off ...... ", /append
	    widget_control, log_text, set_value = "             ... particular channels plot On/Off", /append
	    widget_control, log_text, set_value = "Offset ... plot data_value * 10^offset if logaritmic scale set,", /append
	    widget_control, log_text, set_value = "            plot data_value + 10*offset if linear scale set", /append

	endif
;=======================================

	case (value) of
      "sdet": if( dets_ch_arr(10) eq 0 ) then begin
				dets_ch_arr(10) = 1
				widget_control, s_det_button, set_value='Det. S -  On'
			  endif else begin
				dets_ch_arr(10) = 0
				widget_control, s_det_button, set_value='Det. S - Off'
			  endelse
	  "sall": if( dets_ch_arr(0) eq 0 ) then begin
				dets_ch_arr(0) = 1
				widget_control, s_all_button, set_value='Summa -  On'
			  endif else begin
				dets_ch_arr(0) = 0
				widget_control, s_all_button, set_value='Summa - Off'
			  endelse
	  "s0": if( dets_ch_arr(1) eq 0 ) then begin
				dets_ch_arr(1) = 1
				widget_control, s_0_button, set_value=' 0  -  On'
			  endif else begin
				dets_ch_arr(1) = 0
				widget_control, s_0_button, set_value=' 0  - Off'
			  endelse
	  "s1": if( dets_ch_arr(2) eq 0 ) then begin
				dets_ch_arr(2) = 1
				widget_control, s_1_button, set_value=' 1  -  On'
			  endif else begin
				dets_ch_arr(2) = 0
				widget_control, s_1_button, set_value=' 1  - Off'
			  endelse
	  "s2": if( dets_ch_arr(3) eq 0 ) then begin
				dets_ch_arr(3) = 1
				widget_control, s_2_button, set_value=' 2  -  On'
			  endif else begin
				dets_ch_arr(3) = 0
				widget_control, s_2_button, set_value=' 2  - Off'
			  endelse
	  "s3": if( dets_ch_arr(4) eq 0 ) then begin
				dets_ch_arr(4) = 1
				widget_control, s_3_button, set_value=' 3  -  On'
			  endif else begin
				dets_ch_arr(4) = 0
				widget_control, s_3_button, set_value=' 3  - Off'
			  endelse
	  "s4": if( dets_ch_arr(5) eq 0 ) then begin
				dets_ch_arr(5) = 1
				widget_control, s_4_button, set_value=' 4  -  On'
			  endif else begin
				dets_ch_arr(5) = 0
				widget_control, s_4_button, set_value=' 4  - Off'
			  endelse
	  "s5": if( dets_ch_arr(6) eq 0 ) then begin
				dets_ch_arr(6) = 1
				widget_control, s_5_button, set_value=' 5  -  On'
			  endif else begin
				dets_ch_arr(6) = 0
				widget_control, s_5_button, set_value=' 5  - Off'
			  endelse
	  "s6": if( dets_ch_arr(7) eq 0 ) then begin
				dets_ch_arr(7) = 1
				widget_control, s_6_button, set_value=' 6  -  On'
			  endif else begin
				dets_ch_arr(7) = 0
				widget_control, s_6_button, set_value=' 6  - Off'
			  endelse
	  "s7": if( dets_ch_arr(8) eq 0 ) then begin
				dets_ch_arr(8) = 1
				widget_control, s_7_button, set_value=' 7  -  On'
			  endif else begin
				dets_ch_arr(8) = 0
				widget_control, s_7_button, set_value=' 7  - Off'
			  endelse
	  "s8": if( dets_ch_arr(9) eq 0 ) then begin
				dets_ch_arr(9) = 1
				widget_control, s_8_button, set_value=' 8  -  On'
			  endif else begin
				dets_ch_arr(9) = 0
				widget_control, s_8_button, set_value=' 8  - Off'
			  endelse
	  "ndet": if( detn_ch_arr(10) eq 0 ) then begin
				detn_ch_arr(10) = 1
				widget_control, n_det_button, set_value='Det. N -  On'
			  endif else begin
				detn_ch_arr(10) = 0
				widget_control, n_det_button, set_value='Det. N - Off'
			  endelse
	  "nall": if( detn_ch_arr(0) eq 0 ) then begin
				detn_ch_arr(0) = 1
				widget_control, n_all_button, set_value='Summa -  On'
			  endif else begin
				detn_ch_arr(0) = 0
				widget_control, n_all_button, set_value='Summa - Off'
			  endelse
	  "n0": if( detn_ch_arr(1) eq 0 ) then begin
				detn_ch_arr(1) = 1
				widget_control, n_0_button, set_value=' 0  -  On'
			  endif else begin
				detn_ch_arr(1) = 0
				widget_control, n_0_button, set_value=' 0  - Off'
			  endelse
	  "n1": if( detn_ch_arr(2) eq 0 ) then begin
				detn_ch_arr(2) = 1
				widget_control, n_1_button, set_value=' 1  -  On'
			  endif else begin
				detn_ch_arr(2) = 0
				widget_control, n_1_button, set_value=' 1  - Off'
			  endelse
	  "n2": if( detn_ch_arr(3) eq 0 ) then begin
				detn_ch_arr(3) = 1
				widget_control, n_2_button, set_value=' 2  -  On'
			  endif else begin
				detn_ch_arr(3) = 0
				widget_control, n_2_button, set_value=' 2  - Off'
			  endelse
	  "n3": if( detn_ch_arr(4) eq 0 ) then begin
				detn_ch_arr(4) = 1
				widget_control, n_3_button, set_value=' 3  -  On'
			  endif else begin
				detn_ch_arr(4) = 0
				widget_control, n_3_button, set_value=' 3  - Off'
			  endelse
	  "n4": if( detn_ch_arr(5) eq 0 ) then begin
				detn_ch_arr(5) = 1
				widget_control, n_4_button, set_value=' 4  -  On'
			  endif else begin
				detn_ch_arr(5) = 0
				widget_control, n_4_button, set_value=' 4  - Off'
			  endelse
	  "n5": if( detn_ch_arr(6) eq 0 ) then begin
				detn_ch_arr(6) = 1
				widget_control, n_5_button, set_value=' 5  -  On'
			  endif else begin
				detn_ch_arr(6) = 0
				widget_control, n_5_button, set_value=' 5  - Off'
			  endelse
	  "n6": if( detn_ch_arr(7) eq 0 ) then begin
				detn_ch_arr(7) = 1
				widget_control, n_6_button, set_value=' 6  -  On'
			  endif else begin
				detn_ch_arr(7) = 0
				widget_control, n_6_button, set_value=' 6  - Off'
			  endelse
	  "n7": if( detn_ch_arr(8) eq 0 ) then begin
				detn_ch_arr(8) = 1
				widget_control, n_7_button, set_value=' 7  -  On'
			  endif else begin
				detn_ch_arr(8) = 0
				widget_control, n_7_button, set_value=' 7  - Off'
			  endelse
	  "n8": if( detn_ch_arr(9) eq 0 ) then begin
				detn_ch_arr(9) = 1
				widget_control, n_8_button, set_value=' 8  -  On'
			  endif else begin
				detn_ch_arr(9) = 0
				widget_control, n_8_button, set_value=' 8  - Off'
			  endelse
	   	 else:
	 endcase
	if (ev.select ne 0) then begin
	 case (value) of
	  "log": y_scale = 'log'
      "lin": y_scale = 'lin'
     else:
	 endcase 
	endif
	end
  else:
  endcase

end

;=============================================================================
;      Main proc 'hxrsview'
;=============================================================================

pro hxrsview

common widgets_shared, log_text, file_text, time_from_text, time_to_text, $
			y_range_min_text, y_range_max_text, y_scale_text, n_sum_text, $
			s_det_button, s_all_button, s_0_button, s_1_button, $
			s_2_button, s_3_button, s_4_button, s_5_button, $
			s_6_button, s_7_button, s_8_button, $
			n_det_button, n_all_button, n_0_button, n_1_button, $
			n_2_button, n_3_button, n_4_button, n_5_button, $
			n_6_button, n_7_button, n_8_button, $
			s_det_text, s_all_text, s_0_text, s_1_text, $
			s_2_text, s_3_text, s_4_text, s_5_text, $
			s_6_text, s_7_text, s_8_text, $
			n_det_text, n_all_text, n_0_text, n_1_text, $
			n_2_text, n_3_text, n_4_text, n_5_text, $
			n_6_text, n_7_text, n_8_text, $
			dets_ch_arr, detn_ch_arr, $
			yes_no_dialog, yes_no_message, yes_button, no_button

common data_tables, read_data, raw_data, raw_time, bt, primary_header, secondary_header, $
			cd, mwrfits_data, $
 			conv_time, conv_base_time, num_of_blocks, y_scale, loaded, $
			num_of_normal_blocks, num_of_flare_blocks, num_of_conv_blocks, $
			ct_red, ct_green, ct_blue, overwrite, last_file_name, $
			time_from, time_to, conv_time_from, conv_time_to, old_time_from, old_time_to


num_of_normal_blocks = 0L
num_of_flare_blocks = 0L
loaded = 0
overwrite = 0
y_scale = 'log'

dets_ch_arr = BYTARR(11)
detn_ch_arr = BYTARR(11)

set_hxrs_view_color_table

old_time_from = ''
old_time_to = ''

base = WIDGET_BASE(title='Simple HXRS data viewer 2.0  (c)1999-2000 Martin Cupak', /row)
b1 = WIDGET_BASE(base, /column)
  b2 = widget_base(b1, /row)
  	load_button = widget_button(b2, value="Load", uvalue = "LOAD")
   	t6 = widget_button(b2, value="Plot", uvalue = "PLOT")
  	t7 = widget_button(b2, value="Quit", uvalue = "QUIT")
  	t8 = widget_button(b2, value="Help", uvalue = "HELP")
  b3 = widget_base(b1, /row)
  	t2 = widget_label(b3, value = ' File name: ')
  	if( !version.os_family eq 'Windows' ) then begin
		last_file_name = 'V:\work\hxrs\bin2fits\hxrslog1.fit'
	endif else last_file_name = '/hxrsdat/FTS/hxr000101_0000.fts'
	file_text = widget_text(b3, /editable, xsize=50, ysize=1, value=last_file_name)
  b5 = widget_base(b1, /row)
  b6 = widget_base(b5, /column)
  b8= widget_base(b6, /row)
  	t2 = widget_label(b8, value = 'Time from: ')
  	time_from_text = widget_text(b8, /editable, xsize=34, ysize=1)
  b89= widget_base(b6, /row)
	t3 = widget_label(b89, value = '  Time to: ')
  	time_to_text = widget_text(b89, /editable, xsize=34, ysize=1)
  b9 = widget_base(b6, /row)
  	t2 = widget_label(b9, value = 'Y-axis min:')
  	y_range_min_text = widget_text(b9, /editable, xsize=12, ysize=1, value='1')
  	t3 = widget_label(b9, value = ' max:')
  	y_range_max_text = widget_text(b9, /editable, xsize=12, ysize=1, value='10000' )
  b7 = widget_base(b5, /column)
  	t4 = widget_label(b7, value='Y-axis scale ')
  	scale = [ 'log', 'lin' ]
  	XMENU, scale, b7, /EXCLUSIVE, /FRAME, uvalue=scale
  b75 = widget_base(b7, /row)
  	t4 = widget_label(b75, value='  NSUM: ')
    	n_sum_text = widget_text(b75, /editable, xsize=3, ysize=1, value='1')
 
  b11 = widget_base(base, /COLUMN, /frame)
    b111 = widget_base(b11, /ROW)
  	s_det_button = widget_button(b111, value='Det. S - Off', uvalue="sdet")
	ls = widget_label(b111, value='Offset')
  	b112 = widget_base(b11, /ROW)
  	s_all_button = widget_button(b112, value='Summa - Off', uvalue="sall")
  	s_all_text = widget_text(b112, /editable, xsize=7, ysize=1, value='0')
  	b113 = widget_base(b11, /ROW)
  	s_0_button = widget_button(b113, value=' 0  - Off', uvalue="s0")
    s_0_text = widget_text(b113, /editable, xsize=7, ysize=1, value='0')
  	b114 = widget_base(b11, /ROW)
  	s_1_button = widget_button(b114, value=' 1  - Off', uvalue="s1")
    s_1_text = widget_text(b114, /editable, xsize=7, ysize=1, value='0')
  	b115 = widget_base(b11, /ROW)
  	s_2_button = widget_button(b115, value=' 2  - Off', uvalue="s2")
    s_2_text = widget_text(b115, /editable, xsize=7, ysize=1, value='0')
  	b116 = widget_base(b11, /ROW)
  	s_3_button = widget_button(b116, value=' 3  - Off', uvalue="s3")
    s_3_text = widget_text(b116, /editable, xsize=7, ysize=1, value='0')
  	b117 = widget_base(b11, /ROW)
  	s_4_button = widget_button(b117, value=' 4  - Off', uvalue="s4")
    s_4_text = widget_text(b117, /editable, xsize=7, ysize=1, value='0')
  	b118 = widget_base(b11, /ROW)
  	s_5_button = widget_button(b118, value=' 5  - Off', uvalue="s5")
    s_5_text = widget_text(b118, /editable, xsize=7, ysize=1, value='0')
  	b119 = widget_base(b11, /ROW)
  	s_6_button = widget_button(b119, value=' 6  - Off', uvalue="s6")
    s_6_text = widget_text(b119, /editable, xsize=7, ysize=1, value='0')
  	b11a = widget_base(b11, /ROW)
  	s_7_button = widget_button(b11a, value=' 7  - Off', uvalue="s7")
    s_7_text = widget_text(b11a, /editable, xsize=7, ysize=1, value='0')
  	b11b = widget_base(b11, /ROW)
  	s_8_button = widget_button(b11b, value=' 8  - Off', uvalue="s8")
    s_8_text = widget_text(b11b, /editable, xsize=7, ysize=1, value='0')

  b12 = widget_base(base, /COLUMN, /frame)
  	b121 = widget_base(b12, /ROW)
  	n_det_button = widget_button(b121, value='Det. N - Off', uvalue="ndet")
  	ln = widget_label(b121, value='Offset')
	b122 = widget_base(b12, /ROW)
  	n_all_button = widget_button(b122, value='Summa - Off', uvalue="nall")
  	n_all_text = widget_text(b122, /editable, xsize=7, ysize=1, value='0')
  	b123 = widget_base(b12, /ROW)
  	n_0_button = widget_button(b123, value=' 0  - Off', uvalue="n0")
    n_0_text = widget_text(b123, /editable, xsize=7, ysize=1, value='0')
  	b124 = widget_base(b12, /ROW)
  	n_1_button = widget_button(b124, value=' 1  - Off', uvalue="n1")
    n_1_text = widget_text(b124, /editable, xsize=7, ysize=1, value='0')
  	b125 = widget_base(b12, /ROW)
  	n_2_button = widget_button(b125, value=' 2  - Off', uvalue="n2")
    n_2_text = widget_text(b125, /editable, xsize=7, ysize=1, value='0')
  	b126 = widget_base(b12, /ROW)
  	n_3_button = widget_button(b126, value=' 3  - Off', uvalue="n3")
    n_3_text = widget_text(b126, /editable, xsize=7, ysize=1, value='0')
  	b127 = widget_base(b12, /ROW)
  	n_4_button = widget_button(b127, value=' 4  - Off', uvalue="n4")
    n_4_text = widget_text(b127, /editable, xsize=7, ysize=1, value='0')
  	b128 = widget_base(b12, /ROW)
  	n_5_button = widget_button(b128, value=' 5  - Off', uvalue="n5")
    n_5_text = widget_text(b128, /editable, xsize=7, ysize=1, value='0')
  	b129 = widget_base(b12, /ROW)
  	n_6_button = widget_button(b129, value=' 6  - Off', uvalue="n6")
    n_6_text = widget_text(b129, /editable, xsize=7, ysize=1, value='0')
  	b12a = widget_base(b12, /ROW)
  	n_7_button = widget_button(b12a, value=' 7  - Off', uvalue="n7")
    n_7_text = widget_text(b12a, /editable, xsize=7, ysize=1, value='0')
  	b12b = widget_base(b12, /ROW)
  	n_8_button = widget_button(b12b, value=' 8  - Off', uvalue="n8")
    n_8_text = widget_text(b12b, /editable, xsize=7, ysize=1, value='0')

  t1=widget_label(b1, value='Event log window')
  log_text = widget_text(b1, ysize=12, xsize=52, /scroll, $
  	value=[ 'Hi!', $
	'This is simple HXRS data viewer.' ])

    widget_control, base, /realize

  XMANAGER, 'HXRSVIEW', base
end
