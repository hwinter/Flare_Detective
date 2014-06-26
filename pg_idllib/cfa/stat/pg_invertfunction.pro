;+
; NAME:
;
; pg_invertfunction
;
; PURPOSE:
;
; compute the inverse of a monotonic function (this will NOT work on a
; non-monotonic function!)
;
; CATEGORY:
;
; gen purpose math utilities
;
; CALLING SEQUENCE:
;
; y=pg_invertfunction(x,funcname,range=range,ytol=ytol,_extra=_extra)
;
; INPUTS:
;
; x: point where the value of the inverse function is sought
; funcname: the name of an IDL function that accept one array argument
; _extra arguments are passed to the function
;
; OPTIONAL INPUTS:
;
; dx: 
; range: the range where the function funcname is evaluated (default=[-10,10])
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
; ytol: maximum error in y allowd (default= 10^-5)
; y: an array such that x=funcname(y)
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
; uses interpolate on (y,x) line. If some of the results found are not good
; enough, recursively calls pg_invertfunction with a finer grid
;
; EXAMPLE:
;
;
;
; AUTHOR:
;
; Paolo Grigis
; pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 27-AUG-2008 written PG
;
;-

FUNCTION pg_invertfunction,x,funcname,pgif_range=range,pgif_ytol=ytol,pgif_spline=pgif_spline $
                           ,pgif_quadratic=pgif_quadratic,pgif_lsquadratic=pgif_lsquadratic,pgif_verbose=pgif_verbose $
                           ,_extra=extra

IF n_elements(funcname) EQ 0 OR size(funcname,/tname) NE 'STRING' THEN RETURN,-1
IF n_elements(range) NE 2 THEN range=[-10d,10]
IF n_elements(ytol) NE 1 THEN ytol=1d-5 ELSE ytol=ytol > 1d-15

npoints=100
drange=range[1]-range[0]
;print,range

xx=dindgen(npoints)/(npoints-1)*drange+range[0]


IF n_elements(extra) GT 0 THEN BEGIN 
;   print,'EXTRA'
;   stop
yy=call_function(funcname,xx,_extra=extra)
ENDIF $
ELSE BEGIN  
;   print,'NO EXTRA'
   yy=call_function(funcname,xx)
ENDELSE


thisresult=interpol(xx,yy,x,quadratic=keyword_set(pgif_quadratic),spline=keyword_set(pgif_spline) $
                   ,lsquadratic=keyword_set(pgif_lsquadratic))

index=where(abs(call_function(funcname,thisresult)-x) GT ytol,count)

FOR i=0L,count-1 DO BEGIN
   
   tn=thisresult[index[i]]
   tn2=call_function(funcname,tn)
   tr=(tn+0.1*drange*[-1,1])>range[0]<range[1]
   IF keyword_set(pgif_verbose) THEN $
      print,'Looping over '+strtrim(i,2)+' range '+string(tr[0])+string(tr[1])+string(tn)+string(tn2,format='(d22.18)')
   thisx=x[index[i]]
   thisresult[index[i]]=pg_invertfunction(thisx,funcname,pgif_range=tr,pgif_ytol=ytol,pgif_quadratic=pgif_quadratic $
                                          ,pgif_lsquadratic=pgif_lsquadratic,pgif_spline=pgif_spline,_extra=extra)
ENDFOR

RETURN,thisresult


END


