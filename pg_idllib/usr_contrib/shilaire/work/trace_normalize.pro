;+
; NAME:
;     trace_normalize.pro  
; PURPOSE:
;	to correctly normalize TRACE image cubes...
; CATEGORY:
; CALLING SEQUENCE:
;       trace_normalize,index,data
; INPUTS:
;	     a TRACE image cube and the corresponding index
; OPTIONAL (KEYWORD) INPUT PARAMETERS:
; OUTPUTS: 
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
; EXEMPLE
; MODIFICATION HISTORY:
;     Created by PSH : Thursday 23th, November 2000
;-

pro trace_normalize, index,data
for i=0,n_elements(index)-1 do begin
	expdur=gt_tagval(index(i),/sht_mdur)
	if expdur>0. then data(*,*,i)=data(*,*,i)/expdur < 32767 
				end
end






