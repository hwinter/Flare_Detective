; by PSH, Feb. 2001

; v1.0


pro my_speed_test_v10

starttime=systime(/sec)

;for i=0,2000 do print,'.'

; the following line sadly does not work (as of  feb 20th,2001)
;flist = hsi_select_flare(id=[1369,1380],/form)

window,0,/pixmap
flist = hsi_read_flarelist()
for i=0,10 do begin
		o=hsi_image()
		t0 = anytim(flist(i).start_time,/yohkoh)
		t1 = anytim(flist(i).end_time,/yohkoh)
		im=o -> getdata(time_range=[t0,t1],xyoffset=flist(i).position)
		o -> plot							
	       end
wdel,0		
endtime=systime(/sec)
print,'.............................the whole thing took : ',endtime-starttime,' seconds.'
end
