;+
; NAME:
;
; pg_align
;
; PURPOSE:
;
; image alignment
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
;  im1,im2: two 2-dimensional images
;
; OPTIONAL INPUTS:
;
;  lag: the lag range to use for cross correlation (default: 8)
;       Must be larger than both the x and y difference expected from the two
;       images 
;  darr: "delta-array": size of the chunk of the array aroound the maximum
;        that is fitted by a 2-dim quadratic function
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
; AUTHOR:
;
; Paolo Grigis, pgrigis@cfa.harvard.edu
; 
; MODIFICATION HISTORY:
;
;-


;; FUNCTION pg_align_quadfun,x,par
  
;;   n=n_elements(x)

;;   xx=x[0:n/2-1]
;;   yy=x[n/2:n-1]

;;   RETURN,xx*(par[0]*xx+par[3]+par[1]*yy)+yy*(par[2]*yy+par[4])+par[5]

;; END

FUNCTION pg_align,im1,im2,lag=lag,darr=darr,absmethod=absmethod,cc1=cc1 $
                 ,fftmethod=fftmethod,noedge_truncate=noedge_truncate,pad=pad


s1=size(im1)
s2=size(im2)

IF s1[0] NE 2 OR s2[0] NE 2 THEN BEGIN 
   print,'Need 2-dimensional images for alignment'
   return,-1
ENDIF

nx=s1[1]
ny=s1[2]

IF nx NE s2[1] OR ny NE s2[2] THEN BEGIN 
   print,'The two images must have the same dimensions'
   return,-1
ENDIF

lag=fcheck(lag,8)
darr=fcheck(darr,2)



IF keyword_set(absmethod) THEN BEGIN 
   
;   mask=replicate(0B,nx,ny)
;   mask[lag:nx-lag-1,lag:ny-lag-1]=1

   lagx=indgen(2*lag+1)-lag
   lagy=lagx
   larr=dblarr(2*lag+1,2*lag+1)
   FOR i=0,2*lag DO BEGIN 
      FOR j=0,2*lag DO BEGIN 
         larr[i,j]=total(abs((shift(im1,lagx[i],lagy[j])-im2)[lag:nx-lag-1,lag:ny-lag-1]))
      ENDFOR
   ENDFOR
   cc1=max(larr)-larr
ENDIF ELSE BEGIN
   IF keyword_set(fftmethod) THEN BEGIN 
         iim1=im1
         iim2=im2

         cc1=pg_2dimfftcorr(im1,im2)
  
   ENDIF $
   ELSE BEGIN 
      cc1=pg_2dimcorr(im1,im2,xlag=lag,ylag=lag,edge_truncate=1-keyword_set(noedge_truncate))
   ENDELSE
ENDELSE

print,'Running'


s=size(cc1)
res=pg_fit2dimparpeak(cc1,nsquare=darr)-[s[1],s[2]]/2

;;dummy=max(cc1,ind)
;;twodimind=array_indices(cc1,ind)

;;cc1part=cc1[(twodimind[0]-darr)>0:(twodimind[0]+darr)<(2*lag),(twodimind[1]-darr)>0:(twodimind[1]+darr)<(2*lag)]


;; nx=2*darr+1
;; ny=nx

;; x=findgen(nx)-nx/2
;; y=findgen(ny)-ny/2

;; xx=x#(y*0+1)
;; yy=(x*0+1)#y
;; xd=reform(xx,nx*ny)
;; yd=reform(yy,nx*ny)

;; par0=[1.,0.,1,0,0,0]
;; par=mpfitfun('pg_align_quadfun',[xd,yd],cc1part,0.1,par0,/quiet)

;; discr=4*par[0]*par[2]-par[1]^2

;; x0=(-2*par[2]*par[3]+  par[1]*par[4])/discr
;; y0=(   par[1]*par[3]-2*par[0]*par[4])/discr

;;pos=[twodimind[0]+x0-lag,twodimind[1]+y0-lag]

RETURN,res

END




