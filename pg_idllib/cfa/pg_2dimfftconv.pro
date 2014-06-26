;+
; NAME:
; 
;   pg_2dimfftconv
;
; PURPOSE:
;
;   computes the two dimensional convolution of two matrices a and b.
;   (of any size) or the two dimensional cross-correlation of the same matrices.
;
; CATEGORY:
;
;   image proceesing
;
; CALLING SEQUENCE:
;
;   corrmat=pg_2dimfftconv(a,b,correlation=correlation,nofft=nofft)
;
; INPUTS:
; 
;   a,b: the two matrices to convolve
; 
; OPTIONAL INPUTS:
;
;   None
;
; KEYWORD PARAMETERS:
;
;   correlation: if set, computes the cross correlation instead of the
;                convolution
;   nofft: uses the convolution/correlation sum instead of the fft
;          transform. This is much slower, but may be more accurate.
; 
; OUTPUTS:
;
;   corrmat: the convolution (or correlation if /correlation is set) matrix. 
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
;   Use the FFT <-> cross-correlation & convolution theorems. 
;   FFT(cross_correlation(a,b))=complex_conj(FFT(a))*FFT(b)
;   FFT(convolution(a,b))      =             FFT(a) *FFT(b)
;
;   If /nofft is set, computes the sum:
;   cij=sum_{k,l} (f_i-k,j-l * g_k,l) (convolution)
;   cij=sum_{k,l} (f_k-i,l-j * g_k,l) (correlation)
;
;   See also Fourier Analysis and Imaging, R. N. Bracewell, Kluwer 2003
;
; EXAMPLE:
;
; a=[[1,2,3],[4,5,6]]
; b=[[1,0,0],[1,1,1],[2,1,1]]  
; 
; AUTHOR:
; 
;  Paolo Grigis, pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
;  26-MAR-2008 written PG
;  31-MAR-2008 improved documentation and fixed behaviour for constant arrays input
;  17-APR-2008 corrected
;-

FUNCTION pg_2dimfftconv,a,b,aa=aa,bb=bb,same=same $
                       ,noabs=noabs,nofft=nofft,correlation=correlation $
                       ,sum=sum

s1=size(a)
s2=size(b)

IF (s1[0] EQ 0 OR s1[0] GT 2) OR ( s2[0] EQ 0 OR s2[0] GT 2) THEN BEGIN    
   print,'Invalid input.Please input two 1 or 2-dimensional arrays.'
   return,-1
ENDIF

IF s1[0] EQ 0 AND s2[0] EQ 0 THEN BEGIN    
   print,'Invalid input. At least one array must be two dimensional.'
   return,-1
ENDIF


IF s1[0] EQ 1 THEN BEGIN 
   nx1=s1[1]
   nx2=1
ENDIF $ 
ELSE BEGIN 
   nx1=s1[1]
   ny1=s1[2]
ENDELSE

IF s2[0] EQ 1 THEN BEGIN 
   nx2=s2[1]
   ny2=1
ENDIF ELSE BEGIN
   nx2=s2[1]
   ny2=s2[2]
ENDELSE

totx=nx1+nx2-1
toty=ny1+ny2-1

aa=fltarr(totx,toty)
bb=fltarr(totx,toty)
aa[0,0]=a
bb[nx1-1,ny1-1]=b


IF keyword_set(nofft) THEN BEGIN 

   res=fltarr(totx,toty)

   IF keyword_set(sum) THEN BEGIN 
     IF keyword_set(correlation) THEN BEGIN 
       FOR i=0,totx-1 DO BEGIN 
           FOR j=0,toty-1 DO BEGIN 
              ;print,' '
              sum=0
              FOR k=i,totx-1 DO BEGIN 
                 FOR l=j,toty-1 DO BEGIN 
                    ;print,string(k-i),string(l-j),string(k),string(l),' '
                    sum+=(aa[k-i,l-j]*bb[k,l])
                 ENDFOR
              ENDFOR
              res[i,j]=sum
              ;print,i,j,sum
           ENDFOR
        ENDFOR 
    ENDIF $
     ELSE BEGIN 
       ;print,'Ciao'
        FOR i=0,totx-1 DO BEGIN 
           FOR j=0,toty-1 DO BEGIN 
              sum=0
              FOR k=0,i DO BEGIN 
                 FOR l=0,j DO BEGIN 
                    IF k LT nx2 AND l LT ny2 THEN sum+=(aa[i-k,j-l]*bb[k+nx1-1,l+ny1-1])
                 ENDFOR
              ENDFOR
              res[i,j]=sum
           ENDFOR
        ENDFOR
     ENDELSE
   ENDIF $ 
   ELSE BEGIN 
      IF keyword_set(correlation) THEN BEGIN 
         FOR j=0,ny2-1 DO BEGIN 
            FOR i=0,nx2-1 DO BEGIN 
               res[totx-nx1-i:totx-i-1,toty-ny1-j:toty-j-1]+=a*b[i,j]
            ENDFOR
         ENDFOR
         res=rotate(res,2)
      ENDIF $ 
      ELSE BEGIN 
         FOR j=0,ny2-1 DO FOR i=0,nx2-1 DO BEGIN 
            res[i:i+nx1-1,j:j+ny1-1]+=a*b[i,j]
         ENDFOR
      ENDELSE
   ENDELSE
ENDIF $
ELSE BEGIN 
   IF keyword_set(correlation) THEN BEGIN 
      IF keyword_set(noabs) THEN res=shift(fft(conj(fft(aa,-1,/double))*fft(bb,-1,/double),1,/double)*n_elements(aa),nx2,ny2) $
      ELSE res=double(shift(fft(conj(fft(aa,-1,/double))*fft(bb,-1,/double),1,/double)*n_elements(aa),0,0))
   ENDIF $ 
   ELSE BEGIN 
      IF keyword_set(noabs) THEN res=shift(fft(fft(aa,-1,/double)*fft(bb,-1,/double),1,/double)*n_elements(aa),nx2,ny2) $
      ELSE res=double(shift(fft(fft(aa,-1,/double)*fft(bb,-1,/double),1,/double)*n_elements(aa),nx2,ny2))
   ENDELSE
ENDELSE

RETURN,res 

END





