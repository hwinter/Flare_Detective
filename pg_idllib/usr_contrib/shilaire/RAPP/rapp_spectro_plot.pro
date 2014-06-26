;---------------------------------------------------------------------------
; Document name: spectro_plot
; Created by: this is collective software, it does not belong to anybody
;
; Time-stamp: <2003-07-31 12:49:56 csillag soleil.ifi.fh-aargau.ch>
;---------------------------------------------------------------------------
;
;+
;NAME:
;   spectro_plot
;
;PROJECT:
;   Generic Display utilities
;
;CATEGORY:
;   /ssw/gen/display
;
;PURPOSE:
;       This routine displays 2d and 1d arrays as a function of time. This
;       program merges functionalities of the programs tplot, rapp_plot_spectrogram,
;       and show_image. This is a complete rewrite of the spectro_plot
;       utility that was built on show_image uniquely.
;
;CALLING SEQUENCE:
;       1st form:
;       --------
;       spectro_plot, image1, xaxis1, yaxis1, $
;                     image2, xaxis2, yaxis2, $
;                     ....
;                     image4, xaxis4, yaxis4
;
;       2nd form:
;       --------
;       spectro_plot, struct1, struct2, .... struct12
;
;INPUT:
;       image1...image4: 2d arrays
;       xaxis1...xaxis4: 1d array containing the time values
;                        associated with the xaxis of the array
;       yaxis1...yaxis4: 1d array containing the y-values (whatever
;                        they are) associated with the xaxis of the
;                        array
;       struct1...struct12: structures of the form
;                        {spectrogram:fltarr(nx,ny), x: fltarr(nx), y:fltarr(ny)}
;
;KEYWORDS:
;       IMDISP_NCHANNEL: In case the image array passed has only a
;                         few channels, these channels are displayed
;                         in a plot format instead of an image
;                         format. This integer value gives the number
;                         of channels that switches from one mode to
;                         another.
;       YINTEGRATE: a 1d vector of n_plots elemensts. if set integrates
;                  the plot over the yrange specified
;       NO_INTERPOLATE: supresses the interpolation of the image
;                       Note that this might lead to a wrong display,
;                       as the pixels might not be aligned with the
;                       y- and x-axis values.
;       NO_UT: suppresses the use of utplot and plots the time axis
;              with normal decimal values.
;       POSTSCRIPT: Sends the output to a postscript file (same as calling ps,
;           /color)
;       TIMERANGE: same as XRANGE
;       UTBASE: sets the utbase parameter of utplot, for the case the
;               data is in a special ut base.
;       XRANGE: sets the time limits of the xaxis window (2-element
;               array). Same as TIMERANGE
;       X_REFERENCE: used to tell the system which of the plots passed
;                    is giving the reference for the time range. If
;                    not set, the minimum overlapping time
;                    ranges is used.  If timerange or xrange are used,
;                    they take over the time range setting
;       YLOG: plots the axis and the data with a logarithmic scale
;       YRANGE: a 2xn_plots element setting the range to display
;       ZLOG: plots the data in a logarithmic format
;	XTITLE: can be an array
;
;       ... and all the keywords acccepted by PLOT
;
;HISTORY:
;       acs july 2003: corrected way of displaying spectrograms with
;                      only few channels
;       acs june 2003: now fully featured xstyle and ystyle keywords
;       acs may 2003: fixing the x/y range problem and refactoring session
;       ACS April 2003: including feedback from kim & paolo
;       ACS March 2003: after meeting with AOBenz, PSG and PG extended version
;                       with YINTEGRATE, NO_INTERPOLATE, YRANGE
;                       PS capabilities checked
;       ACS Feb 2003   : make sure it works with other plot routines
;       ETH Zurich       for integration into the plotman utilities
;                        (i.e. zooming etc )
;                        csillag@ssl.berkeley.edu. This is basically a
;                        merge between the functions of Pascal
;                        Saint-Hilaire, Paolo Grigis and Peter Messmer
;                        with the show_image
;                        - ps option modified to be able to set the ps
;                        option outside of the routine
;                        - replacement of the call to utplot with the
;                        set_utaxis and then axis
;                        - interpolation taken from Davin (tplot)
;                        - compatibility with tplot
;                        - utplot is now default
;                        - full logarithm implemented
;       ACS Jan 2003: merged several version of the same program into
;                     the first prototy of this generic
;                     routines. Contributions from all people listed above.
;       Kim 27-Jun-2003: Added cbar option.  Only has effect if > IDL5.2, and only
;		              doing one plot
;
;--------------------------------------------------------------------------------


PRO rapp_spectro_plot_inner, imagep, xaxisp, yaxisp, $
           XTITLE=xtitle, YTITLE=ytitle, $
           CHARSIZE=charsize, $
           NO_INTERPOLATE=no_interpolate, $
           YLOG=ylog, XLOG=xlog, ZLOG=zlog, $
           ZEXP=zexp, $
           NO_UT=no_ut, $
           YINTEGRATE=yintegrate, $
           XRANGE=xrange, $
           YRANGE=yrange, $
           UTBASE=utbase, $
           IMDISP_NCHANNEL=imdisp_nchannel, $
           INVERT=invert, $
           bottom=bottom, top=top, ncolors=ncolors, $ ;kim  - added info on color range to use
           xstyle = xstyle, YSTYLE=ystyle, $
           cbar=cbar, $
           _EXTRA=_extra

IF Keyword_Set( XTITLE ) THEN xtitle = xtitle
IF Keyword_Set( XRANGE ) THEN xrange = anytim(xrange)
CheckVar, imdisp_nchannel, 4
checkvar, xstyle, !x.style
checkvar, ystyle, !y.style
image_size = Size( imagep, /structure )
IF image_size.n_elements LE 1 THEN BEGIN
    message, 'Cannot display a single element -- returning', /CONTINUE
    RETURN
ENDIF
IF image_size.n_dimensions GT 2 THEN BEGIN
    MESSAGE, 'Cannot display a data set with more than two dimensions -- returning', /CONTINUE
    RETURN
ENDIF

nx = image_size.dimensions[0]
ny = image_size.dimensions[1]
yes_plot = ny LE imdisp_nchannel
; kim +
if yes_plot then message, 'Too few y values (< ' + $
    trim(imdisp_nchannel+1) + ') to plot spectrogram.  Switching to line plots.', /continue
if nx eq 1 then begin
    message, 'Cannot display line plots with only one x value -- returning', /continue
    return
endif
;kim -

; make sure the log does not explode
image = Reform( imagep )
IF NOT yes_plot AND Keyword_Set( ZLOG ) THEN begin
    image = Alog( image  + abs( min(image) ) + 1 )
endif
IF NOT yes_plot AND Keyword_Set( ZEXP ) THEN image = Exp(image )
IF keyword_set(INVERT) THEN image = max(image) - image

; first set the coordinate system

IF N_Elements( xaxisp ) EQ 0 THEN xaxis = lindgen(nx) ELSE xaxis = xaxisp
IF N_Elements( yaxisp ) EQ 0 THEN yaxis = lindgen(ny) ELSE yaxis = yaxisp

IF keyword_set( yintegrate ) THEN BEGIN
    IF N_elements( yintegrate ) EQ 1 OR valid_range( yintegrate ) THEN BEGIN
        yes_plot = 1
    ENDIF
ENDIF

IF yes_plot  THEN BEGIN
    nodata = 0
    IF keyword_set( yintegrate ) THEN BEGIN
; here we need the original values from imagep
        IF valid_range( yintegrate ) THEN BEGIN
            im_y_limit = value_locate( yaxis, yintegrate ) > 0
            IF im_y_limit[0] GT im_y_limit[1] THEN im_y_limit = im_y_limit[[1, 0]]
        ENDIF ELSE BEGIN
            im_y_limit = [0, n_elements( yaxis )-1 ]
        ENDELSE
        if im_y_limit[0] ne im_y_limit[1] then begin
            yaxis = Total( imagep[*, im_y_limit[0]:im_y_limit[1]], 2 )
        endif
        ny = 1
    ENDIF ELSE BEGIN
        yaxis = imagep
    ENDELSE
    if not valid_range(yrange) then yrange = minmax( yaxis )		;kim
ENDIF ELSE BEGIN
    nodata = 1
;    ystyle = 7  ; kim changed from 4 to 7
;    IF NOT keyword_Set( ystyle ) THEN ystyle = 4 ELSE ystyle = ystyle + 4
;    xstyle = 3
                                ; normal case
    IF NOT valid_range(yrange) THEN BEGIN ; kim moved this block from just before axis call
        yrange = minmax( yaxis )
        IF yaxis[0] GT last_item(yaxis) THEN yrange = yrange[[1, 0]]
    ENDIF
ENDELSE

CheckVar, charsize, 0
IF charsize NE 0 AND charsize LT 0.05 THEN ymargin = [0, !y.margin[1]]

this_xstyle = yes_plot? xstyle: xstyle MOD 4 + 4
this_ystyle = yes_plot? ystyle: ystyle MOD 4 + 4

cbar = keyword_set(cbar) and not yes_plot

if cbar then position=[.1,.1,.9,.88]

IF NOT Keyword_Set( NO_UT ) THEN BEGIN
    CheckVar, utbase, xrange[0]
    ;pmm, xaxis - utbase
    ;ptim, utbase
    ;ptim, xrange
    xaxis = xaxis - utbase

    utplot, xaxis, yaxis[*, 0], utbase, /nodata, $
        TIMERANGE=xrange, YRANGE=yrange, $
        YLOG=ylog, CHARSIZE=charsize, XTITLE=xtitle, $
        YMARGIN=ymargin, _EXTRA=_extra, xstyle = this_xstyle, $
        ystyle = this_ystyle, position=position

    IF yes_plot THEN BEGIN
        FOR i=0, ny-1 DO BEGIN
            outplot, xaxis, yaxis[*, i], utbase, _extra=_extra    ;  kim added _extra
        ENDFOR
    ENDIF
ENDIF ELSE BEGIN
    plot, xaxis, yaxis[*, 0], nodata=nodata, $
        YRANGE=yrange, CHARSIZE=charsize, /NOERASE, $
        XTITLE=xtitle, _EXTRA=_extra, XRANGE=xrange, YRANGE=yrange, xstyle=this_xstyle, $
        ystyle=this_ystyle, position=position
    IF yes_plot AND ny GT 1 THEN BEGIN
        FOR i=1, ny-1 DO BEGIN
            oplot, xaxis, yaxis[*, i], _EXTRA=_extra
        ENDFOR
    ENDIF
ENDELSE

; if we've done an xyplot we're done. maybe this must be more smart
; (using some kim/dominic xy plot routines?)
IF yes_plot THEN RETURN

; ok now plot the image

CheckVar, xrange, MinMax( xaxis )
if same_data(xrange, [0.d, 0.d], /notype_check)then xrange = minmax(xaxis)  ; kim  0,0 means autoscale

; we need the reference to the window frame (crange), not to xrange
;x_limit = (Value_Locate( xaxis, !x.crange ) + [1,0]) > 0
;y_limit = (Value_locate( yaxis, yrange ) + [1,0]) > 0
x_limit = (Value_Locate( xaxis, !x.crange ) + [0,1] ) > 0 <  (nx-1)
y_limit = (Value_locate( yaxis, yrange ) + [0,1] ) > 0 <  (ny-1)

IF x_limit[0] GT x_limit[1] THEN x_limit = x_limit[[1, 0]]
IF y_limit[0] GT y_limit[1] THEN begin
    y_limit = y_limit[[1, 0]]
endif

image = image[x_limit[0]:x_limit[1], $
              y_limit[0]:y_limit[1]]
xaxis = xaxis[x_limit[0]:x_limit[1]]
yaxis = yaxis[y_limit[0]:y_limit[1]]

;print, 'yaxis = ', yaxis
center =  yaxis
; we assume yaxis contains the center of the bins.
; thus we need to expand the axis to allow the bin extension at the beginning
; and at the end of the range

; find the edges between bins
edge =  (center + shift( center, -1 ))/2.
edge = edge[0:n_elements(edge)-2]
; the expression before is ok except for the first and last values
; for the first value we take the
first =  center[0] - ( edge[0] - center[0] )
last = 2* last_item( center ) -last_item(edge)
IF first GT last THEN BEGIN
    temp =  last
    last =  first
    first =  temp
ENDIF

crange=keyword_set( ylog )? 10^(!y.crange): !y.crange
IF crange[0] LT crange[1] THEN BEGIN
    first = first > crange[0]
    last = last < crange[1]
ENDIF ELSE BEGIN
    last = last < crange[0]
    first = first >  crange[1]
    temp = last
    last = first
    first = temp
ENDELSE


; determine the position where to plot the image

xcrange = minmax( xaxis )
position = convert_coord( xcrange, $
                          [first, last], /data, /to_normal )

;stop
;print, 'first, last = ', first, last

xpos = position[0,*]
ypos = position[1,*]
if ypos[1] lt ypos[0] then ypos = ypos[[1,0]]
if xpos[1] lt xpos[0] then xpos = xpos[[1,0]]


;kim+
checkvar, bottom, 0
checkvar, top, !d.table_size-1
if exist(ncolors) then top = bottom + ncolors
; scale image to range of colors between top and bottom
image = cscale( image, bottom=bottom, top=top, drange=drange, /nan)
;kim-

IF !d.flags AND 1 THEN BEGIN
    image = interp_image( image, xaxis, yaxis, $
                          !d.x_size/!d.x_px_cm*100, $
                          !d.y_size/!d.y_px_cm*100, YLOG=ylog, NO_SMOOTH=no_interpolate)

    tv, image, xpos[0], ypos[0], /normal, $ ;kim  - tvscl -> tv
        xsize=xpos[1]-xpos[0], $
        ysize=ypos[1]-ypos[0]
ENDIF ELSE BEGIN

    im_size = convert_coord(xpos, ypos, /normal, /to_device)

    npixx = round(im_size[0, 1] - im_size[0, 0])
    npixy = round(im_size[1, 1] - im_size[1, 0])
                                ; adapt image to the axis:\

    IF npixx GT 0 AND npixy GT 0 THEN BEGIN
        image = Interp_image( image, xaxis, yaxis, $
                              npixx, npixy, $
;;;;                              first=first , $
;;;;                              last=last, $
                              YLOG=ylog, NO_SMOOTH=no_interpolate )
;kim+  changed tvscl to tv since already scaled image to bytes
        tv, image, xpos[0], ypos[0], /normal, /NAN
    ENDIF
;kim-
ENDELSE

; do the axes again
; wow. took me a while to figure out that you can just issue a dumb command and that will do.
;outplot, [0,0],[0,0]

Axis, YAXIS=0, YRANGE=yrange, YLOG=ylog, ytitle=ytitle, $
    ystyle = ystyle, charsize=charsize ; kim added ytitle, PSH added charsize

if fix( ystyle ) / 8 ne 1 then begin
; this one on the right side  (without annotations)
    Axis, YAXIS=1, CHARSIZE=0.001, XTITLE=' ', $
        YRANGE=yrange, YLOG=ylog, ystyle = ystyle
endif

xaxis = get_utaxis( /xaxis )
temp = !x
!x = xaxis
IF tag_exist(_extra,'xtickname',/QUIET) THEN axis, xaxis = 0, xstyle= xstyle, charsize=charsize,xtickname=_extra.xtickname  ELSE axis, xaxis = 0, xstyle= xstyle, charsize=charsize
if fix(xstyle) / 8 ne 1 then begin
    axis, xaxis = 1, CHARSIZE=0.001, xstyle = xstyle
ENDIF
!x =  temp

 if since_version('5.2') and cbar then plot_map_colorbar, minmax(imagep), $
 	bottom, ncolors, log=zlog, _extra=_extra
END

;-------------------------------------------------------------------------------------------------

PRO rapp_spectro_plot, param0, param1, param2, param3, $
           param4, param5, param6, $
           param7, param8, param9, $
           param10, param11, $
           XRANGE=xrange, YRANGE=yrange, $
           TIMERANGE=timerange, $
           NO_INTERPOLATE=no_interpolate, $
           YINTEGRATE=yintegrate, $
           YLOG=ylog, $
           ZLOG=zlog, ZEXP=zexp, $
           CHARSIZE=charsize, $
           XTITLE=xtitle, YTITLE=ytitle, TITLE=title, $
           POSTSCRIPTS=POSTSCRIPT, $
           INVERT=invert, $
           xstyle  = xstyle, ystyle = ystyle, $
           cbar=cbar, $
           _EXTRA=_extra

; do some admin stuff

IF Keyword_Set( NO_UT ) THEN ut = 0 ELSE ut = 1
IF KEYWORD_SET( POSTSCRIPT ) THEN ps, /color
IF Keyword_Set( TIMERANGE ) THEN xrange = timerange
CheckVar, ylog, 0

; wrapper to allow input from wind's tplot

n_par = N_Params()
param_size = Size( param1, /structure )
yes_multi = 0
yes_struct = Is_Struct( param0 )
IF NOT yes_struct THEN n_par = ((n_par-1)/3)+1
IF n_par GT 1 THEN BEGIN
    yes_multi = 1
    old_multi = !p.multi
    !p.multi = [0, 1, n_par]
ENDIF

; first move the data to an array of structs that we can manipulate
; easily
data = PtrArr(n_par)
this_cbar = n_par gt 1 ? 0 : keyword_set(cbar)
FOR i=0, n_par-1 DO BEGIN
    IF yes_struct THEN BEGIN
        param_nr = strtrim( i, 2 )
        result = Execute( 'this_struct=' + 'param' + param_nr, 1 )
        IF NOT have_tag( this_struct, 'SPECTROGRAM' ) THEN  BEGIN
; attempt to guess if it's a tplot structure; if it's a tplot one, then
; convert the tplot time to anytim
; hope nobody will ever want to do another struct wit x,y,v tags.... it might
; be a little bit risky but in this context it should be safe
            IF have_tag( this_struct, 'x' ) AND have_tag( this_struct, 'y' ) THEN BEGIN
                spectro_struct = {spectrogram: this_struct.y, x: tplot2any( this_struct.x ) }
                IF have_tag( this_struct, 'v' ) THEN BEGIN
                    spectro_struct = add_tag( spectro_struct, this_struct.v, 'y' )
                ENDIF ELSE BEGIN
                    spectro_struct = add_tag( spectro_struct, lindgen(n_elements(this_struct.y[0, *])), 'y' )
                ENDELSE
                data[i] = ptr_new( spectro_struct )
            ENDIF
        ENDIF ELSE BEGIN
            IF NOT have_tag( this_struct, 'y' ) THEN BEGIN
                this_struct = add_tag( this_struct, lindgen(n_elements(this_struct.spectrogram[0, *])), 'y' )
            ENDif
            data[i] = ptr_new( this_struct )
        ENDELSE
    ENDIF ELSE BEGIN
        result = Execute( 'spectrogram=' + 'param' + strtrim( i*3, 2 ), 1 )
        result = Execute( 'xaxis=' + 'param' + strtrim( i*3+1, 2 ), 1 )
        IF NOT result THEN xaxis = lindgen( N_Elements( spectrogram[*, 0] ) )
        result = Execute( 'yaxis=' + 'param' + strtrim( i*3+2, 2 ), 1 )
        IF NOT result THEN yaxis = lindgen( N_Elements( spectrogram[0, *] ) )
        data[i] = Ptr_new( {spectrogram:spectrogram, x:xaxis, y:yaxis} )
    ENDELSE
; try to determine the range
ENDFOR

IF NOT Keyword_Set( XRANGE ) THEN BEGIN
    IF NOT Keyword_Set( X_REFERENCE ) THEN BEGIN
        FOR i=0, n_par-1 DO BEGIN
            this_xrange = MinMax( (*data[i]).x )
            IF i EQ 0 THEN BEGIN
                xrange = this_xrange
            ENDIF ELSE BEGIN
                xrange = [xrange[0] > this_xrange[0], xrange[1] < this_xrange[1]]
                print, anytim( xrange, /ccs )
            ENDELSE
        ENDFOR
    ENDIF ELSE BEGIN
        xrange = MinMax( (*data[x_reference]).x)
    ENDELSE
ENDIF

FOR i=0, n_par-1 DO BEGIN

    IF Keyword_Set( YLOG ) THEN BEGIN
        this_ylog = ylog[i < (N_Elements( YLOG )-1) ]
    ENDIF
    IF Keyword_Set( ZLOG ) THEN BEGIN
        this_zlog = zlog[i < (N_Elements( ZLOG )-1) ]
    ENDIF
    IF Keyword_Set( ZEXP ) THEN BEGIN
        this_zexp = zexp[i < (N_Elements( ZEXP )-1) ]
    ENDIF
    IF Keyword_Set( YRANGE ) THEN BEGIN
        this_yrange = yrange[*, i < (N_Elements( YRANGE[0,*] )-1) ]
        ;print, 'this_range=',this_yrange
        IF NOT valid_range( this_yrange ) THEN this_yrange =  0
    ENDIF ELSE this_yrange =  [0,0]
    IF Keyword_Set( NO_INTERPOLATE ) THEN BEGIN
        this_no_interpolate = no_interpolate[i < (N_Elements( no_interpolate )-1) ]
    ENDIF
    IF Keyword_Set( yintegrate ) THEN BEGIN
        IF N_dimensions( yintegrate ) gt 1 then begin
            if N_Elements( yintegrate[0, *] ) GT 1 THEN BEGIN
                this_yintegrate = yintegrate[*, i < (N_Elements( yintegrate )-1) ]
            ENDIF ELSE BEGIN
                this_yintegrate = yintegrate
            ENDELSE
        endif else if N_dimensions( yintegrate ) eq 1 then begin
            ;this_yintegrate = yintegrate[i < (N_Elements( yintegrate )-1) ]
            this_yintegrate = yintegrate
        endif
    ENDIF
    IF Keyword_Set( ytitle ) THEN BEGIN
        this_ytitle = ytitle[i < (N_Elements( ytitle )-1) ]
    ENDIF
    IF Keyword_Set( title ) THEN BEGIN
        this_title = title[i < (N_Elements( title )-1) ]
    ENDIF
    IF Keyword_Set( invert ) THEN BEGIN
        this_invert = invert[i < (N_Elements( invert )-1) ]
    ENDIF
    IF Keyword_Set( xstyle ) THEN BEGIN
        this_xstyle = xstyle[i < (N_Elements( xstyle )-1) ]
    ENDIF
    IF Keyword_Set( ystyle ) THEN BEGIN
        this_ystyle = ystyle[i < (N_Elements( ystyle )-1) ]
    ENDIF

    ;;;;i LT (n_par-1) ? ' ' : ''
    IF N_ELEMENTS(xtitle) GT 1 THEN xtit=xtitle[i] ELSE IF exist(xtitle) THEN xtit=xtitle ;;;; 
    ;;;;charsize=i LT (n_par-1) ? 0.001 : 0

    rapp_spectro_plot_inner, (*data[i]).spectrogram, (*data[i]).x, (*data[i]).y, $
        _EXTRA=_extra, XRANGE=xrange, $
        ZLOG=this_zlog, YLOG=this_ylog, ZEXP=this_zexp,  $
        XTITLE=xtit, YTITLE=this_ytitle, TITLE=this_title, $
        CHARSIZE=charsize, YRANGE=this_yrange, $
        NO_INTERPOLATE=this_no_interpolate , $
        YINTEGRATE=this_yintegrate, INVERT=this_invert, $
        xstyle = this_xstyle, ystyle = this_ystyle, cbar=this_cbar

ENDFOR

IF KEYWORD_SET(POSTSCRIPT) THEN psclose
IF yes_multi GT 0 THEN !p.multi = old_multi
Ptr_free, data

END

;-------------------------------------------------------------

