;+
;
; NAME:
;        pg_reswidget
;
; PURPOSE: 
;        widget interface for looking (performing?) numerical
;        computations of time dependent 1-dimensional phenomena
;
; CALLING SEQUENCE:
;
;        pg_reswidget,diagnosticarray
;
; INPUTS:
;
;        diagnosticarray: array of structures with the time evolution
;
; OUTPUT:
;        
; EXAMPLE:
;
;        
;
; VERSION:
;
;           SEP/OCT 2005 written PG
;        
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-


;
;plot selected results
;
PRO pg_reswidget_plot,status,drawwidget;spectrum

   

   widget_control,drawwidget,get_value=winmap

   wset,winmap

   
   IF status.xrebplot EQ ptr_new() THEN BEGIN 
      y=status.yplotarr[*,status.time_index]
      x=status.xplot
      nsum=status.nsum
   ENDIF $
   ELSE BEGIN 
      ;stop
      y=(*status.yrebplotarr)[*,status.time_index]
      x=*status.xrebplot
      nsum=1
   ENDELSE

   tagex=tag_exist(status.da.simpar,'TAUESCAPE')
   IF tagex THEN $
      escapedpart=pg_getescaped_part(status.da.energy,status.da.grid[*,status.time_index] $
                                    ,status.da.simpar)


   plot,x,y,/xlog,/ylog,yrange=status.yrange,xrange=status.xrange,nsum=nsum,/xstyle $
        ,psym=-6,title='time '+strtrim(string(status.da.iter[status.time_index]),2)
   oplot,10^status.da[0].ytherm*[1,1],10^!Y.crange,linestyle=1
   oplot,x,status.simpar.density*pg_maxwellian(x,status.da.etherm),color=12,thick=2,nsum=nsum 

   IF tagex THEN $
     oplot,status.da.energy,escapedpart,color=5,thick=2


   IF status.plotdelta THEN BEGIN 
      oplot,status.xrange,exp(double(status.normalization)>(-300.)<300.)* $
                          exp(double(alog(status.xrange)*status.delta)>(-300.)<300.) $
           ,linestyle=2,color=2,thick=2
      oplot,status.emin*[1,1],status.yrange,linestyle=1,color=9
      oplot,status.emax*[1,1],status.yrange,linestyle=1,color=9
   ENDIF

   ;plot escaped population??
   

END



;
;compute & plot photon spectrum
;
PRO pg_reswidget_plotphotons,status,drawwidget

  
   widget_control,drawwidget,get_value=winmap

   wset,winmap


   IF status.plotphotons NE 1 THEN RETURN 
      
   ;stop
   
;    c=3d10;speed of light

      y=status.yplotarr[*,status.time_index]
      x=status.xplot

;    y2=1d10*pg_maxwellian(x,status.da.etherm)


      mc2=511.;electron rest mass, in keV

      N=100
      eph=10^(dindgen(N)/(N-1)*4-1)
      ele=x*mc2
      elsp=y
      ;elflux2=y2*pg_getbeta(x)*c

;    ind=where(ele GT 1. AND ele LT 1d5,count)
;    IF count EQ 0 THEN BEGIN
;       print,'Warning! Bad input electron energy! No photon plot possible'
;       RETURN
;    ENDIF

;    ele=ele[ind]
;    elfluxsp=elfluxsp[ind]
;    elflux2=elflux2[ind]

;    print,'Now computing photon spectrum...'
;    photspectrum=pg_el2phot_thin(elsp=elfluxsp,ele=ele,phe=eph)
;    photspectrum2=pg_el2phot_thin(elsp=elflux2,ele=ele,phe=eph)
;    print,'Done'

     print,'Now computing photon spectrum: Thin target'
     ind=where(ele GT 0.1 AND ele LT 1d6)
     photspectrum=pg_el2phot_thin(elsp=elsp[ind],ele=ele[ind],phe=eph,/eldensity)
;    photspectrum=pg_el2phot_thin(elsp=elsp,ele=ele,phe=eph,/eldensity)
;    photspectrum2=pg_el2phot_thin(elsp=elflux2,ele=ele,phe=eph)
     print,'Done'
     print,'Now computing photon spectrum: Thick target'
     ind=where(ele GT 0.1 AND ele LT 1d6)
     photspectrum2=pg_el2phot_thick(elsp=elsp[ind],ele=ele[ind],phe=eph,/eldensity)
;    photspectrum=pg_el2phot_thin(elsp=elsp,ele=ele,phe=eph,/eldensity)
;    photspectrum2=pg_el2phot_thin(elsp=elflux2,ele=ele,phe=eph)
     print,'Done'

     ;max=max(photspectrum)
     ;stop

     plot,eph,photspectrum,/xlog,/ylog,xrange=[0.1,1000],/xstyle,yrange=[1d-8,1d8];,psym=-4 ;max*[1d-15,1]
     oplot,eph,photspectrum2,color=12
     ;oplot,511.*status.emin*[1,1],10^!y.crange,linestyle=1
     ;oplot,511.*status.emax*[1,1],10^!y.crange,linestyle=1
     ;oplot,eph,photspectrum2,color=12,thick=2

END

PRO pg_reswidget_plottimev,status,drawwidget;timev

   widget_control,drawwidget,get_value=winmap

   wset,winmap


;   y=status.da.diagnostic[*].grid[180]
   y=-status.alldeltas
   IF status.plotpartnumber THEN BEGIN 
      y=abs(status.da.partnumber-status.da.partnumber[0])/status.da.partnumber
   ENDIF

   x=status.da.tottime

   yrange=[20,0.5]
   ylog=1
   IF status.plotpartnumber THEN BEGIN 
      yrange=[1d-9,1d-2]
      ylog=1
   ENDIF

   ;print,min(y),max(y)

   plot,1+x,y,yrange=yrange,ylog=ylog,/xlog,psym=-3,/ystyle
   oplot,1+x[status.time_index]*[1,1],y[status.time_index]*[1,1],psym=6,color=8,thick=2

;,/xlog,/ylog;, $
        ;,psym=-6,title='time '+strtrim(string(status.da[status.time_index].iter),2)
   ;oplot,10^status.da[0].ytherm*[1,1],10^!Y.crange,linestyle=1
   ;oplot,x,1d10*pg_maxwellian(x,status.da[0].etherm),color=12,thick=1

   ;plot,1+x,y,/xlog,/ylog,yrange=yrange,/ystyle;,title=string((randomn(seed,1))[0])

END

;
;text output with summary info
;
FUNCTION pg_reswidget_outtext,status

IF status.computedelta THEN BEGIN
   deltabit=['Spectral index: '+string(status.delta),' ']
ENDIF ELSE deltabit=' '

eref=511.

;change to automatic important pars in sim!!!

outtext=['ITERATION #: '+string(status.da.iter[status.time_index]), $
        'TIME elapsed:'+string(status.da.tottime[status.time_index]*status.da.th), $
        deltabit, $
        '-------------------------------------------------', $
        'MODEL PARAMETERS:', $
        'MODEL is '+status.da.accelerationtype, $
        '- START TEMP: '+string(kev2kel(10d^status.da.ytherm*eref)*1d-6)]

;         '- c*<k>/Omega_H: '+string(status.da.avckomega), $
;         '- U_T/U_B: '+string(status.da.utdivbyub), $
;         'ESCAPE TYPE: '+status.da.escapetype, $
;         '- TAU ESCAPE: '+string(status.da.tauescape), $
;         '- START TEMP: '+string(kev2kel(10d^status.da.ytherm*eref)*1d-6), $
;         '', $
;         '-------------------------------------------------',$
;         'PARS FOR NEW SIMULATION', $
;         '- # ITER'+string(status.newsim_iterations), $
;         '- c*<k>/Omega_H: '+string(status.newsim_ckomega), $
;         '- U_T/U_B: '+string(status.newsim_utdivbyub), $
;         '- TAU ESCAPE: '+string(status.newsim_tauescape), $
;         '- START TEMP: '+string(kev2kel(10d^status.newsim_ytherm*eref)*1d-6), $
;         '-------------------------------------------------']

tagnames=tag_names(status.simpar)

FOR i=0,n_elements(tagnames)-1 DO $
    outtext=[outtext,tagnames[i]+string(status.simpar.(i))]


RETURN,outtext

END


;
;compute spectral index in the selected energy range
;
PRO  pg_reswidget_computedelta,status

IF NOT finite(status.alldeltas[status.time_index]) THEN BEGIN 

   emin=status.emin
   emax=status.emax

   x=status.da.energy
   y=status.da.grid[*,status.time_index]

   ind=where((x GE emin) AND (x LE emax),count)
   IF count GT 0 THEN res=linfit(alog(x[ind]),alog(y[ind])) ELSE res=[0.,0.]
   status.allnormals[status.time_index]=res[0]
   status.alldeltas[status.time_index]=res[1]
   
ENDIF ELSE BEGIN 

res=[status.allnormals[status.time_index],status.alldeltas[status.time_index]]
ENDELSE


status.delta=res[1]
status.normalization=res[0]

END


;
;Widget event handler
;
PRO pg_reswidget_event,ev

widget_control,ev.handler,get_uvalue=status

drawwidget1=widget_info(ev.top,find_by_uname='drawplot')
drawwidget2=widget_info(ev.top,find_by_uname='drawplot2')

CASE ev.ID OF
 
;main button group
    widget_info(ev.top,find_by_uname='commands') : BEGIN


        CASE ev.value OF

            0 : BEGIN ;Draw total Image
                 
               pg_reswidget_plot,status,drawwidget1
                
            END

            1 : BEGIN ;Draw total Image
                 
               pg_reswidget_plottimev,status,drawwidget2
                
            END


            2 : BEGIN ; 'compute spectral index'

                status.computedelta=1-status.computedelta
                pg_reswidget_computedelta,status
                widget_control,ev.handler,set_uvalue=status
                textwindow=widget_info(ev.top,find_by_uname='frameinfo')
                widget_control,textwindow,set_value=pg_reswidget_outtext(status)
 
            END

            3 : BEGIN ; 'plot spectral index'

                status.plotpartnumber=0
                status.plotdelta=1-status.plotdelta
                status.computedelta=1  
                pg_reswidget_computedelta,status
                widget_control,ev.handler,set_uvalue=status
                pg_reswidget_plot,status,drawwidget1
 
            END

            4 : BEGIN ; 'compute new sim'

                print,'Should start sim'
                print,'iter:'+string(status.newsim_iterations)
                
                ;stop

;                 x=status.da.energy
;                 maxwgrid=1d10*pg_maxwellian(x,status.da.etherm)

;                 pg_cn_millerfix,startdist=maxwgrid,ygrid=alog10(x),ytherm=status.da.ytherm $
;                                ,niter=status.newsim_iterations $
;                                ,lastdist=outdist1,diagnostic=outda,tauescape=status.newsim_tauescape $ 
;                                ,xrange=[1d-4,1d2],yrange=[1d0,1d15],dt=10.,maxwsrctemp=status.da.ytherm $
;                                ,avckomega=status.newsim_ckomega,utdivbyub=status.newsim_utdivbyub $
;                                ,/relescape,simpar=simpar ;,/noplot


;                 eref=511.
;                 status={da:outda, $
;                         time_index:0, $
;                         time:0, $
;                         xrange:status.xrange, $
;                         yrange:status.yrange, $
;                         computedelta:0, $
;                         plotdelta:0, $
;                         delta:1., $
;                         alldeltas:replicate(!values.f_nan,n_elements(outda.diagnostic)), $
;                         allnormals:replicate(!values.f_nan,n_elements(outda.diagnostic)), $
;                         normalization:0., $
;                         eref:eref, $
;                         erefunit:'keV', $
;                         emin:30./eref, $
;                         emax:150./eref, $
;                         newsim_ckomega:1., $
;                         newsim_utdivbyub:0.004, $
;                         newsim_tauescape:0.05, $
;                         newsim_iterations:100000L, $
;                         newsim_ytherm:-3d, $
;                         simpar:simpar}


;                 widget_control,ev.handler,set_uvalue=status
                

;                 selim=widget_info(ev.top,find_by_uname='selectim')
;                 widget_control,selim,set_value=string(outda.diagnostic.iter),set_list_select=0

;                 drawwidget=widget_info(ev.top,find_by_uname='drawplot')
;                 drawwidget2=widget_info(ev.top,find_by_uname='drawplot2')
;                 pg_reswidget_plot,status,drawwidget
;                 pg_reswidget_plottimev,status,drawwidget2
                
;                 textwindow=widget_info(ev.top,find_by_uname='frameinfo')
;                 widget_control,textwindow,set_value=pg_reswidget_outtext(status)

 
            END

            5 : BEGIN ; 'save sim'

                print,'SAVE SIM -- NOT IMPLEMENTED YET'
                ;pg_savesim,status.da,/verbose
            
            END

            6 : BEGIN ; 'part number plot'

                status.plotdelta=0
                status.plotpartnumber=1              
                widget_control,ev.handler,set_uvalue=status
                pg_reswidget_plottimev,status,drawwidget2;,/partnumber

 
            END

            7 : BEGIN ; 'REBIN plot'

                nsum=status.nsum
                el=n_elements(status.xplot)
                ;stop
                status.xrebplot=ptr_new(rebin(status.xplot[0:el/nsum*nsum-1],el/nsum))
                status.yrebplotarr=ptr_new(rebin(status.yplotarr[0:el/nsum*nsum-1,*],el/nsum,(size(status.yplotarr))[2]))
                widget_control,ev.handler,set_uvalue=status
            
            END

            8 : BEGIN ; 'plot photons'

                print,'photons plot!'
                status.plotphotons=1-status.plotphotons
                widget_control,ev.handler,set_uvalue=status
                pg_reswidget_plotphotons,status,drawwidget2 
      
            END

            9 : BEGIN ; 'Done'

                widget_control,ev.top,/destroy
            
            END

            ELSE : RETURN

        ENDCASE


;        IF   ev.value NE 10 $
;        THEN widget_control,ev.handler,set_uvalue=spgstr

    END

;select time 
    widget_info(ev.top,find_by_uname='selectim') : BEGIN

       status.time_index=ev.index
       IF status.computedelta EQ 1 THEN pg_reswidget_computedelta,status
       widget_control,ev.handler,set_uvalue=status 
       ;drawwidget=widget_info(ev.top,find_by_uname='drawplot')
       ;drawwidget2=widget_info(ev.top,find_by_uname='drawplot2')
       pg_reswidget_plot,status,drawwidget1
       IF status.plotphotons THEN $
          pg_reswidget_plotphotons,status,drawwidget2 ELSE $
          pg_reswidget_plottimev,status,drawwidget2
  
       textwindow=widget_info(ev.top,find_by_uname='frameinfo')
       widget_control,textwindow,set_value=pg_reswidget_outtext(status)
  

    END

    widget_info(ev.top,find_by_uname='X MIN') : BEGIN
       
       status.xrange[0]=ev.value
       widget_control,ev.handler,set_uvalue=status 
       pg_reswidget_plot,status,drawwidget1
 
    END

    widget_info(ev.top,find_by_uname='X MAX') : BEGIN
       
       status.xrange[1]=ev.value
       widget_control,ev.handler,set_uvalue=status 
       pg_reswidget_plot,status,drawwidget1
 
    END

    widget_info(ev.top,find_by_uname='Y MIN') : BEGIN
       
       status.yrange[0]=ev.value
       widget_control,ev.handler,set_uvalue=status 
       pg_reswidget_plot,status,drawwidget1
 
    END

    widget_info(ev.top,find_by_uname='Y MAX') : BEGIN
       
       status.yrange[1]=ev.value
       widget_control,ev.handler,set_uvalue=status 
       pg_reswidget_plot,status,drawwidget1
 
    END



    ELSE: BEGIN 
       FOR i=0,n_elements(status.simpar.parvalues)-1 DO BEGIN
          IF ev.id EQ widget_info(ev.top,find_by_uname=status.simpar.parnames[i]) THEN BEGIN 
             status.simpar.parvalues[i]=ev.value 
             widget_control,ev.handler,set_uvalue=status 
             textwindow=widget_info(ev.top,find_by_uname='frameinfo')
             widget_control,textwindow,set_value=pg_reswidget_outtext(status)
          ENDIF
       ENDFOR
    ENDELSE 


    ELSE : print,'Ciao'


ENDCASE

END 



;
;Main procedure
;
PRO pg_reswidget,da
;da is the diagnosticarray

linecolors

;variable initialisation stuff
;

IF NOT exist(da) THEN BEGIN
   print,'Please input a diagnostic array'
   RETURN
ENDIF 


;startpar=[1e-2,1.5,1e5,4,1,1,50,0]

eref=511.
status={da:da, $
        time_index:0, $
        time:0, $
        xrange:[1d-6,1d], $
        yrange:[1,1d15], $
        nsum:round(n_elements(da.energy)/1000.)>1, $
        computedelta:0, $
        plotdelta:0, $
        plotpartnumber:0, $
        delta:1., $
        alldeltas:replicate(!values.f_nan,n_elements(da.iter)), $
        allnormals:replicate(!values.f_nan,n_elements(da.iter)), $
        normalization:0., $
        eref:eref, $
        erefunit:'keV', $
        emin:20./eref, $
        emax:100./eref, $
        newsim_ckomega:1., $
        newsim_utdivbyub:0.004, $
        newsim_tauescape:0.05, $
        newsim_iterations:100000L, $
        newsim_ytherm:-3., $
        simpar:da.simpar, $
        xplot:da.energy, $
        yplotarr:da.grid, $
        xrebplot:ptr_new(), $
        yrebplotarr:ptr_new(), $
        plotphotons:0B}


;end variable init

;widget hierarchy creation
;
    base=widget_base(title='Numerical result inspector',/row,uname='base_widget')
    root=widget_base(base,/row,uvalue=status,uname='root')
    
    menu1=widget_base(root,group_leader=root,/column,/frame,uname='menu1')
    drawsurf1=widget_base(root,group_leader=root,/column,uname='drawsurf1')
    buttonm1=widget_base(menu1,group_leader=menu1,/row);,/frame)
    ;buttonm2=widget_base(buttonm1,group_leader=menu1,/row,/frame)
    ;buttonm3=widget_base(menu1,group_leader=menu1,/row,/frame)
    

;end widget hierarchy creation

;buttons
;
    values=['PLOT 1',  ' PLOT TIMEV  ','Compute SPECTRAL INDEX', 'PLOT spectral index', $
            'compute new sim','Save new sim','Part Number plot','rebin plot', $
            'plot photons','Done']

    uname='commands'
    bgroup=cw_bgroup(buttonm1,values,/column,uname=uname)

                
;end buttons

;time frames 
    ntimes=n_elements(da)
    sellab=widget_base(buttonm1,group_leader=menu1,/column,/frame)
;    images=strtrim(string(indgen(ntimes)),2)

    tframes=string(da.iter)

    labelim=widget_label(sellab,value='Selected Time')
    selim=widget_list(sellab,value=tframes,ysize=10,uname='selectim')
;end time frames

;plot properties
    selplot=widget_base(buttonm1,group_leader=menu1,/column)
    
    b1=cw_field(selplot,value=status.xrange[0],title='X MIN' $
                    ,uname='X MIN',/return_events)
    b2=cw_field(selplot,value=status.xrange[1],title='X MAX' $
                    ,uname='X MAX',/return_events)
    b3=cw_field(selplot,value=status.yrange[0],title='Y MIN' $
                    ,uname='Y MIN',/return_events)
    b4=cw_field(selplot,value=status.yrange[1],title='Y MAX' $
                    ,uname='Y MAX',/return_events)

;end plot properties

;text widget
;
    text=widget_text(menu1,value=pg_reswidget_outtext(status) $
                     ,ysize=30,xsize=55,uname='frameinfo')

;end text widget

;values fields...
;

    tagnames=tag_names(da.simpar)
    FOR i=0,n_elements(tagnames)-1 DO BEGIN 
       dummy=cw_field(menu1,value=da.simpar.(i),title=tagnames[i] $
                    ,uname=tagnames[i],/return_events,/long)
    ENDFOR


;     iteration=cw_field(menu1,value=status.newsim_iterations,title='Iterations ' $
;                     ,uname='iter',/return_events,/long)
;     ckomega=cw_field(menu1,value=status.newsim_ckomega,title='c<k>/Omega ' $
;                     ,uname='ckomega',/return_events,/floating)
;     utdivbyub=cw_field(menu1,value=status.newsim_utdivbyub,title='U_T/U_B    ' $
;                     ,uname='utdivbyub',/return_events,/floating)
;     tauescape=cw_field(menu1,value=status.newsim_tauescape,title='TAU ESCAPE ' $
;                     ,uname='tauescape',/return_events,/floating)
;     starttemp=cw_field(menu1,value=kev2kel((10d^status.newsim_ytherm)*eref)*1d-6,title='START TEMP ' $
;                     ,uname='starttemp',/return_events,/floating)

;end values

;draw widgets
;
    draw=widget_draw(drawsurf1,xsize=640,ysize=460,uname='drawplot')    
    draw2=widget_draw(drawsurf1,xsize=640,ysize=460,uname='drawplot2')    

                 
;end draw widget


widget_control,root,set_uvalue=spgstr
  
widget_control,base,/realize

pg_reswidget_plot,status,draw


xmanager,'pg_reswidget',root,/no_block

END












