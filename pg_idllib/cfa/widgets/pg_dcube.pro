;+
; NAME:
;
; pg_dcube
;
; PURPOSE:
;
; Manipulates a data cube (optionally with time)
;
; CATEGORY:
;
; HINODE/XRT utils
;
; CALLING SEQUENCE:
;
; pg_dcube,dcube,time=time
;
; INPUTS:
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

;.comp pg_dcube.pro


;
;plot the map on the screen, with the selected attributes
;
PRO pg_dcube_plotim,mapstr,evtop,roi=roi

x=mapstr.x
y=mapstr.y

IF keyword_set(roi) THEN $
   plotimwidget=widget_info(evtop,find_by_uname='drawroi') $
ELSE $
   plotimwidget=widget_info(evtop,find_by_uname='drawim')


roixrange=mapstr.roicx+mapstr.roidx*[-1,1]
roiyrange=mapstr.roicy+mapstr.roidy*[-1,1]

mapnumber=mapstr.selim

IF   (mapnumber GE 0) OR (mapnumber LT mapstr.nim) $
THEN thismap=mapstr.imcube[*,*,mapnumber] $
ELSE RETURN

;IF mapstr.tiecolor THEN $
;   thismap=pg_rescale(thismap,method_number=mapstr.colscale,scale_gamma=mapstr.gamma,dmin=mapstr.dmin,dmax=mapstr.dmax) $
;ELSE $
 
thismap=pg_rescale(thismap,method_number=mapstr.colscale $
                   ,scale_gamma=mapstr.gamma,dmin=mapstr.dmin,dmax=mapstr.dmax) 
   


widget_control,plotimwidget,get_value=winmap
wset,winmap

IF keyword_set(roi) THEN BEGIN 
   xrange=roixrange
   yrange=roiyrange
ENDIF $
ELSE BEGIN
   xrange=[0,mapstr.nx-1]
   yrange=[0,mapstr.ny-1]
ENDELSE


pg_plotimage,thismap,x,y,xrange=xrange,yrange=yrange,/xstyle,/ystyle,/iso;,/no_rescale
;tvscl,thismap


tvlct,255,0,0,0
IF keyword_set(roi) THEN $
   oplot,mapstr.roicx+0.5*[-1,1,1,-1,-1],mapstr.roicy+0.5*[-1,-1,1,1,-1],color=0 $
ELSE $
   oplot,roixrange[[0,1,1,0,0]],roiyrange[[0,0,1,1,0]],color=0
tvlct,0,0,0,0


END


;
;plot the time evolution on the screen, with the selected attributes
;
PRO pg_dcube_plotlc,mapstr,evtop

drawwidget=widget_info(evtop,find_by_uname='drawlc')
widget_control,drawwidget,get_value=winmap
wset,winmap


t=mapstr.time
y=mapstr.imcube[mapstr.roicx,mapstr.roicy,*]

;minim=                          ;*mapstr.imseq[mapstr.minfr]
;   maxim=;*mapstr.imseq[mapstr.maxfr]
;   selim=mapstr.imseq[mapstr.selim]

;   totseltime=[anytim(minim.time),anytim(maxim.time)+maxim.dur]
;   seltime=[anytim(selim.time),anytim(selim.time)+selim.dur]

   
utplot,t-t[0],y,t[0],/xstyle,/nodata


yrange=!Y.crange
outplot,t[mapstr.selim]*[1,1]-t[0],yrange,t[0],linestyle=2
outplot,t-t[0],y,t[0]

IF mapstr.smooth NE 0 THEN BEGIN
   nn=mapstr.nim
   nwin=mapstr.smooth;24;12;64
   f=fft(y,-1)
   ff=f*0;f*
   ff[nwin/2:n_elements(y)-1-nwin/2]=f[nwin/2:n_elements(y)-1-nwin/2];f[0:nwin/2]
 ;  ff[n_elements(y)-1-nwin/2:n_elements(y)-1]=f[n_elements(y)-1-nwin/2:n_elements(y)-1]
 
   ys=abs(fft(ff,1));*sqrt(n_elements(y));+5
;   ys=ts_smooth(reform(y),mapstr.smooth)

   der=ys-shift(ys,1)

;   tvlct,255,255,0,0
   linecolors
   outplot,t-t[0],ys,t[0],color=5,thick=2
   ;outplot,t-t[0],10+der*6,t[0],color=12
   loadct,0
;   tvlct,0,0,0,0
ENDIF


IF mapstr.showpeak EQ 1 THEN BEGIN 

   print,'Show peak'

   res=pg_detectpeak(y,/peakinfo,confidence=0.95)
;;    indrise=where(res.rise EQ 1,crise)
;;    inddecay=where(res.decay EQ 1,cdecay)
;;    indpeak=where(res.peak EQ 1,cpeak)
;;    inddeep=where(res.deep EQ 1,cdeep)

;;    nondef=y*!values.f_nan
;;    lcrise=nondef
;;    IF crise GT 0 THEN lcrise[indrise]=y[indrise]
;;    lcdecay=nondef
;;    IF cdecay GT 0 THEN lcdecay[inddecay]=y[inddecay]
;;    lcpeak=nondef
;;    IF cpeak GT 0 THEN lcpeak[indpeak]=y[indpeak]
;;    lcdeep=nondef
;;    IF cdeep GT 0 THEN lcdeep[inddeep]=y[inddeep]

   linecolors

   FOR i=1,min([n_elements(res.allpeakstart),n_elements(res.allpeakend)])-1 DO BEGIN 
      outplot,t[res.allpeakstart[i]:res.allpeakend[i]]-t[0],y[res.allpeakstart[i]:res.allpeakend[i]],t[0],color=12
   ENDFOR

;   outplot,t-t[0],lcrise,t[0],color=2
;   outplot,t-t[0],lcdecay,t[0],color=10
;   pg_setplotsymbol,'CIRCLE'
;   outplot,t-t[0],lcpeak,t[0],color=12,psym=8
;   outplot,t-t[0],lcdeep,t[0],color=5,psym=8

   loadct,0


ENDIF

;stop
;test filtering....
fy=fft(reform(y),-1)
fy2=fy*0
df=6
fy2[1:df+1]=fy[1:df+1]
fy2[n_elements(fy)-1-df:n_elements(fy)-1]=fy[1:df+1]

fy[1:df+1]=0
fy[n_elements(fy)-1-df:n_elements(fy)-1]=0

ffy=reverse(fft(fy))*mapstr.nim;+1
ffy2=reverse(fft(fy2))*mapstr.nim;+1
linecolors
outplot,t-t[0],ffy,t[0],color=2
outplot,t-t[0],ffy2+10,t[0],color=5
loadct,0

 ;  outplot,totseltime[0]*[1,1]-t[0],yrange,t[0],linestyle=2
 ;  outplot,totseltime[1]*[1,1]-t[0],yrange,t[0],linestyle=2

 ;  IF mapstr.totim EQ 0 THEN BEGIN
 ;     outplot,seltime[0]*[1,1]-t[0],yrange,t[0],linestyle=1
 ;     outplot,seltime[1]*[1,1]-t[0],yrange,t[0],linestyle=1
 ;  ENDIF
  
END




;
;Returns the text to display as information in the text widget
;
FUNCTION pg_dcube_outtext,mapstr


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
         'Image size: '+strtrim(mapstr.nx,2)+' by '+strtrim(mapstr.ny,2)+' pixels', $;];, $
         'Pixel: '+strtrim(mapstr.roicx)+','+strtrim(mapstr.roicy)]
         ;$;'Pixel selection: '+strtrim(mapstr.selpix,2), $
         ;$;'Pixel selected: x:'+strtrim(mapstr.selpixcoor[0],2)+' y:'+strtrim(mapstr.selpixcoor[1],2), $
         ;$'Coordinate selection', $
         ;$'X: ('+strtrim(string(round(mapstr.selcoor[0])),2)+','  $
         ;$   +strtrim(string(round(mapstr.selcoor[2])),2)+')', $
         ;$'Y: ('+strtrim(string(round(mapstr.selcoor[1])),2)+',' $
         ;$   +strtrim(string(round(mapstr.selcoor[3])),2)+')']



;here add some catalog info

RETURN,outtext

END


PRO pg_dcube_update,mapstr,evtop

   pg_dcube_plotim,mapstr,evtop
   pg_dcube_plotim,mapstr,evtop,/roi
   pg_dcube_plotlc,mapstr,evtop

   textwidget=widget_info(evtop,find_by_uname='frameinfo') 
   widget_control,textwidget,set_value=pg_dcube_outtext(mapstr)
 
END


;
;Widget event handler
;
PRO pg_dcube_event,ev

widget_control,ev.handler,get_uvalue=mapstr

CASE ev.ID OF 
    
    widget_info(ev.top,find_by_uname='selectim') : BEGIN
        
       mapstr.selim=ev.index
       widget_control,ev.handler,set_uvalue=mapstr
       pg_dcube_update,mapstr,ev.top
              
    END


    widget_info(ev.top,find_by_uname='selcolor') : BEGIN

       ;print,'color is now '+string(ev.index)
       mapstr.colscale=ev.index
       widget_control,ev.handler,set_uvalue=mapstr
       pg_dcube_update,mapstr,ev.top

    END

    widget_info(ev.top,find_by_uname='mincolsel') : BEGIN

       mapstr.mincol=ev.value
       widget_control,ev.handler,set_uvalue=mapstr
       pg_dcube_update,mapstr,ev.top
                 
    END

    widget_info(ev.top,find_by_uname='gammasel') : BEGIN

       mapstr.gamma=ev.value
       widget_control,ev.handler,set_uvalue=mapstr
       pg_dcube_update,mapstr,ev.top
        
       
    END

    widget_info(ev.top,find_by_uname='smooth window') : BEGIN

       mapstr.smooth=ev.value
       widget_control,ev.handler,set_uvalue=mapstr
       pg_dcube_update,mapstr,ev.top
        
       
    END



    widget_info(ev.top,find_by_uname='maxcolsel') : BEGIN

       mapstr.maxcol=ev.value
       widget_control,ev.handler,set_uvalue=mapstr
       pg_dcube_update,mapstr,ev.top
        
       
    END
  


    widget_info(ev.top,find_by_uname='commands') : BEGIN

        drawwidget=widget_info(ev.top,find_by_uname='drawwin')
        drawtimewidget=widget_info(ev.top,find_by_uname='plotwin')
         
        CASE ev.value OF


            0 : BEGIN ;Draw selected Image

               pg_dcube_update,mapstr,ev.top 

           END
     
 
            4 : BEGIN ; 'Color table'

                xloadct

            END


 
 
 
   
 
             6 : BEGIN ; 'Show smoothing'

                IF mapstr.smooth EQ 0 THEN mapstr.smooth=20 ELSE mapstr.smooth=0
                widget_control,ev.handler,set_uvalue=mapstr  
                pg_dcube_update,mapstr,ev.top

            
             END


              8 : BEGIN ; 'Show peak'

                 print,'paolo'

                mapstr.showpeak=1-mapstr.showpeak
                widget_control,ev.handler,set_uvalue=mapstr  
                pg_dcube_update,mapstr,ev.top

            
             END


             7 : BEGIN          ; 'Done'

                widget_control,ev.top,/destroy
            
             END

             2 : BEGIN          ; 'Select Region'


                pg_dcube_plotim,mapstr,ev.top 
                !mouse.button=0
                WHILE (!mouse.button NE 1) DO BEGIN
                   cursor,x,y,/data,/down
                ENDWHILE
                
                mapstr.roicx=round(x)>0<(mapstr.nx-1)
                mapstr.roicy=round(y)>0<(mapstr.ny-1)

                widget_control,ev.handler,set_uvalue=mapstr  
                pg_dcube_update,mapstr,ev.top

             END

            1 : BEGIN          ; 'Select Pixel'


                pg_dcube_plotim,mapstr,ev.top,/roi
 
                !mouse.button=0
                WHILE (!mouse.button NE 1) DO BEGIN
                   cursor,x,y,/data,/down
                ENDWHILE
                
                mapstr.roicx=round(x)>0<(mapstr.nx-1)
                mapstr.roicy=round(y)>0<(mapstr.ny-1)

                widget_control,ev.handler,set_uvalue=mapstr  
                pg_dcube_update,mapstr,ev.top
                

             END


            ELSE : RETURN

        ENDCASE


        ;IF   ev.value NE 6 $
        ;THEN widget_control,ev.handler,set_uvalue=mapstr

     END

    ELSE : print,'Ciao'

 ENDCASE    



END 


;
;Main procedure
;
PRO pg_dcube,imcube,time=time

s=size(imcube)

IF s[0] NE 3 THEN BEGIN 
   print,'Invalid input. Need 3-dimensional image cube nx by ny by nimages.'
   RETURN
ENDIF

nx=s[1]
ny=s[2]
nim=s[3]

IF n_elements(time) NE nim THEN time=findgen(nim)

dmin=-0.35;min(imcube)
dmax=200;max(imcube)

;
;ptr is now guaranteed composed only of valid pointers
;

mapstr={imcube:imcube $;temporary(imcube) $;temporary(imcube) $
        ,time:time $
        ,nx:nx $
        ,ny:ny $
        ,dmin:dmin $
        ,dmax:dmax $
        ,x:findgen(nx) $
        ,y:findgen(ny) $
        ,nim:nim $
        ,roicx:nx/2 $
        ,roicy:ny/2 $
        ,roidx:32 $
        ,roidy:32 $
        ,selim:0 $
        ,colscale:1 $
        ,gamma:1. $
        ,mincol:0 $
        ,maxcol:4192 $
        ,tiecolor:1 $
        ,plotimxsize:512 $
        ,plotimysize:512 $
        ,zoomfactor:2 $
        ,smooth:0 $
        ,showpeak:0}



;
;end variable init

;widget hierarchy creation
;

    base=widget_base(title='Data Cube Manipulator',/row)
    root=widget_base(base,/row,uvalue=mapstr,uname='root')
    
    menu1=widget_base(root,group_leader=root,/column,/frame)
    drawsurf1=widget_base(root,group_leader=root,/column)
    drawsurf1a=widget_base(drawsurf1,group_leader=root,/row)
    drawsurf1b=widget_base(drawsurf1,group_leader=root,/row)

    buttonm1=widget_base(menu1,group_leader=menu1,/row,/frame)
;end widget hierarchy creation

;buttons
;
    values=['Draw selected Image','Select pixel', 'Select region','Draw selected Region', $
            'Color table','Col to min/max image','Show Smoothing','Done','Show peak']
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

    smoothwin=cw_field(sellab,value=mapstr.maxcol,uname='smooth window',/floating,/return_events $
                   ,title='smooth window')


;text widget
;
    text=widget_text(menu1,value=pg_dcube_outtext(mapstr),ysize=12 $
                    ,uname='frameinfo')
;end text widget

;draw widget
;
    drawim =widget_draw(drawsurf1a,xsize=600,ysize=600,uname='drawim')
    drawroi=widget_draw(drawsurf1a,xsize=600,ysize=600,uname='drawroi')
    drawlc =widget_draw(drawsurf1b,xsize=1200,ysize=800,uname='drawlc')
;    IF plottimev THEN $
;    draw2=widget_draw(drawsurf1,xsize=725,ysize=512,uname='timevwin')
;end draw widget


    status={selecting:0,thisroi:[0,0,0,0],oldroi:[0,0,0,0]}


    widget_control,drawim,set_uvalue=status


    
    widget_control,root,set_uvalue=mapstr
    
    widget_control,base,/realize

    widget_control,mincol,sensitive=1-mapstr.tiecolor
    widget_control,maxcol,sensitive=1-mapstr.tiecolor

    widget_control,coldlist,set_droplist_select=1

    pg_dcube_update,mapstr,base

    xmanager,'pg_dcube',root,/no_block


END












