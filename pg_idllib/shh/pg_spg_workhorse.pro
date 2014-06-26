;+
;
; NAME:
;        workspg2
;
; PURPOSE: 
;        widget interface for spectrogram manipolation
;
; CALLING SEQUENCE:
;
;        workspg2,spg=spg,scspg=scspg
;
; INPUTS:
;
;        spg: a spectrogram
;        scspg: semical spectrogram
;
; OUTPUT:
;        
; EXAMPLE:
;
;        
;
; VERSION:
;
;           JUL-2003 written
;        
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-


;.comp ~/work/sizespin/workspg2.pro
;loadct,5
;time=anytim('01-JAN-2003')+10*findgen(100)
;y=findgen(100)+1
;im=dist(100)
;spg={spectrogram:im,x:time,y:y}
;spectro_plot,im,time,y,/ystyle,/ylog,/no_interp
;spg_examiner,spg=spg,scspg=scspg



;
;plot the spectrogram on the screen, with the selected attributes,
;using spectro_plot
;
PRO spg_workhorse_plotspg,spgstr=spgstr,drawwidget


IF spgstr.needupdate EQ 1 THEN BEGIN 

    spgstr.needupdate=0

    IF spgstr.background EQ 1 THEN BEGIN

        aspg=hsi_background_subtract(spg=spgstr.spg $
                                           ,timerange=spgstr.backtime)
    ENDIF $
    ELSE BEGIN

        aspg= spgstr.spg

    ENDELSE

    IF spgstr.integrated EQ 1 THEN BEGIN        

        aspg=spg_integrate(aspg,xint=spgstr.xint,yint=spgstr.yint) 
        
    ENDIF

     aspgstr={aspg:aspg}
     spgstr=join_struct(aspgstr,spgstr)

ENDIF

spg=spgstr.aspg

widget_control,drawwidget,get_value=winmap

wset,winmap

spectro_plot,spg.spectrogram>0,spg.x,spg.y,ylog=spgstr.ylog,zlog=spgstr.zlog,/xstyle,/ystyle,xrange=spgstr.xrange,yrange=spgstr.yrange,no_interp=1-spgstr.interp

IF spgstr.showregion EQ 1 THEN BEGIN
    coor=spgstr.selcoor
    oplot,[coor[0],coor[1],coor[1],coor[0],coor[0]]-getutbase() $
         ,[coor[2],coor[2],coor[3],coor[3],coor[2]]
ENDIF

spgstr.xpar=!X
spgstr.ypar=!Y
  
END


PRO spg_workhorse_plotspectrum,spgstr,tindex,fitfun=fitfun,spectrum=spectrum $
                             ,title=title,oplotfit=oplotfit
  spg=spgstr.aspg
  ytitle='Counts'

    IF NOT exist(spectrum) THEN BEGIN
        spectrum=spg.spectrogram[tindex,*]
    ENDIF
    IF NOT exist(title) THEN title='Spectrum at '+anytim(spg.x[tindex],/vms)

    plot,spg.y,spectrum,/ylog,/xlog $
        ,xrange=spgstr.yrange,xstyle=1,ystyle=1 $
        ,title=title $
        ,ytitle=ytitle,yrange=[spgstr.minspy,spgstr.maxspy] $
        ,position=[0.125,0.05,0.975,0.95]


    IF keyword_set(oplotfit) THEN BEGIN
        tvlct,r,g,b,/get
        linecolors
        ;oplot,spg.y,fittedfun,color=12
        oplot,spg.y,fitfun,color=12
        oplot,spg.y,thermal_tpow(spg.y,[spgstr.fitpar[0],spgstr.fitpar[1],0,0,0,0,0,0],/noline),color=7
        ;oplot,spg.y,fittedfun[1,*],color=4                
        tvlct,r,g,b

    ENDIF

END

;
;This procedure draws and/or erase a rectangular frame on the current
;graphic window (taken as is from imseq_manip.pro)
;
PRO spg_workhorse_plotbox,newcoor,oldcoor,sides=sides,noerase=noerase $
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
FUNCTION spg_workhorse_outtext,spgstr

startime=anytim(spgstr.aspg.x[0],/vms)
endtime =anytim(spgstr.aspg.x[n_elements(spgstr.aspg.x)-1],/vms)



outtext=['Shown time intv : '+startime+' - '+endtime,'' $
        ,'Background state '+strtrim(string(spgstr.background)),'' $
        ,'Last fit parameters: ','EM : '+strtrim(string(spgstr.fitpar[0]),2) $
        ,'Temperature    : '+strtrim(string(spgstr.fitpar[1]),2) $
        ,'Spectral Index : '+strtrim(string(spgstr.fitpar[3]),2) $
        ,'Fitting from '+strtrim(string(spgstr.minfitv),2)+' to ' $
        +strtrim(string(spgstr.maxfitv),2),'' $
        ,'Startfitpar '+string(spgstr.startpar)]

IF spgstr.background EQ 1 THEN $
  outtext=[outtext,'',anytim(spgstr.backtime[0],/vms)+' - '+anytim(spgstr.backtime[1],/vms)]
    

RETURN,outtext

END

;fitting
FUNCTION spg_workhorse_fit,spgstr,time,een=een,yy=yy,eerrors=eerrors

IF exist(time) THEN BEGIN
    xtime=spgstr.ascspg.x 
    tmpvar=min(abs(xtime-time),tindex)
ENDIF

;startpar=[1e-2,1.5,1e5,4,1,1,50,0]
startpar=spgstr.startpar

;startpar=spgstr.fitpar
;startpar=[1d-2,1,0.01,5,0,0]
parinfo=replicate({value:0.D, fixed:0, limited:[0,0], $
                                  limits:[0.D,0]}, 8)
parinfo[*].value=startpar
parinfo[4:5].fixed=1.
parinfo[7].fixed=1.
parinfo[0:3].limited=[1,1]
parinfo[6].limited=[1,1]
parinfo[0].limits=[0d,1d3]
parinfo[1].limits=[0.6,10.]
parinfo[2].limits=[1d-30,1d+30]
parinfo[3].limits=[2,10]
parinfo[6].limits=[15,200]

IF NOT keyword_set(een) THEN $
een=spgstr.ascspg.y
IF NOT keyword_set(yy) THEN $
yy=transpose(spgstr.ascspg.spectrogram[tindex[0],*])
IF NOT keyword_set(eerrors) THEN $
eerrors=spgstr.ascspg.espectrogram[tindex[0],*]

ind=where((een GE spgstr.minfitv) AND (een LE spgstr.maxfitv),count)

IF count GT 0 THEN BEGIN
    y=yy[ind]
    en=een[ind]
    errors=eerrors[ind]
ENDIF $
ELSE  BEGIN
y=yy
en=een
errors=eerrors
ENDELSE

;wdef,1
;plot,en,y,/xlog,/ylog

ind=where(y LE 0.,count)
IF count GT 0 THEN BEGIN
    y[ind]=max(y)
    y[ind]=min(y)
ENDIF

;errors=spgstr.ascspg.espectrogram[tindex[0],*]
ind=where(errors LE 0.,count)
IF count GT 0 THEN BEGIN
    errors[ind]=max(errors)
    errors[ind]=min(errors)
ENDIF


;en2=transpose([[en-0.5],[en+0.5]])

;functargs={noline:1}

;par=mpfitfun('thermal_tpow',en,y,errors,parinfo=parinfo $
;            ,functargs=functargs)

functargs={noline:1,log:1}
par=mpfitfun('thermal_tpow',en,alog(y),errors/y,parinfo=parinfo $
            ,functargs=functargs)

;par=mpfitfun('f_vth_bpow',en2,y,replicate(1,n_elements(y)),parinfo=parinfo)


fittedfun=thermal_tpow(een,par,/noline)
;fittedfun2=thermal_tpow(en,par2,/noline)

fitpar={par:par,fun:fittedfun}

;RETURN,transpose([[fittedfun],[fittedfun2]])
RETURN,fitpar
END


;
;Widget event handler
;
PRO pg_spg_workhorse_event,ev

widget_control,ev.handler,get_uvalue=spgstr

CASE ev.ID OF
 
    ;second button group
    widget_info(ev.top,find_by_uname='commands2') : BEGIN

        drawwidget=widget_info(ev.top,find_by_uname='drawwin')
     

        CASE ev.value OF

            0 : BEGIN ;unused
               
                dummy=0
            
            END

            1 : BEGIN ;background select

                ;drawwidget=widget_info(ev.top,find_by_uname='drawwin')

                IF spgstr.background EQ 1 THEN BEGIN
                    spgstr.background=0
                    spgstr.needupdate=1
                ENDIF
 
                spg_workhorse_plotspg,spgstr=spgstr,drawwidget
                
                textwindow=widget_info(ev.top,find_by_uname='frameinfo')
                widget_control,textwindow $
                              ,set_value=spg_workhorse_outtext(spgstr)

 
                status={operation:'bgselect',coor:[0d,0d],x:!X,y:!Y,clicks:0.}

                widget_control,drawwidget,set_uvalue=status

                ;makes the widget sensitive to mouse input events
                widget_control,drawwidget,/draw_button_events
                ;widget_control,drawwidget,/draw_motion_events
                
            END

            2 : BEGIN ;clear background

                ;drawwidget=widget_info(ev.top,find_by_uname='drawwin')
                                
                IF spgstr.background EQ 1 THEN BEGIN
                    spgstr.background=0
                    spgstr.needupdate=1
                ENDIF

                spg_workhorse_plotspg,spgstr=spgstr,drawwidget

                textwindow=widget_info(ev.top,find_by_uname='frameinfo')
                widget_control,textwindow $
                              ,set_value=spg_workhorse_outtext(spgstr)

 
            END

            3 : BEGIN ;clear integration


                askxint=widget_info(ev.top,find_by_uname='askxint')
                askyint=widget_info(ev.top,find_by_uname='askyint') 
          
                widget_control,askxint,set_value=1
                widget_control,askyint,set_value=1


                spgstr.needupdate=1
                spgstr.integrated=0
                spgstr.xint=0
                spgstr.yint=0
 
                spg_workhorse_plotspg,spgstr=spgstr,drawwidget

               

            END

            4 : BEGIN ;fitting

                spgstr.fit=1-spgstr.fit

            END

            5: BEGIN ;fit max spectrum

                IF spgstr.background EQ 1 THEN BEGIN

                    spg=hsi_background_subtract(spg=spgstr.scspg $
                                           ,timerange=spgstr.backtime)
        
                ENDIF ELSE $
                    spg=spgstr.scspg
                
                ind=where((spg.y GE spgstr.fitmaxspband[0]) AND $
                          (spg.y LE spgstr.fitmaxspband[1]),count)

                IF count GT 0 THEN $
                    lightcurve=total(spg.spectrogram[*,ind],2) $
                ELSE $
                    lightcurve=total(spg.spectrogram[*,*],2)

                maxflux=max(lightcurve,maxind)
                maxtime=spg.x[maxind[0]]

                time_intv=[maxtime-0.5*spgstr.fitmaxdeltatime $
                          ,maxtime+0.5*spgstr.fitmaxdeltatime]

                time_ind=where((spg.x GE time_intv[0]) AND $
                               (spg.x LE time_intv[1]),count)

                IF count GT 0 THEN BEGIN
                    spectrum=total(spg.spectrogram[time_ind,*],1) $
                             /n_elements(time_ind)
                    espectrum=sqrt(total(spg.espectrogram[time_ind,*] $
                                 *spg.espectrogram[time_ind,*],1)) $
                             /n_elements(time_ind)
                ENDIF $
                ELSE BEGIN
                    print,'Error in selecting time interval' 
                    spectrum=spg.spectrogram[maxind[0],*]
                ENDELSE

                fitpar=spg_workhorse_fit(spgstr,een=spg.y,eerrors=espectrum $
                                       ,yy=spectrum)

                spgstr.fitmaxfitpar=fitpar.par
                spgstr.fitmaxtime_intv=time_intv

                oldfitpar=spgstr.fitpar
                spgstr.fitpar=fitpar.par

                spg_workhorse_plotspectrum,spgstr,fitfun=fitpar.fun $
                ,spectrum=spectrum,title= anytim(time_intv[0],/vms)+ $
                ' - '+ anytim(time_intv[1],/vms),oplotfit=1

                widget_control,ev.handler,set_uvalue=spgstr

                
            END

            6 : BEGIN ; set fit start par guesses

                startpar=spgstr.startpar
                uvalue={startpar:startpar,widgetid1: ev.handler}
                                                    ;,widgetid2:ev.top}
                
                basesetfitpar=widget_base(title='Set start fit guesses' $
                             ,group_leader=ev.handler,/column,uname='basesetfitpar')

                rootsetfitpar=widget_base(basesetfitpar,/column $
                             ,uvalue=uvalue,uname='rootsetfitpar')

                
                a0=cw_field(rootsetfitpar,value=startpar[0],title='EM    ' $
                                ,uname='a0',/return_events,/float)
                a1=cw_field(rootsetfitpar,value=startpar[1],title='TEMP  ' $
                                ,uname='a1',/return_events,/float)
                a2=cw_field(rootsetfitpar,value=startpar[2],title='A2    ' $
                                ,uname='a2',/return_events,/float)
                a3=cw_field(rootsetfitpar,value=startpar[3],title='GAMMA ' $
                                ,uname='a3',/return_events,/float)
                
                a4=cw_field(rootsetfitpar,value=startpar[0],title='A4    ' $
                                ,uname='a4',/return_events,/float)
                a5=cw_field(rootsetfitpar,value=startpar[1],title='A5    ' $
                                ,uname='a5',/return_events,/float)
                a6=cw_field(rootsetfitpar,value=startpar[2],title='A6    ' $
                                ,uname='a6',/return_events,/float)
                a7=cw_field(rootsetfitpar,value=startpar[3],title='A&    ' $
                                ,uname='a7',/return_events,/float)

                donebut=cw_bgroup(rootsetfitpar,['Reset','Done'],/column $
                                 ,uname='donebut')


                widget_control,basesetfitpar,/realize

                xmanager,'spg_workhorse',basesetfitpar,/no_block

            END

            7 : BEGIN ;save max fit par

                maxfitpar=spgstr.fitpar
                str={maxfitpar:maxfitpar,time:spgstr.spg.x[0]}

                mwrfits,str,spgstr.fitmaxsavefile

            END
            

            ELSE : print,'Ciao'
            

        ENDCASE
    
        widget_control,ev.handler,set_uvalue=spgstr

    END
  

    widget_info(ev.top,find_by_uname='donebut') : BEGIN

        CASE ev.value OF 

            0: BEGIN

                ;print,'Reset button pressed'
                aaa=widget_info(ev.handler,find_by_uname='rootsetfitpar')
                widget_control,aaa,get_uvalue=uvalue
                uvalue.startpar=[1e-2,1.5,1e5,4,1,1,50,0]
                widget_control,aaa,set_uvalue=uvalue

                widget_control,widget_info(ev.top,find_by_uname='a0') $
                                       ,set_value=uvalue.startpar[0]
                widget_control,widget_info(ev.top,find_by_uname='a1') $
                                       ,set_value=uvalue.startpar[1]
                widget_control,widget_info(ev.top,find_by_uname='a2') $
                                       ,set_value=uvalue.startpar[2]
                widget_control,widget_info(ev.top,find_by_uname='a3') $
                                       ,set_value=uvalue.startpar[3]
                widget_control,widget_info(ev.top,find_by_uname='a4') $
                                       ,set_value=uvalue.startpar[4]
                widget_control,widget_info(ev.top,find_by_uname='a5') $
                                       ,set_value=uvalue.startpar[5]
                widget_control,widget_info(ev.top,find_by_uname='a6') $
                                       ,set_value=uvalue.startpar[6]
                widget_control,widget_info(ev.top,find_by_uname='a7') $
                                       ,set_value=uvalue.startpar[7]

            END


            1: BEGIN

                ;print,'Done button pressed'
                aaa=widget_info(ev.handler,find_by_uname='rootsetfitpar')
                widget_control,aaa,get_uvalue=uvalue
                widget_control,uvalue.widgetid1,get_uvalue=spgstr
                spgstr.startpar=uvalue.startpar
                widget_control,uvalue.widgetid1,set_uvalue=spgstr
                widget_control,ev.top,/destroy
            END

        ENDCASE

    END

    widget_info(ev.top,find_by_uname='a0') : BEGIN

        aaa=widget_info(ev.handler,find_by_uname='rootsetfitpar')
        widget_control,aaa,get_uvalue=uvalue
        uvalue.startpar[0]=ev.value
        widget_control,aaa,set_uvalue=uvalue

    END
    
    widget_info(ev.top,find_by_uname='a1') : BEGIN

        aaa=widget_info(ev.handler,find_by_uname='rootsetfitpar')
        widget_control,aaa,get_uvalue=uvalue
        uvalue.startpar[1]=ev.value
        widget_control,aaa,set_uvalue=uvalue

    END

    widget_info(ev.top,find_by_uname='a2') : BEGIN

        aaa=widget_info(ev.handler,find_by_uname='rootsetfitpar')
        widget_control,aaa,get_uvalue=uvalue
        uvalue.startpar[2]=ev.value
        widget_control,aaa,set_uvalue=uvalue

    END
    
    widget_info(ev.top,find_by_uname='a3') : BEGIN

        aaa=widget_info(ev.handler,find_by_uname='rootsetfitpar')
        widget_control,aaa,get_uvalue=uvalue
        uvalue.startpar[3]=ev.value
        widget_control,aaa,set_uvalue=uvalue

    END

    widget_info(ev.top,find_by_uname='a4') : BEGIN

        aaa=widget_info(ev.handler,find_by_uname='rootsetfitpar')
        widget_control,aaa,get_uvalue=uvalue
        uvalue.startpar[4]=ev.value
        widget_control,aaa,set_uvalue=uvalue

    END
    
    widget_info(ev.top,find_by_uname='a5') : BEGIN

        aaa=widget_info(ev.handler,find_by_uname='rootsetfitpar')
        widget_control,aaa,get_uvalue=uvalue
        uvalue.startpar[5]=ev.value
        widget_control,aaa,set_uvalue=uvalue

    END

     widget_info(ev.top,find_by_uname='a6') : BEGIN

        aaa=widget_info(ev.handler,find_by_uname='rootsetfitpar')
        widget_control,aaa,get_uvalue=uvalue
        uvalue.startpar[6]=ev.value
        widget_control,aaa,set_uvalue=uvalue

    END
    
    widget_info(ev.top,find_by_uname='a7') : BEGIN

        aaa=widget_info(ev.handler,find_by_uname='rootsetfitpar')
        widget_control,aaa,get_uvalue=uvalue
        uvalue.startpar[7]=ev.value
        widget_control,aaa,set_uvalue=uvalue

    END
      

;second button group
    widget_info(ev.top,find_by_uname='commands') : BEGIN

        drawwidget=widget_info(ev.top,find_by_uname='drawwin')

        CASE ev.value OF

            0 : BEGIN ;Draw total Image
                 
                spg_workhorse_plotspg,spgstr=spgstr,drawwidget
                
            END

            1 : BEGIN ;toggle ylog

                spgstr.ylog=1-spgstr.ylog

                spg_workhorse_plotspg,spgstr=spgstr,drawwidget                


           END

            2 : BEGIN ;toggle zlog
 
                spgstr.zlog=1-spgstr.zlog

                spg_workhorse_plotspg,spgstr=spgstr,drawwidget                
       
            END

            3 : BEGIN ;interpolation
 
                spgstr.interp=1-spgstr.interp

                spg_workhorse_plotspg,spgstr=spgstr,drawwidget                
       
            END


            5 : BEGIN ;Select region

                spg_workhorse_plotspg,spgstr=spgstr,drawwidget

                status={operation:'select',dragging:0,first:0,last:0 $
                       ,oldcoor:[0.,0.,0.,0.] $
                       ,boxcoor:[0.,0.,0.,0.],sides:ptrarr(4) $
                       ,outcoor:[0.,0.,0.,0.],maxx:0.,maxy:0.}

                geom=widget_info(drawwidget,/geometry)
                status.maxx=geom.draw_xsize-1
                status.maxy=geom.draw_ysize-1

                widget_control,drawwidget,set_uvalue=status

                ;makes the widget sensitive to mouse input events
                widget_control,drawwidget,/draw_button_events
                widget_control,drawwidget,/draw_motion_events

               
            END


            4 : BEGIN ; 'Color table'

                xloadct

            END


            6 : BEGIN ;'Zoom'

                spgstr.xrange=spgstr.selcoor[0:1]
                spgstr.yrange=spgstr.selcoor[2:3]

                ;ptim,spgstr.xrange
                ;print,spgstr.yrange

                spg_workhorse_plotspg,spgstr=spgstr,drawwidget                               
            END

            7 : BEGIN ;'Unzoom'

                spg=spgstr.spg
                coor=[min(spg.x),max(spg.x),min(spg.y),max(spg.y)]

                spgstr.xrange=coor[0:1]
                spgstr.yrange=coor[2:3]
          
                spg_workhorse_plotspg,spgstr=spgstr,drawwidget



            END


            8 : BEGIN ;'X slice'
                               
                spg_workhorse_plotspg,spgstr=spgstr,drawwidget

                status={operation:'xslice',coor:[0d,0d]};,x:!X,y:!Y}

                widget_control,drawwidget,set_uvalue=status

                ;makes the widget sensitive to mouse input events
                widget_control,drawwidget,/draw_button_events
                                    
            END

            9 : BEGIN ;'Y slice'
                               
                spg_workhorse_plotspg,spgstr=spgstr,drawwidget

                status={operation:'yslice',coor:[0d,0d]};,x:!X,y:!Y}

                widget_control,drawwidget,set_uvalue=status

                ;makes the widget sensitive to mouse input events
                widget_control,drawwidget,/draw_button_events
                                       
            END


            10 : BEGIN ; 'Done'

                widget_control,ev.top,/destroy
            
            END

            ELSE : RETURN

        ENDCASE


        IF   ev.value NE 10 $
        THEN widget_control,ev.handler,set_uvalue=spgstr

    END



;change min value fit

    widget_info(ev.top,find_by_uname='minfitv') : BEGIN


        IF ev.value GE min(spgstr.spg.y) THEN $
          spgstr.minfitv=ev.value $
        ELSE BEGIN

            spgstr.minfitv=min(spgstr.spg.y)
            minfitwid=widget_info(ev.top,find_by_uname='minfitv')
            widget_control,minfitwid,set_value=min(spgstr.spg.y)

        ENDELSE
        widget_control,ev.handler,set_uvalue=spgstr
       
    END
 
;change max value fit

    widget_info(ev.top,find_by_uname='maxfitv') : BEGIN

       IF ev.value LT max(spgstr.spg.y) THEN $
          spgstr.maxfitv=ev.value $
        ELSE BEGIN

            spgstr.maxfitv=max(spgstr.spg.y)
            maxfitwid=widget_info(ev.top,find_by_uname='maxfitv')
            widget_control,maxfitwid,set_value=max(spgstr.spg.y)

        ENDELSE
        widget_control,ev.handler,set_uvalue=spgstr
       
    END
 

;change spectrum plot y range

    widget_info(ev.top,find_by_uname='minspy') : BEGIN

        spgstr.minspy=ev.value
        widget_control,ev.handler,set_uvalue=spgstr
       
    END

;change spectrum plot y range (max)

    widget_info(ev.top,find_by_uname='maxspy') : BEGIN

        spgstr.maxspy=ev.value
        widget_control,ev.handler,set_uvalue=spgstr
       
    END
  
;change integration x
    widget_info(ev.top,find_by_uname='askxint') : BEGIN

        drawwidget=widget_info(ev.top,find_by_uname='drawwin')

        IF ev.value NE 1 THEN BEGIN
            spgstr.integrated=1
            spgstr.xint=ev.value>1
            spgstr.needupdate=1
        ENDIF $
        ELSE BEGIN
            IF spgstr.yint EQ 1 THEN BEGIN
                spgstr.integrated=0
                spgstr.xint=1
                spgstr.needupdate=1
            ENDIF $
            ELSE BEGIN
                spgstr.integrated=1
                spgstr.xint=1
                spgstr.needupdate=1
            ENDELSE
            
        ENDELSE
                      
        spg_workhorse_plotspg,spgstr=spgstr,drawwidget
        widget_control,ev.handler,set_uvalue=spgstr

    END

;change integration y
    widget_info(ev.top,find_by_uname='askyint') : BEGIN

        drawwidget=widget_info(ev.top,find_by_uname='drawwin')

        IF ev.value NE 1 THEN BEGIN
            spgstr.integrated=1
            spgstr.yint=ev.value>1
            spgstr.needupdate=1
        ENDIF $
        ELSE BEGIN
            IF spgstr.xint EQ 1 THEN BEGIN
                spgstr.integrated=0
                spgstr.yint=1
                spgstr.needupdate=1
            ENDIF $
            ELSE BEGIN
                spgstr.integrated=1
                spgstr.yint=1
                spgstr.needupdate=1
            ENDELSE
            
        ENDELSE
                      
        spg_workhorse_plotspg,spgstr=spgstr,drawwidget
        widget_control,ev.handler,set_uvalue=spgstr
       
    END
 
    widget_info(ev.top,find_by_uname='drawwin') : BEGIN
;
;   this kind of events will only happen if the draw widget
;   has been made sensitive to mouse events, i.e. the select region
;   button or the x,y slice button has been pressed
;

        widget_control,ev.id,get_uvalue=status


        ;select button was pressed
        IF status.operation EQ 'select' THEN BEGIN

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
                spg_workhorse_plotbox,status.boxcoor,status.oldcoor,/nodraw $
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
           
                spg_workhorse_plotbox,status.boxcoor,status.oldcoor,/noerase $
                                   ,sides=newsides
                status.first=0

            ENDIF $
            ELSE BEGIN

                spg_workhorse_plotbox,status.boxcoor,status.oldcoor $
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

            status.outcoor=[x1+getutbase(),x2+getutbase(),y1,y2]
            
            widget_control,ev.id,set_uvalue=status

            ;make the draw widget insensitive to further mouse activity
            widget_control,ev.id,draw_button_events=0
            widget_control,ev.id,draw_motion_events=0
            

            widget_control,ev.handler,get_uvalue=spgstr
            spgstr.selcoor=status.outcoor
            widget_control,ev.handler,set_uvalue=spgstr

            textwindow=widget_info(ev.top,find_by_uname='frameinfo')
            widget_control,textwindow,set_value=spg_workhorse_outtext(spgstr)
            
            spg_workhorse_plotspg,spgstr=spgstr,ev.id                          

        ENDIF

        widget_control,ev.id,set_uvalue=status

    ENDIF

    ;x slice was selected
    IF status.operation EQ 'xslice' THEN BEGIN
        
        IF ev.press EQ 1 THEN BEGIN


            spglc=widget_info(ev.top,find_by_uname='drawwin')
            widget_control,spglc,get_value=winspg
            drawlc=widget_info(ev.top,find_by_uname='drawlc') 
            widget_control,drawlc,get_value=winlc

            wset,winspg

            oldx=!X
            oldy=!Y
            !X=spgstr.xpar
            !Y=spgstr.ypar
        
            x1=(convert_coord(ev.x,ev.y,/to_data,/device))[0]+getutbase()
            y1=(convert_coord(ev.x,ev.y,/to_data,/device))[1]

            spg=spgstr.aspg  

            yenergy=spg.y
            tmpvar=min(abs(yenergy-y1),enindex) 

            !X=oldx
            !Y=oldy

            wset,winlc
            utplot,spg.x-spg.x[0] $
                  ,spg.spectrogram[*,enindex[0]],spg.x[0] $
                  ,xrange=spgstr.xrange-spg.x[0],xstyle=1 $
                  ,title='Lightcurve at ' $
                  +strtrim(string(yenergy[enindex[0]]),2)+' keV'
                   

        ENDIF

        IF ev.press EQ 4 THEN BEGIN 

            widget_control,ev.id,draw_button_events=0
    
        ENDIF

    
    ENDIF


    ;y slice was selected
    IF status.operation EQ 'yslice' THEN BEGIN
        
        IF ev.press EQ 1 THEN BEGIN

            spglc=widget_info(ev.top,find_by_uname='drawwin')
            widget_control,spglc,get_value=winspg
            drawlc=widget_info(ev.top,find_by_uname='drawlc') 
            widget_control,drawlc,get_value=winlc

            wset,winspg

            oldx=!X
            oldy=!Y
            !X=spgstr.xpar
            !Y=spgstr.ypar
        
            x1=(convert_coord(ev.x,ev.y,/to_data,/device))[0]+getutbase()
            y1=(convert_coord(ev.x,ev.y,/to_data,/device))[1]


            spg=spgstr.aspg 
    

            xtime=spg.x 
            tmpvar=min(abs(xtime-x1),tindex)

            !X=oldx
            !Y=oldy
            wset,winlc

            fitfun=0

            oplotfit=0

            IF (spgstr.fit EQ 1) THEN BEGIN
                fitpar=spg_workhorse_fit(spgstr,x1)
                spgstr.fitpar=fitpar.par
                fitfun=fitpar.fun
                textwindow=widget_info(ev.top,find_by_uname='frameinfo')
                widget_control,textwindow $
                              ,set_value=spg_workhorse_outtext(spgstr)

                widget_control,ev.handler,set_uvalue=spgstr
                oplotfit=1

            ENDIF

            spg_workhorse_plotspectrum,spgstr,tindex[0],fitfun=fitfun $
                                     ,oplotfit=oplotfit
          
        ENDIF

        IF ev.press EQ 4 THEN BEGIN 

            widget_control,ev.id,draw_button_events=0
    
        ENDIF


    ENDIF    

    IF status.operation EQ 'bgselect' THEN BEGIN

        IF ev.release EQ 1 THEN BEGIN


                spglc=widget_info(ev.top,find_by_uname='drawwin')
                widget_control,spglc,get_value=winspg
  
        
                x1=(convert_coord(ev.x,ev.y,/to_data,/device))[0] ;+getutbase()
                y1=(convert_coord(ev.x,ev.y,/to_data,/device))[1]

                oplot,[x1,x1],[min(spgstr.spg.y),max(spgstr.spg.y)],color=255
                status.coor[status.clicks]=x1+getutbase()
                status.clicks=status.clicks+1
                widget_control,ev.id,set_uvalue=status


                IF status.clicks EQ 2 THEN BEGIN
                    widget_control,ev.id,draw_button_events=0

                    spgstr.background=1
                    spgstr.backtime=status.coor
                    spgstr.needupdate=1                     
  
                    spg_workhorse_plotspg,spgstr=spgstr,spglc

                    textwindow=widget_info(ev.top,find_by_uname='frameinfo')
                    widget_control,textwindow,set_value=spg_workhorse_outtext(spgstr)

                    widget_control,ev.handler,set_uvalue=spgstr

                ENDIF

        ENDIF
  
    ENDIF

   
    END


    ELSE : print,'Ciao'

ENDCASE

END 



;
;Main procedure
;
PRO pg_spg_workhorse,spg

;variable initialisation stuff
;


IF NOT exist(spg) THEN BEGIN
   print,'Please input a spectrogram'
   RETURN
ENDIF


aspg=spg

startpar=[1e-2,1.5,1e5,4,1,1,50,0]

spgstr={spg:spg $
       ,aspg:aspg $
       ,ylog:0 $
       ,zlog:1 $
       ,selcoor:[0d,0d,0d,0d] $
       ,showregion:1 $
       ,xrange:[0d,0d] $
       ,yrange:[0d,0d] $
       ,interp:1 $
       ,backtime:[0d,0d] $
       ,background:0 $
       ,xint:1 $
       ,yint:1 $
       ,integrated:0 $
       ,needupdate:0 $
       ,xpar:!X $
       ,ypar:!Y $
       ,minfitv:5. $
       ,maxfitv:max(spg.y) $
       ,fit:0 $
       ,fitpar:startpar $
       ,startpar:startpar $
       ,minspy:0.01d,maxspy:1d5 $
       ,fitmaxspband:[20,30] $
       ,fitmaxdeltatime:8 $
       ,fitmaxtime_intv:[0.d,0.d] $
       ,fitmaxfitpar:startpar*0.d $
       ,fitmaxsavefile:'~/work/sizespin/maxfitpar.fits'}

spgstr.selcoor=[min(spg.x),max(spg.x),min(spg.y),max(spg.y)]

spgstr.xrange=spgstr.selcoor[0:1]
spgstr.yrange=spgstr.selcoor[2:3]


;end variable init

;widget hierarchy creation
;
    base=widget_base(title='Spectrogram examiner',/row,uname='base_widget')
    root=widget_base(base,/row,uvalue=spgstr,uname='root')
    
    menu1=widget_base(root,group_leader=root,/column,/frame,uname='menu1')
    drawsurf1=widget_base(root,group_leader=root,/column,uname='drawsurf1')
    buttonm1=widget_base(menu1,group_leader=menu1,/row,/frame)
    

;end widget hierarchy creation

;buttons
;
    values=['Draw spectrogram','Logarithmic Y','Logarithmic Z' $
           ,'Interpolation','Color table','Select region','Zoom' $
           ,'Unzoom','X slice','Y slice','Done']

    uname='commands'
    bgroup=cw_bgroup(buttonm1,values,/column,uname=uname)

    values=['UNUSED','Background select','Clear Background' $
           ,'Clear Integration','Fitting','Fit max spectrum' $
           ,'Set fit start par','Save maxfitpar']

    uname='commands2'
    bgroup=cw_bgroup(buttonm1,values,/column,uname=uname)




    askxint=cw_field(menu1,value=[1],title='Time integration  ' $
                                ,uname='askxint',/return_events,/integer)
    askyint=cw_field(menu1,value=[1],title='Energy integration' $
                                ,uname='askyint',/return_events,/integer)

    minfitv=cw_field(menu1,value=spgstr.minfitv,title='Min fit energy    ' $
                                ,uname='minfitv',/return_events,/float)
    maxfitv=cw_field(menu1,value=spgstr.maxfitv,title='Max fit energy    ' $
                                ,uname='maxfitv',/return_events,/float)


    minspy=cw_field(menu1,value=spgstr.minspy,title='Spectrum min flux :' $
                                ,uname='minspy',/return_events,/float)

    maxspy=cw_field(menu1,value=spgstr.maxspy,title='Spectrum max flux :' $
                                ,uname='maxspy',/return_events,/float)
                
;end buttons

;text widget
;
    text=widget_text(menu1,value=spg_workhorse_outtext(spgstr) $
                     ,ysize=25,xsize=55,uname='frameinfo')

;end text widget

;draw widgets
;
    draw=widget_draw(drawsurf1,xsize=640,ysize=460,uname='drawwin')    
    drawlc=widget_draw(drawsurf1,xsize=640,ysize=400,uname='drawlc')
                 
;end draw widget

widget_control,root,set_uvalue=spgstr
  
widget_control,base,/realize

spg_workhorse_plotspg,spgstr=spgstr,draw

xmanager,'pg_spg_workhorse',root,/no_block

END












