;+
; NAME:
;
;  pg_variance_analysis
;
; PURPOSE:
;
; from an image cube extract some info about variance.
;
; CATEGORY:
;
; statistic util, data cubes
;
; CALLING SEQUENCE:
;
; res=pg_variance_analysis(datacube,binsize=binsize)
;
; INPUTS:
;
; datacube:an nx by ny by nim cube of floats or doubles
;
; OPTIONAL INPUTS:
;
; binsize:number of images for each time interval to be analyzed.
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;  variance: a nx by ny by nim/binsize datacube with the variance
;  average:  a nx by ny by nim/binsize datacube with the average
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

PRO pg_variance_analysis,imcube,binsize=binsize,variance=variance,average=average,onedim=onedim

thebinsize=round(fcheck(binsize,50))

s=size(imcube)

IF keyword_set(onedim) THEN BEGIN 
   nim=s[1]
;   nimout=nim/thebinsize

   variance=fltarr(nim)
   average=fltarr(nim)

   FOR i=thebinsize/2,nim-1-thebinsize/2 DO BEGIN 
   
      thisimcube=imcube[i-thebinsize/2:i+thebinsize/2-1]
      a=moment(thisimcube,maxmoment=2)
   
      variance[i]=a[1]
      average[i]=a[0]

   ENDFOR
   
   RETURN

ENDIF


IF s[0] NE 3 THEN BEGIN 
   print,'Invalid input. Need 3-dimensional image cube nx by ny by nimages.'
   RETURN
ENDIF

nx=s[1]
ny=s[2]
nim=s[3]

nimout=nim/thebinsize

variance=fltarr(nx,ny,nimout)
average=fltarr(nx,ny,nimout)

FOR i=0,nimout-1 DO BEGIN 
   
   print,i

   thisimcube=imcube[*,*,i*thebinsize:(i+1)*thebinsize-1]
   pg_moment,thisimcube,3,mean=mean,var=var,maxmoment=2
   
   variance[*,*,i]=var
   average[*,*,i]=mean

ENDFOR


END

