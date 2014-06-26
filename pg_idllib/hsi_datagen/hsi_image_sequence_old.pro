;+
;
; NAME:
;        hsi_image_sequence !!!!!!!! OLD VERSION !!!!!!!!!!!!!
;
; PURPOSE: 
;        produces a sequence of RHESSI images and stores them to a file
;        a structure containing the image and the RHESSI parameters
;        is produced for each image.
;
; CALLING SEQUENCE:
;
;        hsi_image_sequence,time_intv,imtime=imtime [, some rhessi
;        image object keywords, see procedure beginning]
;
; INPUTS:
;
;        time_intv: the whole time interval, which will be divided 
;        imtime: duration of the single images in a sequence
;                default: 60 seconds
;
; OUTPUT: to a file        
;
; VERSION:
;       05-NOV-2002 written, based on older routines
;       06-NOV-2002 changed from array of structures to array of
;       pointers, because the RHESSI software gives different
;       structures for different settings of the imaging parameters
;
;
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

PRO  hsi_image_sequence,time_intv,imtime=imtime,energy_band=energy_band $
     ,image_dim=image_dim,pixel_size=pixel_size,xyoffest=xyoffset $
     ,det_index_mask=det_index_mask,filename=filename $
     ,image_algorithm=image_algorithm,noscreen=noscreen


   IF NOT exist(imtime) THEN imtime=60.

   IF NOT exist(energy_band) THEN energy_band=[6,12]
   IF NOT exist(xyoffset) THEN xyoffset=[0,0]
   IF NOT exist(pixel_size) THEN pixel_size=[16,16]
   IF NOT exist(image_dim) THEN image_dim=[128,128]
   IF NOT exist(det_index_mask) THEN det_index_mask=[0,0,0,0,0,0,1,1,1]
   IF NOT exist(filename) THEN filename='im'
   IF NOT exist(image_algorithm) THEN image_algorithm='back projection'


   time_intv=anytim(time_intv)   

   N=ceil((time_intv[1]-time_intv[0])/imtime)
 
   im=hsi_image()
   im->set,obs_time=time_intv
   im->set,energy_band=energy_band
   im->set,det_index_mask=det_index_mask
   im->set,xyoffset=xyoffset
   im->set,pixel_size=pixel_size
   im->set,image_dim=image_dim
   im->set,image_algorithm=image_algorithm

   IF keyword_set(noscreen) THEN im->set_no_screen_output

   ;im->set,ras_time_extension=[-1400,1400] 

   ptr=ptrarr(N)

   FOR i=0,N-1 DO $
       BEGIN

       print,'Now doing frame '+strtrim(i+1,2)

       im->set,time_range=[time_intv[0]+i*imtime,time_intv[0]+(i+1)*imtime]
       
       iii=im->getdata()
       hessipar=im->get()

       image={im:iii,hessipar:hessipar}
       ptr[i]=ptr_new(image)
      
       ;IF i EQ 0 THEN image={im:iii,hessipar:hessipar} $
       ;ELSE image=[image,{im:iii,hessipar:hessipar}]

   ENDFOR
   
   filenamedef='/global/tethys/data1/pgrigis/vlahessi/autodata/' $
            +filename+anytim(time_intv[0],/ccsds)+'.dat'

   save,ptr,filename=filenamedef

   obj_destroy,im

END











