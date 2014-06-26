; to make trace_maps from a few .pl files....


PRO runner4,files

files=['TRACE/tri20000825.1400_0107.pl','TRACE/tri20000825.1400_0113.pl', $
	'TRACE/tri20000825.1400_0119.pl','TRACE/tri20000825.1400_0133.pl', $
	'TRACE/tri20000825.1400_0139.pl','TRACE/tri20000825.1400_0145.pl', $
	'TRACE/tri20000825.1400_0153.pl','TRACE/tri20000825.1400_0161.pl', $
	'TRACE/tri20000825.1400_0169.pl','TRACE/tri20000825.1400_0173.pl', $
	'TRACE/tri20000825.1400_0177.pl','TRACE/tri20000825.1400_0181.pl', $
	'TRACE/tri20000825.1400_0189.pl','TRACE/tri20000825.1400_0197.pl', $
	'TRACE/tri20000825.1400_0205.pl','TRACE/tri20000825.1400_0213.pl', $
	'TRACE/tri20000825.1400_0221.pl','TRACE/tri20000825.1400_0229.pl']
	

;for i=0,n_elements(files) do begin
;		read_trace,files(i),-1,index,data
;		trace_prep,index,data,outindex,outdata,/wave2point,/unspike,/destreak,/deripple
;		TRACE_normalize,outindex,outdata
;		index2map,outindex,outdata,current_map
;		if i gt 0 then trace_map=[trace_map,current_map] else trace_map=current_map
;			end


;read_trace,files,-1,index,data
;trace_prep,index,data,outindex,outdata,/wave2point,/unspike,/destreak,/deripple
;trace_normalize,outindex,outdata
;index2map,outindex,outdata,outmovie
end
