;+
;
; NAME:
;        pg_imcube_xrt_manip
;
; PURPOSE:
;        widget interface for image cube  manipolation
;        new--> overlaps XRT images...
;
; CALLING SEQUENCE:
;
;        imseq_manip,ptrimcube
;
; INPUTS:
;
;        ptrimcube: a pointer to an image cube [time x energy]
;
; OUTPUT:
;
; EXAMPLE:
;
;        imseq_manip,ptrimcube
;
; VERSION:
;
;        05-FEB-2007 written, based on pg_imcube_manip, while visiting at CfA
;        22-MAR-2007 added mechanism for different color table passing...
;
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-

;.comp pg_imcube_spg_xrt_manip
;PRO pg_imcube_spg_xrt_manip_plotmap_test
;
;  pg_imcube_spg_xrt_manip,res,spg=spg,xrtmap=xrtmap
;
;END

;
;plot the map on the screen, with the selected attributes
;
PRO pg_imcube_spg_xrt_manip_plotmap2,mapstr,drawwidget


widget_control,drawwidget,get_value=winmap

map=*mapstr.xrtim[mapstr.this_timexrt]

map.xc=map.xc+mapstr.xshift
map.yc=map.yc+mapstr.yshift

IF mapstr.ctstring NE '' THEN dummy=execute(mapstr.ctstring) ELSE loadct,3

plot_map,map,window=winmap,limb=mapstr.limb $
        ,xrange=mapstr.xrange,yrange=mapstr.yrange,log=mapstr.zlog


if mapstr.overlap then begin

   ;stop
   linecolors
   

   plot_map,*mapstr.imseq[mapstr.this_time,mapstr.this_energy] $
            ,window=winmap,contour=1 $
            ,levels=*mapstr.cont_lev_arr[mapstr.cont_lev],/percent $
            ,/overlay,xrange=mapstr.xrange,yrange=mapstr.yrange,lcolor=9

endif

end


;
;plot the map on the screen, with the selected attributes
;
PRO pg_imcube_spg_xrt_manip_plotmap,mapstr,drawwidget

loadct,5

if mapstr.show_spg EQ 1 then begin

	!p.multi=[0,1,2]
	dospg=1

;	mposition=[0.2,,0.8]
;        spgposition=

endif else begin
	dospg=0
;	!p.multi=0
endelse


IF mapstr.totalplot EQ 1 THEN BEGIN

   mapstr2=mapstr

   oldp=!p

   !p.charsize=1.5
   !p.multi=[0,mapstr.ntime,mapstr.nenergy]

   FOR j=0,mapstr.nenergy-1 DO BEGIN

      FOR i=0,mapstr.ntime-1 DO BEGIN

         mapstr2.this_time=i
         mapstr2.this_energy=j
         mapstr2.totalplot=0

         pg_imcube_spg_xrt_manip_plotmap,mapstr2,drawwidget

      ENDFOR


   ENDFOR

   !p=oldp

   RETURN

ENDIF


maptr=mapstr.imseq[mapstr.this_time,mapstr.this_energy]


widget_control,drawwidget,get_value=winmap

plot_map,*maptr,window=winmap,contour=mapstr.contour,limb=mapstr.limb $
        ,levels=*mapstr.cont_lev_arr[mapstr.cont_lev],/percent $
        ,xrange=mapstr.xrange,yrange=mapstr.yrange

IF mapstr.showregion EQ 1 THEN BEGIN
    coor=mapstr.selcoor
    oplot,[coor[0],coor[1],coor[1],coor[0],coor[0]] $
         ,[coor[2],coor[2],coor[3],coor[3],coor[2]]
ENDIF

IF mapstr.plotfitpos EQ 1 THEN BEGIN
   IF (mapstr.fitpos[0] NE ptr_new()) AND $
      (mapstr.fitpos[0] NE ptr_new()) THEN BEGIN

      x=*mapstr.fitpos[0]
      y=*mapstr.fitpos[1]
      oplot,x,y,psym=1,color=mapstr.fitcol[mapstr.fitcol_sel]
      oplot,x,y,color=mapstr.fitcol[mapstr.fitcol_sel]

   ENDIF
ENDIF

IF tag_exist(*maptr,'PG_ENERGY_RANGE') AND (mapstr.totim NE 1) THEN BEGIN
   en=(*maptr).pg_energy_range
   enstr='Energy Range: '+string(en[0],format='(f6.3)')+' -- ' $
                         +string(en[1],format='(f6.3)')+ 'keV'
   xyouts,100,30,enstr,/device
ENDIF

if dospg then begin

	spectro_plot,mapstr.spg,/zlog,/ylog,/xstyle,/ystyle

	timeintv=(*mapstr.imseq[mapstr.this_time,mapstr.this_energy]).time_intv
	energyintv=(*mapstr.imseq[mapstr.this_time,mapstr.this_energy]).energy_intv


	outplot,timeintv[[0,0]]-mapstr.spg.x[0],10^!y.crange,mapstr.spg.x[0]
	outplot,timeintv[[1,1]]-mapstr.spg.x[0],10^!y.crange,mapstr.spg.x[0]

	oplot,!x.crange,energyintv[[0,0]]
	oplot,!x.crange,energyintv[[1,1]]

endif



END

;
;plot the time evolution on the screen, with the selected attributes
;
PRO pg_imcube_spg_xrt_manip_plottimev,mapstr,drawwidget

   widget_control,drawwidget,get_value=winmap
   wset,winmap

   t=mapstr.timev
   y=mapstr.ytimev

   minim=*mapstr.imseq[mapstr.minfr]
   maxim=*mapstr.imseq[mapstr.maxfr]
   selim=*mapstr.imseq[mapstr.selim]

   totseltime=[anytim(minim.time),anytim(maxim.time)+maxim.dur]
   seltime=[anytim(selim.time),anytim(selim.time)+selim.dur]


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
PRO pg_imcube_spg_xrt_manip_plotbox,newcoor,oldcoor,sides=sides,noerase=noerase $
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
FUNCTION pg_imcube_spg_xrt_manip_outtext,mapstr


timeintv=(*mapstr.imseq[mapstr.this_time,mapstr.this_energy]).time_intv
energyintv=(*mapstr.imseq[mapstr.this_time,mapstr.this_energy]).energy_intv

timexrt=anytim((*mapstr.xrtim[mapstr.this_timexrt]).time,/vms)

startime=anytim(timeintv[0],/vms)
endtime =anytim(timeintv[1],/vms)

starten=strtrim(string(energyintv[0],format='(f5.1)'),2)
enden  =strtrim(string(energyintv[1],format='(f5.1)'),2)




outtext=['Time Intv:' $
        ,startime+' to '+endtime $
        ,'XRT Time:' $
        ,timexrt $
        ,'Energy Intv' $
        ,starten+' to '+enden+ ' keV' $
        ,'Coordinate selection' $
        ,'('+strtrim(string(mapstr.selcoor[0]),2)+',' $
            +strtrim(string(mapstr.selcoor[2]),2)+')' $
        ,'('+strtrim(string(mapstr.selcoor[1]),2)+',' $
            +strtrim(string(mapstr.selcoor[3]),2)+')' $
        ,'',"Fit method: '"+mapstr.fitmethod+"'"]

if have_tag(*mapstr.xrtim[mapstr.this_timexrt],'exp_time') then begin
   outtext=[outtext,'Exp. Time: '+string((*mapstr.xrtim[mapstr.this_timexrt]).exp_time,format='(f8.4)')]
endif

RETURN,outtext

END

;
;Widget event handler
;
PRO pg_imcube_spg_xrt_manip_event,ev

widget_control,ev.handler,get_uvalue=mapstr

CASE ev.ID OF

    ;fit method selection
    widget_info(ev.top,find_by_uname='selectfitm') : BEGIN

       mapstr.fitmethod=mapstr.fitmlist[ev.index]
       widget_control,ev.handler,set_uvalue=mapstr
       textwindow=widget_info(ev.top,find_by_uname='frameinfo')
       widget_control,textwindow,set_value=pg_imcube_spg_xrt_manip_outtext(mapstr)

    END


    ;contour level selection
    widget_info(ev.top,find_by_uname='selectcl') : BEGIN

       mapstr.cont_lev=ev.index
       widget_control,ev.handler,set_uvalue=mapstr
       drawwidget=widget_info(ev.top,find_by_uname='drawwin')
       pg_imcube_spg_xrt_manip_plotmap,mapstr,drawwidget

    END

    ;x shift value change
    widget_info(ev.top,find_by_uname='shiftxsel') : BEGIN

       print,'new x shift'+string(ev.value)
       mapstr.xshift=ev.value
           
       drawwidget2=widget_info(ev.top,find_by_uname='drawwin2')
       pg_imcube_spg_xrt_manip_plotmap2,mapstr,drawwidget2
       widget_control,ev.handler,set_uvalue=mapstr

    end


    ;y shift value change
    widget_info(ev.top,find_by_uname='shiftysel') : BEGIN

       print,'new y shift'+string(ev.value)
       mapstr.yshift=ev.value

       drawwidget2=widget_info(ev.top,find_by_uname='drawwin2')
       pg_imcube_spg_xrt_manip_plotmap2,mapstr,drawwidget2
     widget_control,ev.handler,set_uvalue=mapstr


    END
  

    ;plot fit color selection
    widget_info(ev.top,find_by_uname='selectfitcol') : BEGIN

       mapstr.fitcol_sel=ev.index
       widget_control,ev.handler,set_uvalue=mapstr
       drawwidget=widget_info(ev.top,find_by_uname='drawwin')
       pg_imcube_spg_xrt_manip_plotmap,mapstr,drawwidget

    END


    widget_info(ev.top,find_by_uname='selecttime') : BEGIN


            widget_control,ev.top,/hourglass

            mapstr.this_time=ev.index

            if mapstr.tied then begin
               thistime=mapstr.alltime[mapstr.this_time]
               dummy=min(abs(thistime-mapstr.alltimexrt),index)
               mapstr.this_timexrt=index

               xrtselwidget=widget_info(ev.top,find_by_uname='selecttimexrt')
               
               widget_control,xrtselwidget,set_list_select=mapstr.this_timexrt

               drawwidget2=widget_info(ev.top,find_by_uname='drawwin2')
               pg_imcube_spg_xrt_manip_plotmap2,mapstr,drawwidget2


            endif


            textwindow=widget_info(ev.top,find_by_uname='frameinfo')
            widget_control,textwindow,set_value=pg_imcube_spg_xrt_manip_outtext(mapstr)

            widget_control,ev.handler,set_uvalue=mapstr

            drawwidget=widget_info(ev.top,find_by_uname='drawwin')
            pg_imcube_spg_xrt_manip_plotmap,mapstr,drawwidget

            IF mapstr.plottimev THEN BEGIN
               drawwidget=widget_info(ev.top,find_by_uname='timevwin')
               pg_imcube_spg_xrt_manip_plottimev,mapstr,drawwidget
            ENDIF

    END


  widget_info(ev.top,find_by_uname='selecttimexrt') : BEGIN


            widget_control,ev.top,/hourglass

            mapstr.this_timexrt=ev.index


         if mapstr.tied then begin
         
            thistime=mapstr.alltimexrt[mapstr.this_timexrt]
            dummy=min(abs(thistime-mapstr.alltime),index)
            mapstr.this_time=index

            xrtselwidget=widget_info(ev.top,find_by_uname='selecttime')
               
            widget_control,xrtselwidget,set_list_select=mapstr.this_time

            drawwidget=widget_info(ev.top,find_by_uname='drawwin')
            pg_imcube_spg_xrt_manip_plotmap,mapstr,drawwidget

               
         endif


            textwindow=widget_info(ev.top,find_by_uname='frameinfo')
            widget_control,textwindow,set_value=pg_imcube_spg_xrt_manip_outtext(mapstr)

            widget_control,ev.handler,set_uvalue=mapstr

            drawwidget=widget_info(ev.top,find_by_uname='drawwin2')
            pg_imcube_spg_xrt_manip_plotmap2,mapstr,drawwidget

    END



    widget_info(ev.top,find_by_uname='selectenergy') : BEGIN


            widget_control,ev.top,/hourglass
            mapstr.this_energy=ev.index


            textwindow=widget_info(ev.top,find_by_uname='frameinfo')
            widget_control,textwindow,set_value=pg_imcube_spg_xrt_manip_outtext(mapstr)

            widget_control,ev.handler,set_uvalue=mapstr

            drawwidget=widget_info(ev.top,find_by_uname='drawwin')
            pg_imcube_spg_xrt_manip_plotmap,mapstr,drawwidget
            
            if mapstr.overlap then begin 
               drawwidget2=widget_info(ev.top,find_by_uname='drawwin2')
               pg_imcube_spg_xrt_manip_plotmap2,mapstr,drawwidget2
            endif

    END

    widget_info(ev.top,find_by_uname='commands') : BEGIN

        drawwidget=widget_info(ev.top,find_by_uname='drawwin')
        drawtimevwidget=widget_info(ev.top,find_by_uname='timevwin')

        CASE ev.value OF

            0 : BEGIN ;Show spectrogram


		mapstr.totalplot=0
                mapstr.show_spg=1-mapstr.show_spg

		if mapstr.show_spg then begin
			!P.multi=[0,1,2]
			mapstr.widgxsize=512 
			mapstr.widgysize=860 
		endif $
		else begin
			!P.multi=0
			mapstr.widgxsize=512 
			mapstr.widgysize=512
		endelse
		
		widget_control,drawwidget,draw_xsize=mapstr.widgxsize $
			      ,draw_ysize=mapstr.widgysize

                pg_imcube_spg_xrt_manip_plotmap,mapstr,drawwidget

                IF mapstr.plottimev THEN pg_imcube_spg_xrt_manip_plottimev,mapstr,drawtimevwidget

            END

            1 : BEGIN ;Draw selected Image

                mapstr.totim=0

                pg_imcube_spg_xrt_manip_plotmap,mapstr,drawwidget
                IF mapstr.plottimev THEN pg_imcube_spg_xrt_manip_plottimev,mapstr,drawtimevwidget

           END

            2 : BEGIN ;Contour plot

                mapstr.contour=1-mapstr.contour

                pg_imcube_spg_xrt_manip_plotmap,mapstr,drawwidget

            END

            3 : BEGIN ;Limb

                mapstr.limb=1-mapstr.limb

                pg_imcube_spg_xrt_manip_plotmap,mapstr,drawwidget

            END

            4 : BEGIN ;Select region

                pg_imcube_spg_xrt_manip_plotmap,mapstr,drawwidget

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

                pg_imcube_spg_xrt_manip_plotmap,mapstr,drawwidget

            END


            6 : BEGIN ; 'total plot'

               print,'total plot'

               mapstr.totalplot=1-mapstr.totalplot
               mapstr.show_spg=0

               	IF mapstr.totalplot THEN begin 

			mapstr.widgxsize=512 
			mapstr.widgysize=512
			mapstr.show_spg=0

		endif else begin !P.multi=0 
		endelse

              	IF mapstr.totalplot THEN $
                  widget_control,drawwidget,draw_xsize=mapstr.widgxsize*mapstr.ntime/2 $
				,draw_ysize=mapstr.widgysize*mapstr.nenergy/2 $
               ELSE $
                  widget_control,drawwidget,draw_xsize=mapstr.widgxsize $
				,draw_ysize=mapstr.widgysize

               widget_control,ev.top,/hourglass
               pg_imcube_spg_xrt_manip_plotmap,mapstr,drawwidget
               widget_control,ev.top,/hourglass


            END

            7 : BEGIN ; 'Color table'

                xloadct

            END

            8 : BEGIN ;'Zoom'

                mapstr.xrange=mapstr.selcoor[0:1]
                mapstr.yrange=mapstr.selcoor[2:3]
                pg_imcube_spg_xrt_manip_plotmap,mapstr,drawwidget

            END

            9 : BEGIN ;'Unzoom'

                map=*(mapstr.totmap)
                coor=[map.xc-map.dx*(size(map.data))[1]/2 $
                     ,map.xc+map.dx*(size(map.data))[1]/2 $
                     ,map.yc-map.dy*(size(map.data))[2]/2 $
                     ,map.yc+map.dy*(size(map.data))[2]/2 ]

                mapstr.xrange=coor[0:1]
                mapstr.yrange=coor[2:3]

                pg_imcube_spg_xrt_manip_plotmap,mapstr,drawwidget

             END

             10 : BEGIN ;'Fit position'

                roi=mapstr.selcoor

                widget_control,ev.top,sensitive=0
                pg_mapcfit,mapstr.imseq[*,mapstr.this_energy],x,y $
                          ,method=mapstr.fitmethod,roi=roi,/rdata
                widget_control,ev.top,sensitive=1

                fitposition=[ptr_new(x),ptr_new(y)]
                mapstr.fitpos=fitposition
                mapstr.plotfitpos=1

                pg_imcube_spg_xrt_manip_plotmap,mapstr,drawwidget

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

                pg_imcube_spg_xrt_manip_plotmap,mapstr,drawwidget


             END


             12 : BEGIN         ; 'Tie'

                mapstr.tied=1-mapstr.tied

             END

             13 : BEGIN         ; 'Overlap'

                mapstr.overlap=1-mapstr.overlap

             END


          14 : BEGIN ; 'zlog'

                mapstr.zlog=1-mapstr.zlog

             END
          15 : BEGIN ; 'Done'

		!P.multi=0
                widget_control,ev.top,/destroy

             END

            ELSE : RETURN

        ENDCASE


        IF   ev.value NE 15 $
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
                pg_imcube_spg_xrt_manip_plotbox,status.boxcoor,status.oldcoor,/nodraw $
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

                pg_imcube_spg_xrt_manip_plotbox,status.boxcoor,status.oldcoor,/noerase $
                                   ,sides=newsides
                status.first=0

            ENDIF $
            ELSE BEGIN

                pg_imcube_spg_xrt_manip_plotbox,status.boxcoor,status.oldcoor $
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
            widget_control,textwindow,set_value=pg_imcube_spg_xrt_manip_outtext(mapstr)


            pg_imcube_spg_xrt_manip_plotmap,mapstr,ev.id

        ENDIF

        widget_control,ev.id,set_uvalue=status

    END

    ELSE : print,'Ciao'

ENDCASE

END


;
;Main procedure
;
PRO pg_imcube_spg_xrt_manip,ptrimcube,spg=spg,xrtmap=xrtmap,ctstring=ctstring

ptr=ptrimcube
tot=n_elements(ptr)

pg_mapcfit,avmethods=fitmlist,/getmethods;list of possible fit methods

cont_lev_arr=ptrarr(5)
cont_lev_arr[0]=ptr_new([10.,20,30,40,50,60,70,80,90])
cont_lev_arr[1]=ptr_new([20.,40,60,80])
cont_lev_arr[2]=ptr_new([5.,10,15,20,30,50,70,90])
cont_lev_arr[3]=ptr_new([1.,2,5,10,20,50,90])
cont_lev_arr[4]=ptr_new([50,70,90])

cont_lev_str=strarr(5)
cont_lev_str[0]='10,20...80,90%'
cont_lev_str[1]='20,40...60,80%'
cont_lev_str[2]='5,10,15,20,30...90%'
cont_lev_str[3]='1,2,5,10,20,50,90%'
cont_lev_str[4]='50,70,90%'

fitcol=[0B,1,128,255]
fitcol_str=strarr(4)
fitcol_str[0]='0'
fitcol_str[1]='1'
fitcol_str[2]='128'
fitcol_str[3]='255'

plottimev=0
timev=0.
ytimev=0.


s=size(ptr,/dimension)
ntime=s[0]
nenergy=s[1]
ntimexrt=n_elements(xrtmap)

enframval=strarr(nenergy)
tframval=strarr(ntime)
xrttframval=strarr(ntimexrt)

alltime=dblarr(ntime)
alltimexrt=dblarr(ntimexrt)


FOR i=0,nenergy-1 DO $
   enframval[i]=strtrim(i,2)+' : '+ $
   strtrim(string((*ptr[0,i]).energy_intv[0],format='(f5.1)'),2)+' keV to '+ $
   strtrim(string((*ptr[0,i]).energy_intv[1],format='(f5.1)'),2)+' keV'

FOR i=0,ntime-1 DO begin 
   tframval[i]=strtrim(i,2)+' : '+ $
   anytim((*ptr[i,0]).time_intv[0],/vms,/time_only)+' to '+ $
   anytim((*ptr[i,0]).time_intv[1],/vms,/time_only)
   alltime[i]=0.5*(anytim((*ptr[i,0]).time_intv[0])+anytim((*ptr[i,0]).time_intv[1]))
endfor

FOR i=0,ntimexrt-1 DO begin 
   xrttframval[i]=strtrim(i,2)+' : '+ $
   anytim((*xrtmap[i]).time,/vms,/time_only)
   alltimexrt[i]=anytim((*xrtmap[i]).time)
endfor

ctstring=fcheck(ctstring,'')

mapstr={imseq:ptr,totmap:ptr_new(),minfr:0,maxfr:n_elements(ptr)-1 $
       ,selim:0,totim:1,contour:0,limb:1,selcoor:[0.,0.,0.,0.] $
       ,xrange:[0.,0.],yrange:[0.,0.] $
       ,showregion:1,fitmethod:'MAX',fitmlist:fitmlist $
       ,timev:timev,ytimev:ytimev,plottimev:plottimev $
       ,plotfitpos:0,fitpos:[ptr_new(),ptr_new()] $
       ,cont_lev_arr:cont_lev_arr,cont_lev:0,fitcol:fitcol $
       ,fitcol_sel:1,totalplot:0 $
       ,ntime:ntime,nenergy:nenergy,this_time:0,this_energy:0 $
       ,show_spg:0,spg:spg,widgxsize:512,widgysize:512,this_timexrt:0 $
       ,xrtim:xrtmap,tied:0,alltime:alltime,alltimexrt:alltimexrt,overlap:0 $
       ,zlog:0,xshift:0.,yshift:0.,ctstring:ctstring}


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
    values=['Show Spectrogram','Draw selected Image','Contour plot' $
           ,'Limb','Select region','Draw selected Region','Total plot' $
            ,'Color table','Zoom','Unzoom','Fit position','Plot fit pos' $
            ,'Tie','Overlap','Zlog','Done']
    uname='commands'
    bgroup=cw_bgroup(buttonm1,values,/column,uname=uname) ;,/frame)
;end buttons

;selection of current image
;
    sellab=widget_base(buttonm1,group_leader=buttonm1,/column)
    images=strtrim(string(indgen(tot)),2)

;    labelim=widget_label(sellab,value='Selected Frame')
;    selim=widget_list(sellab,value=images,ysize=10,uname='selectim')

    labellistfm=widget_label(sellab,value='Fit Method')
    selfitm=widget_droplist(sellab,value=fitmlist,uname='selectfitm')
    ;widget_control,selim,set_list_select=mapstr.selim

    labellistcl=widget_label(sellab,value='Contour Levels')
    selcontl=widget_droplist(sellab,value=cont_lev_str,uname='selectcl')

    labellistfitcol=widget_label(sellab,value='Fit Pos Color')
    selfitcol=widget_droplist(sellab,value=fitcol_str,uname='selectfitcol')


    shiftxsel=cw_field(sellab,value=0,/floating,uname='shiftxsel',/return_events,title='X SHIFT')
    shiftysel=cw_field(sellab,value=0,/floating,uname='shiftysel',/return_events,title='Y SHIFT')

;    labelcntcl=widget_label(sellab,value='Contour color')
;    selcontcl=widget_droplist(sellab,value=[,uname='selcntcl')


;end selection of current image

;selection of max and min
;
    selectframe=widget_base(menu1,group_leader=menu1,/row,/frame)

 


    minval=strarr(n_elements(ptr))
    FOR i=0,n_elements(ptr)-1 DO BEGIN
        minval[i]=strtrim(i,2)
    ENDFOR


    sellab1=widget_base(selectframe,group_leader=menu1,/column)
    label1=widget_label(sellab1,value='Time Interval RHESSI')
    select1=widget_list(sellab1,value=tframval,ysize=8,uname='selecttime')
    widget_control,select1,set_list_select=0

    sellab2=widget_base(selectframe,group_leader=menu1,/column)
    label2=widget_label(sellab2,value='Energy_interval')
    select2=widget_list(sellab2,value=enframval,ysize=8,uname='selectenergy')
    widget_control,select2,set_list_select=0

    sellab3=widget_base(selectframe,group_leader=menu1,/column)
    label3=widget_label(sellab3,value='Time Interval XRT')
    select3=widget_list(sellab3,value=xrttframval,ysize=8,uname='selecttimexrt')
    widget_control,select3,set_list_select=0


;end selection of max end min

;text widget
;
    text=widget_text(menu1,value=pg_imcube_spg_xrt_manip_outtext(mapstr),ysize=12 $
                    ,uname='frameinfo')
;end text widget

;draw widget
;
    draw=widget_draw(drawsurf1,xsize=mapstr.widgxsize,ysize=mapstr.widgysize $
		    ,uname='drawwin')

    draw2=widget_draw(drawsurf1,xsize=mapstr.widgxsize,ysize=mapstr.widgysize $
		    ,uname='drawwin2')


widget_control,root,set_uvalue=mapstr

widget_control,base,/realize

pg_imcube_spg_xrt_manip_plotmap,mapstr,draw
pg_imcube_spg_xrt_manip_plotmap2,mapstr,draw2


xmanager,'pg_imcube_spg_xrt_manip',root,/no_block

END












