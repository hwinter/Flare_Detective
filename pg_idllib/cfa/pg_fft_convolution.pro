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
;
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
;-

FUNCTION pg_fft_convolution,x,y,correlation=correlation,nopad=nopad

nx=n_elements(x)
ny=n_elements(y)

n=max([nx,ny])

IF keyword_set(nopad) THEN BEGIN 

IF keyword_set(correlation) THEN BEGIN 
   fftres=fft(fft(x,-1)*conj(fft(y,-1)),1)*n 
ENDIF $
ELSE BEGIN 
   fftres=fft(fft(x,-1)*fft(y,-1),1)*n    
ENDELSE

ENDIF $
ELSE BEGIN 


neff=2LL^(ceil(alog(1.5*n)/alog(2)))

xpad=fltarr(neff)
ypad=fltarr(neff)

xpad[neff/2-nx/2]=x
ypad[neff/2-ny/2]=y

IF keyword_set(correlation) THEN BEGIN 
   fftres=fft(fft(xpad,-1)*conj(fft(ypad,-1)),1)*neff 
ENDIF $
ELSE BEGIN 
   fftres=fft(fft(xpad,-1)*fft(ypad,-1),1)*neff    
ENDELSE

;print,total(fftres)

RETURN,(shift(fftres,neff/2))[neff/2-n/2:neff/2+n/2-1]

ENDELSE 

END

