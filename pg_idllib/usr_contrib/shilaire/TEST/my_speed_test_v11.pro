; by PSH, Feb 2001

; v1.1

pro my_speed_test_v11

starttime=systime(/sec)

window,0,/pixmap
flist = hsi_read_flarelist()
;o=hsi_image()
for i=0,9 do begin
		o=hsi_image()
		print,' .......................................Doing flare #',i
		print,'...................................total counts: ',flist(i).TOTAL_COUNTS
		t0 = anytim(flist(i).start_time,/yohkoh)
		t1 = anytim(flist(i).end_time,/yohkoh)
		im=o -> getdata(time_range=[t0,t1],xyoffset=flist(i).position,  $ 
				pixel_size=[2.,2.], image_dim=[64,64])	; v1.0 didn't have this line
		o -> plot							
	        Obj_Destroy, o
	       end
wdel,0		
endtime=systime(/sec)
print,'.............................the whole thing took : ',endtime-starttime,' seconds.'
end
