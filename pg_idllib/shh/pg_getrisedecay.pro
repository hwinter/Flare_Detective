;+
; NAME:
;      pg_getrisedecay
;
; PURPOSE: 
;      automatically find rise and decay phases from a lightcurve
;
; CALLING SEQUENCE:
;      res=pg_getrisedecay(lc)
;
; INPUTS:
;      lc: a lightcurve
;
;
; KEYWORDS:
;      
;
; OUTPUT:
;     a structure TBD
;       
;
; COMMENT:
;      
;
; EXAMPLE   
;  
;
;
; VERSION:
;       
;
;
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;
; HISTORY:
;       16-NOV-2006 written PG
;
;-

;.comp pg_getrisedecay
;res=pg_getrisedecay(y,minflux=20.)

FUNCTION pg_getrisedecay,lcin,winwidth=winwidth,minflux=minflux,proxind=proxind

lc=lcin

n=n_elements(lc)
xlc=findgen(n)

winwidth=fcheck(winwidth,5.)
minflux=fcheck(minflux,0.)
proxind=fcheck(proxind,3)


indzero=where(lc LE minflux,count)
IF count GT 0 THEN lc[indzero]=!values.f_nan

indnan=where(NOT finite(lc),countnan)
indfin=where(finite(lc),countfin)

resmax=lc*0
resmin=lc*0

FOR i=winwidth,n-1-winwidth DO BEGIN 
   y=lc[i-winwidth:i+winwidth]
   dummy=max(y,indmax,/nan)
   dummy=min(y,indmin,/nan)

   IF indmax EQ winwidth THEN resmax[i]=1
   IF indmin EQ winwidth THEN resmin[i]=1

ENDFOR

maxind=where(resmax EQ 1)
minind=where(resmin EQ 1)

temp=[minind,maxind]
sortind=temp[sort(temp)]

proximity1=shift(sortind,-1)-sortind
proximity2=sortind-shift(sortind,1)


indchange=where(((proximity1 GE proxind) AND (proximity2 GE proxind)),count)

IF count GT 0 THEN RETURN,sortind[indchange] ELSE return,-1

END



; plot,xlc,lc,/ylog
; ;oplot,xlc[maxind],lc[maxind],psym=6,color=12
; ;oplot,xlc[minind],lc[minind],psym=6,color=5

; oplot,xlc[sortind],lc[sortind],psym=6,color=2

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; increasefactor=shift(lc[shift(sortind,-1)]/lc[sortind],1)
; decreasefactor=lc[shift(sortind,1)]/lc[sortind]
; proximity1=shift(sortind,-1)-sortind
; proximity2=sortind-shift(sortind,1)

; indchange=where( (increasefactor GE 2 OR decreasefactor GE 2) AND $
;                  ((proximity1 GE 3) AND (proximity2 GE 3)))
; ;oplot,xlc[sortind[ind2]],lc[sortind[ind2]],psym=6,color=12
; ;ind3=where((proximity1 GE 2))
; ;oplot,xlc[sortind[ind3]],lc[sortind[ind3]],psym=6,color=10
; ;ind4=where((proximity2 GE 2))
; ;oplot,xlc[sortind[ind4]],lc[sortind[ind4]],psym=6,color=6
; ;ind5=where((proximity1 GE 2) AND (proximity2 GE 2))
; ;oplot,xlc[sortind[ind5]],lc[sortind[ind5]],psym=2

; bigincordec=where((ind1 OR ind2) AND ind5)


; ;bigincordec=1+where(((increasefactor GE 1.4) OR $
; ;                     (decreasefactor GE 1.4)    ) AND $
; ;                    ((proximity1 GE 2) AND $
; ;                     (proximity2 GE 2)))


; oplot,xlc[sortind[indchange]],lc[sortind[indchange]],psym=6,color=5


; nextind=where(abs(sortind - shift(sortind,-1)) LE 3)

; sortind[nextind]=-1
; sortind2=sortind[where(sortind GE 0)]

; plot,xlc,lc,yrange=[0,100];,/ylog
; oplot,xlc[sortind2],lc[sortind2],psym=4,color=2

; ;seem accepatble --> see where flux increase by, say, 50% or more
; plot,xlc,lc,yrange=[0,100];,/ylog
; oplot,xlc[sortind2],lc[sortind2],psym=4,color=2


; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



; nfit=20

; sl=lc

; plot,xlc,lc,/ylog


; indstop=160
; y= lc[0:indstop]

; aa=lc[130:180]
; aa=lc[505:516]

; ;Result = TS_FCAST(aa,2,100)
; ;doesn't work..

; plot,findgen(50),aa,yrange=[0,5000];,color=12
; oplot,findgen(50),aa,color=12

; oplot,lc[505:700]
; oplot,[aa,result]
; oplot,[aa,result]


; plot,lc[0:indstop+30]


; ; Define an n-element vector of time-series samples:  
; X = [6.63, 6.59, 6.46, 6.49, 6.45, 6.41, 6.38, 6.26, 6.09, 5.99, $  
;      5.92, 5.93, 5.83, 5.82, 5.95, 5.91, 5.81, 5.64, 5.51, 5.31, $  
;      5.36, 5.17, 5.07, 4.97, 5.00, 5.01, 4.85, 4.79, 4.73, 4.76]  
  
; ; Compute and print five future values of the time-series using ten   
; ; time-series values:  
; PRINT, TS_FCAST(X, 10, 5)  
 









