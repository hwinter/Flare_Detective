;-ask a demo about mySQL: why so great to use it...? Instead of some simple(r) files (system)?
;-need ROOT access to install?
;
;
;$ps -o user,pgid,stime,etime,time,args|grep rsi|grep 11179|grep -v grep
;
;$ps -o pgid,args | grep rsi
;$ps -o user,pgid,stime,etime,time,args|grep rsi|grep 12436|grep -v grep
;00:49:23 for 18*6=108 images
; fits file size: 4299840
;

;18
t_intvs='2002/07/23 '+[['00:18','00:19'],['00:22','00:23'],['00:24','00:25'],['00:27:30','00:28'],['00:28','00:29'],['00:30','00:31'],['00:31','00:32'],['00:34','00:35'],['00:38','00:39'],['00:39','00:40'],['00:41','00:42'],['00:42','00:43'],['00:48','00:49'],['00:51','00:52'],['00:58','00:59'],['01:01','01:02'],['01:12','01:13'],['01:14','01:15']]
;ebands=[[4,5],[5,6],[6,7],[7,8],[8,9],[9,10],[10,12],[12,14],[14,16],[16,18],[18,20],[20,25],[25,30],[30,35],[35,40],[40,45],[45,50],[50,60],[60,70],[70,80],[80,90],[90,100]]
;22
ebands=[[6,8],[8,12],[12,25],[25,50],[50,100],[100,300]]
;6

mmo=hsi_multi_image()
mmo->set,im_time_interval=t_intvs
mmo->set,im_energy_bin=ebands
mmo->set,FRONT=1,REAR=0
mmo->set,DECIMATION_CORRECT=1
mmo->set,image_alg='back'
mmo->set,pixel_size=1,image_dim=64,xyoffset=[-895,-228]
mmo->set,det_index_mask=[0,0,1,1,1,1,1,1,0]
mmo->set_no_screen_output
mmo->set,progress_bar=0
mmo->set,im_out='imgtess.fits'
imagetesseract=mmo->getdata()	




