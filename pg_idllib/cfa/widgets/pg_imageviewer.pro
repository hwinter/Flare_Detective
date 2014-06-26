;+
; NAME:
;
;  pg_imageviewer
;
; PURPOSE:
;
;  widgets for looking at a sequence of images
;
; CATEGORY:
;
; widget utils
;
; CALLING SEQUENCE:
;
; pg_imageviewer,imagelist
;
; INPUTS:
;
; imagelist: an array of strings of valid image file names
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
; AUTHOR:
; 
; Paolo Grigis, CfA
; pgrigis@cfa.harvard.edu
;
;
; MODIFICATION HISTORY:
;
; 6-SEP-2007 written
; 
;-

;.comp pg_imageviewer

;
;plot the map on the screen, with the selected attributes
;
PRO pg_imageviewer_plotim,imdata,drawwidget


IF imdata.true THEN thisim=imdata.imcube[*,*,*,imdata.thistime] ELSE thisim=imdata.imcube[*,*,imdata.thistime]

; IF   mapstr.totim EQ 1 $
; THEN maptr=mapstr.totmap $
; ELSE $
;      IF   (mapnumber GE 0) OR (mapnumber LT n_elements(mapstr.imseq)) $
;      THEN maptr=mapstr.imseq[mapnumber] $
;      ELSE RETURN

widget_control,drawwidget,get_value=winmap

wset,winmap

tv,thisim,true=imdata.true


END



;
;Widget event handler
;
PRO pg_imageviewer_event,ev

widget_control,ev.handler,get_uvalue=imdata

CASE ev.ID OF


    widget_info(ev.top,find_by_uname='selecttime') : BEGIN


       imdata.thistime=ev.index


       widget_control,ev.handler,set_uvalue=imdata

       drawwidget=widget_info(ev.top,find_by_uname='drawwin')
       pg_imageviewer_plotim,imdata,drawwidget


    END

 
  
 
ENDCASE

END


;
;Main procedure
;
PRO pg_imageviewer,imlist,true=true

IF NOT exist(true) THEN true=0

n=n_elements(imlist)

print,'Loading Images...'

tempim=read_image(imlist[0],r,g,b)

imsize=size(tempim,/dimension)

IF NOT keyword_set(true) THEN BEGIN 
   imcube=lonarr(imsize[0],imsize[1],n) 
 
  FOR i=0L,n-1 DO BEGIN 

      imcube[*,*,i]=read_image(imlist[i],r,g,b)
   
   ENDFOR

   tvlct,r,g,b


ENDIF ELSE BEGIN 
   
   imcube=bytarr(imsize[0],imsize[1],imsize[2],n)

   FOR i=0L,n-1 DO BEGIN 

      imcube[*,*,*,i]=read_image(imlist[i])
   
   ENDFOR

ENDELSE


IF true EQ 0 THEN BEGIN 
   imdata={xsize:imsize[0], $
           ysize:imsize[1], $
           nim:n, $
           thistime:0, $
           imcube:imcube, $
           true:true}
ENDIF ELSE BEGIN 
   imdata={xsize:imsize[1], $
           ysize:imsize[2], $
           nim:n, $
           thistime:0, $
           imcube:imcube, $
           true:true}
ENDELSE



;
;end variable init

;widget hierarchy creation
;
    base=widget_base(title='Image manipulator',/row)
    root=widget_base(base,/row,uvalue=mapstr,uname='root')

    menu1=widget_base(root,group_leader=root,/column,/frame)
    drawsurf1=widget_base(root,group_leader=root,/row)
    buttonm1=widget_base(menu1,group_leader=menu1,/row,/frame)
;end widget hierarchy creation


;selection of current image
;
    sellab=widget_base(buttonm1,group_leader=buttonm1,/column)
    images=strtrim(string(indgen(imdata.nim)),2)

;end selection of current image

;
    selectframe=widget_base(menu1,group_leader=menu1,/row,/frame)

    tframval=strarr(n)

    FOR i=0,n-1 DO $
       tframval[i]=strtrim(i,2)


    sellab1=widget_base(selectframe,group_leader=menu1,/column)
    label1=widget_label(sellab1,value='Time Interval')
    select1=widget_list(sellab1,value=tframval,ysize=8,uname='selecttime')
    widget_control,select1,set_list_select=imdata.thistime

  


;draw widget
;
    draw=widget_draw(drawsurf1,xsize=imdata.xsize,ysize=imdata.ysize,uname='drawwin' $
                    ,/scroll,x_scroll_size=imdata.xsize,y_scroll_size=imdata.ysize)



widget_control,root,set_uvalue=imdata

widget_control,base,/realize


pg_imageviewer_plotim,imdata,draw


xmanager,'pg_imageviewer',root,/no_block

END












