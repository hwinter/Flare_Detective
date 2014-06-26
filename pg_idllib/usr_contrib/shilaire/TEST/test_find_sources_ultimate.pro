
logfile='test_findsources_ultimate.txt'



flaresourcenumbers=[1,1,1,1,1,2,2,2,2,3]
Ni=10L
Nj=4L	; forget pixon for now, would take me more than a month !!!
Nk=9L
Np=2L
lowerlimit=[0.01,0.05,0.1,0.2,0.25,0.3]
Nl=N_ELEMENTS(lowerlimit)

text='Start time: '+SYSTIME()
hedc_add_to_log,text,dir='/global/hercules/users/shilaire/HEDC/TESTS/findsources',/new,file=logfile
text2='nbr/flareid/imgalg/det_index_mask/pixsiz/duration'
hedc_add_to_log,text2,dir='/global/hercules/users/shilaire/HEDC/TESTS/findsources',/new,file='dbase.txt'


text=' 10x10 arcsecs per pixel, 64x64 images'
hedc_add_to_log,text,dir='/global/hercules/users/shilaire/HEDC/TESTS/findsources',file=logfile


dataset=FLTARR(64,64,Ni*Nj*Nk*Np)
counter=0L

;the following array stores the difference between number of sources found vs. correct number
rightwrong=INTARR(Ni,Nj,Nk,Np,Nl,2)		; flare number, imgalg, det_index, lower_limit,smooth

FOR i=0L,Ni-1 DO BEGIN			; flare number
	FOR j=0L,Nj-1 DO BEGIN			; back proj, clean or mem
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
			
						 
			io=hsi_image()
			io->set,time_range=anytim('2000/09/01 '+t_intv)
			io->set,xyoffset=xy,pixel_size=[pixsize,pixsize]
			io->set,image_algorithm=imgalg,ENERGY_BAND=[20.,50.],DET_INDEX_MASK=detindex
			io->set_no_screen_output
			starttime=SYSTIME(/seconds)	
			data=io->getdata()
			endtime=SYSTIME(/seconds)
			dataset(*,*,counter)=data
			obj_destroy,io
			io=-1
			heap_gc
			
			text='Counter: '+STRN(counter)+'  Flare#'+STRN(i+1)+'  '+imgalg+'  Det. Index: '+strn(k)+' pixsiz: '+strn(pixsize)+' Time to do: '+strn(endtime-starttime)+' seconds.'
				;for later easy dbase entries:
				text2=STRN(counter)+' '+STRN(i+1)+' '+imgalg+' '+strn(k)+' '+strn(pixsize)+' '+strn(endtime-starttime)
				hedc_add_to_log,text2,dir='/global/hercules/users/shilaire/HEDC/TESTS/findsources',file='dbase.txt'
				
					
			FOR l=0L,Nl-1 DO BEGIN
				find_sources,data,nb,positions,n_sigma=5,back_pix=0.1,low=lowerlimit(l),/quiet
				addtext='  Lowerlimit: '+STRN(lowerlimit(l))+'  Unsmoothed: '+STRN(nb)+' sources.'
				hedc_add_to_log,text+addtext,dir='/global/hercules/users/shilaire/HEDC/TESTS/findsources',file=logfile				
				rightwrong(i,j,k,p,l,0)=nb-flaresourcenumbers(i)

				find_sources,data,nb,positions,n_sigma=5,back_pix=0.1,low=lowerlimit(l),/quiet,/smoothe
				addtext='  Lowerlimit: '+STRN(lowerlimit(l))+'  Smoothed: '+STRN(nb)+' sources.'
				hedc_add_to_log,text+addtext,dir='/global/hercules/users/shilaire/HEDC/TESTS/findsources',file=logfile
				rightwrong(i,j,k,p,l,1)=nb-flaresourcenumbers(i)
			ENDFOR;l		
		
			print,'Percent done: '+STRN(100./(Ni*Nj*Nk*Np)*(1+p+Np*k+Np*Nk*j+Np*Nk*Nj*i))+'%'
			counter=counter+1		
		  ENDFOR;p		
		ENDFOR;k
	ENDFOR;j
ENDFOR;I

text='End time: '+SYSTIME()
hedc_add_to_log,text,dir='/global/hercules/users/shilaire/HEDC/TESTS/findsources',file=logfile

save,filename='/global/hercules/users/shilaire/HEDC/TESTS/findsources/dataset.dat',dataset,rightwrong

;END



;Success rate of each ImgAlg:
print,'ImgAlg:'
tot=INTARR(Nj)
FOR j=0,Nj-1 DO BEGIN
	tot(j)=N_ELEMENTS(WHERE(rightwrong(*,j,*,*,*,*) EQ 0))
	print,'ImgAlg#'+strn(j)+': '+strn(100.*tot(j)/N_elements(rightwrong(*,0,*,*,*,*)))+'%'
ENDFOR
print,''

;Success rate of each Det_Index:
print,'Det_Index'
tot=INTARR(Nk)
FOR k=0,Nk-1 DO BEGIN
	tot(k)=N_ELEMENTS(WHERE(rightwrong(*,*,k,*,*,*) EQ 0))
	print,'Missing det_index'+strn(k)+': '+strn(100.*tot(k)/N_elements(rightwrong(*,*,0,*,*,*)))+'%'
ENDFOR
print,''

;Success rate of each lower_limit:
print,'Lower limit:'
tot=INTARR(Nl)
FOR l=0,Nl-1 DO BEGIN
	tot(l)=N_ELEMENTS(WHERE(rightwrong(*,*,*,*,l,*) EQ 0))
	print,'Low_limit'+strn(l)+': '+strn(100.*tot(l)/N_elements(rightwrong(*,*,*,*,0,*)))+'%'
ENDFOR
print,''

;Success rate of non-/smoothed:
print,'non-/smoothed:'
tot=INTARR(2)
FOR m=0,1 DO BEGIN
	tot(m)=N_ELEMENTS(WHERE(rightwrong(*,*,*,*,*,m) EQ 0))
	print,'Non-/smoothed'+strn(l)+': '+strn(100.*tot(m)/N_elements(rightwrong(*,*,*,*,*,0)))+'%'
ENDFOR
print,''


;NOW, is the best combination also the one with the highest success rate ? (Hopefully, yes !)
;Success rate of each individual method:
successpercent=BYTARR(Nj,Nk,Np,Nl,2)
FOR j=0,Nj-1 DO BEGIN
	FOR k=0,Nk-1 DO BEGIN
		FOR p=0,Np-1 DO BEGIN	
			FOR l=0,Nl-1 DO BEGIN
				FOR m=0,1 DO BEGIN
					successpercent(j,k,p,l,m)=10*N_ELEMENTS(WHERE(rightwrong(*,j,p,k,l,m) EQ 0))
				ENDFOR
			ENDFOR
		ENDFOR
	ENDFOR
ENDFOR

maxsuccessrate=MAX(successpercent,ss)
nbr_ss=N_ELEMENTS(WHERE(successpercent GE maxsuccessrate))
print,'.........'+strn(nbr_ss)+' methods had the max. success rate of '+strn(maxsuccessrate)+'%'

END
