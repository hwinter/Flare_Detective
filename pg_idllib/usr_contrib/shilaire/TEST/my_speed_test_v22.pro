; by PSH, MARCH 2001

; v2.2
; ---->>>  start with the unix command: "time hessiidl" or "\usr\bin\time hessiidl"


pro my_speed_test_v22

wdef,0,/pixmap
flist = hsi_read_flarelist()

for i=0,9 do begin
	o=hsi_image()
	print,' .......................................Doing flare #',i
	print,'...................................total counts: ',flist(i).TOTAL_COUNTS
	t0 = anytim(flist(i).start_time,/yohkoh)
	t1 = anytim(flist(i).end_time,/yohkoh)
	im=o -> getdata(time_range=[t0,t1],xyoffset=flist(i).position,  $ 
		pixel_size=[2.,2.], image_dim=[64,64] ,image_algorithm='clean')
		
	o -> plot							
	Obj_Destroy, o
	     end
wdel,0		
EXIT
end


; subtract about 1 sec from user&sys time (IDL start)

