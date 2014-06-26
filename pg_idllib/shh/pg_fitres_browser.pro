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
;pg_fitres_browser,mydata




;
;plot the spectrum of selected interval
;
PRO pg_fitres_browser_plotsp,mydata


  intv=mydata.intv
  cntedges=mydata.fitres.cntedges
  cntmean=sqrt(cntedges[*,0]*cntedges[*,1])

  showbreaks=mydata.fitres.modtype EQ 'THERM+BPOW'

  if showbreaks then pg_setplotsymbol,'CIRCLE',size=2.


  pg_plotsp,cntedges,mydata.fitres.cntspectra[*,intv] $
            ,espectrum=mydata.fitres.cntespectra[*,intv],/xlog,/ylog,xstyle=1 $
            ,yrange=[mydata.minysp,mydata.maxysp]

  pg_plotsp,cntedges,mydata.fitres.cnttherm[*,intv],color=7,/overplot
  pg_plotsp,cntedges,mydata.fitres.cntnontherm[*,intv],color=12,/overplot
  pg_plotsp,cntedges,mydata.fitres.cntmodels[*,intv],color=2,/overplot,thick=2
  
  pg_plotsp,cntedges,mydata.fitres.bspectrum $
           ,espectrum=mydata.fitres.bespectrum,color=5,/overplot
 
  if showbreaks then begin 
  ;show the breaks...
  par=mydata.fitres.fitpar[*,intv]
  fitebreakl=par[4]
  fitebreakh=par[5]

  dummy=min(abs(cntmean-fitebreakl),indl)
  dummy=min(abs(cntmean-fitebreakh),indh)

  plots,cntmean[indl],mydata.fitres.cntnontherm[indl,intv],psym=8,color=12
  plots,cntmean[indh],mydata.fitres.cntnontherm[indh,intv],psym=8,color=12
         
  endif


  ;pg_plotspres,cntedges,spectrum=spectrum,modspectrum=resulttot,espectrum=espectrum $
  ;                   ,/xlog,/xstyle,yrange=[-4,4],/noerase,position=resposition


END

;
;plot fit result as a function of time
;
PRO pg_fitres_browser_plotlc,mydata

;here plot the spectrum

  intv=mydata.intv
  time=mydata.fitres.time

  par=mydata.fitres.fitpar

  showdelta=mydata.fitres.modtype EQ 'THERM+BPOW'

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

          utplot,time-time[0],delta,time[0],yrange=[9,1],ystyle=1+8,title='Delta (white) & Fnorm (purple)'
          axis,!X.crange[1],/yaxis,yrange=[minfnorm,maxfnorm],/save,/ylog
          outplot,time-time[0],fnorm,time[0],color=12


      ENDIF ELSE BEGIN 
          utplot,time-time[0],kev2kel(temp),time[0],yrange=[0,5d7],ystyle=1+8 $
                ,title='Temp (white) & EM (purple)'
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

     outplot,time[intv]*[1,1]-time[0],10^!Y.crange,time[0],linestyle=2,color=5

END

;
;Returns the text to display as information in the text widget
;
FUNCTION pg_fitres_browser_outtext,mydata

intv=mydata.intv
par=mydata.fitres.fitpar[*,intv]
parnames=mydata.fitres.parnames

outtext=['Interval '+strtrim(intv,2) $
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

drawwidgetsp=widget_info(ev.top,find_by_uname='drawwin')
drawwidgetlc=widget_info(ev.top,find_by_uname='drawlc')
widget_control,drawwidgetsp,get_value=plotwinsp
widget_control,drawwidgetlc,get_value=plotwinlc
 

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
       widget_control,ev.handler,set_uvalue=mydata
       
       textwindow=widget_info(ev.top,find_by_uname='frameinfo')
       widget_control,textwindow $
                     ,set_value=pg_fitres_browser_outtext(mydata)

       drawwidget=widget_info(ev.top,find_by_uname='drawwin')
       widget_control,drawwidget,get_value=plotwin
       wset,plotwin
       pg_fitres_browser_plotsp,mydata

       drawwidget=widget_info(ev.top,find_by_uname='drawlc')
       widget_control,drawwidget,get_value=plotwin
       wset,plotwin
       pg_fitres_browser_plotlc,mydata
      
    END


;second button group
    widget_info(ev.top,find_by_uname='commands') : BEGIN

        drawwidgetsp=widget_info(ev.top,find_by_uname='drawwin')
        drawwidgetlc=widget_info(ev.top,find_by_uname='drawlc')
        widget_control,drawwidgetsp,get_value=plotwinsp
        widget_control,drawwidgetlc,get_value=plotwinlc
 
        CASE ev.value OF

            0 : BEGIN ;Draw total Image
                 
               wset,plotwinsp
               pg_fitres_browser_plotsp,mydata
               wset,plotwinlc
               pg_fitres_browser_plotlc,mydata
                
            END

            1 : BEGIN ;Toggle delta temp
                 
               mydata.plotdelta=1-mydata.plotdelta
               widget_control,ev.handler,set_uvalue=mydata

               wset,plotwinsp
               pg_fitres_browser_plotsp,mydata
               wset,plotwinlc
               pg_fitres_browser_plotlc,mydata
                
            END

 

            2 : BEGIN ; 'Done'

                widget_control,ev.top,/destroy
            
            END

            ELSE : RETURN

        ENDCASE


    END


;change spectrum plot y range

    widget_info(ev.top,find_by_uname='minysp') : BEGIN

        mydata.minysp=ev.value
        widget_control,ev.handler,set_uvalue=mydata
 
        wset,plotwinsp
        pg_fitres_browser_plotsp,mydata
 
    END

;change spectrum plot y range (max)

    widget_info(ev.top,find_by_uname='maxysp') : BEGIN

        mydata.maxysp=ev.value
        widget_control,ev.handler,set_uvalue=mydata

        wset,plotwinsp
        pg_fitres_browser_plotsp,mydata
     
    END
  


    ELSE : print,'Ciao'

ENDCASE

END 



;
;Main procedure
;
PRO pg_fitres_browser,fitres

;variable initialisation stuff
;


IF NOT exist(fitres) THEN BEGIN
   print,'Please input a fit result structure'
   RETURN
ENDIF


mydata={fitres:fitres,$
        intv:0, $
        plotdelta:1, $
        minysp:0.1, $
        maxysp:1e4}

;end variable init

;widget hierarchy creation
;
    base=widget_base(title='Fit result examiner',/row,uname='base_widget')
    root=widget_base(base,/row,uvalue=spgstr,uname='root')
    
    menu1=widget_base(root,group_leader=root,/column,/frame,uname='menu1')
    drawsurf1=widget_base(root,group_leader=root,/column,uname='drawsurf1')
    buttonm1=widget_base(menu1,group_leader=menu1,/row,/frame)
    

;end widget hierarchy creation

;buttons
;
    values=['Draw spectrum', 'Toggle delta/temp','Done']

    uname='commands'
    bgroup=cw_bgroup(buttonm1,values,/column,uname=uname)

;    values=['UNUSED']
    testfield1 = cw_field(buttonm1,title='MIN Y SPECTRUM',/return_events,/column,uname='minysp')
    testfield2 = cw_field(buttonm1,title='MAX Y SPECTRUM',/return_events,/column,uname='maxysp')

;    uname='commands2'
;    bgroup=cw_bgroup(buttonm1,values,/column,uname=uname)

;end buttons

;list
    intvlist='   '+strtrim(lindgen(n_elements(fitres.time)),2)+'   '
    dlist=widget_list(menu1,value=intvlist,uname='droplist',ysize=15)

;text widget
;
    text=widget_text(menu1,value=pg_fitres_browser_outtext(mydata) $
                     ,ysize=25,xsize=55,uname='frameinfo')

;end text widget

;draw widgets
;
    draw=widget_draw(drawsurf1,xsize=800,ysize=550,uname='drawwin')    

    drawlc=widget_draw(drawsurf1,xsize=800,ysize=450,uname='drawlc')
                 
;end draw widget

widget_control,root,set_uvalue=mydata
  
widget_control,base,/realize

drawwidget=widget_info(base,find_by_uname='drawwin')
widget_control,drawwidget,get_value=plotwin
wset,plotwin

pg_fitres_browser_plotsp,mydata

drawwidget=widget_info(base,find_by_uname='drawlc')
widget_control,drawwidget,get_value=plotwin
wset,plotwin

pg_fitres_browser_plotlc,mydata
  
xmanager,'pg_fitres_browser',root,/no_block

END












