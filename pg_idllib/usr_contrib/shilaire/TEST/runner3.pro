; made dec 8th,2000 by PSH
; out of a trace_map and an hxt_map, makes a byte array which can be run 
;	directly through my mpeg_maker...

pro runner3,tracemap,hxtmap,outmovie
outmovie=bytarr(512,512,109)
wdef,0
;plot_map,tracemap(20),/log,grid=10	;,ncolors=250
;myct2
;xloadct,ncolors=250

for i=0,108 do begin
	plot_map,tracemap(i),/log,grid=10,ncolors=250
	map_time=str2utc(tracemap(i).time)
	map_time=map_time.time
	if map_time gt 44040000 and map_time lt 44160000 then $
		plot_map,hxtmap,/over,lcolor=250

	outmovie(*,*,i)=tvrd()
		end
end


;mpeg_maker,trace_nrh_new,filename='/global/helene/home/www/staff/shilaire/private/trace_nrh_new.mpg'


