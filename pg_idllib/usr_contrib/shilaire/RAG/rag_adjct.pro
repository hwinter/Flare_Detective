;---------------------------------------------------------------------------
; Document name: rag_adjct.pro
; Created by:    Andre Csillaghy, June 1991
;
; Last Modified: Thu Dec 10 11:12:06 1998 (csillag@soleil)
;---------------------------------------------------------------------------
;
;+
; PROJECT: 
;       Phoenix II
;
; NAME:
;	RAG_ADJCT
;
; PURPOSE:
;	Interactively adjusts color tables using mouse input.
;
; CATEGORY:
;	Image display.
;
; CALLING SEQUENCE:
;	RAG_ADJCT
;
; INPUTS:
;	No explicit inputs.
;
; OUTPUTS:
;	No explicit outputs.
; COMMON BLOCKS:
;	Colors - color table common block.
; SIDE EFFECTS:
;	Color tables are modified.
; RESTRICTIONS:
;	None.
; PROCEDURE:
;	A new window is created and a graph of the color output value
;	versus pixel value is created.  The user can adjust this function
;	a number of ways using the mouse.
; MODIFICATION HISTORY:
;	DMS, March, 1988, written.
;	DMS, April, 1989, modified cursor handling to use less CPU
;	A.Csillaghy, Inst. of Astronomy, ETH Zurich, August 1991
;       Modified for IDL5/SSW/Ragview (renamed to rag_adjct)
;                in March 1998 -- ACs
;       New position of window, Dec 98 csillag@ssl.berkeley.edu
;-

FUNCTION FindIndex

;
; PURPOSE:
; 	Finds the indexes corresponding to a color table
;	already adjusted
;

COMMON Colors, rOrig, gOrig, bOrig, rCurr, gCurr, bCurr

nbEls = N_Elements(rOrig)
p = BytArr(nbEls)

origArr = LONG(rOrig)*1000000L + LONG(gOrig)*1000 + $
	 LONG(bOrig)
currArr = LONG(rCurr)*1000000L + LONG(gCurr)*1000 + $
	 LONG(bCurr)

i = 0B
WHILE i LT nbEls DO BEGIN
  testForSet = BYTE(currArr EQ origArr(i))
  totalRes = BYTE(TOTAL(testForSet))
  IF totalRes GT 0 THEN p = p + i*testForSet 
  i = i+ 1
  IF i LT nbEls-1 THEN $
    WHILE origArr(i+1) EQ origArr(i) DO i = i+1
ENDWHILE
	
RETURN, p

END

; $Id: adjct.pro,v 1.3 90/05/13 16:33:30 wave Exp $
;
PRO	RAG_ADJCT		;ADJUST COLOR TABLES WITH JOYSTICK

common colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr

oldX = !x & oldY = !y & oldZ = !z & oldP = !p

if !d.table_size eq 0 then begin
	print,'ADJCT - Device has static color tables, can''t adjust'
	return
	endif
old_noclip = !p.noclip

!p.noclip=1		;No clipping
old_window = !d.window	;Previous window

if n_elements(r_orig) le 0 then begin
	r_orig = bytscl(indgen(!d.table_size))
	g_orig = r_orig & b_orig = r_orig
	r_curr = r_orig & g_curr = r_orig & b_curr = r_orig
	endif
nc = N_Elements(r_orig)
nc1 = nc-1

xx = BIndGen(nc)
p = FindIndex()

big = 1.0e6		;Large slope
xsize = 400		;Window width
ysize = 300

window, xs=xsize, ys=ysize, title='Intensity transformation', /free, $
    xpos=10, ypos=20
tvcrs,.5,.5,/norm
tvlct,r_curr, g_curr, b_curr

slope = 1.0
inter = 0.0

choices = ['Ramp','Segments','Draw', 'Help']
instr = [ 'Left = 1st endpoint, Middle = other endpoint, Rt = Done',$
	'Left button for 1st pnt, Middle = following, Rt = Done', $
	'Left button down to draw, up to load colors, Rt = Done', $
	' ']

set_xy,-0.1,nc,-0.1,255 

plot,xx,p,xtit='Pixel Value',ytit='Intensity', XSTYLE = 1, YSTYLE = 1, $
	SUBTITLE = ''
i  = menus(0, choices, instr) ;Output orig choices

;ramp = bytscl(indgen(1,ysize-1))
;for x=xsize-10,xsize-1 do tv,ramp,x,0
	

while 1 do begin	;Main loop

mode = menus(1,choices,instr)	;Get choice
Wait,1
!err = 0		;Reset erre

case mode of
0: begin
	isub = 0
	x = [0.,FLOAT(nc1)]
	y = x
	oldx = x & oldy = y
	Cursor,x1,y1, /WAIT	;data coords, wait
	while !err ne 4 do begin
	  if !err ne 0 then begin
		  if !err eq 1 then isub = 0
		  if !err eq 2 then isub = 1
		  x(isub) = x1 		;& y(isub) = y1

	  if total(abs(oldx-x)+abs(oldy-y)) ne 0 then begin
		  oldx = x & oldy = y
		  x(isub) = x1 		; & y(isub) = y1
		  dx = FLOAT(x(1) - x(0))
		  dy = FLOAT(nc-1)		;  float(y(1) - y(0))
		  if dx ne 0 then slope = dy/dx else slope = big
		  inter = y(1) - slope * x(1)
		  plots,xx,p,col=0
		  p = long(findgen(nc) * slope + inter) > 0 < nc1
	;		Prevent invisible color tables...
		  if (abs(p(0) - p(nc-1)) le nc1/4) then $
			p(nc-1) = nc1 * (p(0) le nc/2)
		plots,xx,p,col=nc1
		r_curr = r_orig(p)
		g_curr = g_orig(p)
		b_curr = b_orig(p)
		tvlct,r_curr,g_curr,b_curr

		endif

	  endif
	  tvrdc,x1,y1,2		;Next point
	endwhile
   end

1: begin		;Segments
	p0 = 0
	x = [0.,0.] & y=x
	n = 0
	while (!err ne 4) do begin
	  tvrdc,x1,y1,1
	  if !err eq 1 then n = 0
	  if (!err and 3) ne 0 then begin
		x1 = x1 < (nc-1) > 0 & y1 = y1 < nc1 > 0
		x(p0) = x1 & y(p0) = y1
	  	dx = x(p0) - x(1-p0)
		dy = y(p0) - y(1-p0)
		n = n + 1
		if (n ge 2) and (dx ne 0) then begin
			slope = dy/dx
			inter = y(p0) - slope * x(p0)
			x0 = x(1-p0) < x(p0)
			pp = (findgen(abs(dx)+1)+x0) *slope +inter
			plots,xx,p,col=0
			p(x0) = pp
	; Prevent invisibility
			if (abs(p(0) - p(nc-1)) le nc1/4) then $
			  p(nc-1) = nc1 * (p(0) le nc/2)
			plots,xx,p,col=nc1
			r_curr = r_orig(p)
			g_curr = g_orig(p)
			b_curr = b_orig(p)
			tvlct,r_curr,g_curr,b_curr
			endif
	  p0 = 1-p0		;Swap endpoints
	  endif
	endwhile
	endcase		

2:	while !err ne 4 do begin
		tvrdc,x0,y0,1	;Get 1st point
		x0 = x0 < (nc-1) > 0 & y0 = y0 < nc1 > 0
		while !err eq 1 do begin
		 tvrdc,x1,y1,0    ;Next pnt
		 x1 = x1 < (nc-1) > 0 & y1 = y1 < nc1 > 0
		 if x1 ne x0 then begin	;Draw
			i0 = fix(x0 < x1)
			i1 = fix((x1 > x0) + 0.9999)
			i00 = i0 - 1 > 0
			i11 = i1 + 1 < nc1
			xxx = xx(i00:i11)
			plots,xxx,p(i00:i11),col=0 ;Erase old segment
			slope = (y1 - y0) / (x1 - x0)
			inter = y1 - slope * x1
			p(i0) = xx(i0:i1) * slope + inter
			plots,xxx,p(i00:i11),col=nc1
			x0 = x1
			y0 = y1
			endif	;Draw
		  endwhile
			; Prevent invisibility
			if (abs(p(0) - p(nc-1)) le nc1/4) then $
		  p(nc-1) = nc1 * (p(0) le nc/2)
		r_curr = r_orig(p)
		g_curr = g_orig(p)
		b_curr = b_orig(p)
		tvlct,r_curr,g_curr,b_curr
	endwhile

3:	begin
	print,'All functions: right button ends function.'
	print,'       Clicking right button twice exits procedure.'
	print,'Ramp - Left button controls one endpoint of ramp (normally the left).'
	print,'       Middle controls other endpoint.  Hint: Move the cursor along'
	print,'        an axis border with either button depressed.'
	print,'Segments - Left button begins a new segment.'
	print,'       Middle button marks a vertex and continues a segment.'
	print,'Draw - Depressing the left button and moving it marks a series of points.'
	print,'       Releasing it updates the color tables with the curve.'
	endcase

-1:	begin		;Quit entry
	wdelete		;Done with window
	if old_window ge 0 then begin
		wset,old_window	;Restore old window
		tvcrs,!d.x_vsize/2, !d.y_vsize/2,/dev ;Put cursor in middle
;;;		tvcrs,0		;and hide it
		endif
	!p.noclip = old_noclip
	return
	end
else:	begin
	end
endcase
	;Clean up instructions

r_curr(nc1) = 255 & g_curr(nc1) = 255 & b_curr(nc1) = 255
r_curr(0) = 0 & g_curr(0) = 0 & b_curr(0) = 0

tvlct, r_curr, g_curr, b_curr

endwhile

!p = oldP & !x = oldX & !y = oldY & !z = oldZ

end
