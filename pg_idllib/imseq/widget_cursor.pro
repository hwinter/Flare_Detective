;.comp ~/rapp_idl/imseq/widget_cursor.pro
;
;widget_cursor,x=x,y=y
;

PRO widget_cursor_plotbox,newcoor,oldcoor,sides=sides,noerase=noerase $
                         ,nodraw=nodraw;,imagexsize=imagexsize,imageysize

color=255B
lines=ptrarr(4)

xoldmin=min(oldcoor[0:1])
xmin=min(newcoor[0:1])
xoldmax=max(oldcoor[0:1])
xmax=max(newcoor[0:1])
yoldmin=min(oldcoor[2:3])
ymin=min(newcoor[2:3])
yoldmax=max(oldcoor[2:3])
ymax=max(newcoor[2:3])

IF NOT keyword_set(noerase) THEN BEGIN
    tv,*sides[0],xoldmin,yoldmin,/true
    tv,*sides[1],xoldmax,yoldmin,/true
    tv,*sides[2],xoldmin,yoldmin,/true
    tv,*sides[3],xoldmin,yoldmax ,/true   
ENDIF
IF NOT keyword_set(nodraw) THEN BEGIN
    sides[0]=ptr_new(tvrd(xmin,ymin,xmax-xmin+1,1,/true))
    sides[1]=ptr_new(tvrd(xmax,ymin,1,ymax-ymin+1,/true))
    sides[2]=ptr_new(tvrd(xmin,ymin,1,ymax-ymin+1,/true))
    sides[3]=ptr_new(tvrd(xmin,ymax,xmax-xmin+1,1,/true))

    ; sides[0]=ptr_new(*imageptr[xmin:xmax,ymin])
    ; sides[1]=ptr_new(tvrd(xmax,yoldmin,1,ymax-ymin+1))
    ; sides[2]=ptr_new(tvrd(xmin,yoldmin,1,ymax-ymin+1))
    ; sides[3]=ptr_new(tvrd(xmin,yoldmax,xmax-xmin+1,1))


    lines[0]=ptr_new(reform(make_array(3,xmax-xmin+1,1,/byte,value=color) $
                           ,3,xmax-xmin+1,1))
    lines[1]=ptr_new(reform(make_array(3,1,ymax-ymin+1,/byte,value=color) $
                           ,3,1,ymax-ymin+1))
    lines[2]=ptr_new(reform(make_array(3,1,ymax-ymin+1,/byte,value=color) $
                           ,3,1,ymax-ymin+1))
    lines[3]=ptr_new(reform(make_array(3,xmax-xmin+1,1,/byte,value=color) $
                           ,3,xmax-xmin+1,1))


    tv,*lines[0],xmin,ymin,/true
    tv,*lines[1],xmax,ymin,/true
    tv,*lines[2],xmin,ymin,/true
    tv,*lines[3],xmin,ymax,/true
ENDIF

END


PRO widget_cursor_event,ev

widget_control,ev.id,get_uvalue=status

maxx=status.maxx
maxy=status.maxy


CASE ev.ID OF 
    
    widget_info(ev.top,find_by_uname='drawwin') : BEGIN

    IF ev.press EQ 1 THEN BEGIN
        
        status.dragging=1
        status.first=1        
        status.boxcoor=[ev.x>0 <maxx,ev.x>0 <maxx,ev.y>0 <maxx,ev.y>0 <maxx]

        IF status.last THEN BEGIN
 
            status.last=0
            newsides=status.sides
            widget_cursor_plotbox,status.boxcoor,status.oldcoor,/nodraw $
                                 ,sides=newsides
        ENDIF

        status.oldcoor=[ev.x>0 <maxx,ev.x>0 <maxx,ev.y>0 <maxx,ev.y>0 <maxx]

    ENDIF

    IF ev.release EQ 1 THEN BEGIN
 
        status.dragging=0
        status.last=1
 
    ENDIF
    

    IF status.dragging EQ 1 THEN BEGIN
        
        status.boxcoor=[status.oldcoor[0],ev.x>0 <maxx, $
                        status.oldcoor[2],ev.y>0 <maxy]
        newsides=status.sides

        IF status.first THEN BEGIN
           
            widget_cursor_plotbox,status.boxcoor,status.oldcoor,/noerase $
                                 ,sides=newsides;,imageptr=status.image 
            status.first=0

        ENDIF $
        ELSE BEGIN
            widget_cursor_plotbox,status.boxcoor,status.oldcoor $
                                 ,sides=newsides;,imageptr=status.image 
        ENDELSE

        status.sides=newsides
        status.oldcoor=status.boxcoor
        widget_control,ev.id,set_uvalue=status
    ENDIF

    
    IF ev.release EQ 4 THEN BEGIN
        status.outcoor=status.boxcoor
        widget_control,ev.id,set_uvalue=status
        ;widget_control,ev.id,/destroy

    ENDIF

    widget_control,ev.id,set_uvalue=status
   
    END

    ELSE : RETURN

ENDCASE

END 

PRO widget_cursor,image=image

status={dragging:0,first:0,last:0,oldcoor:[0,0,0,0],boxcoor:[0,0,0,0] $
       ,sides:ptrarr(4),maxx:0,maxy:0,outcoor:[0,0,0,0]}

base=widget_base(title='Widget for getting cursor boxes',/row)
root=widget_base(base)
draw=widget_draw(root,xsize=512,ysize=512,uname='drawwin');,uvalue=status)

widget_control,base,/realize
widget_control,draw,/draw_button_events
widget_control,draw,/draw_motion_events

geom=widget_info(draw,/geometry)
status.maxx=geom.draw_xsize-1
status.maxy=geom.draw_ysize-1
widget_control,draw,set_uvalue=status

;winnum=widget_info(,find_by_uname='drawwin')
widget_control,draw,get_value=winnum2
wset,winnum2
IF exist(image) THEN tv,image

xmanager,'widget_cursor',root,/no_block

print,2+2

END
