;+
; NAME:
;
; pg_getgaussian
;
; PURPOSE:
;
; returns a gaussian curve with given average value and standard deviation
;
; CATEGORY:
;
; util, statistics
;
; CALLING SEQUENCE:
;
; y=pg_getgaussian(min=min,max=max,avg=avg,stdev=stdev,N=N,x=x)
;
; INPUTS:
;
; min,max: minimum,maximum value
; avg: average of the gaussian funxtion
; stdev: standard deviation
; N: number of points (default:1001)
; 
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
; y: y array of the distrivbution values
; x: corrwsponding x values
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
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
;
; 
; MODIFICATION HISTORY:
;
; 06-SEP-2004 written
; 
;-

FUNCTION pg_getgaussian,min=min,max=max,avg=avg,stdev=stdev,N=N,x=x

 
min=fcheck(min,-10d)
max=fcheck(max,10d) 
avg=fcheck(avg,0d)
stdev=fcheck(stdev,1d)
N=fcheck(N,1001)

x=findgen(N)/(N-1)*(max-min)+min

;dx=double(max-min)/N

A=1/sqrt(2*!DPi)/stdev
y=A*exp(-0.5*((x-avg)/stdev)^2);*dx

return,y
  
END
