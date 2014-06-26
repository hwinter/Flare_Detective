;+
;
; NAME:
;        imseq_manip
;
; PURPOSE: 
;        widget interface for image sequence manipolation
;
; CALLING SEQUENCE:
;
;        imseq_manip,ptrimseq,timev,ytimev
;
; INPUTS:
;
;        ptrimseq: a pointer to an image sequence
;        timev,ytimev: optional time and flux fot lightcurve plotting
;
; OUTPUT:
;        
; EXAMPLE:
;
;        imseq_manip,ptr
;
; VERSION:
;
;           APR-2003 written
;        14-APR-2003 version 0.2
;        13-OCT-2004 added 'Fit Position' buttons and functionalities 
;        21-OCT-2004 polished up fit position functionality
;        02-NOV-2004 added lightcurve plotting facilities
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

;.comp ~/pand_rapp_idl/imseq/imseq_manip2.pro


;
;plot the map on the screen, with the selected attributes
;
PRO imseq_manip_plotmap,mapstr,drawwidget

mapnumber=mapstr.selim

IF   mapstr.totim EQ 1 $
THEN maptr=mapstr.totmap $
ELSE $
     IF   (mapnumber GE 0) OR (mapnumber LT n_elements(mapstr.imseq)) $
     THEN maptr=mapstr.imseq[mapnumber] $
     ELSE RETURN

widget_control,drawwidget,get_value=winmap

plot_map,*maptr,window=winmap,contour=mapstr.contour,limb=mapstr.limb $
        ,levels=mapstr.levels,/percent $
        ,xrange=mapstr.xrange,yrange=mapstr.yrange

IF mapstr.showregion EQ 1 THEN BEGIN
    coor=mapstr.selcoor
    oplot,[coor[0],coor[1],coor[1],coor[0],coor[0]] $
         ,[coor[2],coor[2],coor[3],coor[3],coor[2]]
ENDIF

IF mapstr.plotfitpos EQ 1 THEN BEGIN
   IF (mapstr.fitpos[0] NE ptr_new()) AND (mapstr.fitpos[0] NE ptr_new()) THEN BEGIN 
      x=*mapstr.fitpos[0]
      y=*mapstr.fitpos[1]
      oplot,x,y,psym=1,color=1
      oplot,x,y,color=1
   ENDIF
ENDIF 

END

;
;plot the time evolution on the screen, with the selected attributes
;
PRO imseq_manip_plottimev,mapstr,drawwidget

   widget_control,drawwidget,get_value=winmap
   wset,winmap

   t=mapstr.timev
   y=mapstr.ytimev

   minim=*mapstr.imseq[mapstr.minfr]
   maxim=*mapstr.imseq[mapstr.maxfr]
   selim=*mapstr.imseq[mapstr.selim]

   totseltime=[anytim(minim.time)-0.5*minim.dur,anytim(maxim.time)+0.5*maxim.dur]
   seltime=[anytim(selim.time)-0.5*selim.dur,anytim(selim.time)+0.5*selim.dur]

   
   utplot,t-t[0],y,t[0],/xstyle

   yrange=!Y.crange

   outplot,totseltime[0]*[1,1]-t[0],yrange,t[0],linestyle=2
   outplot,totseltime[1]*[1,1]-t[0],yrange,t[0],linestyle=2

   IF mapstr.totim EQ 0 THEN BEGIN
      outplot,seltime[0]*[1,1]-t[0],yrange,t[0],linestyle=1
      outplot,seltime[1]*[1,1]-t[0],yrange,t[0],linestyle=1
   ENDIF
  
END



;
;This procedure draws and/or erase a rectangular frame on the current
;graphic window
;
PRO imseq_manip_plotbox,newcoor,oldcoor,sides=sides,noerase=noerase $
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
FUNCTION imseq_manip_outtext,mapstr


startime=anytim((*(mapstr.imseq[mapstr.minfr])).time,/vms)
endtime =anytim((*(mapstr.imseq[mapstr.maxfr])).time,/vms)

outtext=['Start at frame '+strtrim(mapstr.minfr,2),startime,'' $
        ,'End at frame '+strtrim(mapstr.maxfr,2),endtime,'' $
        ,'Coordinate selection' $
        ,'('+strtrim(string(mapstr.selcoor[0]),2)+',' $
            +strtrim(string(mapstr.selcoor[2]),2)+')' $
        ,'('+strtrim(string(mapstr.selcoor[1]),2)+',' $
            +strtrim(string(mapstr.selcoor[3]),2)+')' $
        ,'',"Fit method: '"+mapstr.fitmethod+"'"]

RETURN,outtext

END

;
;Widget event handler
;
PRO imseq_manip_event,ev

widget_control,ev.handler,get_uvalue=mapstr

CASE ev.ID OF 
    
    widget_info(ev.top,find_by_uname='selectim') : BEGIN
        
       mapstr.totim=0
       mapstr.selim=ev.index
       widget_control,ev.handler,set_uvalue=mapstr

       drawwidget=widget_info(ev.top,find_by_uname='drawwin')
       imseq_manip_plotmap,mapstr,drawwidget

       IF mapstr.plottimev THEN BEGIN 
          drawwidget=widget_info(ev.top,find_by_uname='timevwin')
          imseq_manip_plottimev,mapstr,drawwidget
       ENDIF


    END

    widget_info(ev.top,find_by_uname='selectfitm') : BEGIN
              
       mapstr.fitmethod=mapstr.fitmlist[ev.index]
       widget_control,ev.handler,set_uvalue=mapstr
       textwindow=widget_info(ev.top,find_by_uname='frameinfo')
       widget_control,textwindow,set_value=imseq_manip_outtext(mapstr)
       
    END

    widget_info(ev.top,find_by_uname='selectmin') : BEGIN

        IF ev.index NE mapstr.minfr THEN BEGIN

            widget_control,ev.top,/hourglass
            mapstr.minfr=ev.index
            mapstr.totmap=ptr_new(summaps(mapstr.imseq $
                                  ,min=mapstr.minfr,max=mapstr.maxfr))

            mapstr.totim=1

            textwindow=widget_info(ev.top,find_by_uname='frameinfo')
            widget_control,textwindow,set_value=imseq_manip_outtext(mapstr)

            widget_control,ev.handler,set_uvalue=mapstr

            drawwidget=widget_info(ev.top,find_by_uname='drawwin')
            imseq_manip_plotmap,mapstr,drawwidget

            IF mapstr.plottimev THEN BEGIN 
               drawwidget=widget_info(ev.top,find_by_uname='timevwin')
               imseq_manip_plottimev,mapstr,drawwidget
            ENDIF

        ENDIF
    END

    widget_info(ev.top,find_by_uname='selectmax') : BEGIN

        IF ev.index NE mapstr.maxfr THEN BEGIN

            widget_control,ev.top,/hourglass
            mapstr.maxfr=ev.index
            mapstr.totmap=ptr_new(summaps(mapstr.imseq $
                                  ,min=mapstr.minfr,max=mapstr.maxfr))

            mapstr.totim=1

            textwindow=widget_info(ev.top,find_by_uname='frameinfo')
            widget_control,textwindow,set_value=imseq_manip_outtext(mapstr)
  
            widget_control,ev.handler,set_uvalue=mapstr

            drawwidget=widget_info(ev.top,find_by_uname='drawwin')
            imseq_manip_plotmap,mapstr,drawwidget

            IF mapstr.plottimev THEN BEGIN 
               drawwidget=widget_info(ev.top,find_by_uname='timevwin')
               imseq_manip_plottimev,mapstr,drawwidget
            ENDIF

        ENDIF
    END     
 
    widget_info(ev.top,find_by_uname='commands') : BEGIN

        drawwidget=widget_info(ev.top,find_by_uname='drawwin')
        drawtimevwidget=widget_info(ev.top,find_by_uname='timevwin')
         
        CASE ev.value OF

            0 : BEGIN ;Draw total Image

                mapstr.totim=1
                 
                imseq_manip_plotmap,mapstr,drawwidget

                IF mapstr.plottimev THEN imseq_manip_plottimev,mapstr,drawtimevwidget
               
            END

            1 : BEGIN ;Draw selected Image

                mapstr.totim=0

                imseq_manip_plotmap,mapstr,drawwidget
                IF mapstr.plottimev THEN imseq_manip_plottimev,mapstr,drawtimevwidget
 
           END

            2 : BEGIN ;Contour plot
       
                mapstr.contour=1-mapstr.contour

                imseq_manip_plotmap,mapstr,drawwidget

            END

            3 : BEGIN ;Limb

                mapstr.limb=1-mapstr.limb

                imseq_manip_plotmap,mapstr,drawwidget

            END

            4 : BEGIN ;Select region

                imseq_manip_plotmap,mapstr,drawwidget

                status={dragging:0,first:0,last:0,oldcoor:[0.,0.,0.,0.] $
                       ,boxcoor:[0.,0.,0.,0.],sides:ptrarr(4),maxx:0,maxy:0 $
                       ,outcoor:[0.,0.,0.,0.]}

                geom=widget_info(drawwidget,/geometry)
                status.maxx=geom.draw_xsize-1
                status.maxy=geom.draw_ysize-1

                widget_control,drawwidget,set_uvalue=status

                ;makes the widget sensitive to mouse input events
                widget_control,drawwidget,/draw_button_events
                widget_control,drawwidget,/draw_motion_events

               
            END

            5 : BEGIN ; 'Draw selected region'

                mapstr.showregion=1-mapstr.showregion

                imseq_manip_plotmap,mapstr,drawwidget

            END


            6 : BEGIN ; 'Lightcurve'

                baselc=widget_base(title='Lightcurve',/row,group_leader=ev.top)

                drawlc=widget_draw(baselc,xsize=700,ysize=500 $
                                  ,uname='drawlc')
                
                widget_control,baselc,/hourglass

                imseq_ltc,mapstr.imseq,lev=0,tim=tim,lc=lc,box=mapstr.selcoor $
                         ,err=err


                IF err EQ 0 THEN BEGIN 

                     widget_control,baselc,/realize
                     widget_control,drawlc,get_value=winlc
                     wset,winlc
                     utplot,tim-tim[0],lc,tim[0]

                     outplot,tim[mapstr.minfr]*[1,1]-tim[0],!Y.crange,linestyle=2
                     outplot,tim[mapstr.maxfr]*[1,1]-tim[0],!Y.crange,linestyle=2

                     drawwidget=widget_info(ev.top,find_by_uname='drawwin')
 
                ENDIF $
                ELSE print,['An error occurred during the lightcurve '+ $
                           'computation.','Please select another region.']
                   
                
            END

            7 : BEGIN ; 'Color table'

                xloadct

            END

            8 : BEGIN ;'Zoom'

                mapstr.xrange=mapstr.selcoor[0:1]
                mapstr.yrange=mapstr.selcoor[2:3]
                imseq_manip_plotmap,mapstr,drawwidget           
                
            END

            9 : BEGIN ;'Unzoom'

                map=*(mapstr.totmap)
                coor=[map.xc-map.dx*(size(map.data))[1]/2 $
                     ,map.xc+map.dx*(size(map.data))[1]/2 $
                     ,map.yc-map.dy*(size(map.data))[2]/2 $
                     ,map.yc+map.dy*(size(map.data))[2]/2 ]

                mapstr.xrange=coor[0:1]
                mapstr.yrange=coor[2:3]
          
                imseq_manip_plotmap,mapstr,drawwidget

             END

             10 : BEGIN ;'Fit position'

                roi=mapstr.selcoor
   
                widget_control,ev.top,sensitive=0
                pg_mapcfit,mapstr.imseq[mapstr.minfr:mapstr.maxfr],x,y $
                          ,method=mapstr.fitmethod,roi=roi,/rdata
                widget_control,ev.top,sensitive=1

                fitposition=[ptr_new(x),ptr_new(y)]
                mapstr.fitpos=fitposition
                mapstr.plotfitpos=1

                imseq_manip_plotmap,mapstr,drawwidget

                ;primitive plotting utils --> to do: make'em better

                dy=max(y)-min(y)
                yrangey=[min(y)-0.1*dy,max(y)+0.1*dy]
                dx=max(x)-min(x)
                yrangex=[min(x)-0.1*dx,max(x)+0.1*dx]

                
                ;get image times...
                tarr=dblarr(mapstr.maxfr-mapstr.minfr+1)
                FOR i=mapstr.minfr,mapstr.maxfr DO $
                  tarr[i-mapstr.minfr]=anytim((*mapstr.imseq[i]).time)


                titlex='X coordinate of center from region ['+ $
                       strtrim(string(mapstr.selcoor[0]),2)+','+ $
                       strtrim(string(mapstr.selcoor[1]),2)+']'
                titley='Y coordinate of center from region ['+ $
                       strtrim(string(mapstr.selcoor[2]),2)+','+ $
                       strtrim(string(mapstr.selcoor[3]),2)+']'

                wdef,1,/lleft
                utplot,tarr-tarr[0],x,tarr[0],yrange=yrangex,/ystyle,title=titlex
                wdef,2,/lright
                utplot,tarr-tarr[0],y,tarr[0],yrange=yrangey,/ystyle,title=titley
   
             END

             11 : BEGIN ; 'Plot fit position'

                mapstr.plotfitpos=1-mapstr.plotfitpos

                imseq_manip_plotmap,mapstr,drawwidget
                
            
             END

             12 : BEGIN ; 'Done'

                widget_control,ev.top,/destroy
            
             END

            ELSE : RETURN

        ENDCASE


        IF   ev.value NE 12 $
        THEN widget_control,ev.handler,set_uvalue=mapstr

    END
 
    widget_info(ev.top,find_by_uname='drawwin') : BEGIN
;
;   this kind of events will only happen if the draw widget
;   has been made sensitive to mouse events, i.e. the select region
;   button (or zoom) has been pressed
;

        widget_control,ev.id,get_uvalue=status

        maxx=status.maxx
        maxy=status.maxy

        drawwidget=widget_info(ev.top,find_by_uname='drawwin')
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
                imseq_manip_plotbox,status.boxcoor,status.oldcoor,/nodraw $
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
           
                imseq_manip_plotbox,status.boxcoor,status.oldcoor,/noerase $
                                   ,sides=newsides
                status.first=0

            ENDIF $
            ELSE BEGIN

                imseq_manip_plotbox,status.boxcoor,status.oldcoor $
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
            

            widget_control,ev.handler,get_uvalue=mapstr
            mapstr.selcoor=status.outcoor
            widget_control,ev.handler,set_uvalue=mapstr

            textwindow=widget_info(ev.top,find_by_uname='frameinfo')
            widget_control,textwindow,set_value=imseq_manip_outtext(mapstr)
            
            imseq_manip_plotmap,mapstr,ev.id                          

        ENDIF

        widget_control,ev.id,set_uvalue=status
   
    END

    ELSE : print,'Ciao'

ENDCASE

END 


;
;Main procedure
;
PRO imseq_manip,ptrimseq,timev,ytimev

;
;variable initialisation stuff
;
wh=where(ptrimseq NE ptr_new())
tot=n_elements(wh)
ptr=ptrarr(tot)
FOR i=0,tot-1 DO ptr[i]=ptrimseq[wh[i]]
;
;ptr is now guaranteed composed only of valid pointers
;

pg_mapcfit,avmethods=fitmlist,/getmethods;list of possible fit methods


;check existence of timev and ytimev

IF exist(timev) AND exist(ytimev) THEN $
   plottimev=1 ELSE $
BEGIN
   plottimev=0
   timev=0.
   ytimev=0.
ENDELSE



mapstr={imseq:ptr,totmap:ptr_new(),minfr:0,maxfr:n_elements(ptr)-1 $
       ,selim:0,totim:1,contour:0,limb:1,selcoor:[0.,0.,0.,0.] $
       ,levels:[10,20,30,40,50,60,70,80,90],xrange:[0.,0.],yrange:[0.,0.] $
       ,showregion:1,fitmethod:'MAX',fitmlist:fitmlist $
       ,timev:timev,ytimev:ytimev,plottimev:plottimev $
       ,plotfitpos:0,fitpos:[ptr_new(),ptr_new()]}

map=summaps(ptr)
mapstr.selcoor=[map.xc-map.dx*(size(map.data))[1]/2 $
               ,map.xc+map.dx*(size(map.data))[1]/2 $
               ,map.yc-map.dy*(size(map.data))[2]/2 $
               ,map.yc+map.dy*(size(map.data))[2]/2 ]

mapstr.totmap=ptr_new(map)
mapstr.xrange=mapstr.selcoor[0:1]
mapstr.yrange=mapstr.selcoor[2:3]


;
;end variable init

;widget hierarchy creation
;
    base=widget_base(title='Image sequence manipulator',/row)
    root=widget_base(base,/row,uvalue=mapstr,uname='root')
    
    menu1=widget_base(root,group_leader=root,/column,/frame)
    drawsurf1=widget_base(root,group_leader=root,/row)
    buttonm1=widget_base(menu1,group_leader=menu1,/row,/frame)
;end widget hierarchy creation

;buttons
;
    values=['Draw total Image','Draw selected Image','Contour plot' $
           ,'Limb','Select region','Draw selected Region','Lightcurve' $
            ,'Color table','Zoom','Unzoom','Fit position','Plot fit pos' $
            ,'Done']
    uname='commands'
    bgroup=cw_bgroup(buttonm1,values,/column,uname=uname) ;,/frame)
;end buttons

;selection of current image
;
    sellab=widget_base(buttonm1,group_leader=buttonm1,/column)
    images=strtrim(string(indgen(tot)),2)
    labelim=widget_label(sellab,value='Selected Frame')
    selim=widget_list(sellab,value=images,ysize=10,uname='selectim')
    labellistfm=widget_label(sellab,value='Fit Method')
    selfitm=widget_droplist(sellab,value=fitmlist,uname='selectfitm')
    widget_control,selim,set_list_select=mapstr.selim
;end selection of current image

;selection of max and min
;
    selectframe=widget_base(menu1,group_leader=menu1,/row,/frame)

    minval=strarr(n_elements(ptr))
    FOR i=0,n_elements(ptr)-1 DO BEGIN
        minval[i]=strtrim(i,2)
    ENDFOR

    sellab1=widget_base(selectframe,group_leader=menu1,/column)
    label1=widget_label(sellab1,value='First frame     ')
    select1=widget_list(sellab1,value=minval,ysize=5,uname='selectmin')
    widget_control,select1,set_list_select=mapstr.minfr

    sellab2=widget_base(selectframe,group_leader=menu1,/column)
    label2=widget_label(sellab2,value='Last frame      ')
    select2=widget_list(sellab2,value=minval,ysize=5,uname='selectmax')
    widget_control,select2,set_list_select=mapstr.maxfr
;end selection of max end min

;text widget
;
    text=widget_text(menu1,value=imseq_manip_outtext(mapstr),ysize=12 $
                    ,uname='frameinfo')
;end text widget

;draw widget
;
    draw=widget_draw(drawsurf1,xsize=512,ysize=512,uname='drawwin')
    IF plottimev THEN $
      draw2=widget_draw(drawsurf1,xsize=512+256,ysize=512,uname='timevwin')
;end draw widget

widget_control,root,set_uvalue=mapstr
  
widget_control,base,/realize

imseq_manip_plotmap,mapstr,draw
IF plottimev EQ 1 THEN imseq_manip_plottimev,mapstr,draw2

xmanager,'imseq_manip',root,/no_block

END












