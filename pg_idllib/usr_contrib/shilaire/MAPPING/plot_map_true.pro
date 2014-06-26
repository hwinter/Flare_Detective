;+
; Project     : SOHO_CDS
;
; Name        : PLOT_MAP
;
; Purpose     : Plot an image map
;
; Category    : imaging
;
; Syntax      : plot_map,map
;
; Inputs      : MAP = image structure map created by MAKE_MAP
;               INDEX = optional index (if array of maps) [def=0]
;
; Keywords    :
;     /OVERLAY = overlay on previous image
;     /CONT = contour the image
;     SMOOTH_WIDTH = smoothing width (> 1)
;     FOV = [fx,fy] = field of view to be plotted
;     GRID = grid spacing (deg) for latitude-longitude grid [def= 0, no grid]
;     GLABEL = label grid with coordinate values [def = 0, no labels]
;     GSTYLE = grid linestyle [def=0]
;     CENTER = [xc,yc] = center coordinates (arcsec) of FOV [def = center of image]
;            (if center is a valid map, then use its center)
;     DMIN,DMAX = min, max data for plot [def = data min,max]
;     BORDER = draw border around image [def = no]
;     /TAIL = allows user to tailor contours
;     /LOG  = log_10 scale image
;     WINDOW = window index to send plot to
;     /NOAXES = inhibit plotting axes
;     /NOTITLE = inhibit printing title
;     /NOLABELS = inhibit axis labels
;     /NOXTICKS = inhibit X-tick labels
;     /NOYTICKS = inhibit Y-tick labels
;     /DROTATE  = solar rotate image contour
;     LEVELS  = user specified contour levels
;     /POSITIVE_ONLY = plot positive data
;     /NEGATIVE_ONLY = plot negative data
;     XRANGE,YRANGE = cartesian plot limits
;     /INTERLACE = interlace two images when overlaying
;     /COMPOSITE = simultaneously plot two images when overlaying
;                = type of compositing:
;                  1: original , 2: latest(new), 3: max(new/old) 4: min(new/old)
;     /AVERAGE   = average two images when using /COMPOSITE
;     BOTTOM = lowermost color index to use in color scaling [def=0]
;     LAST_SCALE = use MIN/MAX from previous plot, or if LAST is a valid map
;                  use scaling from it
;     LIMB = overplot solar limb
;     ROLL = roll image contour
;     BTHICK = border thickness
;     CTHICK = contour thickness
;     LCOLOR = contour line color
;     ACOLOR = axes color (removed)
;     MULTI = set for multiple plots per page, e.g. mult=[2,2] (or 2) for 4
;             plots per page (!p.multi remains at this value until cleared)
;     NOERASE = don't erase previous plot
;     SQUARE = force equal aspect ratio (by adjusting position)
;     CLABEL  = label contours
;     CSTYLE  = contour linestyle
;     MARGIN  = margin around plot [normalized coords, used only if /SQUARE]
;     /SURFACE = show the image as a wire surface
;     /SHADE_SURF = show the image as a shaded surface
;     AX_SURF = Angle of rotation about X axis for surface (degrees)
;     AZ_SURF = Angle of rotation about Z axis for surface (degrees)
;     ERR_MSG = String error message if any
;     STATUS = 0/1 means failure/success
;     CBAR = 0/1 means draw colorbar on image plots (only works in > IDL 5.2)
;     CCHARSIZE = size of characters used for contour level labels.  (if not set, but charsize is
;        passed in extra, then c_charsize is .75 * charsize.  Otherwise 0.)
;     PERCENT = if levels are entered, they are in % of data max
;
; Restrictions:
;      - do not set /GRID unless absolute coordinates of image are known
;      - do not set /OVERLAY unless a plot exists on the current device
;
; History     : Written 22 December 1996, D. Zarro, SAC/GSFC
;             : S.L.Freeland - let COMPOSITE have different interpretations
;             : Major modifications 15 Feb 1999, Zarro (SM&A/GSFC)
;                -- reorganized
;                -- sped-up sub-field extraction
;                -- fixed potential bug in contour levels scaling
;                -- fixed potential bug in image color scaling
;                -- fixed roll correction
;             : Zarro (SM&A/GSFC) 28 April 1999
;                -- fixed roll_center interpretation
;                (heaven help me for onlining this during Gopal's CDAW)
;             : Zarro (SM&A/GSFC) 3 May 1999
;                -- allowed overlaying images with different roll centers.
;             : Zarro (SM&A/GSFC) 5 Aug 1999
;                -- Made VIEW_ADJUST=1 the default
;             : Zarro (SM&A/GSFC) 25 Sep 1999
;                -- Made VIEW_ADJUST=0 the default
;             : Zarro (SM&A/GSFC) 1 Nov 1999
;                -- Added GSTYLE grid style keyword
;             : Zarro (SM&A/GSFC) 30 Nov 1999
;                -- Added OVERLAY=2 hidden feature
;             : Zarro (SM&A/GSFC) 14 Feb 2000
;                -- changed CONT keyword to CONTOUR, and added /EXTEND
;             : Zarro (SM&A/GSFC) 27 Mar 2000
;                -- changed CLABEL, removed old keywords
;             : Zarro (SM&A/GSFC) 7 Apr 2000
;                -- fixed roundoff errors causing edge pixels
;                   to spill over during hardcopying. Also improved smoothing.
;             : Zarro (SM&A/GSFC) 25 Apr 2000
;                -- fixed problem with image viewport falling outside plot
;                   limits; removed EXTENDS, VIEW_ADJUST keywords
;             : Zarro (EIT/GSFC) 10 May 2000, added optional INDEX argument
;             : Zarro (EIT/GSFC) 28 June 2000, added MARGIN keyword and call
;                to GET_ASPECT
;				: Kim 27 Sep 2000 - added surface and shade_surface options
;				: Kim 29 Sep 2000 - removed some keywords to stay under 64 argument limit
;					in versions < 5.3.  Handle new keywords in _extra
;				: Kim 1 Oct 2000 - added show3 option
;				: Kim 4 Oct 2000 - added status keyword.  err keyword became err_msg.
;             : Zarro (EIT/GSFC): 6 Oct 2000 -- restored capability to overlay
;                                images without using contours.
;                                13 Oct 2000 -- added rescale zoom logic
;             : Kim 9 Jan 2001 - added colorbar option (for > IDL V 5.2) and ccharsize keyword
;             : Khan (MSSL/ISAS): 2001 Mar 30 -- Changed Kim's colorbar to cbar to avoid conflict with color keyword
;             : Zarro (EITI/GSFC): 2001 Jun 18 -- Fixed Z-buffer bug
;             : Zarro (EITI/GSFC): 2001 Sept 1 -- added /PERCENT
;             : Kim: 2001 Sep 6 - don't draw limb for surface, shade_surf, or show3
;			  : PSH: 2001/11/10 - added channelcolor keyword (modifications done only for X or WIN displays)
;	
;
; Contact     : dzarro@solar.stanford.edu
;-

pro plot_map_white,xb_dev,yb_dev,xr_dev,yr_dev

;-- utility routine to white-out "over the edge pixels" in postscript plots

 white=!d.table_size-1
 left_x=min(xb_dev)
 right_x=max(xb_dev)
 sx=right_x-left_x+1.
 bot_y=min(yb_dev)
 top_y=max(yb_dev)
 sy=top_y-bot_y+1.
 white_out=bytarr(2,2)+white
 t1=left_x
 t2=min(xr_dev)
 if (t1 lt t2) and ((t2-t1) ge 1) then begin
  tv,white_out,t1,yb_dev(0),xsize=t2-t1,ysize=sy
 endif
 t1=right_x
 t2=max(xr_dev)
 if (t1 gt t2) and ((t1-t2) ge 1) then begin
  tv,white_out,t2+1,yb_dev(0),xsize=t1-t2,ysize=sy
 endif
 t1=bot_y
 t2=min(yr_dev)
 if (t1 lt t2) and ( (t2-t1) ge 1) then begin
  tv,white_out,xb_dev(0),t1,xsize=sx,ysize=t2-t1
 endif
 t1=top_y
 t2=max(yr_dev)
 if (t1 gt t2) and ( (t1-t2) ge 1) then begin
  tv,white_out,xb_dev(0),t2+1,xsize=sx,ysize=t1-t2
 endif
 return & end

;-----------------------------------------------------------------------------

pro plot_map_true,map,index,contour=cont,overlay=overlay,smooth_width=smooth_width,border=border,$
 fov=fov,grid=grid,glabel=glabel,gstyle=gstyle,center=center,$
 tail=tail,log_scale=log_scale,notitle=notitle,title=title,$
 lcolor=lcolor,window=window,noaxes=noaxes,nolabels=nolabels,$
 xsize=xsize,ysize=ysize,new=new,levels=levels,$
 missing=missing,dmin=dmin,dmax=dmax,$
 top=top,quiet=quiet,square=square,$
 trans=trans,positive_only=positive_only,$
 negative_only=negative_only,$
 offset=offset,time=time,bottom=bottom,$
 cstyle=cstyle,cthick=cthick,date_only=date_only,nodate=nodate,$
 gfont=gfont,last_scale=last_scale,composite=composite,$
 interlace=interlace,xrange=xrange,yrange=yrange,$
 average=average,ncolors=ncolors,drange=drange,$
 limb=mark_limb,roll=roll,rcenter=rcenter,truncate=truncate,$
 duration=duration,bthick=bthick,drotate=drotate,$
 multi=multi,noerase=noerase,_extra=extra,clabel=clabel,margin=margin, $
 status=status, err_msg=err_msg,channelcolor=channelcolor

IF NOT KEYWORD_SET(channelcolor) THEN channelcolor=0

status = 1
err_msg = ''


;-- determine extra keywords

more_keywords = ['surface', 'shade_surf', 'ax_surf', 'az_surf', 'show3',$
                 'rescale_image', 'cbar', 'ccharsize','percent']

@extra_keywords

;-- some variables saved in memory for overlay

@plot_map_com

err=''

;-- color controls

zbuff=!d.name eq 'Z'
wbuff=(!d.name eq 'X') or (!d.name eq 'WIN')
post=(!d.name eq 'PS')
n_colors=!d.table_size
white=n_colors-1L & black=0L

if not exist(lcolor) then begin
 if wbuff or zbuff then lcolor=white else lcolor=black
endif

if not exist(bottom) then bottom=0 else bottom=bottom > 0
if not exist(top) then begin
 if exist(ncolors) then top=(bottom+ncolors-1L) else top=n_colors-1L
endif
top=top < (n_colors-1L)

;-- examine keywords

quiet=keyword_set(quiet)
loud=1-quiet
surf=keyword_set(surface)		;-- surface image
sh_surf = keyword_set(shade_surf) 	;-- shade_surf image
show3 = keyword_set(show3)		;-- image, surface, contour
bord=exist(border)              ;-- plot image border
dlog=keyword_set(log_scale)     ;-- log scale image
droll=exist(roll)               ;-- roll image
dtrans=n_elements(trans) eq 2   ;-- translate image
if not exist(grid) then grid=0  ;-- no grid

limb = keyword_set(mark_limb)
if surf or sh_surf or show3 then limb = 0

if keyword_set(rotate) and (1-keyword_set(drotate)) then $
 message,'in future, please use /DROTATE instead of /ROTATE',/cont
drotate=keyword_set(rotate) or keyword_set(drotate)

;-- always overlay as a contour unless /interlace, /composite, or cont=0, are set

if is_number(overlay) then over = (0 > overlay < 1) else over=0
if is_number(cont) then cont= (0 > cont < 1) else cont=over
if over and (not cont) then composite=2
if is_number(noerase) then noerase= (0 > noerase < 1) else noerase=over


take_average=keyword_set(average)
interlace=keyword_set(interlace)
if keyword_set(composite) then comptype=composite   ; intercept COMPTYPE
composite=keyword_set(composite)
if composite or interlace then begin
 over=1 & cont=0
endif

;dprint,'% over, cont, composite, noerase: ',$
;          over, cont, composite, noerase

;-- open a new window if one doesn't exist
;-- else get viewport from previous plot


if (over eq 0) then begin

 get_xwin,window,xsize=xsize,ysize=ysize,new=new

; if (!d.name eq 'X') then wshow,window,0

endif else begin

 if exist(window) and exist(last_window) and (not zbuff) then begin
  if window ne last_window then begin
   err_msg='WARNING - overlaying on other than last plot window. Cannot guarantee coalignment'
   print,'---------------------------------------------------------------------'
   message,err_msg,/cont
   print,'% window, last_window: ',window,last_window
   print,'---------------------------------------------------------------------'
  endif
 endif
 ok=1

 if over eq 1 then begin
  if not exist(last_window) then begin
   if not exist(window) then begin
    status = 0
    err_msg='No previous window on which to overlay'
    message,err_msg,/cont
    return
   endif else last_window=window
  endif
  smart_window,last_window,status=ok,draw=draw
 endif

 if not ok then begin
  if exist(last_window) then app=trim(string(last_window))
  status = 0
  err_msg='Could not open window '
  if exist(app) then err_msg=err_msg+app
  message,err_msg,/cont
  return
 endif
endelse

;-- overlay limb and/or grid

if (over gt 0) and keyword_set(limb) then begin
 if not exist(last_time) then begin
  err_msg='No previous image on which to overlay limb/grid'
  message,err_msg,/cont
  if not valid_map(map) then begin
  	status = 0
  	return
  endif
 endif
 plot_helio,last_time,roll=last_roll,grid=grid,glabel=glabel,gstyle=gstyle,$
  /over,color=lcolor,font=gfont,soho=last_view,center=last_rcenter,limb=limb
 return
endif

;-- check input map

if not exist(map) then begin
 status = 0
 err_msg = 'plot_map,map'
 pr_syntax,err_msg
 return
endif

if not valid_map(map) then begin
 status = 0
 err_msg='Invalid input image map'
 message,err_msg,/cont
 return
endif

nmaps=n_elements(map)
if not is_number(index) then index=0 else index= 0 > index < (nmaps-1)
if nmaps gt 1 then begin
 err = 'input map is an array, plotting index '+trim(index)
 message, err, /cont
endif

;-- plot labels

mtime=get_map_time(map(index),/tai,/original)
mtitle=get_map_prop(map(index),/id,def='')
if (over eq 0) then begin
 err=''
 date_obs=anytim2utc(mtime,/vms,err=err,time_only=keyword_set(nodate),$
  date_only=date_only,truncate=truncate)
 if (1-keyword_set(date_only)) then field=' UT' else field=''
 if err eq '' then mtitle=mtitle+' '+date_obs+field
endif
mtitle=trim(mtitle)
if datatype(title) eq 'STR' then mtitle=title
if keyword_set(notitle) then mtitle=''
units=get_map_prop(map(index),/units,def='arcsecs')
units='('+units+')'
xunits=units & yunits=units
if tag_exist(map(index),'xunits') then xunits='('+(map(index)).xunits+')'
if tag_exist(map(index),'yunits') then yunits='('+(map(index)).yunits+')'
xtitle='X '+xunits & ytitle='Y '+yunits
if keyword_set(nolabels) then begin
 xtitle='' & ytitle=''
endif

;-- keep track of plot location for multi-page plots
;-- clear page if !p.multi changed

if exist(multi) then begin
 pmulti=[multi(0),multi(n_elements(multi)-1)]
 !p.multi([1,2])=pmulti
endif
pnx=!p.multi(1)
pny=!p.multi(2)
if n_elements(last_multi) lt 3 then last_multi=!p.multi
if (last_multi(1) ne pnx) or (last_multi(2) ne pny) then begin
 help,'erasing...'
 erase & !p.multi(0)=0
endif

;-- go to previous image if an overlay

sp=!p.multi(0)
if (over gt 0) then begin
 !p.multi(0)=(!p.multi(0)+1)
 if !p.multi(0) gt pnx*pny then !p.multi(0)=0
 sp=!p.multi(0)
endif

;-- deduce image center
;   (start with that of image, then FOV keyword, then CENTER keyword)

icenter=get_map_prop(map(index),/center)
dcenter=icenter
if valid_map(fov) then dcenter=get_map_prop(fov,/center)
if exist(center) then begin
 if valid_map(center) then dcenter=get_map_prop(center,/center) else begin
  if n_elements(center) eq 2 then dcenter=float(center)
 endelse
endif

;-- deduce actual ranges
;   (start with image, then FOV, then XRANGE/YRANGE keywords)

ixrange=get_map_prop(map(index),/xr)
iyrange=get_map_prop(map(index),/yr)
dx=get_map_prop(map(index),/dx)
dy=get_map_prop(map(index),/dy)
dx2=dx/2. & dy2=dy/2.

def_xmin=min(ixrange)-dx2
def_xmax=max(ixrange)+dx2
def_ymin=min(iyrange)-dy2
def_ymax=max(iyrange)+dy2
dxrange=[def_xmin,def_xmax]
dyrange=[def_ymin,def_ymax]
oxrange=dxrange
oyrange=dyrange

if exist(fov) then begin
 if valid_map(fov) then dfov=get_map_fov(fov) else begin
  nfov=n_elements(fov)
  dfov=60.*float([fov(0),fov(nfov-1)])
 endelse
endif else dfov=[max(dxrange)-min(dxrange),max(dyrange)-min(dyrange)]
half_fov=dfov/2.
dxrange=[dcenter(0)-half_fov(0),dcenter(0)+half_fov(0)]
dyrange=[dcenter(1)-half_fov(1),dcenter(1)+half_fov(1)]

if valid_range(xrange) then dxrange=float(xrange)
if valid_range(yrange) then dyrange=float(yrange)

;-- if overlaying, match with previous viewport

if (over gt 0) then begin
 if valid_range(last_xrange) then begin
  dxrange(0)=last_xrange(0) > dxrange(0)
  dxrange(1)=last_xrange(1) < dxrange(1)
 endif
 if valid_range(last_yrange) then begin
  dyrange(0)=last_yrange(0) > dyrange(0)
  dyrange(1)=last_yrange(1) < dyrange(1)
 endif
endif

;-- def viewport

;dprint,'% dxrange ',dxrange
;dprint,'% dyrange ',dyrange

xmin=min(dxrange) & xmax=max(dxrange)
ymin=min(dyrange) & ymax=max(dyrange)

if (xmin eq xmax) or (ymin eq ymax) then begin
 status = 0
 err_msg='Plot scale MIN/MAX must differ'
 message,err_msg,/cont
 goto,clean_up
endif

;-- get some map properties

curr_view=get_map_prop(map(index),/soho,def=0b)
curr_roll=get_map_prop(map(index),/roll_angle,def=0.)
curr_rcenter=get_map_prop(map(index),/roll_center,def=icenter)
if exist(rcenter) then begin
 if valid_map(rcenter) then roll_center=get_map_prop(rcenter,/center) else $
  if n_elements(rcenter) eq 2 then roll_center=float(rcenter)
endif else roll_center=icenter
;if curr_view then dprint,'% using SOHO view'
if exist(time) then rtime=time else $
 if exist(last_time) and (over gt 0) then rtime=last_time
if not exist(last_view) then last_view=curr_view

;-- warn if views differ

if over and exist(last_view) then begin
 if curr_view ne last_view then begin
  warn='Overlay image has different spacecraft view from previous.'
  warn1='Use MAP2EARTH or EARTH2MAP to correct'
  message,warn,/cont
  message,warn1,/cont,/noname
  err_msg = warn + ' ' + warn1
 endif
endif

;-- if solar rotating, first de-rotate viewport and extract only
;   pixels that will be rotated into field (faster this way)

mxrange=dxrange & myrange=dyrange
xt=[mxrange(0),mxrange(1),mxrange(1),mxrange(0)]
yt=[myrange(0),myrange(0),myrange(1),myrange(1)]

if drotate and cont then begin
 dprint,'% solar rotating to: '+rtime
 dur=get_drot_dur(map(index),duration,time=rtime)
 if not exist(rtime) then rtime=mtime+dur
 if dur eq 0. then drotate=0b else begin
  drot_xy,xt,yt,mtime,mtime-dur,xtm,ytm,$
   roll_angle=curr_roll,roll_center=curr_rcenter,view=curr_view
  mxrange=[min(xtm),max(xtm)]
  myrange=[min(ytm),max(ytm)]
  rcheck=sqrt(mxrange^2 + myrange^2)
  pr=pb0r(mtime,soho=curr_view,/arcsec)
  radius=float(pr(2))
  if rcheck(0) ge radius then begin
   mxrange(0)=ixrange(0) & myrange(0)=iyrange(0)
  endif
  if rcheck(1) ge radius then begin
   mxrange(1)=ixrange(1) & myrange(1)=iyrange(1)
  endif
 endelse
 xt=[mxrange(0),mxrange(1),mxrange(1),mxrange(0)]
 yt=[myrange(0),myrange(0),myrange(1),myrange(1)]
endif

;-- if overlaying and roll is not specifically requested, then we need to
;    roll second image to same roll angle and center as first image

if droll then roll=float(roll)
need_to_roll=0b
if (over gt 0) and cont and (not droll) and exist(last_roll) then begin
 need_to_roll=(abs(last_roll-curr_roll) mod 360.) ne 0.
 if need_to_roll then begin
  dprint,'% PLOT_MAP: base and overlay image have different rolls -- will correct'
  dprint,last_roll,curr_roll
  droll=1b & roll=last_roll-curr_roll
  if exist(last_rcenter) and ((last_roll mod 360.) ne 0.) then $
   roll_center=last_rcenter else roll_center=curr_rcenter
 endif
endif

;-- if rolling, roll only pixels in viewport

if droll then droll=(roll mod 360.) ne 0.

need_to_rcenter=0b
if droll and cont and (over gt 0) then begin
 dprint,'% roll angle , roll center: ',roll,roll_center
 if need_to_roll then $
  need_to_rcenter=(roll_center(0) ne curr_rcenter(0)) or $
                  (roll_center(1) ne curr_rcenter(1))
 if need_to_rcenter then begin
   dprint,'% PLOT_MAP: base and overlay image have different roll_centers -- will correct'
   dprint,roll_center,curr_rcenter
   roll_xy,xt,yt,-last_roll,xtm,ytm,center=roll_center
   roll_xy,xtm,ytm,curr_roll,xtm,ytm,center=curr_rcenter
 endif else roll_xy,xt,yt,-roll,xtm,ytm,center=roll_center
 mxrange=[min(xtm),max(xtm)]
 myrange=[min(ytm),max(ytm)]
endif


;-- check if translating

xoff=0. & yoff=0.
if dtrans then begin
 xoff=trans(0) & yoff=trans(1)
endif

;-- unpack data and pixel arrays

pic=get_map_sub(map(index),xrange=mxrange-xoff,yrange=myrange-yoff,arange=brange,$
                irange=irange,count=count,err=err_msg)

if (err_msg ne '') then begin
	status = 0
	goto,clean_up
endif

;-- smoothing?

if is_number(smooth_width) then begin
 if smooth_width gt 0. then begin
  smo=round(smooth_width) > 2
  pic=call_function('smooth',temporary(pic),smo,/edge)
 endif
endif

brange(0:1)=brange(0:1)+xoff
brange(2:3)=brange(2:3)+yoff
if cont or surf or sh_surf or show3 then begin
 xp=get_map_prop(map(index),/xp)
 yp=get_map_prop(map(index),/yp)
 xp=temporary(xp(irange(0):irange(1),irange(2):irange(3)))+xoff
 yp=temporary(yp(irange(0):irange(1),irange(2):irange(3)))+yoff
endif

if (drotate or droll) and (not cont) then begin
 status = 0
 err_msg='Can only solar rotate/roll in overlay or contour mode'
 message,err_msg,/cont
 goto,clean_up
endif

;-- solar rotate

if drotate then begin
 drot_xy,xp,yp,mtime,mtime+dur,xp,yp,err=err_msg,/verbose,/no_copy,$
  roll_angle=curr_roll,roll_center=curr_rcenter,view=curr_view
 if err_msg ne '' then begin
  status = 0
  goto,clean_up
 endif
endif

;-- apply roll

if droll then begin
 if need_to_rcenter then begin
  roll_xy,xp,yp,-curr_roll,xp,yp,center=curr_rcenter
  roll_xy,xp,yp,last_roll,xp,yp,center=roll_center
 endif else roll_xy,xp,yp,roll,xp,yp,center=roll_center
endif

;-- get data limits

if cont or surf or sh_surf or show3 then begin
 min_x=min(xp) & max_x=max(xp)
 min_y=min(yp) & max_y=max(yp)
endif else begin
 min_x=brange(0) & max_x=brange(1)
 min_y=brange(2) & max_y=brange(3)
endelse

;-- define outer edges of extracted data
;   (for heaven's sake don't roundoff here)

emin_x=(min_x-dx2)
emax_x=(max_x+dx2)
emin_y=(min_y-dy2)
emax_y=(max_y+dy2)
xedge = [emin_x,emax_x,emax_x,emin_x,emin_x]
yedge = [emin_y,emin_y,emax_y,emax_y,emin_y]

nx=data_chk(pic,/nx)
ny=data_chk(pic,/ny)

;-- get data value limits
;-- start with actual data, then dmin/dmax keywords, then last scale, and
;   finally drange.

npic=n_elements(pic)
pmin=min(pic,max=pmax)
prange=[pmin,pmax]

if exist(dmin) then prange(0)=dmin
if exist(dmax) then prange(1)=dmax
if exist(last_scale) then begin
 if valid_map(last_scale) then prange=get_map_prop(last_scale,/dr) else begin
  if valid_range(last_drange) then prange=last_drange
 endelse
endif

if exist(drange) then begin
 if valid_map(drange) then prange=get_map_prop(drange,/dr) else begin
  if n_elements(drange) eq 2 then prange=float(drange)
 endelse
endif

if (min(prange) eq max(prange)) then prange=[pmin,pmax]
if n_elements(positive_only) eq 1 then if (positive_only ne 0) then begin
 prange(0)=0 & missing=0
endif

if keyword_set(negative_only) then begin
 prange(1)=0 & missing=0
endif

;-- if zooming and rescale_zoom=0, then we use drange of
;   unzoomed image

if is_number(rescale_image) then rescale_zoom=(0 > rescale_image < 1) else $
 rescale_zoom=1

zoom= (min(dxrange) ne min(oxrange)) or (min(dyrange) ne min(oyrange)) or $
      (max(dxrange) ne max(oxrange)) or (max(dyrange) ne max(oyrange))

;dprint,'% zoom, rescale_zoom: ',zoom,rescale_zoom
if zoom and (rescale_zoom eq 0) then prange=get_map_prop(map(index),/dr)

;-- set up contours

@plot_map_cont

;-- plot axes & viewport
;-- try to preserve aspect ratio (won't work if multi is set)

; if not(cont or surf or sh_surf) and keyword_set(cbar) then margin = .17

@plot_map_aspect

 if not aspect and not(cont or surf or sh_surf) and keyword_set(cbar) then begin
  if have_tag(extra, 'position') then extra.position = extra.position * [1.,1.,1.,.9] else begin
   position = [.1,.1, .9, .85]
   sz = size(extra)
  	if sz(n_elements(sz)-2) eq 8 then extra = add_tag (extra, position, 'position') else $
  		extra = {position: position}
  endelse
 endif


;-- make an empty plot to establish scaling


if (over eq 0) then begin
 if have_tag(extra,'noxt') then begin
  xticks=replicate(' ',n_elements(!x.tickname)-1)
  extra=rep_tag_value(extra,xticks,'xtickname')
 endif
 if have_tag(extra,'noyt') then begin
  yticks=replicate(' ',n_elements(!y.tickname)-1)
  extra=rep_tag_value(extra,yticks,'ytickname')
 endif
 !p.multi(0)=sp
 plot,[xmin,xmax,xmax,xmin,xmin],[ymin,ymin,ymax,ymax,ymin],/data, $
  xstyle=5,ystyle=5,noerase=noerase,/nodata,xrange=dxrange,yrange=dyrange,$
  _extra=extra
 smart_window,window,/set,draw=draw
endif

;-- plot contour


if cont or surf or sh_surf then begin
 !p.multi(0)=sp
 if drotate then begin
  off_limb=where_off_limb(xp,yp,mtime,count=count,view=curr_view)
  if (count gt 0) then pic(off_limb)=2.*abs(max(pic))
 endif

 if cont then $
 	contour,pic,xp,yp,/data,xstyle=5,ystyle=5,c_linestyle=c_style,$
	 levels=c_levels,c_labels=c_labels,c_thick=c_thick,c_colors=c_color,$
  	 max_value=corange(1),min_value=corange(0),over=(over gt 0),$
  	 /noeras,noclip=0,/follow,xrange=dxrange,yrange=dyrange,$
  	 clip=[dxrange(0),dyrange(0),dxrange(1),dyrange(1)],c_charsize=c_charsize,_extra=extra
 if surf then begin
 	font_sav = !p.font
  	if post then if !p.font eq 0 then !p.font = -1
 	surface, pic, xp, yp, xrange=dxrange, yrange=dyrange, $
 		xtitle=xtitle, ytitle=ytitle, $
 		ax=ax_surf, az=az_surf, zlog=dlog, _extra=extra
 	xyouts, .5, .95, mtitle, align=.5, /norm, _extra=extra
 	!p.font = font_sav
 endif

 if sh_surf then begin
 	background_sav = !p.background
 	font_sav = !p.font
 	if post then begin
 		if !p.background eq 0 then !p.background=white
 		if !p.font eq 0 then !p.font = -1
 	endif
 	shade_surf, pic, xp, yp, xrange=dxrange, yrange=dyrange, $
 		xtitle=xtitle, ytitle=ytitle, $
 		ax=ax_surf, az=az_surf, zlog=dlog, _extra=extra
 	xyouts, .5, .95, mtitle, align=.5, /norm, _extra=extra
 	!p.background = background_sav
 	!p.font = font_sav
 endif


;-- plot image

endif else begin

;-- bail out if trying to image at the sub-pixel level

 diff_x=(max(dxrange)-min(dxrange))
 diff_y=(max(dyrange)-min(dyrange))
 if (zbuff or wbuff) then begin
  if (diff_x lt dx2) or (diff_y lt dy2) then begin
   status = 0
   err_msg='cannot display below half pixel resolution limit'
   message,err_msg,/cont
   return
  endif
 endif

;-- outer device pixels of extracted data

 xb_dev=float(!d.x_size)*(float(!x.s(0))+float(!x.s(1))*xedge)
 yb_dev=float(!d.y_size)*(float(!y.s(0))+float(!y.s(1))*yedge)

;-- dimensions of scaled image

 sx=(abs(max(xb_dev)-min(xb_dev))+1.) > 1.
 sy=(abs(max(yb_dev)-min(yb_dev))+1.) > 1.

;-- device pixels of range window

 xr_dev=!d.x_size*(!x.s(0)+!x.s(1)*dxrange)
 yr_dev=!d.y_size*(!y.s(0)+!y.s(1)*dyrange)

 xscale=diff_x/(max(xr_dev)-min(xr_dev))
 yscale=diff_y/(max(yr_dev)-min(yr_dev))

;-- rebin image for X-windows or Z-buffer (!d.name = 'X' or 'Z')
;-- or plot in Postscript using scalable pixels (!d.name = 'PS')

dprint,'% prange = ', prange
dprint,'% rescale_zoom = ', rescale_zoom
 pic=cscale(pic,top=top,bottom=bottom,max=prange(1),min=prange(0),/no_copy,$
            missing=missing,err=err_msg,log=dlog)

 if err_msg ne '' then begin
  status = 0
  goto,done
 endif

;-- check if composite/interlace is requested

; dprint,'% over, sx, sy:',over, sx,sy

;  dprint,'% xscale, yscale: ',xscale,yscale

 !p.multi(0)=sp

 if zbuff or wbuff then begin
  words=data_chk((map(index)).data,/type) ne 1         ; boolean for tv/tvrd
  true=!d.n_colors gt 256

  pic=congrid(temporary(pic),sx,sy)
  sx=(size(pic))(1)
  sy=(size(pic))(2)

;-- set pixels outside plot window range to black

  xpic=xb_dev(0)+findgen(sx)
  xleft=where(xpic lt xr_dev(0),lcount)
  xright=where(xpic gt xr_dev(1),rcount)

  ypic=yb_dev(0)+findgen(sy)
  ybot=where(ypic lt yr_dev(0),bcount)
  ytop=where(ypic gt yr_dev(1),tcount)

  if lcount gt 0 then pic(xleft(0):xleft(lcount-1),*)=black
  if rcount gt 0 then pic(xright(0):xright(rcount-1),*)=black
  if bcount gt 0 then pic(*,ybot(0):ybot(bcount-1),*)=black
  if tcount gt 0 then pic(*,ytop(0):ytop(tcount-1),*)=black

  if (composite or interlace) and (over gt 0) then begin
   ok=(xb_dev(0) gt 0) and (xb_dev(0) lt !d.x_size) and $
      (yb_dev(0) gt 0) and (yb_dev(0) lt !d.y_size) and $
      (xb_dev(0)+sx lt !d.x_size) and $
      (yb_dev(0)+sy lt !d.y_size)

;-- just create a blank bytarr if underlying image cannot be read

   if ok then begin
    if zbuff then $
     base=tvrd(xb_dev(0),yb_dev(0),sx,sy,channel=words,words=words) else $
      base=tvrd(xb_dev(0),yb_dev(0),sx,sy)
   endif else base=bytarr(sx,sy)

   base=cscale(base,top=last_top,bottom=last_bottom,/no_copy)

;-- combine underlying and overlaying images

   if interlace then begin
    base=swiss_cheese(base,last_bottom,/shift,/no_copy)
    pic=swiss_cheese(pic,bottom,/no_copy)
    pic=temporary(base)+temporary(pic)
   endif else begin                             ; COMPOSITE set
    case comptype of                            ; setable option
       1: begin                                 ; backwardly compatible
	   bfac=([1,2])(take_average)
           pic=temporary(base)/bfac+temporary(pic)/bfac
          end
       3: pic=temporary(base) > temporary(pic)        ; 'largest'  pixel
       4: pic=temporary(base) < temporary(pic)        ; 'smallest' pixel
       else: do_nothing=1
    endcase
   endelse
  endif
 endif

;-- call TV
;   SX and SY used only in postscript mode

 if show3 then begin
  	xarr = xmin + indgen(sx) * (xmax-xmin) / sx
  	yarr = ymin + indgen(sy) * (ymax-ymin) / sy
  	e_contour = {xrange: dxrange, yrange: dyrange, _extra: extra}
 	e_surface = {xrange: dxrange, yrange: dyrange, $
 		ax: ax_surf, az: az_surf, zlog: dlog, _extra: extra}
 endif

if wbuff then begin
  if show3 then begin
	show3, pic, xarr, yarr, sscale=sx/50>1, top=top, bottom=bottom, $
		e_contour=e_contour, e_surface=e_surface
  endif else tv,pic,xb_dev(0),yb_dev(0),channel=channelcolor
 endif

;-- if Postscript, we literally "white-out" pixels outside viewport

 if post then begin
  if show3 then begin
    status = 0
    err_msg = "Can't make PostScript file for show3 plot."
    message, err_msg, /cont
    return
  endif else tv,pic,xb_dev(0),yb_dev(0),xsize=sx,ysize=sy
  plot_map_white,xb_dev,yb_dev,xr_dev,yr_dev
 endif

;-- if Z-buffer, we have to physically avoid pixels outside viewport

 if zbuff then begin
  inx=where( (xpic le !d.x_size) and (xpic ge 0) ,xcount)
  iny=where( (ypic le !d.y_size) and (ypic ge 0) ,ycount)
  if (xcount eq 0) or (ycount eq 0) then begin
   status = 0
   err_msg='image overflows Z-buffer'
   message,err_msg,/cont
   goto,clean_up
  endif
  pic=temporary(pic(inx(0):inx(xcount-1),iny(0):iny(ycount-1)))
  ux=xpic(inx(0))
  uy=ypic(iny(0))
  dprint,'% ux, uy',ux,uy
  if show3 then begin
  	show3, pic, xarr, yarr, sscale=sx/50>1, top=top, bottom=bottom, $
		e_contour=e_contour, e_surface=e_surface
  endif else tv,pic,ux,uy
 endif

 if !version.release gt '5.2' then $
 	if keyword_set(cbar) then plot_map_colorbar, prange, bottom, ncolors, _extra=extra

endelse


done:

;-- plot axes and labels


noaxes=keyword_set(noaxes)
if (over eq 0 and not (surf or sh_surf or show3) ) then begin
 if noaxes then begin
  xstyle=5 & ystyle=5
 endif else begin
  xstyle=1 & ystyle=1
 endelse
 !p.multi(0)=sp
 plot,[xmin,xmax,xmax,xmin,xmin],[ymin,ymin,ymax,ymax,ymin],/data,noclip=0, $
  xstyle=xstyle,ystyle=ystyle,/noeras,/nodata,xrange=dxrange,$
  yrange=dyrange,xtitle=xtitle,ytitle=ytitle,title=mtitle,$
  _extra=extra,$
  clip=[dxrange(0),dyrange(0),dxrange(1),dyrange(1)]
endif

;-- overlay a solar latitude-longitude grid

if (over eq 0) or composite or interlace then begin
 !p.multi(0)=sp
 if have_tag(map,'rtime') then htime=map(index).rtime else htime=mtime
 plot_helio,htime,roll=curr_roll,grid=grid,glabel=glabel,gstyle=gstyle,$
  /over,color=lcolor,font=gfont,soho=curr_view,center=curr_rcenter,limb=limb
endif

;-- plot border edges

if not exist(bthick) then bthick=1
if bord then begin
 if (border eq 2) and cont then begin
  edge=replicate(1.,nx,ny)
  if ((nx gt 2) and (ny gt 2)) then edge(1:nx-2,1:ny-2) = 0
  !p.multi(0)=sp
  contour,edge,xp,yp,xstyle=5,ystyle=5,levels=[0,1],$
   /data,noclip=0,/noeras,/follow,c_linestyle=[0,0],c_thick=bthick,$
   xrange=dxrange,yrange=dyrange,c_color=[lcolor,lcolor],over=(over gt 0),$
   clip=[dxrange(0),dyrange(0),dxrange(1),dyrange(1)],_extra=extra
 endif else begin
  !p.multi(0)=sp
  oplot,xedge,yedge,thick=bthick,color=white
 endelse
endif

;-- save last settings

if (over eq 0) then begin
 if exist(window) then last_window=window
 if exist(prange) then last_drange=prange
 if exist(dxrange) then last_xrange=dxrange
 if exist(dyrange) then last_yrange=dyrange
 if exist(rtime) then last_time=rtime else last_time=get_map_time(map(index))
 if exist(top) then last_top=top
 if exist(bottom) then last_bottom=bottom
 if exist(curr_view) then last_view=curr_view
 if exist(curr_roll) then last_roll=curr_roll
 if exist(curr_rcenter) then last_rcenter=curr_rcenter
endif

!p.multi(0)=(!p.multi(0)-1)
if !p.multi(0) lt 0 then !p.multi(0)=(pnx*pny-1)
last_multi=!p.multi

clean_up:

delvarx,xp,yp,pic,xpic,ypic

return & end
