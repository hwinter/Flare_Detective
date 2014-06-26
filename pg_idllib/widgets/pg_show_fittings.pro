;+
;
; NAME:
;        pg_show_fittings
;
; PURPOSE: 
;        widget interface for looking at a sries of fittings
;
; CALLING SEQUENCE:
;
;        pg_show_fittings,ptrflstr
;
; INPUTS:
;
;        ptrflstr: array of pointers to spex fitting results
;        structures (null pointers are allowed)
;
; KEYWORDS:
;        norebin: inhibits the rebinning at E>60
;
; OUTPUT:
;
;        none
;        
; EXAMPLE:
;
;        
;
; VERSION:
;
;        05-JAN-2004 written (based on imseq_manip) P.G.
;        06-JAN-2004 minor mods P.G.
;        06-JAN-2004 added 'flare overview' draw panel!
;        08-JAN-2004 added low enrgy cutoff
;        04-FEB-2004 added norebin /keyword
;        05-FEB-2004 added call to linecolor
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;-



;
;plot the spectrum and fittings on the screen, with the selected attributes
;
PRO pg_show_fittings_plotfit,infstr,drawwidget
oldp=!P

!P.MULTI=[0,1,1]

widget_control,drawwidget,get_value=window_id

oldwin=!window
wset,window_id

xrange=[3,300]
yrange=[1e-3,1e4]

IF infstr.ptrflstr[infstr.flare] NE ptr_new() THEN BEGIN
   IF infstr.norebin THEN $
      pg_plotspextrum, *infstr.ptrflstr[infstr.flare],n_spec=infstr.frame $
                     ,yrange=[1e-3,1e4],/ystyle, xrange=[3,300],/xstyle $
   ELSE $
     pg_plotspextrum, *infstr.ptrflstr[infstr.flare],n_spec=infstr.frame $
                   ,yrange=[1e-3,1e4],/ystyle, xrange=[3,300],/xstyle $
                   ,nrebin=5,erebin=60 
ENDIF $
ELSE BEGIN
   plot,xrange,[yrange[0],yrange[0]],/xstyle,/ystyle,/xlog,/ylog
   xyouts,5,1e-1,'No valid frame available',charsize=5,/data
ENDELSE    

wset,oldwin

!P=oldp


END


;
;plot the flare overview on the screen, with the selected attributes
;
PRO pg_show_fittings_plotoverview,infstr,drawwidget

oldp=!P

!P.MULTI=[0,1,2]

widget_control,drawwidget,get_value=window_id

oldwin=!window
wset,window_id

;xrange=[3,300]
yrange=[0,5]

IF infstr.ptrflstr[infstr.flare] NE ptr_new() THEN BEGIN
   sp_st=*infstr.ptrflstr[infstr.flare]
   time_arr=anytim(sp_st.date)+sp_st.xselect
   av_time_arr=anytim(sp_st.date)+0.5*(sp_st.xselect[0,*]+sp_st.xselect[1,*])
   yarray=sp_st.chi

   utplot,av_time_arr-av_time_arr[0],yarray,av_time_arr[0],/xstyle,/ystyle,yrange=yrange
   outplot,[time_arr[0,infstr.frame],time_arr[0,infstr.frame]]-av_time_arr[0] $
           ,[min(yrange),max(yrange)], av_time_arr[0] $
          ,color=12
   outplot,[time_arr[1,infstr.frame],time_arr[1,infstr.frame]]-av_time_arr[0] $
           ,[min(yrange),max(yrange)], av_time_arr[0] $
          ,color=12


   CASE infstr.type OF 
      'temp'     : yarray=sp_st.apar_arr[1,*]
      'em'       : yarray=sp_st.apar_arr[0,*]
      'flux35'   : yarray=(pg_apar2flux_fmultispec(sp_st,35.)).flux
      'spindex'  : yarray=sp_st.apar_arr[5,*]
      'ecut'     : yarray=sp_st.apar_arr[8,*]
         
      END 

   utplot,av_time_arr-av_time_arr[0],yarray,av_time_arr[0],/xstyle,/ystyle
   outplot,[time_arr[0,infstr.frame],time_arr[0,infstr.frame]]-av_time_arr[0] $
           ,!Y.crange, av_time_arr[0],color=12
   outplot,[time_arr[1,infstr.frame],time_arr[1,infstr.frame]]-av_time_arr[0] $
           ,!Y.crange, av_time_arr[0],color=12


ENDIF $
ELSE BEGIN
   plot,[0,1],[0,0],yrange=[0,1],/ystyle,/xstyle
   xyouts,0.1,0.4,'No valid frame available',charsize=3,/data

   plot,[0,1],[0,0],yrange=[0,1],/ystyle,/xstyle
   xyouts,0.1,0.4,'No valid frame available',charsize=3,/data

ENDELSE    

wset,oldwin

!P=oldp

END



;
;Returns the text to display as information in the text widget
;
FUNCTION pg_show_fittings_outtext,infstr

IF infstr.ptrflstr[infstr.flare] NE ptr_new() THEN BEGIN

   sp_st=*infstr.ptrflstr[infstr.flare]

   spindex  = sp_st.apar_arr[5,infstr.frame]
   norm     = sp_st.apar_arr[4,infstr.frame]
   epiv     = sp_st.epivot
   temp     = sp_st.apar_arr[1,infstr.frame]
   em       = sp_st.apar_arr[0,infstr.frame]
   ecut     = sp_st.apar_arr[8,infstr.frame]
   time_intv= anytim(sp_st.date)+sp_st.xselect[*,infstr.frame]

   temp=kev2kel(temp)*1e-6;convert in MegaKelvin


   outtext=['Flare number '+strtrim(string(infstr.flare),2) $
            ,'Frame number '+strtrim(string(infstr.frame),2),'                  ' + $
            '                          ' $
           ,'Time interval ',anytim(time_intv[0],/vms),anytim(time_intv[1],/vms) $
           ,'Photon Spectral Index: '+strtrim(string(spindex),2) $
           ,'Non-thermal flux at '+strtrim(string(epiv,format='(f5.1)'),2)+':' $
           + strtrim(string(norm),2) $
           ,'Temperature: '+strtrim(string(temp),2)+' MK' $
           ,'Emission Measure: '+strtrim(string(em),2)+ ' 10^49 cm-3'] 

ENDIF $
ELSE outtext=['Flare number '+strtrim(string(infstr.flare),2) $
             ,'No valid frame available']

RETURN,outtext

END


;
;Widget event handler
;
PRO pg_show_fittings_event,ev

widget_control,ev.handler,get_uvalue=infstr

CASE ev.ID OF 
    
    widget_info(ev.top,find_by_uname='selectflare') : BEGIN ;change flare number


       infstr.flare=ev.index

       framesel     = widget_info(ev.top,find_by_uname='selectframe')
       textwindow   = widget_info(ev.top,find_by_uname='frameinfo')
       drawwindow   = widget_info(ev.top,find_by_uname='drawwin')               
       overviewdraw = widget_info(ev.top,find_by_uname='overviewdraw')               

       IF infstr.ptrflstr[infstr.flare] NE ptr_new() THEN BEGIN

          nframes=(size((*infstr.ptrflstr[infstr.flare]).apar_arr))[2]
          infstr.frame=min([nframes-1,infstr.oldframe])
          ;print,infstr.frame
      
          pg_show_fittings_plotfit,infstr,drawwindow
          widget_control,textwindow,set_value=pg_show_fittings_outtext(infstr)
 
          frames=strtrim(string(indgen(nframes)),2)

          widget_control,framesel,set_value=frames
          widget_control,framesel,set_list_select=infstr.frame
    
          ;drawwindow=widget_info(ev.top,find_by_uname='drawwin')
          pg_show_fittings_plotfit,infstr,drawwindow
          pg_show_fittings_plotoverview,infstr,overviewdraw
 
 
       ENDIF $
       ELSE BEGIN

          widget_control,framesel,set_value='NONE AVAILABLE'
          widget_control,framesel,set_list_select=0
          widget_control,textwindow,set_value=pg_show_fittings_outtext(infstr)
          pg_show_fittings_plotfit,infstr,drawwindow
          pg_show_fittings_plotoverview,infstr,overviewdraw
 
       ENDELSE

       widget_control,ev.handler,set_uvalue=infstr

    END

    widget_info(ev.top,find_by_uname='selectframe') : BEGIN; change frame number


       infstr.frame=ev.index
       textwindow   = widget_info(ev.top,find_by_uname='frameinfo')
       drawwindow   = widget_info(ev.top,find_by_uname='drawwin')
       overviewdraw = widget_info(ev.top,find_by_uname='overviewdraw')               

       pg_show_fittings_plotfit,infstr,drawwindow
       pg_show_fittings_plotoverview,infstr,overviewdraw
 
       widget_control,textwindow,set_value=pg_show_fittings_outtext(infstr)
 
       IF infstr.ptrflstr[infstr.flare] NE ptr_new() THEN $
          infstr.oldframe=infstr.frame
       widget_control,ev.handler,set_uvalue=infstr

    END

    widget_info(ev.top,find_by_uname='buttons') : BEGIN ;a button has been pressed
       
       CASE ev.value OF

          0 : BEGIN             ;spectral index

             infstr.type='spindex'
                                          
          END
          
          1: BEGIN              ;flux35

             infstr.type='flux35'
                                          
          END

          2: BEGIN              ;temp

             infstr.type='temp'                 
                         
          END

          3: BEGIN              ;em

             infstr.type='em'
                                          
          END

          4: BEGIN              ;ecutoff

             infstr.type='ecut'
                                          
          END
         
          5: BEGIN              ;done
             
             widget_control,ev.top,/destroy
                         
          END

       ENDCASE 

       IF ev.value NE 5 THEN BEGIN
          overviewdraw = widget_info(ev.top,find_by_uname='overviewdraw')               
          pg_show_fittings_plotoverview,infstr,overviewdraw
          widget_control,ev.handler,set_uvalue=infstr
       ENDIF 


    END


 
    ELSE : print,'Ciao'

ENDCASE

END 



;
;Main procedure
;

PRO pg_show_fittings,ptrflstr,norebin=norebin


;oldp=!P

;!P.multi=[0,1,1]

;variable initialisation stuff
;

linecolors

nflares=n_elements(ptrflstr)
nframes=(size((*ptrflstr[0]).apar_arr))[2]
infstr={flare:0,frame:0,oldframe:0,ptrflstr:ptrflstr,type:'spindex' $
       ,norebin:keyword_set(norebin)}

;end variable init

;widget hierarchy creation
;
    base=widget_base(title='Fitting show widget',/row)
    root=widget_base(base,/row,uvalue=selstr,uname='root')
    
    menu1=widget_base(root,group_leader=root,/column,/frame)
    drawsurf1=widget_base(root,group_leader=root,/column)

;end widget hierarchy creation


;selection of current flare/frame
;

    selectsurf=widget_base(menu1,group_leader=menu1,/row);,/frame)

    selbasflare=widget_base(selectsurf,group_leader=menu1,/column)
    selbasframe=widget_base(selectsurf,group_leader=menu1,/column)
    flares=strtrim(string(indgen(nflares)),2)
    frames=strtrim(string(indgen(nframes)),2)
    labelflare=widget_label(selbasflare,value='  Selected Flare  ')
    labelframe=widget_label(selbasframe,value='  Selected Frame  ')
    selflare=widget_list(selbasflare,value=flares,ysize=10,uname='selectflare')
    selframe=widget_list(selbasframe,value=frames,ysize=10,uname='selectframe')
    widget_control,selflare,set_list_select=infstr.flare
    widget_control,selframe,set_list_select=infstr.frame
    
;end selection of current flare/frame

;text widget
;
    text=widget_text(menu1,value=pg_show_fittings_outtext(infstr),ysize=12 $
                    ,uname='frameinfo')
;end text widget

;buttons
;

    buttonm1=widget_base(menu1,group_leader=menu1,/row)

    values=['spindex','flux35','temp','em','ecutoff','Done']
    uname='commands'
    bgroup=cw_bgroup(buttonm1,values,/row,uname='buttons')
;end buttons

;draw widgets
;
    ;flare overview draw widget
    overviewdraw=widget_draw(menu1,xsize=480,ysize=640,uname='overviewdraw',/frame)
    
    ;spectrum draw widget
    draw=widget_draw(drawsurf1,xsize=900,ysize=900,uname='drawwin',/frame)
;end draw widget

widget_control,root,set_uvalue=infstr
  
widget_control,base,/realize

pg_show_fittings_plotfit,infstr,draw
pg_show_fittings_plotoverview,infstr,overviewdraw

xmanager,'pg_show_fittings',root,/no_block

;!P=oldp

END












