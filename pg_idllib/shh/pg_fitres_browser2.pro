;+
;
; NAME:
;        pg_fitres_browser
;
; PURPOSE: 
;        widget interface for browsing fit results
;
; CALLING SEQUENCE:
;
;        pg_fitres_browser,fitres
;
; INPUTS:
;
;        fitres: a sstructure with TAGS:
;   TIME            DOUBLE    Array[n]
;   CHISQ           DOUBLE    Array[n]
;   FITPAR          DOUBLE    Array[9, n]
;   RESIDUALS       DOUBLE    Array[x, n]
;   CNTSPECTRA      DOUBLE    Array[x, n]
;   CNTESPECTRA     DOUBLE    Array[x, n]
;   CNTMODELS       DOUBLE    Array[x, n]
;   BSPECTRUM       FLOAT     Array[x]
;   BESPECTRUM      FLOAT     Array[x]
;   ENORM           FLOAT           50.0000
;   ERANGE          INT       Array[2]
;   THERMRANGE      INT       Array[2]
;   NONTHERMRANGE   INT       Array[2]
;   PARINFO         POINTER   Array[n]
;I
;
; OUTPUT:
;        
; EXAMPLE:
;
;        
;
; VERSION:
;
;     NOV-2003 written
;        
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-


;.comp pg_fitres_browser
;pg_fitres_browser2,mydata




;
;plot the spectrum of selected interval
;
PRO pg_fitres_browser_plotsp,mydata

  pg_plot_spfitres,mydata.fitres,intv=mydata.intv,/xlog,/ylog,/xstyle,/ystyle $
                  ,yrange=[mydata.minysp,mydata.maxysp] $
                  ,/residuals ;$
                  ;,title=smallint2str(myi,strlen=4)+' : '+anytim(fitres.time[i],/yohkoh)


END

;
;plot the spectrogram
;
PRO pg_fitres_browser_plotspg,mydata,thisx=thisx,thisy=thisy,thisp=thisp,status=status


  intv=mydata.intv
  time=mydata.spectrogram.x
  thisspike= mydata.thisspike

  IF mydata.showeband EQ 1 THEN BEGIN 


     data=mydata.fitres.cntspectra
     eband=mydata.fitres.cntedges

     ind=where(eband[*,0] GE mydata.mineb AND eband[*,1] LE mydata.maxeb)

     lc=total(data[ind,*],1)/(mydata.maxeb-mydata.mineb)

     utplot,time-time[0],lc,time[0],yrange=[1d-1,1d4],ystyle=1 $
               ,/xstyle,title='EBAND (...)',/ylog

     
     IF ptr_valid(status.spikint) THEN BEGIN 
        spint=*status.spikint
        FOR i=0,n_elements(spint)/2-1 DO BEGIN 
           outplot,spint[0,i]*[1,1]-time[0],10^!Y.crange,time[0]
           outplot,spint[1,i]*[1,1]-time[0],10^!Y.crange,time[0]
           outplot,spint[*,i]-time[0],10^!Y.crange[[1,1]],time[0],color=2,thick=2
       ENDFOR

     ENDIF
        
     IF status.operation EQ 'spikeselect' THEN $
        IF status.lastbutton EQ 1 THEN $
           outplot,status.lasttime*[1,1]-time[0],10^!Y.crange,time[0]


     IF mydata.showspikes EQ 1 THEN BEGIN 
        IF ptr_valid(mydata.spikesint) THEN BEGIN 

           thisint=(*mydata.spikesint)[*,thisspike]
           outplot,time[thisint[0]:thisint[1]]-time[0],lc[thisint[0]:thisint[1]],time[0],color=2

        ENDIF
     ENDIF


  ENDIF ELSE BEGIN 


     tvlct,r,g,b,/get
     loadct,5,/silent
     spectro_plot,mydata.spectrogram,/ylog,/zlog,/xstyle,/ystyle,title=' . '
     tvlct,r,g,b

  ENDELSE

  outplot,time[intv]*[1,1]-time[0],10^!y.crange,time[0],linestyle=2,color=12,thick=2
  outplot,time-time[0],3+mydata.fitres.atten_state,time[0],color=12,thick=2

  thisy=!Y
  thisx=!X
  thisp=!P

END

;
;plot fgamma
;
PRO pg_fitres_browser_plotfgamma,mydata

  delta=mydata.fitres.fitpar[0,*]
  fnorm=mydata.fitres.fitpar[3,*]

  intv=mydata.intv

  pg_setplotsymbol,'CIRCLE',size=1.

  plot,fnorm,delta,/xlog,xrange=[1d-4,1d2],psym=8,yrange=[1,10]

  IF mydata.showspikes EQ 1 AND ptr_valid(mydata.spikesint) THEN BEGIN 
     ;print,'spike'
     thisspike= mydata.thisspike
     thisint=(*mydata.spikesint)[*,thisspike]

     thisfnorm=fnorm[thisint[0]:thisint[1]]
     thisdelta=delta[thisint[0]:thisint[1]]

     oplot,thisfnorm,thisdelta,psym=8,color=2
    
     res=pg_findpivot(thisdelta,thisfnorm,mydata.fitres.enorm,minrange=1.5,maxrange=10)
     
     a=res.sixlin_a[2]
     b=res.sixlin_b[2]

     fmin=min(thisfnorm)
     fmax=max(thisfnorm)

     oplot,[fmin,fmax],a+b*alog([fmin,fmax]),thick=2,color=2

     xyouts,5d-4,9.3,'EPIV: '+string(res.epiv),color=12
     xyouts,5d-4,8.9,'FPIV: '+string(res.fpiv),color=12

  ENDIF


  oplot,fnorm[[intv,intv]],delta[[intv,intv]],psym=8,color=7



END

;
;plot fit result as a function of time
;
PRO pg_fitres_browser_plotlc,mydata

;here plot the spectrum

  intv=mydata.intv
  time=mydata.fitres.time
  thisspike= mydata.thisspike

  par=mydata.fitres.fitpar

  showdelta=mydata.fitres.modtype EQ 'THERM+BPOW'
  
;   IF mydata.showeband EQ 1 THEN BEGIN 


;      data=mydata.fitres.cntspectra
;      eband=mydata.fitres.cntedges

;      ind=where(eband[*,0] GE mydata.mineb AND eband[*,1] LE mydata.maxeb)

;      lc=total(data[ind,*],1)/(mydata.maxeb-mydata.mineb)

;      utplot,time-time[0],lc,time[0],yrange=[1d-1,1d4],ystyle=1 $
;                ,/xstyle,title='EBAND (...)',/ylog

;      IF mydata.showspikes EQ 1 THEN BEGIN 

;         thisint=[mydata.spikesint[thisspike],mydata.spikesint[thisspike+1]]
;         outplot,time[thisint[0]:thisint[1]]-time[0],lc[thisint[0]:thisint[1]],time[0],color=2
            
;      ENDIF


;   ENDIF ELSE BEGIN 

     if showdelta then begin


      delta=par[0,*]
      fnorm=par[3,*]
      temp=par[7,*]
      em=par[6,*]
      ind=where(finite(fnorm),count)
      IF count GT 0 THEN maxfnorm=max(fnorm[ind]) ELSE maxfnorm=1d2
      IF count GT 0 THEN minfnorm=min(fnorm[ind]) ELSE minfnorm=1d-2
      minfnorm=minfnorm>1d-3

      IF mydata.plotdelta THEN BEGIN 

         utplot,time-time[0],delta,time[0],yrange=[1,9],ystyle=1+8 $
               ,/xstyle,title='Delta (white) & Fnorm (purple)'

         IF mydata.showspikes EQ 1 AND ptr_valid(mydata.spikesint) THEN BEGIN 

            thisint=(*mydata.spikesint)[*,thisspike]
            outplot,time[thisint[0]:thisint[1]]-time[0],delta[thisint[0]:thisint[1]],time[0],color=2
            
         ENDIF
;         oldy=!Y
         axis,!X.crange[1],/yaxis,yrange=[minfnorm,maxfnorm],/save,/ylog
         outplot,time-time[0],fnorm,time[0],color=12

         IF mydata.showspikes EQ 1 AND ptr_valid(mydata.spikesint) THEN BEGIN 

            thisint=(*mydata.spikesint)[*,thisspike]
            outplot,time[thisint[0]:thisint[1]]-time[0],fnorm[thisint[0]:thisint[1]],time[0],color=5
            
         ENDIF

;        !Y=oldy



      ENDIF ELSE BEGIN 
          utplot,time-time[0],kev2kel(temp),time[0],yrange=[0,5d7],ystyle=1+8 $
                ,/xstyle,title='Temp (white) & EM (purple)'
          axis,!X.crange[1],/yaxis,yrange=[1d-3,1d3],/save,/ylog
          outplot,time-time[0],em,time[0],color=12
     
      ENDELSE


    endif else begin 

      templow=par[1,*]
      emlow=par[0,*]
      temphigh=par[3,*]
      emhigh=par[2,*]

      ;ind=where(finite(emlow),count)
      ;IF count GT 0 THEN maxfnorm=max(emlow[ind]) ELSE maxfnorm=1d4
      ;IF count GT 0 THEN minfnorm=min(emlow[ind]) ELSE minfnorm=1d-10
;      minfnorm=minfnorm>1d-3

      IF mydata.plotdelta THEN BEGIN 

          utplot,time-time[0],kev2kel(templow),time[0],yrange=[0,5d7],ystyle=1+8 $
                ,title='Temp low (white) & EM low (purple)'
          axis,!X.crange[1],/yaxis,yrange=[1d-3,1d3],/save,/ylog
          outplot,time-time[0],emlow,time[0],color=12
     
 
      ENDIF ELSE BEGIN 
          utplot,time-time[0],kev2kel(temphigh),time[0],yrange=[0,1d9],ystyle=1+8 $
                ,title='Temp high (white) & EM high(purple)'
          axis,!X.crange[1],/yaxis,yrange=[1d-10,1d3],/save,/ylog
          outplot,time-time[0],emhigh,time[0],color=12
     
      ENDELSE

    endelse
   
;   ENDELSE


     outplot,time[intv]*[1,1]-time[0],10^!Y.crange,time[0],linestyle=2,color=5

END

PRO pg_fitres_browser_doallplots,base,mydata

  drawwidget=widget_info(base,find_by_uname='drawsp')
  widget_control,drawwidget,get_value=plotwin
  wset,plotwin
  pg_fitres_browser_plotsp,mydata

  drawwidget=widget_info(base,find_by_uname='drawspg')       
  widget_control,drawwidget,get_uvalue=status
  widget_control,drawwidget,get_value=plotwin
  wset,plotwin
  pg_fitres_browser_plotspg,mydata,thisx=thisx,thisy=thisy,thisp=thisp,status=status

  drawwidget=widget_info(base,find_by_uname='drawfgamma')
  widget_control,drawwidget,get_value=plotwin
  wset,plotwin
  pg_fitres_browser_plotfgamma,mydata

  drawwidget=widget_info(base,find_by_uname='drawpar')
  widget_control,drawwidget,get_value=plotwin
  wset,plotwin
  pg_fitres_browser_plotlc,mydata


  mydata.thisx=thisx
  mydata.thisy=thisy
  mydata.thisp=thisp

  mydata.debug='not empty'

END




;
;Returns the text to display as information in the text widget
;
FUNCTION pg_fitres_browser_outtext,mydata

intv=mydata.intv
thisspike=mydata.thisspike
par=mydata.fitres.fitpar[*,intv]
parnames=mydata.fitres.parnames

spikeinfo=ptr_valid(mydata.spikesint) ? $
             ' : '+strtrim((*mydata.spikesint)[0,thisspike],2)+ $
             ' - '+strtrim((*mydata.spikesint)[1,thisspike],2) : $
             '  '

outtext=['Interval '+strtrim(intv,2) $
        ,'Spike intv '+strtrim(thisspike,2)+ spikeinfo $
        ,'Attenuator State: '+ strtrim(fix(mydata.fitres.atten_state[intv]),2)$
        ,'          ']


for i=0,n_elements(parnames)-1 do begin 
    outtext=[outtext,parnames[i]+' '+strtrim(par[i],2)]
endfor

RETURN,outtext

END


;
;Widget event handler
;
PRO pg_fitres_browser_event,ev

widget_control,ev.handler,get_uvalue=mydata

;drawwidgetsp=widget_info(ev.top,find_by_uname='drawwin')
;drawwidgetlc=widget_info(ev.top,find_by_uname='drawlc')
;widget_control,drawwidgetsp,get_value=plotwinsp
;widget_control,drawwidgetlc,get_value=plotwinlc
 

CASE ev.ID OF
 
    ;second button group
    widget_info(ev.top,find_by_uname='commands2') : BEGIN

        drawwidget=widget_info(ev.top,find_by_uname='drawwin')
     

        CASE ev.value OF

            0 : BEGIN ;unused
               
                dummy=0
            
            END        

            ELSE : print,'Ciao'
            
        ENDCASE
    
        widget_control,ev.handler,set_uvalue=mydata

    END
  
      
    widget_info(ev.top,find_by_uname='droplist') : BEGIN

       newintv=ev.index

       widget_control,ev.handler,get_uvalue=mydata
       mydata.intv=newintv
       
       textwindow=widget_info(ev.top,find_by_uname='frameinfo')
       widget_control,textwindow $
                     ,set_value=pg_fitres_browser_outtext(mydata)


       pg_fitres_browser_doallplots,ev.top,mydata
 
       widget_control,ev.handler,set_uvalue=mydata

      
    END

    widget_info(ev.top,find_by_uname='spikelist') : BEGIN

       newintv=ev.index

       widget_control,ev.handler,get_uvalue=mydata
       mydata.thisspike=newintv

       IF mydata.chain THEN BEGIN 
          mydata.intv=(*mydata.spikesint)[0,newintv]
          droplistwidget=widget_info(ev.top,find_by_uname='droplist')
          widget_control,droplistwidget,set_list_select=mydata.intv
       ENDIF


       
       textwindow=widget_info(ev.top,find_by_uname='frameinfo')
       widget_control,textwindow $
                     ,set_value=pg_fitres_browser_outtext(mydata)


       pg_fitres_browser_doallplots,ev.top,mydata

       widget_control,ev.handler,set_uvalue=mydata

      
    END

    widget_info(ev.top,find_by_uname='drawspg') : BEGIN

       widget_control,ev.handler,get_uvalue=mydata
 
       widget_control,ev.id,get_value=winspg
       widget_control,ev.id,get_uvalue=status
       wset,winspg

       !X=mydata.thisx
       !Y=mydata.thisy
       !P=mydata.thisp

       x1=(convert_coord(ev.x,ev.y,/to_data,/device,/double))[0]+mydata.fitres.time[0]
       y1=(convert_coord(ev.x,ev.y,/to_data,/device,/double))[1]

       ;stop

       IF ev.release EQ 1 THEN BEGIN 
          status.lastbutton=1
          status.lasttime=x1
          print,'Left click'
          ptim,x1
          ;stop
       ENDIF

       IF ev.release EQ 4 THEN BEGIN 
          status.lastbutton=2

          IF ptr_valid(status.spikint) THEN BEGIN
             int=*status.spikint
             ptr_free,status.spikint
             status.spikint=ptr_new([[int],[status.lasttime,x1]])
            ; print,'ptr valid'
          ENDIF ELSE BEGIN 
             status.spikint=ptr_new([status.lasttime,x1])
             ;print,'new_ptr'
          ENDELSE 

          print,'Right click'
          ptim,*status.spikint
       ENDIF
       
       widget_control,ev.id,set_uvalue=status

       pg_fitres_browser_doallplots,ev.top,mydata
   
       ;ptim,x1-mydata.fitres.time[0];time
       ;print,y1;energy

    END


;second button group
    widget_info(ev.top,find_by_uname='commands') : BEGIN

 
        CASE ev.value OF

            0 : BEGIN ;Draw total Image

               pg_fitres_browser_doallplots,ev.top,mydata

               widget_control,ev.handler,set_uvalue=mydata
                  
            END

            1 : BEGIN ;Toggle delta temp
                 
               mydata.plotdelta=1-mydata.plotdelta
 
               pg_fitres_browser_doallplots,ev.top,mydata
 
               widget_control,ev.handler,set_uvalue=mydata
                
            END

            2 : BEGIN ;show_spikes
                 
               IF ptr_valid(mydata.spikesint) THEN mydata.showspikes=1-mydata.showspikes

               pg_fitres_browser_doallplots,ev.top,mydata

               widget_control,ev.handler,set_uvalue=mydata

                 
            END

            3 : BEGIN ;show_eband
                 
               mydata.showeband=1-mydata.showeband

               pg_fitres_browser_doallplots,ev.top,mydata

               widget_control,ev.handler,set_uvalue=mydata

                 
            END

            4 : BEGIN ;chain
                 
               mydata.chain=1-mydata.chain

               pg_fitres_browser_doallplots,ev.top,mydata

               widget_control,ev.handler,set_uvalue=mydata

                 
            END

            5 : BEGIN ;select it yourself
                 
               mydata.siy=1-mydata.siy
  
               widget_control,ev.handler,set_uvalue=mydata

               ;status={operation:'select',coor:[0d,0d]} ;,x:!X,y:!Y}

               drawspg= widget_info(ev.top,find_by_uname='drawspg')

               widget_control,drawspg,get_uvalue=status
               status.operation='spikeselect'
               status.lastbutton=0
               status.lasttime=!Values.d_nan

               widget_control,drawspg,set_uvalue=status

               ;makes the widget sensitive to mouse input events
               widget_control,drawspg,/draw_button_events
                 
            END

            6 : BEGIN ;done selecting
                 
               drawspg= widget_info(ev.top,find_by_uname='drawspg')
               widget_control,drawspg,draw_button_events=0
               widget_control,drawspg,get_uvalue=status               
               status.operation=''
     
               mydata.userspike=status.spikint
               status.spikint=ptr_new()
               widget_control,drawspg,set_uvalue=status
    
             ;ptim,*mydata.userspike
 
               widget_control,ev.handler,set_uvalue=mydata

            END

            7 : BEGIN ;add spikes
                 
               drawspg= widget_info(ev.top,find_by_uname='drawspg')

 
               
               widget_control,drawspg,get_uvalue=status               
               IF status.operation NE '' THEN BEGIN
                  print,'Please terminate actual operation first ('+status.operation+')'
               ENDIF ELSE BEGIN 
                  IF NOT ptr_valid(mydata.userspike) THEN BEGIN 
                     print,'Please select spike yourself before pressing this button'
                  ENDIF ELSE BEGIN 
                     timelist=*mydata.userspike
                     outlist=long(timelist)
                     time=mydata.fitres.time
                     FOR j=0,n_elements(timelist)-1 DO BEGIN 
                        dummy=min(abs(time-timelist[j]),res)
                        outlist[j]=res
                     ENDFOR
                     mydata.userspike=ptr_new()
                     IF ptr_valid(mydata.spikesint) THEN BEGIN
                        mydata.spikesint=ptr_new([[*mydata.spikesint],[outlist]])
                     ENDIF $
                     ELSE mydata.spikesint=ptr_new(outlist)
                  ENDELSE
               ENDELSE

               widget_control,ev.handler,set_uvalue=mydata

               ;stop

               intvlist='  '+strtrim(lindgen(n_elements((*mydata.spikesint))/2),2)
               spikelist = widget_info(ev.top,find_by_uname='spikelist')
               widget_control,spikelist,set_value=intvlist
               widget_control,spikelist,set_list_select=0

            END

             8 : BEGIN ;remove spike
                 
               drawspg= widget_info(ev.top,find_by_uname='drawspg')
                
               widget_control,drawspg,get_uvalue=status               

               IF status.operation NE '' THEN BEGIN
                  print,'Please terminate actual operation first ('+status.operation+')'
               ENDIF ELSE BEGIN 
 
                  IF ptr_valid(mydata.spikesint) THEN BEGIN
                     spikelist= widget_info(ev.top,find_by_uname='spikelist')
                                ;widget_control,spikelist,get_list_select=thisspike
                     thisspike=mydata.thisspike
                     spikesint=*mydata.spikesint
                     n=n_elements(spikesint)/2-1

                     IF n EQ 0 THEN BEGIN 
                        mydata.spikesint=ptr_new()                   
                        intvlist='  '
                        spikelist = widget_info(ev.top,find_by_uname='spikelist')
                        widget_control,spikelist,set_value=intvlist
                        widget_control,spikelist,set_list_select=0

                     ENDIF ELSE BEGIN 


                     CASE thisspike OF 
                        0    :  newspike=spikesint[*,1:n]
                        n    :  newspike=spikesint[*,0:n-1]
                        ELSE :  newspike=[[spikesint[*,0:thisspike-1]],[spikesint[*,thisspike+1:n]]]
                     ENDCASE

                     mydata.spikesint=ptr_new(newspike)

                     mydata.thisspike=(mydata.thisspike-1)>0
                     
  
                     intvlist='  '+strtrim(lindgen(n_elements((*mydata.spikesint))/2),2)
                     spikelist = widget_info(ev.top,find_by_uname='spikelist')
                     widget_control,spikelist,set_value=intvlist
                     widget_control,spikelist,set_list_select=mydata.thisspike

                  ENDELSE


                ;ind=findgen(n_elements(spikesint))
                  
                  ;newspikesint=[*
  
                     widget_control,ev.handler,set_uvalue=mydata

                     pg_fitres_browser_doallplots,ev.top,mydata

                ENDIF
               ENDELSE



  
               ;stop

  
            END



            9 : BEGIN ; 'print spiketime'

               time=mydata.fitres.time
               IF ptr_valid(mydata.spikesint) THEN BEGIN 
                  ptim,time[*mydata.spikesint]
                  print,*mydata.spikesint
               ENDIF

            
            END


            10 : BEGIN ; 'Done'

                widget_control,ev.top,/destroy
            
            END

            ELSE : RETURN

        ENDCASE


    END


;change spectrum plot y range

    widget_info(ev.top,find_by_uname='minysp') : BEGIN

        mydata.minysp=ev.value
        
        pg_fitres_browser_doallplots,ev.top,mydata
        widget_control,ev.handler,set_uvalue=mydata
        
 
    END

;change spectrum plot y range (max)

    widget_info(ev.top,find_by_uname='maxysp') : BEGIN

        mydata.maxysp=ev.value


        pg_fitres_browser_doallplots,ev.top,mydata
        widget_control,ev.handler,set_uvalue=mydata
             
    END
  
;change eband range min

    widget_info(ev.top,find_by_uname='mineb') : BEGIN

        mydata.mineb=ev.value

        
        pg_fitres_browser_doallplots,ev.top,mydata
        widget_control,ev.handler,set_uvalue=mydata        
 
    END

;change eband range max

    widget_info(ev.top,find_by_uname='maxeb') : BEGIN

        mydata.maxeb=ev.value


        pg_fitres_browser_doallplots,ev.top,mydata
        widget_control,ev.handler,set_uvalue=mydata
             
    END
  


    ELSE : print,'Ciao'

ENDCASE

END 



;
;Main procedure
;
PRO pg_fitres_browser,fitres,keepatten=keepatten,inputspikes=inputspikes

;interval finding (?)

;variant a --> from fnorm/delta
keepatten=fcheck(keepatten,1)
intvdata=fitres.fitpar[4,*]
attstate=fitres.atten_state
ind=where(attstate LT keepatten,count)
IF count GT 0 THEN intvdata[ind]=!values.f_nan
;spikesint=pg_getrisedecay(fitres.fitpar[4,*])

data=fitres.cntspectra
eband=fitres.cntedges

ind=where(eband[*,0] GE 40 AND eband[*,1] LE 60)

lc=total(data[ind,*],1)

attstate=fitres.atten_state
ind2=where(attstate LT keepatten,count)
IF count GT 0 THEN lc[ind2]=!values.f_nan
;x=findgen(n_elements(lc))


;spikesint=pg_getrisedecay(lc,winwidth=5)


;variant b --> from spectrogram...

;variable initialisation stuff
;

IF NOT exist(fitres) THEN BEGIN
   print,'Please input a fit result structure'
   RETURN
ENDIF


cntedges=fitres.cntedges
cntmean=sqrt(cntedges[*,0]*cntedges[*,1])
time=fitres.time


IF exist(inputspikes) THEN BEGIN 
   spikesint=inputspikes 
   ptrspikes=ptr_new(spikesint)
ENDIF $
ELSE ptrspikes=ptr_new()


mydata={fitres:fitres,$
        intv:0, $
        plotdelta:1, $
        minysp:0.1, $
        maxysp:1e4, $
        mineb:40, $
        maxeb:60, $
        showeband:0, $
        spikesint:ptrspikes, $
        showspikes:0, $
        thisspike:0, $
        spectrogram:{spectrogram:transpose(fitres.cntspectra)>1d-2,x:time,y:cntmean}, $
        chain:0, $
        siy:0, $
        thisx:!X, $
        thisy:!Y, $
        thisp:!P, $
        userspike:ptr_new(), $
        debug:'empty' $;this is noly for debuggin purpose, ignore
       }

;end variable init

;widget hierarchy creation
;
    base=widget_base(title='Fit result examiner',/row,uname='base_widget')
    root=widget_base(base,/row,uvalue=spgstr,uname='root')
    
    menu1=widget_base(root,group_leader=root,/column,uname='menu1')
    menu2=widget_base(menu1,group_leader=menu1,/row,uname='menu1')
    drawsurf1=widget_base(root,group_leader=root,/column,uname='drawsurf1')
    buttonm1=widget_base(menu2,group_leader=menu2,/row)
    buttonm2=widget_base(menu2,group_leader=menu2,/column)
    

;end widget hierarchy creation

;buttons
;
    values=['Draw spectrum', 'Toggle delta/temp','Show spikes','Show EBAND' $
           ,'Chain','Select it yourself','Done selecting','add spikes' $
           ,'remove spike','print spiktime','Done']

    uname='commands'
    bgroup=cw_bgroup(buttonm1,values,/column,uname=uname)

;    values=['UNUSED']


    testfield1 = cw_field(buttonm2,value=mydata.minysp,xsize=12 $
       ,title='MIN Y SPECTRUM',/return_events,/column,uname='minysp')
    testfield2 = cw_field(buttonm2,value=mydata.maxysp,xsize=12 $
       ,title='MAX Y SPECTRUM',/return_events,/column,uname='maxysp')
    testfield3 = cw_field(buttonm2,value=mydata.mineb,xsize=12 $
       ,title='MIN EBAND',/return_events,/column,uname='mineb')
    testfield4 = cw_field(buttonm2,value=mydata.maxeb,xsize=12 $
       ,title='MAX EBAND',/return_events,/column,uname='maxeb')

;    uname='commands2'
;    bgroup=cw_bgroup(buttonm1,values,/column,uname=uname)

;end buttons

;list
    intvlist='  '+strtrim(lindgen(n_elements(fitres.time)),2)
    dlist=widget_list(menu1,value=intvlist,uname='droplist',ysize=15,xsize=10)

    IF ptr_valid(mydata.spikesint) THEN $ 
       intvlist='  '+strtrim(lindgen(n_elements(*mydata.spikesint)/2),2) $
    ELSE $
       intvlist='  '

    dlist=widget_list(menu1,value=intvlist,uname='spikelist',ysize=5,xsize=10)

;text widget
;
    text=widget_text(menu1,value=pg_fitres_browser_outtext(mydata) $
                     ,ysize=25,xsize=35,uname='frameinfo')

;end text widget

;draw widgets
;

    status={operation:'',spikint:ptr_new(),lastbutton:0,lasttime:!Values.d_nan}

    drawbase1=widget_base(drawsurf1,group_leader=drawsurf1,/row)
    drawbase2=widget_base(drawsurf1,group_leader=drawsurf1,/row)
 
    drawspg=widget_draw(drawbase1,xsize=600,ysize=500,uname='drawspg',uvalue=status)    
    drawsp=widget_draw(drawbase1,xsize=600,ysize=500,uname='drawsp')
    drawpar=widget_draw(drawbase2,xsize=600,ysize=500,uname='drawpar')    
    drawfgamma=widget_draw(drawbase2,xsize=600,ysize=500,uname='drawfgamma')
                 
;end draw widget

widget_control,root,set_uvalue=mydata
  
widget_control,base,/realize

linecolors
pg_fitres_browser_doallplots,base,mydata
widget_control,root,set_uvalue=mydata

xmanager,'pg_fitres_browser',root,/no_block

END












