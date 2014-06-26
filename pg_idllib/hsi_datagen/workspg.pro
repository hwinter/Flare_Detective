;+
; NAME:
;      workspg
;
; PURPOSE: 
;      interactive spg manipulation 
;
; INPUTS:
;      inspg: a spectrogram
;  
; OUTPUTS:
;      zoompar: selected part of the spectrogram
;      backpar: selected background part
;
; KEYWORDS:
;        
;
; HISTORY:
;        14-OCT-2002 written
;  up to 21-OCT-2002 added more commands & extended functionality
;        24-APR-2003 start to convert to use the new plot_spg
;        routine... 
;        28-APR-2003 more or less working now...
;        24-JUN-2003 changed to work with new version of spectro_plot
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

@utcommon

;-----------------------------------------------------------
;mouse interval select
;-----------------------------------------------------------

FUNCTION select,spg,xonly=xonly,yonly=yonly;

;
;keywords (x,y)only: select only an x or y interval, if they aren't
;set an interval in both axis is returned
;

COMMON utcommon

plotx=spg.x
ploty=spg.y
plotim=spg.spectrogram

!mouse.button=0
clicks=0
xint=0 & yint=0
oldx=0 & oldy=0

WHILE (!mouse.button NE 4) AND (clicks LE 1) DO BEGIN
    cursor,xint,yint,/data,/down

    xarrint=where(abs(plotx-(utbase+xint)) EQ $
                      min(abs(plotx-(utbase+xint))))

    yarrint=min(where(abs(ploty-yint) EQ min(abs(ploty-yint))))



    IF !mouse.button EQ 1 THEN BEGIN
        IF clicks EQ 0 THEN BEGIN
            oldx=xarrint
            oldy=yarrint
        ENDIF

        clicks=clicks+1
    ENDIF
    ;print,clicks
ENDWHILE

;
;position is sorted
;
IF oldx GT xarrint THEN BEGIN
    tmp=oldx
    oldx=xarrint
    xarrint=tmp
ENDIF
IF oldy GT yarrint THEN BEGIN
    tmp=oldy
    oldy=yarrint
    yarrint=tmp
ENDIF

;
;output depends on keyword settings
;
IF keyword_set(xonly) THEN position=[oldx,xarrint] ELSE $
    IF keyword_set(yonly) THEN position=[oldy,yarrint] ELSE $
        position=[oldx,oldy,xarrint,yarrint]

return,position

END


;-----------------------------------------------------------------
;mouse point selection & print coordinates on the IDL command line
;-----------------------------------------------------------------

PRO pointselect,spg

COMMON utcommon

;print,utbase

!mouse.button=0
clicks=0
xint=0 & yint=0

plotx=spg.x
ploty=spg.y
plotim=spg.spectrogram

WHILE (!mouse.button NE 4) DO BEGIN
    cursor,xint,yint,/data,/down
    IF !mouse.button EQ 1 THEN BEGIN

        xarrint=where(abs(plotx-(utbase+xint)) EQ $
                      min(abs(plotx-(utbase+xint))))

        yarrint=min(where(abs(ploty-yint) EQ min(abs(ploty-yint))))

        print,'Energy: ',yint,' keV'
        print,'Time  : ',anytim(xint+utbase,/yohkoh)
        ;print,'x'+string(xarrint)
        ;print,'y'+string(yarrint)
        print,'Value : ',plotim[xarrint,yarrint]
    ENDIF
ENDWHILE

END


;------------------------------------------------------------------
;spectrogram draw routine
;------------------------------------------------------------------

PRO spg_draw,spg,no_interpolate=no_interpolate,ylog=ylog

im=spg.spectrogram>0
x=spg.x
y=spg.y

;plotim=congrid(im,winxsize,winysize)
;plotx=congrid(x,winxsize)
;ploty=congrid(y,winysize)

;plotspg={spectrogram:plotim,x:plotx,y:ploty}

;plotimtv=alog(1+(plotim>0))
;plotimtv=255./(max(plotimtv)-min(plotimtv))*plotimtv
;tv,plotimtv
;stop
spectro_plot,im,x,y,no_interpolate=no_interpolate,ylog=ylog,/zlog $
            ,xstyle=1,ystyle=1

;print,min(plotim)
;print,max(plotim)

;return,plotspg

END

;------------------------------------------------------------------
;main routine
;------------------------------------------------------------------

PRO workspg,inspg=inspg,zoompar=zoompar,backpar=backpar $
           ,no_interpolate=no_interpolate,ylog=ylog



@utcommon

COMMON utcommon

IF not keyword_set(no_interpolate) THEN no_interpolate=0
IF not keyword_set(ylog) THEN ylog=0


IF not exist(inspg) THEN BEGIN
    print,'Input a spectrogram!'
    return
END

winxsize=800
winysize=600
window,xsize=winxsize,ysize=winysize,/free

zoompar=[min(inspg.x),min(inspg.y),max(inspg.x),max(inspg.y)]
;zoompar: min time, min energy, max time, max energy

backpar=[0,0,0,0]

;
;first plot of the spg
;

spg_draw,inspg,no_interpolate=no_interpolate,ylog=ylog


;
;enter command mode
;

input=''

WHILE (input[0] NE 'q') DO BEGIN

    pos=0

    print,'Commands: q -quits t -select time interval s: select energy & time range'
    print,'c -print coordinates of the point z -zoom u -unzoom b -background subtraction '
    print,'n -no background subtraction o -background subtraction time only'
    
    print,'my -manual zoom (y axis only) i -print info about spg'

    print,'v -plot vertical slice h: -plot horizntal slice y -toggle ylog'

    print,'a -toggle smoothing'
    
    read,'>',input
    CASE input[0] OF
                                ;quit
        'q' : print,'quitting...'

                                ;select time interval
        't' : BEGIN
            pos=select(inspg,/xonly)
            IF total(pos) GT 0 THEN $
              print,anytim([inspg.x[pos[0]],inspg.x[pos[1]]],$
                           /yohkoh) $
            ELSE print,'No interval selected'              
        END

                                ;select energy & time interval
        's' : BEGIN
            pos=select(inspg)
            IF total(pos) GT 0 THEN BEGIN
                print,'Energy: ',inspg.y[pos[1]],' - ',$
                      inspg.y[pos[3]],' keV'
                print,anytim([inspg.x[pos[0]],inspg.x[pos[1]]],$
                             /yohkoh)
            ENDIF ELSE print,'No interval selected'              
        END
        
                                ;print coordinates
        'c' : pointselect,inspg

                                ;zoom
        'z' : BEGIN
            pos=select(inspg)
            IF total(pos) GT 0 THEN BEGIN
                zoompar=[inspg.x[pos[0]],inspg.y[pos[1]],$
                         inspg.x[pos[2]],inspg.y[pos[3]]]
                
                spg=inspg
                IF total(backpar) GT 0 THEN $
                  spg=hsi_background_subtract(timerange=[backpar[0],backpar[2]],$
                                              erange=[backpar[1],backpar[3]],$
                                              spg=inspg)                
                
                spg=hsi_spg_reduce(timerange=[zoompar[0],zoompar[2]],$
                                   erange=[zoompar[1],zoompar[3]],spg=spg)

                spg_draw,spg,no_interpolate=no_interpolate,ylog=ylog
                

            ENDIF ELSE print,'No interval selected'              

        END

                                ;unzoom
        'u' : BEGIN

            zoompar=[min(inspg.x),min(inspg.y),max(inspg.x),max(inspg.y)]

            spg=inspg
            IF total(backpar) GT 0 THEN $
              spg=hsi_background_subtract(timerange=[backpar[0],backpar[2]]$
                                          ,erange=[backpar[1],backpar[3]]$
                                          ,spg=inspg)

            spg=hsi_spg_reduce(timerange=[zoompar[0],zoompar[2]]$
                               ,erange=[zoompar[1],zoompar[3]],spg=spg)

            spg_draw,spg,no_interpolate=no_interpolate,ylog=ylog
            
        END  
        
                                ;no background sub
        'n' : BEGIN

            spg=hsi_spg_reduce(timerange=[zoompar[0],zoompar[2]]$
                               ,erange=[zoompar[1],zoompar[3]],spg=inspg)

            spg_draw,spg,no_interpolate=no_interpolate,ylog=ylog
            
            backpar=[0,0,0,0]
            
        END    

                                ;background subtraction time only
        'o' : BEGIN
            pos=select(inspg,/xonly)

            IF total(pos) GT 0 THEN BEGIN
                
                backpar=[inspg.x[pos[0]],min(inspg.y),inspg.x[pos[1]],max(inspg.y)]

                spg=hsi_background_subtract(timerange=[backpar[0],backpar[2]]$
                                            ,erange=[backpar[1],backpar[3]]$
                                            ,spg=inspg)                
                
                spg=hsi_spg_reduce(timerange=[zoompar[0],zoompar[2]],$
                                   erange=[zoompar[1],zoompar[3]],spg=spg)

                spg_draw,spg,no_interpolate=no_interpolate,ylog=ylog
                
            ENDIF $
            ELSE print,'No interval selected'     
        END

        'b' : BEGIN
            pos=select(inspg)

            IF total(pos) GT 0 THEN BEGIN
                
                backpar=[inspg.x[pos[0]],inspg.y[pos[1]],$
                         inspg.x[pos[2]],inspg.y[pos[3]]]
                
                spg=hsi_background_subtract(timerange=[backpar[0],backpar[2]],$
                                            erange=[backpar[1],backpar[3]],$
                                            spg=inspg)

                spg=hsi_spg_reduce(timerange=[zoompar[0],zoompar[2]],$
                                   erange=[zoompar[1],zoompar[3]],spg=spg)

                spg_draw,spg,no_interpolate=no_interpolate,ylog=ylog
                
            ENDIF $
            ELSE print,'No interval selected'     
        END
                                ;manual (y) zoom
        'm'  : BEGIN
            print,'Low energy range (keV):'
            read,len
            print,'High energy range (keV):'
            read,hen

            zoompar[1]=[len]
            zoompar[3]=[hen]
            
            spg=inspg
            IF total(backpar) GT 0 THEN $
              spg=hsi_background_subtract(timerange=[backpar[0],backpar[2]],$
                                          erange=[backpar[1],backpar[3]],$
                                          spg=inspg)                
            
            spg=hsi_spg_reduce(timerange=[zoompar[0],zoompar[2]],$
                               erange=[zoompar[1],zoompar[3]],spg=spg)

            spg_draw,spg,no_interpolate=no_interpolate,ylog=ylog
            

        END

                                ;print info
        'i'  : BEGIN

            ;print,'Segment used : '+hsi_seg2str(inspg.segment)
            print,'Time interval: '+anytim(min(inspg.x),/yohkoh)+' - '$
                  +anytim(max(inspg.x),/yohkoh)

        END

                                ;plot vertical slice
        'v'  : BEGIN

            spgx=!X
            spgy=!Y

            spgwin=!D.WINDOW
            window,xsize=600,ysize=400,/free
            pwin=!D.WINDOW
            wset,spgwin
            
            !mouse.button=0
            clicks=0
            xint=0 & yint=0

            plotx=inspg.x
            ploty=inspg.y
            plotim=inspg.spectrogram
 
            WHILE (!mouse.button NE 4) DO BEGIN

                !X=spgx
                !Y=spgy      
                cursor,xint,yint,/data,/down

                xarrint=where(abs(plotx-(utbase+xint)) EQ $
                              min(abs(plotx-(utbase+xint))))

                yarrint=min(where(abs(ploty-yint) EQ min(abs(ploty-yint))))

                IF !mouse.button NE 0 THEN BEGIN
                    wset,pwin
                    plot,ploty,plotim[xarrint,*]>1e-2 $;,yrange=[0.1,max(plotim[xarrint,*])] $
                         ,/ylog,xrange=[zoompar[1],zoompar[3]],/xlog,xstyle=1
                    wset,spgwin
                ENDIF
            ENDWHILE

            wdelete,pwin

            spg=inspg
            IF total(backpar) GT 0 THEN $
            spg=hsi_background_subtract(timerange=[backpar[0],backpar[2]],$
                                          erange=[backpar[1],backpar[3]],$
                                          spg=inspg)                
            
            spg=hsi_spg_reduce(timerange=[zoompar[0],zoompar[2]],$
                               erange=[zoompar[1],zoompar[3]],spg=spg)

            spg_draw,spg,no_interpolate=no_interpolate,ylog=ylog
            
            
        END


                               ;plot horizontal slice
        'h'  : BEGIN


            spgx=!X
            spgy=!Y
            spgwin=!D.WINDOW
            window,xsize=600,ysize=400,/free
            pwin=!D.WINDOW
            wset,spgwin
            
            !mouse.button=0
            clicks=0
            xint=0. & yint=0.

            plotx=inspg.x
            ploty=inspg.y
            plotim=inspg.spectrogram

            WHILE (!mouse.button NE 4) DO BEGIN
                !X=spgx
                !Y=spgy
                cursor,xint,yint,/data,/down

                IF !mouse.button NE 0 THEN BEGIN
                xarrint=where(abs(plotx-(utbase+xint)) EQ $
                              min(abs(plotx-(utbase+xint))))

                yarrint=min(where(abs(ploty-yint) EQ min(abs(ploty-yint))))

                ;print,'energy= '+string(ploty[yarrint])
                ;print,yint,yarrint

                    wset,pwin
                    utplot,plotx-utbase,plotim[*,yarrint],utbase $
                          ,yrange=[0.1,max(plotim[*,yarrint])] $
                          ,timerange=anytim([zoompar[0],zoompar[2]],/yohkoh) $
                          ,/ylog,xstyle=1

                    wset,spgwin
                ENDIF
            ENDWHILE
            clear_utplot
            wdelete,pwin

            spg=inspg
            IF total(backpar) GT 0 THEN $
            spg=hsi_background_subtract(timerange=[backpar[0],backpar[2]],$
                                          erange=[backpar[1],backpar[3]],$
                                          spg=inspg)                
            
            spg=hsi_spg_reduce(timerange=[zoompar[0],zoompar[2]],$
                               erange=[zoompar[1],zoompar[3]],spg=spg)

            spg_draw,spg,no_interpolate=no_interpolate,ylog=ylog

        END


        'y'  : BEGIN    ; toggle y logarithm
 
            ylog=1-ylog
            ;spg=inspg
            
            spg=hsi_spg_reduce(timerange=[zoompar[0],zoompar[2]],$
                               erange=[zoompar[1],zoompar[3]],spg=inspg)

            spg_draw,spg,no_interpolate=no_interpolate,ylog=ylog
            

        END

        'a'  : BEGIN    ; toggle smoothing
 
            no_interpolate=1-no_interpolate
            ;spg=inspg
            
            spg=hsi_spg_reduce(timerange=[zoompar[0],zoompar[2]] $
                              ,erange=[zoompar[1],zoompar[3]],spg=inspg)

            spg_draw,spg,no_interpolate=no_interpolate,ylog=ylog
            

        END


        
        ELSE : print,'this is not a valid command, try again. press ''q'' to quit'

    ENDCASE
    
ENDWHILE

END







