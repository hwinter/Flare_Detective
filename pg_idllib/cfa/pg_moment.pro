;+
; NAME:
;
; pg_moment
;
; PURPOSE:
;
; compute the moments of a array with n dimensions in a given dimension only,
; returning a n-1 array.
; 
;
; CATEGORY:
;
; statistic tools
;
; CALLING SEQUENCE:
;
; data=pg_moment(array,dimension,maxmoment=maxmoment,nan=nan)
;
; INPUTS:
;
; array: a multidimensional array (n dimensions)
; dimension: an integer between 1 and n, specifying the dimension over which to sum
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;  MAXMOMENT:
;               Use this keyword to limit the number of moments:
;               Maxmoment = 1  Calculate only the mean.
;               Maxmoment = 2  Calculate the mean and variance.
;               Maxmoment = 3  Calculate the mean, variance, and skewness.
;               Maxmoment = 4  Calculate the mean, variance, skewness,
;                              and kurtosis (the default).
;  NAN:    Treat NaN elements as missing data.
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
;  Paolo C. Grigis, pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
;  19-FEB-2007 written, based on moment.pro from (IITVIS)
;
;
;-

PRO pg_moment_test

array=[1.,2.,5.,7.,3.,2.,2.,2.,2.,1.,19.]
array=findgen(4,4)
array=findgen(4,3,2,5,6,7)


print,meandim,vardim,skewdim,kurtdim
print,moment(array)


n=4L
array=randomn(seed,n,n,n)

pg_moment,array,1,mean=meandim,var=vardim,skew=skewdim,kurt=kurtdim
pg_moment,array,2,mean=meandim,var=vardim,skew=skewdim,kurt=kurtdim
pg_moment,array,3,mean=meandim,var=vardim,skew=skewdim,kurt=kurtdim


mean=fltarr(n,n)
var=fltarr(n,n)
skew=fltarr(n,n)
kurt=fltarr(n,n)

FOR i=0,n-1 DO FOR j=0,n-1 DO  mean[i,j]=(moment(array[i,j,*]))[0]
FOR i=0,n-1 DO FOR j=0,n-1 DO var[i,j]= (moment(array[i,j,*]))[1]
FOR i=0,n-1 DO FOR j=0,n-1 DO skew[i,j]=(moment(array[i,j,*]))[2]
FOR i=0,n-1 DO FOR j=0,n-1 DO kurt[i,j]=(moment(array[i,j,*]))[3]

FOR i=0,n-1 DO FOR j=0,n-1 DO mean[i,j]=(moment(array[i,*,j]))[0]
FOR i=0,n-1 DO FOR j=0,n-1 DO var[i,j]= (moment(array[i,*,j]))[1]
FOR i=0,n-1 DO FOR j=0,n-1 DO skew[i,j]=(moment(array[i,*,j]))[2]
FOR i=0,n-1 DO FOR j=0,n-1 DO kurt[i,j]=(moment(array[i,*,j]))[3]

FOR i=0,n-1 DO FOR j=0,n-1 DO mean[i,j]=(moment(array[*,i,j]))[0]
FOR i=0,n-1 DO FOR j=0,n-1 DO var[i,j]= (moment(array[*,i,j]))[1]
FOR i=0,n-1 DO FOR j=0,n-1 DO skew[i,j]=(moment(array[*,i,j]))[2]
FOR i=0,n-1 DO FOR j=0,n-1 DO kurt[i,j]=(moment(array[*,i,j]))[3]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
n=4L
array=randomn(seed,n,n,n,n)

pg_moment,array,1,mean=meandim,var=vardim,skew=skewdim,kurt=kurtdim
pg_moment,array,2,mean=meandim,var=vardim,skew=skewdim,kurt=kurtdim
pg_moment,array,3,mean=meandim,var=vardim,skew=skewdim,kurt=kurtdim
pg_moment,array,4,mean=meandim,var=vardim,skew=skewdim,kurt=kurtdim


mean=fltarr(n,n,n)
var=fltarr(n,n,n)
skew=fltarr(n,n,n)
kurt=fltarr(n,n,n)

FOR i=0,n-1 DO FOR j=0,n-1 DO FOR k=0,n-1 do mean[i,j,k]=(moment(array[i,j,k,*]))[0]
FOR i=0,n-1 DO FOR j=0,n-1 DO FOR k=0,n-1 do  var[i,j,k]=(moment(array[i,j,k,*]))[1]
FOR i=0,n-1 DO FOR j=0,n-1 DO FOR k=0,n-1 do skew[i,j,k]=(moment(array[i,j,k,*]))[2]
FOR i=0,n-1 DO FOR j=0,n-1 DO FOR k=0,n-1 do kurt[i,j,k]=(moment(array[i,j,k,*]))[3]
                                                                          
FOR i=0,n-1 DO FOR j=0,n-1 DO FOR k=0,n-1 do mean[i,j,k]=(moment(array[i,j,*,k]))[0]
FOR i=0,n-1 DO FOR j=0,n-1 DO FOR k=0,n-1 do  var[i,j,k]=(moment(array[i,j,*,k]))[1]
FOR i=0,n-1 DO FOR j=0,n-1 DO FOR k=0,n-1 do skew[i,j,k]=(moment(array[i,j,*,k]))[2]
FOR i=0,n-1 DO FOR j=0,n-1 DO FOR k=0,n-1 do kurt[i,j,k]=(moment(array[i,j,*,k]))[3]
                                                                       
FOR i=0,n-1 DO FOR j=0,n-1 DO FOR k=0,n-1 do mean[i,j,k]=(moment(array[i,*,j,k]))[0]
FOR i=0,n-1 DO FOR j=0,n-1 DO FOR k=0,n-1 do  var[i,j,k]=(moment(array[i,*,j,k]))[1]
FOR i=0,n-1 DO FOR j=0,n-1 DO FOR k=0,n-1 do skew[i,j,k]=(moment(array[i,*,j,k]))[2]
FOR i=0,n-1 DO FOR j=0,n-1 DO FOR k=0,n-1 do kurt[i,j,k]=(moment(array[i,*,j,k]))[3]
                                                                       
FOR i=0,n-1 DO FOR j=0,n-1 DO FOR k=0,n-1 do mean[i,j,k]=(moment(array[*,i,j,k]))[0]
FOR i=0,n-1 DO FOR j=0,n-1 DO FOR k=0,n-1 do  var[i,j,k]=(moment(array[*,i,j,k]))[1]
FOR i=0,n-1 DO FOR j=0,n-1 DO FOR k=0,n-1 do skew[i,j,k]=(moment(array[*,i,j,k]))[2]
FOR i=0,n-1 DO FOR j=0,n-1 DO FOR k=0,n-1 do kurt[i,j,k]=(moment(array[*,i,j,k]))[3]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


print,mean-meandim
print,var-vardim
print,skew-skewdim
print,kurt-kurtdim

;print,meandim



res=moment(array)
pg_moment,array,mean=mean,var=var,skew=skew,kurt=kurt
pg_moment,array,1,mean=mean,var=var,skew=skew,kurt=kurt
pg_moment,array,2,mean=mean,var=var,skew=skew,kurt=kurt

print,res
print,'***'
print,mean,var,skew,kurt


;.comp pg_moment

END


PRO pg_moment,array,dimension,maxmoment=maxmoment,nan=nan,double=double,mean=mean,var=var,skew=skew,kurt=kurt

  IF keyword_set(nan) THEN BEGIN  ;If NaN set, remove NaNs and recurse.
     whereNotNaN = where( finite(array), count)
     IF count GT 0 THEN BEGIN
        pg_moment,array[whereNotNan],dimension,maxmoment=maxmoment,double=double,mean=mean,var=var,skew=skew,kurt=kurt
        RETURN
     ENDIF
  ENDIF

  IF NOT keyword_set( maxmoment ) THEN maxmoment = 4

  IF Maxmoment GT 1 AND n_elements(array) LT 2 THEN $ ;Check length.
     MESSAGE, "X array must contain 2 OR more elements."

  TypeX = SIZE(array)

  dimension=fcheck(dimension,TypeX[0])
  thedimension=dimension[0]>1<TypeX[0]

  IF N_ELEMENTS(Double) EQ 0 THEN $
     Double = (TypeX[TypeX[0]+1] EQ 5 OR TypeX[TypeX[0]+1] EQ 9)

  nX = TypeX[thedimension]; ELSE nX = TypeX[1]

  Mean = TOTAL(array,thedimension, Double = Double) / nX
  meansize=size(mean)

  IF Maxmoment GT 1 THEN BEGIN  ; Calculate higher moments.

     ;stop

     IF TypeX[0] GT 1 THEN BEGIN

        ;dimension juggling.... add the dimension at the
        ;end of the array, to ensure that it is replicated
        meantmp=rebin(Mean,[meansize[1:meansize[0]],TypeX[thedimension]])
        ;then transposes it to put the replicated bits at the right spot
        ;first builds an array index for transpose
        CASE thedimension OF 
           1: tmpindex=[TypeX[0]-1,bindgen(TypeX[0]-1)]
           TypeX[0]: tmpindex=bindgen(TypeX[0])
           ELSE : tmpindex=[bindgen(thedimension-1),TypeX[0]-1,thedimension-1+bindgen(TypeX[0]-thedimension)]
        ENDCASE

        meantmp=transpose(meantmp,tmpindex)
        Resid = array - meantmp;,TypeX[1:TypeX[0]]) 

     ENDIF $
     ELSE Resid = array-Mean

; Numerically-stable "two-pass" formula, which offers less
; round-off error. Page 613, Numerical Recipes in C.
     Var = (TOTAL(Resid^2,thedimension, Double = Double) - $
            (TOTAL(Resid,thedimension, Double = Double)^2)/nX)/(nX-1.0)


;;Mean absolute deviation (returned through the Mdev keyword).
;     IF  arg_present(Mdev) THEN  $
;        Mdev = TOTAL(ABS(Resid), Double = Double) / nX
    
; Standard deviation (returned through the Sdev keyword).
     Sdev = SQRT(Var)
;     ind=where(SdeV EQ 0,count)
    
;    IF Sdev NE 0 THEN BEGIN     ;Skew & kurtosis defined
       IF Maxmoment GT 2 THEN $
          Skew = TOTAL(Resid^3,thedimension, Double = Double) / (nX * Sdev ^ 3)
; The "-3" term makes the kurtosis value zero for normal distributions.
; Positive values of the kurtosis (lepto-kurtic) indicate pointed or
; peaked distributions; Negative values (platy-kurtic) indicate flat-
; tened or non-peaked distributions.
       IF Maxmoment GT 3 THEN $
          Kurt = TOTAL(Resid^4,thedimension, Double = Double) / (nX * Sdev ^ 4) - 3.0
    ENDIF
; ENDIF

END



