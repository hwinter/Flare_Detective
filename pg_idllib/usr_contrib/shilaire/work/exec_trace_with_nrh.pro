pro exec_trace_with_nrh,movie

myct
restore,'TRACE/1999_09_08/nrh_image_files.dat'
file='TRACE/1999_09_08/tri19990908.1200'

read_trace,file,-1,index
ss = trace_sswhere(index)
;ss=where(index.wave_len eq '1600' and index.naxis1 eq 768 and index.img_max gt 4000 and index.time_obs lt '45023000')
read_trace,file,ss,index,data 

trace_prep,index,data,outindex,outdata,/wave2point,/unspike,/destreak,/deripple

TRACE_normalize,outindex,outdata

index2map,outindex,outdata,trace_map

make_nrh_movie_v3,nrh_image_files,levels=[0.97,0.99],trace_map,/log,movie

end

; save,filename='TRACE/1999_09_08/movieA.dat',movie
