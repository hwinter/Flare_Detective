;+
; NAME:
;      hsi_background_subtract
;
; PURPOSE: 
;      background subtraction for a spectrogram 
;
; INPUTS:
;      spg: original spectrogram
;      timerange: the selected timerange
;      erange: the selected energy range
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
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

FUNCTION hsi_background_subtract,timerange=timerange,erange=erange,spg=spg

IF n_elements(erange) NE 2 THEN erange=[min(spg.y),max(spg.y)] $
ELSE erange=erange[sort(erange)]

CASE n_elements(timerange) OF

    2: BEGIN
        type=1
        timerange=timerange[sort(anytim(timerange))] 
    END

    4: BEGIN
        type=2
        timerange[0,*]=timerange[0,sort(anytim(timerange[0,*]))]
        timerange[1,*]=timerange[1,sort(anytim(timerange[1,*]))]
    END

    ELSE: BEGIN
        timerange=[min(spg.x),max(spg.x)]
        type=1
    END
ENDCASE
timerange=anytim(timerange)

qy=where(spg.y GE erange[0] AND spg.y LE erange[1])

IF type EQ 1 THEN $
qx=where(spg.x GE timerange[0] AND spg.x LE timerange[1]) $
ELSE $
IF type EQ 2 THEN BEGIN
    qx=where(spg.x GE timerange[0,0] AND spg.x LE timerange[0,1])
    qx2=where(spg.x GE timerange[1,0] AND spg.x LE timerange[1,1])
    xx2=spg.x[qx2]
ENDIF

xx=spg.x[qx]
yy=spg.y[qy]

tmp=spg.spectrogram

IF type EQ 1 THEN BEGIN
    FOR j=0,n_elements(yy)-1 DO BEGIN
        bg=0
        FOR i=0,n_elements(xx)-1 DO bg=bg+tmp[qx[i],qy[j]]
        tmp[*,qy[j]]=tmp[*,qy[j]]-bg/(n_elements(xx)-1)
    ENDFOR


    spg2={spectrogram:tmp,x:spg.x,y:spg.y}

    RETURN,spg2

ENDIF ELSE BEGIN

    FOR j=0,n_elements(yy)-1 DO BEGIN
        bg1=0
        bg2=0
        FOR i=0,n_elements(xx)-1 DO bg1=bg1+tmp[qx[i],qy[j]]
        FOR i=0,n_elements(xx2)-1 DO bg2=bg2+tmp[qx2[i],qy[j]]
        
        bg1=bg1/(n_elements(xx)-1)
        bg2=bg2/(n_elements(xx2)-1)


        t1=(max(xx)+min(xx))/2
        t2=(max(xx2)+min(xx2))/2

        m=(bg2-bg1)/(t2-t1)
        h=bg1-m*t1
            
        tmp[*,qy[j]]=tmp[*,qy[j]]-m*spg.x-h ;bg/(n_elements(xx)-1)

    ENDFOR


    spg2={spectrogram:tmp,x:spg.x,y:spg.y}

    RETURN,spg2

ENDELSE

END











