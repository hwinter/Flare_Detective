;+
; NAME:
;
; pg_tetrachorrelate
;
; PURPOSE:
;
; calculates the confidence for correlation of a 2-dim data set using
; the tetrachoric method
;
; CATEGORY:
;
; statistics util
;
; CALLING SEQUENCE:
;
; confidence=pg_tetrachorrelate(x,y)
;
; INPUTS:
;
; x,y: array to be cross correlated (must have same number of points)
;
; OPTIONAL INPUTS:
;
; 
;
; KEYWORD PARAMETERS:
;
; plot: if set, plots the point and the division in sectors
;
; OUTPUTS:
;
;  confidence level for correaltion, between 0. and 1.
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
; as described in Marina's Diploma Thesis
;
; EXAMPLE:
;
; x=[1,3,4,6,8]
; y=[2,4,1,2,5]
; conf=pg_tetrachorrelate(x,y)
;
; AUTHOR:
; 
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; written 20-AUG-2004 PG
;
;-
FUNCTION pg_tetrachorrelate,x,y,plot=plot

;computes the median

xmed=median(x,/even)
ymed=median(y,/even)

;Number of elements in x,y
N=n_elements(x)

;number of elemnts in quadrant 'C': nquad_C

dummy=where((x GT xmed) AND (Y GT ymed),nquad_c)

q=4d*nquad_C/N-1d
chisq=q*N*q

conf=errorf(sqrt(chisq/2))

IF keyword_set(plot) THEN BEGIN
   dx=max(x)-min(x)
   dy=max(y)-min(y)

   plot,x,y,psym=1,xrange=[min(x)-0.1*dx,max(x)+0.1*dx] $
                  ,yrange=[min(y)-0.1*dy,max(y)+0.1*dy]
   oplot,[xmed,xmed],!Y.crange
   oplot,[!X.crange],[ymed,ymed]
ENDIF


RETURN,conf

END


; N=1000
; res=dblarr(N)
; .run
; for i=0,N-1 do begin
; x=randomn(seed,1000)
; y=randomn(seed,1000)
; res[i]=pg_tetrachorrelate(x,y)
; endfor
; end

; pg_plot_histo,res,binsize=0.1,yrange=[0,200]

; res2=dblarr(N)
; .run
; for i=0,N-1 do begin
; x=randomn(seed,10000)
; y=randomn(seed,10000)
; res2[i]=pg_tetrachorrelate(x,y)
; endfor
; END

; ;linecolors
; pg_plot_histo,res2,binsize=0.1,/over,color=12
