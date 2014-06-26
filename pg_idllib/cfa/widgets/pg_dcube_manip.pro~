;+
; NAME:
;
; pg_dcube_manip
;
; PURPOSE:
;
; widget tool to view and manipulate XRT images
;
; CATEGORY:
;
; HINODE/XRT utils
;
; CALLING SEQUENCE:
;
; pg_dcube_manip,xrtimseq,cat
;
; INPUTS:
;
; xrtimseq: either a list of XRT image files or an array of pointers to image maps
; cat: XRT catalog information, as output by xrt_cat
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
; pgrigis@cfa.haravrd.edu
;
; MODIFICATION HISTORY:
;
; 7-SEP-2007 written PG (based on imseq_manip, originally written in 2003 and 2004)
;
;-

;.comp pg_dcube_manip.pro


;
;plot the map on the screen, with the selected attributes
;
PRO pg_dcube_manip_plotmap,mapstr,evtop,oneonly=oneonly

drawwidget=widget_info(evtop,find_by_uname='drawwin')
drawwidget2=widget_info(evtop,find_by_uname='drawwin2')

mapnumber=mapstr.selim

IF   (mapnumber GE 0) OR (mapnumber LT mapstr.nim) $
THEN thismap=mapstr.imcube[*,*,mapnumber] $
ELSE RETURN

widget_control,drawwidget,get_value=winmap
widget_control,drawwidget2,get_value=winmap2
wset,winmap

;thismap=maptr,imcube[*,*,mapnumber]

;; IF mapstr.histo EQ 1 THEN BEGIN 

;;    max=10d^ceil(alog10(n_elements(thismap.data)))
;;    min=1

;;    pg_plot_histo,thismap.data,min=10.,max=4196,nbins=100 $
;;                 ,/ylog,/xlog,yrange=[min,max],/ystyle,xrange=[10,4196],/xstyle

;; ENDIF ELSE BEGIN 


   IF mapstr.tiecolor THEN $
      thismap=pg_rescale(thismap,method_number=mapstr.colscale,scale_gamma=mapstr.gamma) $
   ELSE $
     thismap=pg_rescale(thismap,method_number=mapstr.colscale $
                             ,scale_gamma=mapstr.gamma,dmin=mapstr.mincol,dmax=mapstr.maxcol) 
     

   ;thismap=congrid(thismap,mapstr.nx*mapstr.zoom,mapstr.ny*mapstr.zoom)

   pg_plotimage,thismap,/xstyle,/ystyle,/iso
   ;tvscl,thismap


   tvlct,255,0,0,0
   dx=mapstr.dzx/2
   dy=mapstr.dzy/2
   oplot,mapstr.selpixcoor[0]+[-dx,dx,dx,-dx,-dx],mapstr.selpixcoor[1]+[-dy,-dy,dy,dy,-dy],color=0
   tvlct,0,0,0,0

   ;wset,winmap
   ;tvscl,thismap;[mapstr.xrange[0]:mapstr.xrange[1],mapstr.yrange[0]:mapstr.yrange[1]];,window=winmap
   ;pg_plotimage,thismap,window=winmap,/iso,/xstyle,/ystyle $
   ;        ,xrange=mapstr.xrange,yrange=mapstr.yrange

;   IF mapstr.showregion EQ 1 THEN BEGIN
;      coor=mapstr.selcoor
;      plots,[coor[0],coor[1],coor[1],coor[0],coor[0]] $
;           ,[coor[2],coor[2],coor[3],coor[3],coor[2]],/DEVICE
;   ENDIF

;;ENDELSE

   IF NOT keyword_set(oneonly) THEN BEGIN 

      wset,winmap2
      pg_plotimage,thismap[(mapstr.selpixcoor[0]-mapstr.dzx/2)>0:(mapstr.selpixcoor[0]+mapstr.dzx/2)<(mapstr.nx-1), $
                           (mapstr.selpixcoor[1]-mapstr.dzy/2)>0:(mapstr.selpixcoor[1]+mapstr.dzy/2)<(mapstr.ny-1)] $
                  ,/xstyle,/ystyle,/iso

      tvlct,255,0,0,0
      dx=0.5
      dy=0.5
      oplot,mapstr.dzx/2-1+[-dx,dx,dx,-dx,-dx],mapstr.dzy/2-1+[-dy,-dy,dy,dy,-dy],color=0
      tvlct,0,0,0,0


   ENDIF


   ;tvscl,thismap

END

;
;plot the time evolution on the screen, with the selected attributes
;
PRO pg_dcube_manip_plotlc,mapstr,drawwidget

   widget_control,drawwidget,get_value=winmap
   wset,winmap

   t=mapstr.time
   y=mapstr.imcube[mapstr.selpixcoor[0],mapstr.selpixcoor[1],*]

;   minim=;*mapstr.imseq[mapstr.minfr]
;   maxim=;*mapstr.imseq[mapstr.maxfr]
;   selim=mapstr.imseq[mapstr.selim]

;   totseltime=[anytim(minim.time),anytim(maxim.time)+maxim.dur]
;   seltime=[anytim(selim.time),anytim(selim.time)+selim.dur]

   
   utplot,t-t[0],y,t[0],/xstyle,/nodata

   yrange=!Y.crange
   outplot,t[mapstr.selim]*[1,1]-t[0],yrange,t[0],linestyle=2
   outplot,t-t[0],y,t[0]

 ;  outplot,totseltime[0]*[1,1]-t[0],yrange,t[0],linestyle=2
 ;  outplot,totseltime[1]*[1,1]-t[0],yrange,t[0],linestyle=2

 ;  IF mapstr.totim EQ 0 THEN BEGIN
 ;     outplot,seltime[0]*[1,1]-t[0],yrange,t[0],linestyle=1
 ;     outplot,seltime[1]*[1,1]-t[0],yrange,t[0],linestyle=1
 ;  ENDIF
  
END



;
;This procedure draws and/or erase a rectangular frame on the current
;graphic window
;
PRO pg_dcube_manip_plotbox,newcoor,oldcoor,sides=sides,noerase=noerase $
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
FUNCTION pg_dcube_manip_outtext,mapstr


;startime=anytim((*(mapstr.imseq[mapstr.minfr])).time,/vms)
;endtime =anytim((*(mapstr.imseq[mapstr.maxfr])).time,/vms)

i=mapstr.selim;image index
;imsize=size((*mapstr.imseq[i]).data,/dimension)

thistime=anytim(mapstr.time[i],/vms)
thisim=mapstr.imcube[*,*,i]

outtext=['Image Nr.: '+strtrim(i,2),$
         'Time: '+thistime ,$
         'Image min: '+ strtrim(min(thisim),2), $
         'Image max: '+ strtrim(max(thisim),2), $
         'Image size: '+strtrim(mapstr.nx,2)+' by '+strtrim(mapstr.ny,2)+' pixels', $
         'Pixel selection: '+strtrim(mapstr.selpix,2), $
         'Pixel selected: x:'+strtrim(mapstr.selpixcoor[0],2)+' y:'+strtrim(mapstr.selpixcoor[1],2), $
         'Coordinate selection', $
         'X: ('+strtrim(string(round(mapstr.selcoor[0])),2)+','  $
            +strtrim(string(round(mapstr.selcoor[2])),2)+')', $
         'Y: ('+strtrim(string(round(mapstr.selcoor[1])),2)+',' $
            +strtrim(string(round(mapstr.selcoor[3])),2)+')']



;here add some catalog info

RETURN,outtext

END

;
;Widget event handler
;
PRO pg_dcube_manip_event,ev

widget_control,ev.handler,get_uvalue=mapstr

CASE ev.ID OF 
    
    widget_info(ev.top,find_by_uname='selectim') : BEGIN
        

       ;stop

       mapstr.selim=ev.index
       widget_control,ev.top,set_uvalue=mapstr

       drawwidget=widget_info(ev.handler,find_by_uname='drawwin')
       pg_dcube_manip_plotmap,mapstr,ev.top

       drawtimewidget=widget_info(ev.top,find_by_uname='plotwin')
       pg_dcube_manip_plotlc,mapstr,drawtimewidget


       textwidget=widget_info(ev.top,find_by_uname='frameinfo') 
       widget_control,textwidget,set_value=pg_dcube_manip_outtext(mapstr)
       

    END


    widget_info(ev.top,find_by_uname='selcolor') : BEGIN

       ;print,'color is now '+string(ev.index)
       mapstr.colscale=ev.index
       widget_control,ev.handler,set_uvalue=mapstr
        
       drawwidget=widget_info(ev.top,find_by_uname='drawwin')
       pg_dcube_manip_plotmap,mapstr,ev.top

       drawtimewidget=widget_info(ev.top,find_by_uname='plotwin')
       pg_dcube_manip_plotlc,mapstr,drawtimewidget

;       textwidget=widget_info(ev.top,find_by_uname='frameinfo') 
;       widget_control,textwidget,set_value=pg_dcube_manip_outtext(mapstr)
       
    END

    widget_info(ev.top,find_by_uname='mincolsel') : BEGIN

       mapstr.mincol=ev.value
       widget_control,ev.handler,set_uvalue=mapstr
        
       drawwidget=widget_info(ev.top,find_by_uname='drawwin')
       pg_dcube_manip_plotmap,mapstr,ev.top
       
       drawtimewidget=widget_info(ev.top,find_by_uname='plotwin')
       pg_dcube_manip_plotlc,mapstr,drawtimewidget



;       textwidget=widget_info(ev.top,find_by_uname='frameinfo') 
;       widget_control,textwidget,set_value=pg_dcube_manip_outtext(mapstr)
       
    END

    widget_info(ev.top,find_by_uname='gammasel') : BEGIN

       mapstr.gamma=ev.value
       widget_control,ev.handler,set_uvalue=mapstr
        
       drawwidget=widget_info(ev.top,find_by_uname='drawwin')
       pg_dcube_manip_plotmap,mapstr,ev.top
       

       drawtimewidget=widget_info(ev.top,find_by_uname='plotwin')
       pg_dcube_manip_plotlc,mapstr,drawtimewidget


;       textwidget=widget_info(ev.top,find_by_uname='frameinfo') 
;       widget_control,textwidget,set_value=pg_dcube_manip_outtext(mapstr)
       
    END



    widget_info(ev.top,find_by_uname='maxcolsel') : BEGIN

       mapstr.maxcol=ev.value
       widget_control,ev.handler,set_uvalue=mapstr
        
       drawwidget=widget_info(ev.top,find_by_uname='drawwin')
       pg_dcube_manip_plotmap,mapstr,ev.top
       
       drawtimewidget=widget_info(ev.top,find_by_uname='plotwin')
       pg_dcube_manip_plotlc,mapstr,drawtimewidget


;       textwidget=widget_info(ev.top,find_by_uname='frameinfo') 
;       widget_control,textwidget,set_value=pg_dcube_manip_outtext(mapstr)
       
    END
  


    widget_info(ev.top,find_by_uname='commands') : BEGIN

        drawwidget=widget_info(ev.top,find_by_uname='drawwin')
        drawtimewidget=widget_info(ev.top,find_by_uname='plotwin')
         
        CASE ev.value OF


            0 : BEGIN ;Draw selected Image



                pg_dcube_manip_plotmap,mapstr,ev.top
              
  ;              drawtimewidget=widget_info(ev.top,find_by_uname='plotwin')
                pg_dcube_manip_plotlc,mapstr,ev.top

                textwidget=widget_info(ev.top,find_by_uname='frameinfo') 
                widget_control,textwidget,set_value=pg_dcube_manip_outtext(mapstr)
 
;                IF mapstr.plottimev THEN pg_dcube_manip_plottimev,mapstr,drawtimevwidget
 

           END

      
            1 : BEGIN ;Limb

                mapstr.limb=1-mapstr.limb

                pg_dcube_manip_plotmap,mapstr,ev.top


            END

           ;; 2 : BEGIN ;Select region
;
;                pg_dcube_manip_plotmap,mapstr,ev.top;
;
;                status={dragging:0,first:0,last:0,oldcoor:[0.,0.,0.,0.] $
;                       ,boxcoor:[0.,0.,0.,0.],sides:ptrarr(4),maxx:0,maxy:0 $
;                       ,outcoor:[0.,0.,0.,0.],mousecoor:0}
;
;                geom=widget_info(drawwidget,/geometry)
;                status.maxx=geom.draw_xsize-1
;                status.maxy=geom.draw_ysize-1;
;
;                widget_control,drawwidget,set_uvalue=status;
;
;                ;makes the widget sensitive to mouse input events
;                widget_control,drawwidget,/draw_button_events
;               widget_control,drawwidget,/draw_motion_events

               
;            END

            3 : BEGIN ; 'Draw selected region'

                mapstr.showregion=1-mapstr.showregion

                pg_dcube_manip_plotmap,mapstr,ev.top

            END


            4 : BEGIN ; 'Lightcurve'

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

            5 : BEGIN ; 'Color table'

                xloadct

            END

            6 : BEGIN ;'Zoom'

                ;mapstr.xrange=mapstr.selcoor[0:1]
                ;mapstr.yrange=mapstr.selcoor[2:3]
                ;pg_dcube_manip_plotmap,mapstr,ev.top           
                
            END

            ;;7 : BEGIN ;'Unzoom'

                ;map=*mapstr.imseq[mapstr.selim]

                ;coor=[0,mapstr.nx,0,mapstr.ny];map.xc-map.dx*(size(map.data))[1]/2 $
                     ;,map.xc+map.dx*(size(map.data))[1]/2 $
                     ;,map.yc-map.dy*(size(map.data))[2]/2 $
                     ;,map.yc+map.dy*(size(map.data))[2]/2 ]

                ;mapstr.xrange=coor[0:1]
                ;mapstr.yrange=coor[2:3]
          
                ;pg_dcube_manip_plotmap,mapstr,ev.top

             ;;END

             8 : BEGIN ; 'Tie color max min to image'

                mapstr.tiecolor=1-mapstr.tiecolor
                widget_control,ev.handler,set_uvalue=mapstr
   
                mincolwidget=widget_info(ev.top,find_by_uname='mincolsel')
                maxcolwidget=widget_info(ev.top,find_by_uname='maxcolsel')

                widget_control,mincolwidget,sensitive=1-mapstr.tiecolor
                widget_control,maxcolwidget,sensitive=1-mapstr.tiecolor               


             END

             9 : BEGIN ; 'Histogram'


                mapstr.histo=1-mapstr.histo
                widget_control,ev.handler,set_uvalue=mapstr
                
                pg_dcube_manip_plotmap,mapstr,ev.top


             END

   
             10 : BEGIN         ; mouse coordinates


;                widget_control,ev.handler,set_uvalue=mapstr
;               
;                pg_dcube_manip_plotmap,mapstr,drawwidget

                widget_control,drawwidget,get_uvalue=status
                status.mousecoor=1
                widget_control,drawwidget,set_uvalue=status

                widget_control,drawwidget,/draw_button_events



             END


             11 : BEGIN ; 'Done'

                widget_control,ev.top,/destroy
            
             END

             2 : BEGIN          ; 'Select Region'

                IF mapstr.selpix EQ 1 THEN mapstr.selpix=0 ELSE BEGIN 
                   mapstr.selpix=1
                   pg_dcube_manip_plotmap,mapstr,ev.top,/oneonly
                
                ;textwidget=widget_info(ev.top,find_by_uname='frameinfo') 
                ;widget_control,textwidget,set_value=pg_dcube_manip_outtext(mapstr)


                                ;pg_dcube_manip_plotmap,mapstr,drawwidget
                ;wset...
                   widget_control,drawwidget,get_value=winmap
                   wset,winmap
                   mouse_get_data,/noa,out=out

                   mapstr.selpixcoor[0]=round(out[0])
                   mapstr.selpixcoor[1]=round(out[1])

                   pg_dcube_manip_plotmap,mapstr,ev.top ;,/oneonly
                


                ENDELSE 
             END


            12 : BEGIN          ; 'Select Pixel'

                ;IF mapstr.selpix EQ 1 THEN mapstr.selpix=0 ELSE BEGIN 
                ;   mapstr.selpix=1
                 
               pg_dcube_manip_plotmap,mapstr,ev.top ;,/oneonly
                
                ;textwidget=widget_info(ev.top,find_by_uname='frameinfo') 
                ;widget_control,textwidget,set_value=pg_dcube_manip_outtext(mapstr)


                                ;pg_dcube_manip_plotmap,mapstr,drawwidget
                ;wset...
               widget_control,drawtimewidget,get_value=winmap
               wset,winmap
               mouse_get_data,/noa,out=out

               mapstr.selpixcoor[0]=round(out[0]+mapstr.selpixcoor[0]-mapstr.dzx/2-1)
               mapstr.selpixcoor[1]=round(out[1]+mapstr.selpixcoor[1]-mapstr.dzy/2-1)


               pg_dcube_manip_plotmap,mapstr,ev.top ;,/oneonly
                

            ;ENDELSE 
                  
         END

            ELSE : RETURN

        ENDCASE


        IF   ev.value NE 11 $
        THEN widget_control,ev.handler,set_uvalue=mapstr

    END
 
    widget_info(ev.top,find_by_uname='drawwin') : BEGIN
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
                pg_dcube_manip_plotbox,status.boxcoor,status.oldcoor,/nodraw $
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
           
                pg_dcube_manip_plotbox,status.boxcoor,status.oldcoor,/noerase $
                                   ,sides=newsides
                status.first=0

            ENDIF $
            ELSE BEGIN

                pg_dcube_manip_plotbox,status.boxcoor,status.oldcoor $
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
            widget_control,textwindow,set_value=pg_dcube_manip_outtext(mapstr)
            
            pg_dcube_manip_plotmap,mapstr,ev.id                          

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
PRO pg_dcube_manip,imcube,time=time,zoom=zoom ;xrtimseq,incat,quiet=quiet,outptrimseq=ptr,outcat=cat

s=size(imcube)
IF s[0] NE 3 THEN BEGIN 
   print,'Invalid input. Need 3-dimensional image cube nx by ny by nimages.'
   RETURN
ENDIF

nx=s[1]
ny=s[2]
nim=s[3]

IF n_elements(time) NE nim THEN time=findgen(nim)

zoom=fcheck(zoom,1)

;
;ptr is now guaranteed composed only of valid pointers
;

mapstr={imcube:imcube $;temporary(imcube) $;temporary(imcube) $
        ,time:time $
        ,nx:nx $
        ,ny:ny $
        ,nim:nim $
        ,zoom:zoom $
        ,dzx:32,dzy:32 $
        ,dzpix:128,dzpiy:128 $
        ,selim:0 $
        ,limb:1 $
        ,selcoor:[0.,0.,0.,0.] $
        ,xrange:[0.,0.] $
        ,yrange:[0.,0.] $
        ,showregion:1 $
        ,colscale:1 $
        ,gamma:1. $
        ,mincol:30 $
        ,maxcol:4192 $
        ,tiecolor:1 $
        ,histo:0 $
        ,selpix:0 $
        ,selpixcoor:[0,0]}


;map=*ptr[0]
mapstr.selcoor=[0,nx-1,0,ny-1]

mapstr.xrange=mapstr.selcoor[0:1]
mapstr.yrange=mapstr.selcoor[2:3]

;
;end variable init

;widget hierarchy creation
;
    base=widget_base(title='Image sequence manipulator',/row)
    root=widget_base(base,/row,uvalue=mapstr,uname='root')
    
    menu1=widget_base(root,group_leader=root,/column,/frame)
    drawsurf1=widget_base(root,group_leader=root,/column)
    drawsurf1a=widget_base(drawsurf1,group_leader=root,/row)
    drawsurf1b=widget_base(drawsurf1,group_leader=root,/row)

    buttonm1=widget_base(menu1,group_leader=menu1,/row,/frame)
;end widget hierarchy creation

;buttons
;
    values=['Draw selected Image' $
            ,'Limb','Select region','Draw selected Region','Lightcurve' $
            ,'Color table','Zoom','Unzoom','Col to min/max image','Toggle Histogram' $
            ,'Mouse Coordinates','Done', 'Select pixel']
    uname='commands'
    bgroup=cw_bgroup(buttonm1,values,/column,uname=uname) ;,/frame)
;end buttons

;selection of current image
;
    sellab=widget_base(buttonm1,group_leader=buttonm1,/column)
    images=strtrim(string(indgen(nim)),2)

    labelim=widget_label(sellab,value='Selected Frame')
    selim=widget_list(sellab,value=images,ysize=10,uname='selectim')

    
;end selection of current image


;droplist for color state etc.
    coldlist = widget_droplist(sellab,value=['Linear','Logarithmic','Quadratic'],title='color stuff',uname='selcolor')
    gamma=cw_field(sellab,value=mapstr.gamma,uname='gammasel',/floating,/return_events $
                   ,title='Gamma')

    mincol=cw_field(sellab,value=mapstr.mincol,uname='mincolsel',/floating,/return_events $
                   ,title='Min color')
    maxcol=cw_field(sellab,value=mapstr.maxcol,uname='maxcolsel',/floating,/return_events $
                   ,title='Max color')


;text widget
;
    text=widget_text(menu1,value=pg_dcube_manip_outtext(mapstr),ysize=12 $
                    ,uname='frameinfo')
;end text widget

;draw widget
;
    draw=widget_draw(drawsurf1a,xsize=600,ysize=600,uname='drawwin')
    drawbis=widget_draw(drawsurf1a,xsize=600,ysize=600,uname='drawwin2')
    draw2=widget_draw(drawsurf1b,xsize=1200,ysize=800,uname='plotwin')
;    IF plottimev THEN $
;    draw2=widget_draw(drawsurf1,xsize=725,ysize=512,uname='timevwin')
;end draw widget


    status={dragging:0,first:0,last:0,oldcoor:[0.,0.,0.,0.] $
           ,boxcoor:[0.,0.,0.,0.],sides:ptrarr(4),maxx:0,maxy:0 $
           ,outcoor:[0.,0.,0.,0.],mousecoor:0}


    widget_control,draw,set_uvalue=status



widget_control,root,set_uvalue=mapstr
  
widget_control,base,/realize

widget_control,mincol,sensitive=1-mapstr.tiecolor
widget_control,maxcol,sensitive=1-mapstr.tiecolor

widget_control,coldlist,set_droplist_select=1

;pg_dcube_manip_plotmap,mapstr,draw
;pg_dcube_manip_plottimev,mapstr,draw2

xmanager,'pg_dcube_manip',root,/no_block


END












