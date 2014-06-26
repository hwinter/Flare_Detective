;+
; NAME:
;
; pg_imseq_roi
;
; PURPOSE:
;
; widget tool to view and manipulate ROIs in image sequences
;
; CATEGORY:
;
; imseq utils
;
; CALLING SEQUENCE:
;
; pg_imseq_roi,imseq
;
; INPUTS:
;
; imseq: a nx by ny by nim image cube (float or double)
; time: (optional) double time
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
; AUTHOR:
;
; Paolo Grigis, CfA
; pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 9-JAN-2008 written PG (based on pg_xrtimviewer)
;
;-

;.comp pg_xrtimviewer.pro


;
;plot the map on the screen, with the selected attributes
;
PRO pg_imseq_roi_plotim,widgpar,drawwidget,showroi=showroi

imnumber=widgpar.selim

widget_control,drawwidget,get_value=window
wset,window

im=(*widgpar.imseq)[*,*,widgpar.selim>0<widgpar.nimages]

IF NOT keyword_set(showroi) THEN BEGIN 

   tvscl,rebin(im,768,768)
  
ENDIF ELSE BEGIN 


   IF ptr_valid(widgpar.ind) THEN BEGIN 

      im=byte((im-min(im))/(max(im)-min(im))*254)
      im[*widgpar.ind]=255B

   ;im[*widgpar.ind]=0;max(im)
   ;im=bytscl(im)
   
      tvlct,r,g,b,/get
      r2=r & g2=g & b2=b
      r2[255]=0
      g2[255]=255
      b2[255]=0
      tvlct,r2,g2,b2

      tvscl,rebin(im,768,768)

      tvlct,r,g,b

   ENDIF

   
ENDELSE

END



;
;plot the lightcurve on the screen, with the selected attributes
;
PRO pg_imseq_roi_plotlc,widgpar,drawwidget,overplotroi=overplotroi

  imnumber=widgpar.selim

  widget_control,drawwidget,get_value=window
  wset,window

  t=widgpar.time
  lc=total(total(*widgpar.imseq,2),1)
 
  dlc=max(lc)-min(lc)
;  yrange=[min(lc)-0.05*dlc,max(lc)+0.05*dlc]
  yrange=[0.,max(lc)+0.05*dlc]


  ;stop
  IF keyword_set(overplotroi) THEN BEGIN 
     IF ptr_valid(widgpar.roilc) THEN roilc=*widgpar.roilc ELSE roilc=lc*!values.f_nan
  ENDIF


  IF widgpar.fillgaps NE 0 THEN BEGIN 
     pg_fillnaningaps,t,lc,yout=oklc,xout=oktime,gaplength=widgpar.gaplength,/twonan
     utplot,oktime-oktime[0],oklc,oktime[0],yrange=yrange,/ystyle,/xstyle

     IF keyword_set(overplotroi) THEN BEGIN 
        pg_fillnaningaps,t,roilc,yout=roioklc,xout=oktime,gaplength=widgpar.gaplength,/twonan
        outplot,oktime-oktime[0],roioklc,oktime[0],color=128
     ENDIF


  ENDIF ELSE BEGIN 
     utplot,t-t[0],lc,t[0],yrange=yrange,/ystyle,/xstyle     

     IF keyword_set(overplotroi) THEN BEGIN 
        outplot,oktime-oktime[0],roilc,oktime[0],color=128
     ENDIF

  ENDELSE

     

END



;
;This procedure draws and/or erase a rectangular frame on the current
;graphic window
;
PRO pg_imseq_roi_plotbox,newcoor,oldcoor,sides=sides,noerase=noerase $
                       ,nodraw=nodraw


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


;
;Returns the text to display as information in the text widget
;
FUNCTION pg_imseq_roi_outtext,widgpar


outtext=['Image '+string(widgpar.selim), $
         'Time '+anytim(widgpar.time[widgpar.selim],/vms)]


;here add some catalog info

RETURN,outtext

END

;
;Widget event handler
;
PRO pg_imseq_roi_event,ev

widget_control,ev.handler,get_uvalue=widgpar

CASE ev.ID OF 
    

   widget_info(ev.top,find_by_uname='selectim') : BEGIN
        
      widgpar.selim=ev.index
      widget_control,ev.handler,set_uvalue=widgpar

      drawwidget=widget_info(ev.top,find_by_uname='drawim')
      pg_imseq_roi_plotim,widgpar,drawwidget
      drawwidget=widget_info(ev.top,find_by_uname='drawroi')
      pg_imseq_roi_plotim,widgpar,drawwidget,/show

      textwidget=widget_info(ev.top,find_by_uname='frameinfo') 
      widget_control,textwidget,set_value=pg_imseq_roi_outtext(widgpar)
       

    END

    widget_info(ev.top,find_by_uname='roithresholdsel') : BEGIN

       widgpar.roithreshold=ev.value
       widget_control,ev.handler,set_uvalue=widgpar
        
;       drawwidget=widget_info(ev.top,find_by_uname='drawim')
;       pg_imseq_roi_plotim,widgpar,drawwidget
       
;       textwidget=widget_info(ev.top,find_by_uname='frameinfo') 
;       widget_control,textwidget,set_value=pg_imseq_roi_outtext(widgpar)
       
    END





    widget_info(ev.top,find_by_uname='commands') : BEGIN

        drawwidget=widget_info(ev.top,find_by_uname='drawim')
        drawroi=widget_info(ev.top,find_by_uname='drawroi')
        drawtimevwidget=widget_info(ev.top,find_by_uname='timevwin')
         
        CASE ev.value OF


            0 : BEGIN ;Draw selected Image


                pg_imseq_roi_plotim,widgpar,drawwidget

                textwidget=widget_info(ev.top,find_by_uname='frameinfo') 
                widget_control,textwidget,set_value=pg_imseq_roi_outtext(widgpar)
 
;                IF widgpar.plottimev THEN pg_imseq_roi_plottimev,widgpar,drawtimevwidget
 

           END

      
            1 : BEGIN ; Select Threshold

               thisim=(*widgpar.imseq)[*,*,widgpar.selim>0<widgpar.nimages]

               mask=thisim GT widgpar.roithreshold
               ind=where(mask GT 0,count)

               IF count GT 0 THEN BEGIN 

                  widgpar.mask=mask
                  widgpar.ind=ptr_new(ind)

                  roilc=fltarr(widgpar.nimages)
                  FOR i=0,widgpar.nimages-1 DO BEGIN 
                     thisim=(*widgpar.imseq)[*,*,i]
                     roilc[i]=total(thisim[ind])
                  ENDFOR
                  widgpar.roilc=ptr_new(roilc)
               
               ENDIF


               print,widgpar.roithreshold

            END

            2 : BEGIN ;Draw ROI


               pg_imseq_roi_plotim,widgpar,drawroi,/showroi

               ;textwidget=widget_info(ev.top,find_by_uname='frameinfo') 
               ;widget_control,textwidget,set_value=pg_imseq_roi_outtext(widgpar)


 
               
            END

            3 : BEGIN ; 'fill gaps'

               widgpar.fillgaps=1-widgpar.fillgaps

               drawwidget=widget_info(ev.top,find_by_uname='drawlc')
               pg_imseq_roi_plotlc,widgpar,drawwidget


            END


            4 : BEGIN ; 'Lightcurve'

                ;baselc=widget_base(title='Lightcurve',/row,group_leader=ev.top)

                ;drawlc=widget_draw(baselc,xsize=700,ysize=500 $
                ;                  ,uname='drawlc')
                
                ;widget_control,baselc,/hourglass

                ;imseq_ltc,widgpar.imseq,lev=0,tim=tim,lc=lc,box=widgpar.selcoor $
                ;         ,err=err


                ;IF err EQ 0 THEN BEGIN 

                     ;widget_control,baselc,/realize
               ;widget_control,drawlc,get_value=winlc
               ;      wset,winlc
               ;      utplot,tim-tim[0],lc,tim[0]

                ;     outplot,tim[widgpar.minfr]*[1,1]-tim[0],!Y.crange,linestyle=2
                ;     outplot,tim[widgpar.maxfr]*[1,1]-tim[0],!Y.crange,linestyle=2


               drawwidget=widget_info(ev.top,find_by_uname='drawlc')
               pg_imseq_roi_plotlc,widgpar,drawwidget
               pg_imseq_roi_plotlc,widgpar,drawwidget,/overplotroi

 
                ;ENDIF $
                ;ELSE print,['An error occurred during the lightcurve '+ $
                ;           'computation.','Please select another region.']
                   
                
            END

            5 : BEGIN ; 'Color table'

                xloadct

            END

            6 : BEGIN ;'Zoom'

                widgpar.xrange=widgpar.selcoor[0:1]
                widgpar.yrange=widgpar.selcoor[2:3]
                pg_imseq_roi_plotim,widgpar,drawwidget           
                
            END

            7 : BEGIN ;'Unzoom'

                map=*widgpar.imseq[widgpar.selim]

                coor=[map.xc-map.dx*(size(map.data))[1]/2 $
                     ,map.xc+map.dx*(size(map.data))[1]/2 $
                     ,map.yc-map.dy*(size(map.data))[2]/2 $
                     ,map.yc+map.dy*(size(map.data))[2]/2 ]

                widgpar.xrange=coor[0:1]
                widgpar.yrange=coor[2:3]
          
                pg_imseq_roi_plotim,widgpar,drawwidget

             END

             8 : BEGIN ; 'GROW ROI'

               ;grow roi with dilate
                

                print,'growing...'
                dilmat=bytarr(3,3)+1B
                
                widgpar.mask=dilate(widgpar.mask,dilmat)
                widgpar.ind=ptr_new(where(widgpar.mask EQ 1))
                pg_imseq_roi_plotim,widgpar,drawroi,/showroi
                widget_control,ev.handler,set_uvalue=widgpar

                roilc=fltarr(widgpar.nimages)
                FOR i=0,widgpar.nimages-1 DO BEGIN 
                   thisim=(*widgpar.imseq)[*,*,i]
                   roilc[i]=total(thisim[*widgpar.ind])
                ENDFOR
                widgpar.roilc=ptr_new(roilc)
 

             END


            9 : BEGIN ; 'open ROI'

                print,'opening ROI'
                

                print,'growing...'
                dilmat=bytarr(3,3)+1B
                
                widgpar.mask=dilate(erode(widgpar.mask,dilmat),dilmat)
                widgpar.ind=ptr_new(where(widgpar.mask EQ 1))
                pg_imseq_roi_plotim,widgpar,drawroi,/showroi
                widget_control,ev.handler,set_uvalue=widgpar



             END

            10 : BEGIN ; 'closing ROI'

                ;grow roi with dilate
                print,'closing ROI'
                

                print,'growing...'
                dilmat=bytarr(3,3)+1B
                
                widgpar.mask=erode(dilate(widgpar.mask,dilmat),dilmat)
                widgpar.ind=ptr_new(where(widgpar.mask EQ 1))
                pg_imseq_roi_plotim,widgpar,drawroi,/showroi
                widget_control,ev.handler,set_uvalue=widgpar



             END


             11 : BEGIN ; 'Histogram'


                widgpar.histo=1-widgpar.histo
                widget_control,ev.handler,set_uvalue=widgpar
                
                pg_imseq_roi_plotim,widgpar,drawwidget


             END

   
             12 : BEGIN         ; mouse coordinates


;                widget_control,ev.handler,set_uvalue=widgpar
;               
;                pg_imseq_roi_plotim,widgpar,drawwidget

                widget_control,drawwidget,get_uvalue=status
                status.mousecoor=1
                widget_control,drawwidget,set_uvalue=status

                widget_control,drawwidget,/draw_button_events



             END


             13 : BEGIN ; 'Done'

                widget_control,ev.top,/destroy
            
             END

            ELSE : RETURN

        ENDCASE


        IF   ev.value NE 11 $
        THEN widget_control,ev.handler,set_uvalue=widgpar

    END
 
    widget_info(ev.top,find_by_uname='drawim') : BEGIN
;
;   this kind of events will only happen if the draw widget
;   has been made sensitive to mouse events, i.e. the select region
;   button (or zoom) has been pressed
;

        widget_control,ev.id,get_uvalue=status

        IF status.mousecoor THEN BEGIN 

           IF ev.press EQ 1 THEN BEGIN;left button click
              
              x=(convert_coord(ev.x,ev.y,/to_data,/device))[0]
              y=(convert_coord(ev.x,ev.y,/to_data,/device))[1]
              

              print,'('+strtrim(round(x),2)+','+strtrim(round(y),2)+')'

           ENDIF

           IF ev.release EQ 4 THEN BEGIN 
              
              status.mousecoor=0
              widget_control,ev.id,set_uvalue=status

           ENDIF

        ENDIF ELSE BEGIN 

        maxx=status.maxx
        maxy=status.maxy

        drawwidget=widget_info(ev.top,find_by_uname='drawim')
        widget_control,drawwidget,get_value=plotwin
        wset,plotwin
       
        IF ev.press EQ 1 THEN BEGIN
        
            status.dragging=1
            status.first=1        
            status.boxcoor=[ev.x >0 <maxx, ev.x >0 <maxx, ev.y >0 <maxx $
                           ,ev.y >0 <maxx]

            IF status.last THEN BEGIN
 
                status.last=0
                newsides=status.sides
                pg_imseq_roi_plotbox,status.boxcoor,status.oldcoor,/nodraw $
                                     ,sides=newsides
            ENDIF

            status.oldcoor=[ev.x >0 <maxx, ev.x >0 <maxx, ev.y >0 <maxx $
                           ,ev.y >0 <maxx]

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
           
                pg_imseq_roi_plotbox,status.boxcoor,status.oldcoor,/noerase $
                                   ,sides=newsides
                status.first=0

            ENDIF $
            ELSE BEGIN

                pg_imseq_roi_plotbox,status.boxcoor,status.oldcoor $
                                   ,sides=newsides
            ENDELSE

            status.sides=newsides
            status.oldcoor=status.boxcoor
            widget_control,ev.id,set_uvalue=status

        ENDIF

           
        IF ev.release EQ 4 THEN BEGIN

            ;right mouse click, finalize the selection

            widget_control,ev.id,get_value=winmap
            wset,winmap

            ;coord transformation from pixel to device
            newcoor=status.boxcoor

            xmin=min(newcoor[0:1])
            xmax=max(newcoor[0:1])
            ymin=min(newcoor[2:3])
            ymax=max(newcoor[2:3])

            x1=(convert_coord(xmin,ymin,/to_data,/device))[0]
            y1=(convert_coord(xmin,ymin,/to_data,/device))[1]
            x2=(convert_coord(xmax,ymax,/to_data,/device))[0]
            y2=(convert_coord(xmax,ymax,/to_data,/device))[1]

            status.outcoor=[x1,x2,y1,y2]
            
            widget_control,ev.id,set_uvalue=status

            ;make the draw widget insensitive to further mouse activity
            widget_control,ev.id,draw_button_events=0
            widget_control,ev.id,draw_motion_events=0
            

            widget_control,ev.handler,get_uvalue=widgpar
            widgpar.selcoor=status.outcoor
            widget_control,ev.handler,set_uvalue=widgpar

            textwindow=widget_info(ev.top,find_by_uname='frameinfo')
            widget_control,textwindow,set_value=pg_imseq_roi_outtext(widgpar)
            
            pg_imseq_roi_plotim,widgpar,ev.id                          

        ENDIF

        ENDELSE


        widget_control,ev.id,set_uvalue=status
   
    END

    ELSE : print,'Ciao'

ENDCASE

END 


;
;Main procedure
;
PRO pg_imseq_roi,imseq,time=time,fillgaps=fillgaps

;check whether one image or an image sequence is given as input
s=size(imseq)

IF s[0] EQ 3 THEN BEGIN ;3-dim imcube... OK
   nx=s[1]
   ny=s[2]
   nimages=s[3]
   imptr=ptr_new(imseq)
   IF n_elements(time) GT nimages THEN mytime=time[0:nimages-1] ELSE $
      IF n_elements(time) LT nimages THEN mytime=findgen(nimages) ELSE $
         mytime=time
ENDIF ELSE BEGIN 
   IF s[0] EQ 2 THEN BEGIN ;only one image, duplicate it
      myimseq=[[[imseq],[imseq]]]
      nimages=2
      imptr=ptr_new(myimseq)
      mytime=[0,1]
   ENDIF
ENDELSE

;stop

;have images ok

widgpar={imseq:imptr $
        ,time:mytime $
        ,nimages:nimages $
        ,selim:0 $
        ,roi:ptr_new() $
        ,roilc:ptr_new() $
        ,roicolor:1 $
        ,nx:nx $
        ,ny:ny $
        ,fillgaps:keyword_set(fillgaps) $
        ,gaplength:60 $
        ,roithreshold:500. $
        ,mask:imseq[*,*,0] $
        ,ind:ptr_new()}
;        ,selcoor:[0.,0.,0.,0.] $
;        ,xrange:[0.,0.] $
;        ,yrange:[0.,0.] $
;        ,showregion:1 $
;        ,cat:cat $
;        ,colscale:1 $
;        ,gamma:1. $
;        ,mincol:30 $
;        ,maxcol:4192 $
;        ,tiecolor:1 $
;        ,histo:0}


;; map=*ptr[0]
;; widgpar.selcoor=[map.xc-map.dx*(size(map.data))[1]/2 $
;;                ,map.xc+map.dx*(size(map.data))[1]/2 $
;;                ,map.yc-map.dy*(size(map.data))[2]/2 $
;;                ,map.yc+map.dy*(size(map.data))[2]/2 ]

;; widgpar.xrange=widgpar.selcoor[0:1]
;; widgpar.yrange=widgpar.selcoor[2:3]

;
;end variable init

;widget hierarchy creation
;
    base=widget_base(title='Image sequence ROI manipulator',/row)
    root=widget_base(base,/row,uvalue=widgpar,uname='root')
    
    menu1=widget_base(root,group_leader=root,/column,/frame)
    drawsurf1=widget_base(root,group_leader=root,/column)
    drawsurf2=widget_base(drawsurf1,group_leader=drawsurf1,/row)
    drawsurf3=widget_base(drawsurf1,group_leader=drawsurf1,/row)
    buttonm1=widget_base(menu1,group_leader=menu1,/row,/frame)
;end widget hierarchy creation

;buttons
;
    values=['Draw selected Image' $
            ,' Select ROI ',' Draw ROI ',' fill gaps ','Lightcurve' $
            ,'Color table','Zoom','Unzoom',' GROW ROI','OPEN ROI','CLOSE ROI','Toggle Histogram' $
            ,'Mouse Coordinates','Done']
    uname='commands'
    bgroup=cw_bgroup(buttonm1,values,/column,uname=uname) ;,/frame)
;end buttons

;selection of current image
;
    sellab=widget_base(buttonm1,group_leader=buttonm1,/column)
    images=strtrim(string(indgen(nimages)),2)

    labelim=widget_label(sellab,value='Selected Frame')
    selim=widget_list(sellab,value=images,ysize=10,uname='selectim')

    
;end selection of current image

;ROI selection threshold
;
    roi_threshold=cw_field(sellab,value=widgpar.roithreshold,uname='roithresholdsel',/floating,/return_events $
                          ,title='ROI threshold')


;droplist for color state etc.
;    coldlist = widget_droplist(sellab,value=['Linear','Logarithmic','Quadratic'],title='color stuff',uname='selcolor')
;
;    mincol=cw_field(sellab,value=widgpar.mincol,uname='mincolsel',/floating,/return_events $
;                   ,title='Min color')
;    maxcol=cw_field(sellab,value=widgpar.maxcol,uname='maxcolsel',/floating,/return_events $
;                   ,title='Max color')


;text widget
;
    text=widget_text(menu1,value=pg_imseq_roi_outtext(widgpar),ysize=12 $
                    ,uname='frameinfo')
;end text widget

;draw widget
;
    drawim=widget_draw(drawsurf2,xsize=768,ysize=768,uname='drawim')
    drawroi=widget_draw(drawsurf2,xsize=768,ysize=768,uname='drawroi')
    drawlc=widget_draw(drawsurf3,xsize=1024,ysize=512,uname='drawlc')

;    IF plottimev THEN $
;    draw2=widget_draw(drawsurf1,xsize=725,ysize=512,uname='timevwin')
;end draw widget


;    status={dragging:0,first:0,last:0,oldcoor:[0.,0.,0.,0.] $
;           ,boxcoor:[0.,0.,0.,0.],sides:ptrarr(4),maxx:0,maxy:0 $
;           ,outcoor:[0.,0.,0.,0.],mousecoor:0}


;    widget_control,draw,set_uvalue=status



widget_control,root,set_uvalue=widgpar
  
widget_control,base,/realize

;widget_control,mincol,sensitive=1-widgpar.tiecolor
;widget_control,maxcol,sensitive=1-widgpar.tiecolor


pg_imseq_roi_plotim,widgpar,drawim
;pg_imseq_roi_plotim,widgpar,drawroi
;pg_imseq_roi_plottimev,widgpar,draw2

xmanager,'pg_imseq_roi',root,/no_block

END












