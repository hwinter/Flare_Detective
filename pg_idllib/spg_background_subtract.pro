;+
; NAME:
;      spg_background_subtract
;
; PURPOSE: 
;      background subtraction for a spectrogram 
;
; INPUTS:
;      spg: original spectrogram
;      timerange: the selected background timerange(s)
;                 allowed formats:
;                 array[2]: constant background sub (mean value in
;                 interval)
;                 array[2,2]: two time intvs background (linear interp 
;                             between average values at average times)
; 
;
;      erange: the selected energy range(s)
;  
; OUTPUTS:
;      returns the background subtracted spg
;      
; KEYWORDS:
;        
;
; HISTORY:
;       15-OCT-2002 written
;       25-OCT-2002 added two time intervals background
;       06-MAY-2002 renamed & tested
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

FUNCTION spg_background_subtract,spg,timerange=timerange,erange=erange $
                                ,help=help

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;documentation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IF keyword_set(help) THEN BEGIN

    print,''
    print,'Background subtraction routine SPG_BACKGROUND_SUBTRACT'
    print,''
    print,'Inputs:'
    print,'spg: a spectrogram, i.e. a structure {spectrogram,x,y}, '
    print,'     where spectrogram is a array NxM of data, x an array N'
    print,'     of times in the default format output by "anytim" and'
    print,'     y an array M of y-values for the data.'
    print,'timerange: the selected background timerange(s), it can be:'
    print,'           array[2] for constant background subtraction OR'
    print,'           array[2,2] for a linear interpolated background'
    print,'erange: the y range over which background subtraction should'
    print,'        be applied'
    print,''
    print,'Usage:'
    print,'out_spg=spg_background_subtract(spg,timerange=timerange, $'
    print,'erange=erange)'
    print,''
    
    RETURN,-1

ENDIF


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;checks input and/or sets default
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

spgout=spg

IF n_elements(erange) NE 2 THEN $
    erange=[min(spg.y),max(spg.y)] 

CASE n_elements(timerange) OF

    2: BEGIN ;simple interval
        type=1
        timer=anytim(timerange[sort(anytim(timerange))]) 
    END

    4: BEGIN ;array 2x2 of the two intervals
        type=2
        timer=timerange
        timer[0,*]=timerange[0,sort(anytim(timerange[0,*]))]
        timer[1,*]=timerange[1,sort(anytim(timerange[1,*]))]
        timer=anytim(timer)
    END

    ELSE: BEGIN ;if no range is provided, defaults to the whole spg range
        type=1
        timer=anytim([min(spg.x),max(spg.x)])
    END

ENDCASE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;find where background is to be computed in the data array
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

qy=where(spg.y GE erange[0] AND spg.y LE erange[1])

IF qy[0] EQ -1 THEN RETURN,spgout

IF type EQ 1 THEN BEGIN

   qx=where(spg.x GE timer[0] AND spg.x LE timer[1]) 
   IF qx[0] EQ -1 THEN RETURN,spgout


ENDIF ELSE BEGIN

    qx=where(spg.x GE timer[0,0] AND spg.x LE timer[1,0])
    qx2=where(spg.x GE timer[0,1] AND spg.x LE timer[1,1])
    
    IF (qx[0] EQ -1) OR (qx2[0] EQ -1) THEN RETURN,spgout
    
    xx2=spg.x[qx2]

ENDELSE

xx=spg.x[qx]
yy=spg.y[qy]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;background subtraction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



tmp=spg.spectrogram

IF type EQ 1 THEN BEGIN  ; one time interval

    FOR j=0,n_elements(yy)-1 DO BEGIN ;for each lightcurve

        bg=total(tmp[qx,qy[j]])/n_elements(qx) ;average background value

        tmp[*,qy[j]]=tmp[*,qy[j]]-bg  ; new data= old data - const

    ENDFOR

ENDIF ELSE BEGIN ;type=2, 2 time intervals

    FOR j=0,n_elements(yy)-1 DO BEGIN ;for each lightcurve

        bg1=total(tmp[qx,qy[j]])/(n_elements(qx))       ;average value of
        bg2=total(tmp[qx2,qy[j]])/(n_elements(qx2))     ;the background   

        t1=(max(xx)+min(xx))/2.       ;"mean" time
        t2=(max(xx2)+min(xx2))/2.

        m=(bg2-bg1)/(t2-t1)           ;straight line parameters
        h=bg1-m*t1

        tmp[*,qy[j]]=tmp[*,qy[j]]-m*spg.x-h ;new data=old data - straight line

    ENDFOR

ENDELSE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;final data handling and return values
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

spgout.spectrogram=tmp

RETURN,spgout

END











