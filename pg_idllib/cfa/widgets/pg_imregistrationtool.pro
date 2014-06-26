;+
; NAME:
;
; pg_imregistrationtool
;
; PURPOSE:
;
;
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
;
;
; INPUTS:
;
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
; 10-SEP-2008 written PG
;
;-

PRO pg_imregistrationtool_event,ev

;stop

x1=widget_info(ev.top,find_by_uname='drawwin1')
x2=widget_info(ev.top,find_by_uname='drawwin2')
x3=widget_info(ev.top,find_by_uname='drawwin3')
y=widget_info(ev.top,find_by_uname='root')

widget_control,y,get_uvalue=wdata
;print,wdata

widget_control,x1,get_value=winmap
wset,winmap
tvscl,wdata.im1

widget_control,x2,get_value=winmap
wset,winmap
tvscl,wdata.im2

;IF have_tag(ec,''
;print,'KEY: '+strtrim(ev.type,2)
;print,'CH:  '+string(ev.ch)
;print,'MOD: '+string(ev.modifiers)

IF ev.modifiers EQ 0 THEN dx=1 ELSE dx=10

;IF ev.type EQ 6 THEN wait,0.05 
IF ev.key EQ 5 THEN wdata.shiftx=wdata.shiftx-dx
IF ev.key EQ 6 THEN wdata.shiftx=wdata.shiftx+dx
IF ev.key EQ 7 THEN wdata.shifty=wdata.shifty+dx
IF ev.key EQ 8 THEN wdata.shifty=wdata.shifty-dx

rootwidget=widget_info(ev.top,find_by_uname='root')
widget_control,rootwidget,set_uvalue=wdata

widget_control,x3,get_value=winmap
wset,winmap
tv,[[[wdata.im1]],[[shift(wdata.im2,wdata.shiftx,wdata.shifty)]],[[wdata.im1*0]]],true=3

IF ev.key NE 0 THEN BEGIN 
   textwidget=widget_info(ev.top,find_by_uname='statusw')
   widget_control,textwidget,set_value='Shift: '+strtrim(wdata.shiftx,2)+', '+strtrim(wdata.shifty,2)
ENDIF


;stop

END

PRO pg_imregistrationtool,im1,im2

s1=size(im1)
s2=size(im2)

newx=2d^ceil(alog(max([s1[1],s2[1]]))/alog(2d))
newy=2d^ceil(alog(max([s1[2],s2[2]]))/alog(2d))

iml1=fltarr(newx,newy)
iml1[0,0]=im1

iml2=fltarr(newx,newy)
iml2[0,0]=im2


;; window,1,xsize=s1[1],ysize=s1[2];,/pixmap
;; wset,1
;; tvscl,im1

;; window,2,xsize=s2[1],ysize=s2[2];,/pixmap
;; wset,2
;; tvscl,im2

;; window,3,xsize=newx,ysize=newy;,/pixmap
;; wset,3
;; tvscl,iml1+iml2


;have all ready, can start widgets...

;;stop

wdata={im1:bytscl(iml1),im2:bytscl(iml2),shiftx:0,shifty:0}

;widget hierarchy creation
;
    base=widget_base(title='WIFIR',/row)
    root=widget_base(base,/row,uvalue=wdata,uname='root')
    
    menu1=widget_base(root,group_leader=root,/column,/frame)
    text=widget_text(menu1,group_leader=root,value='Shift: 0, 0',uname='statusw')


    drawsurf=widget_base(root,group_leader=root,/column)
    drawsurf1=widget_base(drawsurf,group_leader=root,/row)
    drawsurf2=widget_base(drawsurf,group_leader=root,/row)
    ;buttonm1=widget_base(menu1,group_leader=menu1,/row,/frame)

    draw1=widget_draw(drawsurf1,xsize=600,ysize=600,uname='drawwin1')
    draw2=widget_draw(drawsurf1,xsize=600,ysize=600,uname='drawwin2')
    draw3=widget_draw(drawsurf2,xsize=600,ysize=600,uname='drawwin3')
;end widget hierarchy creation


widget_control,base,/realize
widget_control,draw1,/draw_button_event,/draw_keyboard_events
xmanager,'pg_imregistrationtool',root,/no_block


END


