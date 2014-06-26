;start with: /usr/bin/time pixontestidl

;pslist='user,nice,comm,vsz,rss,etime,cputime,systime,usertime,sl' ;for carme
pslist='user,nice,args,vsz,rss,etime,time' ;for hercules
;pslist='user,nice,comm,vsz,rss,etime,cputime' ;for stokes


;the following are system-dependant:
        SETENV,'HSI_DATA_ARCHIVE=~/.'


Ni=10L
Nj=4L
Nk=9L
Np=2L

j=4

FOR i=0L,Ni-1 DO BEGIN			; flare number
		FOR k=0L,Nk-1 DO BEGIN			; detectors used
		   FOR p=0L,Np-1 DO BEGIN	
			CASE i OF
				0: BEGIN & t_intv=['03:37:00','03:37:04'] & xy=[600,200] & END
				1: BEGIN & t_intv=['03:42:00','03:42:04'] & xy=[-800,200] & END
				2: BEGIN & t_intv=['03:48:24','03:48:28'] & xy=[-900,-100] & END
				3: BEGIN & t_intv=['03:52:16','03:52:20'] & xy=[600,300] & END
				4: BEGIN & t_intv=['03:57:01','03:57:03'] & xy=[-600,300] & END
				5: BEGIN & t_intv=['04:02:20','04:02:24'] & xy=[600,-200] & END
				6: BEGIN & t_intv=['04:07:20','04:07:24'] & xy=[-800,300] & END
				7: BEGIN & t_intv=['04:14:00','04:14:04'] & xy=[-800,200] & END
				8: BEGIN & t_intv=['04:17:20','04:17:24'] & xy=[900,-50] & END
				9: BEGIN & t_intv=['04:22:20','04:22:24'] & xy=[900,100] & END				
			ENDCASE;i
			CASE j OF
				0: imgalg='back projection'
				1: imgalg='clean'
				2: imgalg='mem'
				3: imgalg='memvis'
				4: imgalg='pixon'
			ENDCASE;j
			CASE k OF
				0: detindex=[1,1,1,1,1,1,1,1,1]
				1: detindex=[0,1,1,1,1,1,1,1,1]
				2: detindex=[0,0,1,1,1,1,1,1,1]
				3: detindex=[0,0,0,1,1,1,1,1,1]
				4: detindex=[0,0,0,0,1,1,1,1,1]
				5: detindex=[0,0,0,0,0,1,1,1,1]
				6: detindex=[0,0,0,0,0,0,1,1,1]
				7: detindex=[0,0,0,0,0,0,0,1,1]
				8: detindex=[0,0,0,0,0,0,0,0,1]
			ENDCASE;k
			CASE p OF
				0: pixsize=5.
				1: pixsize=10.
			ENDCASE;p
			
			filprefix='pixonimg_'+strn(i)+strn(j)+strn(k)+strn(p)			 

			openw,lun,filprefix+'.log',/GET_LUN,/APPEND
			pscmd='ps -Ao "'+pslist+'" |grep shilaire |grep idl'
			printf,lun,'Result of '+pscmd+' :'
			SPAWN,pscmd,res
			printf,lun,res
			FREE_LUN,lun

			io=hsi_image()
			io->set,time_range=anytim('2000/09/01 '+t_intv)
			io->set,xyoffset=xy,pixel_size=[pixsize,pixsize]
			io->set,image_algorithm=imgalg,ENERGY_BAND=[20.,50.],DET_INDEX_MASK=detindex
			io->set_no_screen_output
			starttime=SYSTIME(/seconds)	
			data=io->getdata()
			fil=filprefix+'.dat'
			save,filename=fil,data
			obj_destroy,io
			io=-1
			heap_gc

			openw,lun,filprefix+'.log',/GET_LUN,/APPEND
			pscmd='ps -Ao "'+pslist+'" |grep shilaire |grep idl'
			printf,lun,'Result of '+pscmd+' :'
			SPAWN,pscmd,res
			printf,lun,res
			FREE_LUN,lun
			
		  ENDFOR;p		
		ENDFOR;k
ENDFOR;I

print,'OK!'
EXIT
END


