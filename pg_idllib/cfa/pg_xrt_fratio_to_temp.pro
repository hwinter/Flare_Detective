;+
; NAME:
;
;  pg_xrt_fratio_to_temp
;
; PURPOSE:
;
;  convert XRT filterratios to temperatures (assuming isothermality)
;
; CATEGORY:
;
;  XRT utilities
;
; CALLING SEQUENCE:
;
;  temp=pg_xrt_fratio_to_temp(fratio,filter1=filter1,filter2=filter2,tresp=tresp)
;
; INPUTS:
;
;  fratio:  the filter ratio (intensity in filter 1 / intensity in filter 2)
;  filter1: number of filter (or filter combination) 1 (as defined below)
;  filter2: number of filter (or filter combination) 2 (as defined below)
;              0: Al-mesh
;              1: Al-poly
;              2: C-poly
;              3: Ti-poly
;              4: Be-thin
;              5: Be-med
;              6: Al-med
;              7: Al-thick
;              8: Be-thick
;              9: Al-poly/Al-mesh
;             10: Al-poly/Ti-poly
;             11: Al-poly/Al-thick
;             12: Al-poly/Be-thick
;             13: C-poly/Ti-poly
;             14: C-poly/Al-thick
;
;
;
; OPTIONAL INPUTS:
;
;  tresp:  user-defined response (for advanced user only), also as output: response used 
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
; AUTHOR:
;
; Paolo C. Grigis
; pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 16-SEP-2008 PCG: written
;
;-

FUNCTION pg_xrt_fratio_to_temp,fratio,filter1=filter1,filter2=filter2,tresp=tresp,plot=plot,_extra=_extra,new=new

IF n_elements(tresp) EQ 0 THEN tresp=calc_xrt_temp_resp()

IF n_elements(filter1) EQ 0 || n_elements(filter2) EQ 0 $
   || filter1 LT 0 || filter1 GT 14 $
   || filter2 LT 0 || filter2 GT 14 THEN BEGIN 
   
   print,'Invalid filter value. Please recheck your inputs. Returning -1.'
   print,'  Valid filter values are:'
   print,'            0: Al-mesh'
   print,'            1: Al-poly'
   print,'            2: C-poly'
   print,'            3: Ti-poly'
   print,'            4: Be-thin'
   print,'            5: Be-med'
   print,'            6: Al-med'
   print,'            7: Al-thick'
   print,'            8: Be-thick'
   print,'            9: Al-poly/Al-mesh'
   print,'           10: Al-poly/Ti-poly'
   print,'           11: Al-poly/Al-thick'
   print,'           12: Al-poly/Be-thick'
   print,'           13: C-poly/Ti-poly'
   print,'           14: C-poly/Al-thick'

   RETURN,-1
ENDIF

;filter ratio from response
fry=(tresp[filter1].temp_resp/tresp[filter2].temp_resp)[0:tresp[filter1].length-1]
frx=(tresp[filter1].temp)[0:tresp[filter1].length-1]

IF keyword_set(new) THEN BEGIN
   temp=interpol(frx,fry,fratio,_extra=_extra)
ENDIF $
ELSE BEGIN 
   temp=10d^(interpol(frx,fry,fratio,_extra=_extra))
ENDELSE


IF keyword_set(plot) THEN BEGIN 
   loadct,0
   plot,10d^frx,fry,/xlog,ylog=plot-1,psym=-6,yrange=[1d-3,1d3],xrange=[5d5,5d7],/xstyle
   linecolors
   plots,temp,fratio,psym=6,color=2

ENDIF

RETURN,temp

END







