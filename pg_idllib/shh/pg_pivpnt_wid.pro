;+
; NAME:
;
;        PG_PIVPNT_WID
;
; PURPOSE:
;
;        widget util to display flux versus gamma curves, and finding pivot points
;
; CATEGORY:
;
;        spectral evolution utils
;
; CALLING SEQUENCE:
;
;        pg_pivpnt_wid,flux,gamma,time=time,eref=eref
;
; INPUTS:
;
;        flux: array of fluxes
;        gamma: array of spectral indices
;
; OPTIONAL INPUTS:
;     
;        eref: reference energy (default 50 [keV])
;        time: time array
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
;-

;.comp pg_pivpnt_wid

PRO pg_pivpnt_wid_test


  restore,'~/work/shh_data/fitresults/corrected/newres_parab_basic_pileindx_03_intv_08.sav'

  time=newfitres.time
  flux=newfitres.fitpar[2,*]
  gamma=newfitres.fitpar[1,*]

  frange=[0.001,100]
  grange=[-10,-2]
  ;grange=[-20,-2]

;  n=100
;  flux=10^(findgen(n)/(n-1)*5)
;  gamma=-7+findgen(n)/(n-1)*5

  pg_pivpnt_wid,flux,gamma,time=time $
                 ,frange=frange,grange=grange;,trange=trange


END

;this plots gamma and flux as a function of time
PRO pg_pivpnt_wid_plotseq,udata,drawwidget

  widget_control,drawwidget,get_value=winmap

  wset,winmap

  t0=udata.t0

  fcol=2
  gcol=10

  timestring=anytim(t0,/date_only,/vms)

  ;print,timestring

  ;stop

  utplot,udata.time-t0,udata.flux,t0,/ylog,yrange=udata.frange $
        ,ytitle='Flux at 50 keV '+textoidl('(photons s^{-1} cm^{-2} keV^{-1})') $
         ,ystyle=8+1,timerange=udata.trange,/xstyle,xtitle=timestring $
         ,xmargin=[12,8],/nodata



  outplot,udata.time-t0,udata.flux,t0,color=fcol



  axis,/yaxis,max(udata.time)-t0,yrange=udata.grange,ylog=0,/save $
      ,ytitle='Spectral Index '+textoidl('\gamma'),/ystyle

  ;stop

  outplot,udata.time-t0,udata.gamma,t0,color=gcol

  IF udata.seltimeintv[0] GT 0 THEN BEGIN 
     outplot,udata.time[udata.seltimeindx[0]]*[1,1]-t0,!Y.crange,t0,color=5
     outplot,udata.time[udata.seltimeindx[1]]*[1,1]-t0,!Y.crange,t0,color=5
  ENDIF



END

;this plots flux vs. gamma
PRO pg_pivpnt_wid_plotfgamma,udata,drawwidget,plottrend=plottrend

  widget_control,drawwidget,get_value=winmap

  wset,winmap

  t0=udata.t0

  fcol=12
  gcol=10

  timestring=anytim(t0,/date_only,/vms)


  ;print,timestring

  ;stop

  pg_setplotsymbol,'CIRCLE',size=0.6

  plot,udata.flux,udata.gamma,xrange=udata.frange,yrange=udata.grange[[1,0]],/xlog,psym=-8

  IF udata.seltimeintv[0] GT 0 THEN BEGIN 
     indlist=lindgen(udata.seltimeindx[1]-udata.seltimeindx[0]+1)+udata.seltimeindx[0]

     ;print,indlist

     oplot,udata.flux[indlist],udata.gamma[indlist],psym=-8,color=2

  ENDIF

  IF keyword_set(plottrend) THEN BEGIN 
     
     as=udata.asixlin
     bs=udata.bsixlin

     xr=10^!X.crange
     yr=!Y.crange

     ;stop

     oplot,xr,alog(xr)*bs[0]+as[0],color=12
     oplot,xr,alog(xr)*bs[1]+as[1],color=12
     oplot,xr,alog(xr)*bs[2]+as[2],color=12,linestyle=2


  ENDIF


END


PRO pg_pivpnt_wid_event,ev

  widget_control,ev.handler,get_uvalue=udata

  ;print,'An event occurred!'



  CASE ev.ID OF    

     widget_info(ev.top,find_by_uname='pg_pivpnt_wid_commands') : BEGIN

 
        CASE ev.value OF



           0 : BEGIN;plot fgamma         

              drawwidget=widget_info(ev.top,find_by_uname='pg_pivpnt_wid_drawsp1')
              pg_pivpnt_wid_plotfgamma,udata,drawwidget

           END


           1 : BEGIN;plot timeseq

              drawwidget=widget_info(ev.top,find_by_uname='pg_pivpnt_wid_drawsp2')
              pg_pivpnt_wid_plotseq,udata,drawwidget      

              ptim,udata.seltimeintv
 

           END
           
           2 : BEGIN            ; select interval 

     
              udata.seltimeintv=[-1d,-1]
              udata.seltimeindx=[-1L,-1]
              widget_control,ev.handler,set_uvalue=udata

              drawwidget=widget_info(ev.top,find_by_uname='pg_pivpnt_wid_drawsp2')
              pg_pivpnt_wid_plotseq,udata,drawwidget       


              print,'Now selecting '

              selstr={t1:-1,t2:-1}

              widget_control,drawwidget,set_uvalue=selstr
 
              ;mouse selecting etc...
 

              widget_control,drawwidget,/draw_button_events
              ;widget_control,drawwidget,/draw_motion_events


             

           END


           3 : BEGIN ; unselect 

              print,'unselect' 
              udata.seltimeintv=[-1d,-1]
              udata.seltimeindx=[-1L,-1]

              widget_control,ev.handler,set_uvalue=udata

              drawwidget=widget_info(ev.top,find_by_uname='pg_pivpnt_wid_drawsp1')
              pg_pivpnt_wid_plotfgamma,udata,drawwidget
              drawwidget=widget_info(ev.top,find_by_uname='pg_pivpnt_wid_drawsp2')
              pg_pivpnt_wid_plotseq,udata,drawwidget      


           END

           4 : BEGIN ; find pivot

              print,'Find pivot...' 


              IF udata.seltimeintv[0] GT 0 THEN BEGIN 

                 indlist=lindgen(udata.seltimeindx[1]-udata.seltimeindx[0]+1) $
                         +udata.seltimeindx[0]
                 
                 xx=alog(udata.flux[indlist])
                 yy=udata.gamma[indlist]

                 sixlin,xx,yy,a,siga,b,sigb

                 a=a[0:2]
                 b=b[0:2]

                 udata.asixlin=a
                 udata.bsixlin=b

                 widget_control,ev.handler,set_uvalue=udata

                 print,'Intercept',string(a)
                 print,'Slope',string(b)

                 epiv=50*exp(-1/b)
                 fpiv=exp(-a/b)

                 print,'EPIV'
                 print,epiv
                 print,' '

                 print,'FPIV'
                 print,fpiv
                 print,' '

                 print,'INDEX'
                 print,udata.seltimeindx

                 drawwidget=widget_info(ev.top,find_by_uname='pg_pivpnt_wid_drawsp1')
                 pg_pivpnt_wid_plotfgamma,udata,drawwidget,/plottrend
       
              ENDIF ELSE BEGIN 

                 print,'select an interval first!'

              ENDELSE 



           END

           5 : BEGIN ; DONE 

              print,'done' 
              widget_control,ev.top,/destroy       

           END

           ELSE: print,'Error: unexpected button event'

        ENDCASE

     END

   ;min delta changes
    widget_info(ev.top,find_by_uname='mingamma') : BEGIN

       print,'new min delta'+string(ev.value)

       udata.grange[0]=ev.value
       widget_control,ev.handler,set_uvalue=udata

       drawwidget=widget_info(ev.top,find_by_uname='pg_pivpnt_wid_drawsp1')
       pg_pivpnt_wid_plotfgamma,udata,drawwidget
       drawwidget=widget_info(ev.top,find_by_uname='pg_pivpnt_wid_drawsp2')
       pg_pivpnt_wid_plotseq,udata,drawwidget      

 
    END

   ;max delta changes
    widget_info(ev.top,find_by_uname='maxgamma') : BEGIN

       print,'new max delta'+string(ev.value)

       udata.grange[1]=ev.value
       widget_control,ev.handler,set_uvalue=udata

       drawwidget=widget_info(ev.top,find_by_uname='pg_pivpnt_wid_drawsp1')
       pg_pivpnt_wid_plotfgamma,udata,drawwidget
       drawwidget=widget_info(ev.top,find_by_uname='pg_pivpnt_wid_drawsp2')
       pg_pivpnt_wid_plotseq,udata,drawwidget      

 
    END

   ;min flux changes
    widget_info(ev.top,find_by_uname='minflux') : BEGIN

       print,'new min delta'+string(ev.value)

       udata.frange[0]=ev.value
       widget_control,ev.handler,set_uvalue=udata

       drawwidget=widget_info(ev.top,find_by_uname='pg_pivpnt_wid_drawsp1')
       pg_pivpnt_wid_plotfgamma,udata,drawwidget
       drawwidget=widget_info(ev.top,find_by_uname='pg_pivpnt_wid_drawsp2')
       pg_pivpnt_wid_plotseq,udata,drawwidget      

 
    END

   ;max flux changes
    widget_info(ev.top,find_by_uname='maxflux') : BEGIN

       print,'new max flux'+string(ev.value)

       udata.frange[1]=ev.value
       widget_control,ev.handler,set_uvalue=udata

       drawwidget=widget_info(ev.top,find_by_uname='pg_pivpnt_wid_drawsp1')
       pg_pivpnt_wid_plotfgamma,udata,drawwidget
       drawwidget=widget_info(ev.top,find_by_uname='pg_pivpnt_wid_drawsp2')
       pg_pivpnt_wid_plotseq,udata,drawwidget      

 
    END

   ;min indx changes
    widget_info(ev.top,find_by_uname='minindx') : BEGIN

       print,'new min indx'+string(ev.value)

       udata.seltimeindx[0]=ev.value
       udata.seltimeintv[0]=udata.time[ev.value]

       widget_control,ev.handler,set_uvalue=udata

       drawwidget=widget_info(ev.top,find_by_uname='pg_pivpnt_wid_drawsp1')
       pg_pivpnt_wid_plotfgamma,udata,drawwidget
       drawwidget=widget_info(ev.top,find_by_uname='pg_pivpnt_wid_drawsp2')
       pg_pivpnt_wid_plotseq,udata,drawwidget      

 
    END

    ;max indx changes
    widget_info(ev.top,find_by_uname='maxindx') : BEGIN

       print,'new max indx'+string(ev.value)

       udata.seltimeindx[1]=ev.value
       udata.seltimeintv[1]=udata.time[ev.value]

       widget_control,ev.handler,set_uvalue=udata

       drawwidget=widget_info(ev.top,find_by_uname='pg_pivpnt_wid_drawsp1')
       pg_pivpnt_wid_plotfgamma,udata,drawwidget
       drawwidget=widget_info(ev.top,find_by_uname='pg_pivpnt_wid_drawsp2')
       pg_pivpnt_wid_plotseq,udata,drawwidget      

 
    END



     widget_info(ev.top,find_by_uname='pg_pivpnt_wid_drawsp2') : BEGIN

        ;print,'new event drawsp2'


        drawwidget=widget_info(ev.top,find_by_uname='pg_pivpnt_wid_drawsp2')
        widget_control,drawwidget,get_uvalue=selstr,get_value=plotwin
        wset,plotwin
   
        widget_control,ev.handler,get_uvalue=udata
   
        IF ev.press EQ 1 THEN BEGIN

           ;print,'Pressed',string(ev.x),string(ev.y)

           IF selstr.t1 LT 0 THEN BEGIN 
              selstr.t1=ev.x       

              widget_control,drawwidget,set_uvalue=selstr
 
              x1=(convert_coord(ev.x,1.,/to_data,/device))[0]
    
              ;ptim,x1+udata.t0

              oplot,x1*[1,1],!y.crange,color=5

           ENDIF ELSE BEGIN 

              IF selstr.t2 LT 0 THEN BEGIN 
              
                 selstr.t2=ev.x             
                 x2=(convert_coord(ev.x,1.,/to_data,/device))[0]
                 oplot,x2*[1,1],!y.crange,color=5
                 widget_control,drawwidget,set_uvalue=selstr

                 widget_control,drawwidget,draw_button_events=0
                 seltimeintv=udata.t0+[(convert_coord(selstr.t1,1.,/to_data,/device))[0], $
                                       (convert_coord(selstr.t2,1.,/to_data,/device))[0]]

                 IF seltimeintv[0] GT seltimeintv[1] THEN seltimeintv=seltimeintv[[1,0]]

                 udata.seltimeintv=seltimeintv

                 stindx=value_locate(udata.time,udata.seltimeintv)

                 udata.seltimeindx=stindx

                 widget_control,ev.handler,set_uvalue=udata
                 minindx=widget_info(ev.top,find_by_uname='minindx')
                 widget_control,minindx,set_value=udata.seltimeindx[0]
                 maxindx=widget_info(ev.top,find_by_uname='maxindx')
                 widget_control,maxindx,set_value=udata.seltimeindx[1]
 

                 
                 drawwidget=widget_info(ev.top,find_by_uname='pg_pivpnt_wid_drawsp1')
                 pg_pivpnt_wid_plotfgamma,udata,drawwidget
                 drawwidget=widget_info(ev.top,find_by_uname='pg_pivpnt_wid_drawsp2')
                 pg_pivpnt_wid_plotseq,udata,drawwidget      


              ENDIF ELSE BEGIN
                 
                 print,'last click, done!'
 
              ENDELSE
 
           ENDELSE
     
        ENDIF

     END


     ELSE: print,-1 


  ENDCASE


END


PRO pg_pivpnt_wid,flux,gamma,time=time,eref=eref $
                 ,frange=frange,grange=grange,trange=trange

  n1=n_elements(flux)
  n2=n_elements(gamma)

  n=min([n1,n2])

  IF n LT 2 THEN BEGIN 
     print,'Error! Please input two arrays with at least two elemnts each!'
     RETURN
  ENDIF

  linecolors
  
  eref=fcheck(eref,50)

  time=fcheck(time,findgen(n))

  frange=fcheck(frange,[min(flux),max(flux)])
  grange=fcheck(grange,[min(gamma),max(gamma)])
  trange=fcheck(trange,[min(time),max(time)])

  dnan=!values.d_nan


  udata={flux:flux $
        ,gamma:gamma $
        ,eref:eref $
        ,n:n $
        ,time:time $
        ,t0:min(time) $
        ,frange:frange $
        ,grange:grange $
        ,trange:trange $
        ,seltimeintv:[-1d,-1] $
        ,seltimeindx:[-1L,-1] $
        ,asixlin:replicate(dnan,3) $
        ,bsixlin:replicate(dnan,3)}


;widget hierarchy creation

  base=widget_base(title='Pivot point finder widget',/row,uname='pg_pivpnt_wid_base')
  root=widget_base(base,/row,uvalue=udata,uname='pg_pivpnt_wid_root')
    
  menu1=widget_base(root,group_leader=root,/column,uname='pg_pivpnt_wid_menu1')
;  menu2=widget_base(menu1,group_leader=menu1,/row,uname='pg_pivpnt_wid_menu2')

  drawsurf1=widget_base(root,group_leader=root,/column,uname='pg_pivpnt_wid_drawsurf1')

  buttonm1=widget_base(menu1,group_leader=menu1,/row)
  buttonm2=widget_base(menu1,group_leader=menu1,/column)
    
  mingamma=cw_field(menu1,value=udata.grange[0],/floating,uname='mingamma',/return_events,title='Min gamma')
  maxgamma=cw_field(menu1,value=udata.grange[1],/floating,uname='maxgamma',/return_events,title='Max gamma')
  minflux=cw_field(menu1,value=udata.frange[0],/floating,uname='minflux',/return_events,title='Min flux')
  maxflux=cw_field(menu1,value=udata.frange[1],/floating,uname='maxflux',/return_events,title='Max flux')

  minindx=cw_field(menu1,value=udata.seltimeindx[0],/floating,uname='minindx',/return_events,title='Min sel Index')
  maxindx=cw_field(menu1,value=udata.seltimeindx[1],/floating,uname='maxindx',/return_events,title='Max sel Index')



;end widget hierarchy creation

;buttons

    values=['Plot fgamma','Plot time','Select Intv','Unselect','Find Pivot','Done']

    uname='pg_pivpnt_wid_commands'
    bgroup=cw_bgroup(buttonm1,values,/column,uname=uname)

;end buttons




;drawbase=widget_base(drawsurf1,group_leader=drawsurf1,/row)
 
drawsp1=widget_draw(drawsurf1,xsize=800,ysize=600,uname='pg_pivpnt_wid_drawsp1')
drawsp2=widget_draw(drawsurf1,xsize=800,ysize=400,uname='pg_pivpnt_wid_drawsp2')

widget_control,root,set_uvalue=mydata
  
widget_control,base,/realize

drawwidget=widget_info(root,find_by_uname='pg_pivpnt_wid_drawsp1')
pg_pivpnt_wid_plotfgamma,udata,drawwidget
drawwidget=widget_info(root,find_by_uname='pg_pivpnt_wid_drawsp2')
pg_pivpnt_wid_plotseq,udata,drawwidget      

;drawwidget=widget_info(ev.top,find_by_uname='pg_pivpnt_wid_drawsp')
;widget_control,drawsp,get_value=plotwin
;wset,plotwin
                
;pg_wid_fitsp_plot,mydata

;linecolors
;pg_fitres_browser_doallplots,base,mydata
;widget_control,root,set_uvalue=mydata

;   xmanager,'pg_wid_fitsp',root,/no_block

xmanager,'pg_pivpnt_wid',root,/no_block



END

