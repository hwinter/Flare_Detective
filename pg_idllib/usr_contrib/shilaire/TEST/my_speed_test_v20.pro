; by PSH, Feb 2001

; v2.0 : for Peter Steiner ....

pro my_speed_test_v20

starttime=systime(/sec)

window,0
flist = hsi_read_flarelist()
;i=6
for i=0,9 do begin
	o=hsi_image()
	print,' .......................................Doing flare #',i
	print,'...................................total counts: ',flist(i).TOTAL_COUNTS
	t0 = anytim(flist(i).start_time,/yohkoh)
	t1 = anytim(flist(i).end_time,/yohkoh)
	im=o -> getdata(time_range=[t0,t1],xyoffset=flist(i).position,  $ 
			pixel_size=[4.,4.], image_dim=[64,64])
	o -> plot							
	Obj_Destroy, o
	     end
	         
wdel,0		
endtime=systime(/sec)
print,'.............................the whole thing took : ',endtime-starttime,' seconds.'
end
