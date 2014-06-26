;+
; NAME:
;
;   pg_fft_convolution
;
; PURPOSE:
;
;  perform 1-dimensional convolution (optionally correlation) by using FFT and
;  appropriate padding to avoid edge effects.
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
;
;
; INPUTS:
;
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
; nopad: if set, does not pad the arrays
;
; OUTPUTS:
;
;
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
; MODIFICATION HISTORY:
;
; written PG spring 2009
; 28-SEP-2009 PG investigate padding to see if it's correct
;
;-

FUNCTION pg_fft_2dim_convolution,x,y,correlation=correlation,nopad=nopad,xpad=xpad,ypad=ypad

;find sizes of input arrays
sx=size(x)
sy=size(y)

nx1=sx[1]
ny1=sx[2]
nx2=sy[1]
ny2=sy[2]

n1=max([nx1,nx2])
n2=max([ny1,ny2])


IF keyword_set(nopad) THEN BEGIN 

   IF keyword_set(correlation) THEN BEGIN 
      fftres=fft(fft(x,-1)*conj(fft(y,-1)),1)*n1*n2 
   ENDIF $
   ELSE BEGIN 
      fftres=fft(fft(x,-1)*fft(y,-1),1)*n1*n2    
   ENDELSE

   RETURN,(shift(fftres,n1/2,n2/2))

ENDIF $
ELSE BEGIN 


neff1=2LL^(ceil(alog(1.5*n1)/alog(2)))
neff2=2LL^(ceil(alog(1.5*n2)/alog(2)))

print,neff1,neff2

xpad=fltarr(neff1,neff2)
ypad=fltarr(neff1,neff2)

xpad[neff1/2-nx1/2,neff2/2-ny1/2]=x
ypad[neff1/2-nx2/2,neff2/2-ny2/2]=y

IF keyword_set(correlation) THEN BEGIN 
   fftres=fft(fft(xpad,-1)*conj(fft(ypad,-1)),1)*neff1*neff2 
ENDIF $
ELSE BEGIN 
   fftres=fft(fft(xpad,-1)*fft(ypad,-1),1)*neff1*neff2    
ENDELSE

;print,total(fftres)

RETURN,(shift(fftres,neff1/2,neff2/2))[neff1/2-n1/2:neff1/2+n1/2-1,neff2/2-n2/2:neff2/2+n2/2-1]

ENDELSE 

END

