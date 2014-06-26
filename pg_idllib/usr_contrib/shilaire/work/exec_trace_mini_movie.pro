; later on : try to make 'stand alone' : just enter the time intervals, and the
;total time interval, and let it run... 

pro trace_mini_movie,map
file='TRACE/1999_09_08/tri19990908.1200'
read_trace,file,-1,index
ss = trace_sswhere(index)
read_trace,file,ss,index,data

trace_prep,index,data,outindex,outdata,/wave2point,/unspike,/destreak,/deripple,subimgx=300,subimgy=300,sllex=220,slley=200
TRACE_normalize,outindex,outdata
;maybe I should BYTSCL here ?!?!
index2map,outindex,outdata,map

end
