; by PSH, Feb 2001

; v2.1 

pro my_speed_test_v21,results

results={blabla, nbr:intarr(10), duration:dblarr(10)}

wdef,0,/pixmap
flist = hsi_read_flarelist()

for i=0,9 do begin
	starttime=systime(/sec)
	o=hsi_image()
	print,' .......................................Doing flare #',i
	print,'...................................total counts: ',flist(i).TOTAL_COUNTS
	t0 = anytim(flist(i).start_time,/yohkoh)
	t1 = anytim(flist(i).end_time,/yohkoh)
	im=o -> getdata(time_range=[t0,t1],xyoffset=flist(i).position,  $ 
		pixel_size=[2.,2.], image_dim=[64,64] ,image_algorithm='clean')
		
	o -> plot							
	Obj_Destroy, o
	endtime=systime(/sec)
	results.nbr(i)=i
	results.duration(i)= endtime-starttime    
	print,'.............................this one took : ',results.duration(i),' seconds.'     
	     end
	  
wdel,0		
print,' '
for i=0,9 do print,'...............Flare ',i,' took ',results.duration(i),' seconds.'

end
