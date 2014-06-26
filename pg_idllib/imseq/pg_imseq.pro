;+
;
; NAME:
;        pg_imseq
;
; PURPOSE: 
;        produces a sequence of RHESSI images and stores them to
;        fit files
;
; CALLING SEQUENCE:
;
;        hsi_image_sequence,time_intv,n_intv,basefilename
;        [, some rhessi image object keywords, see procedure beginning]
;
; INPUTS:
;
;        time_intv: the whole time interval, which will be divided 
;        n_intv: number of intervals
;        basefilename: file name, frame number will be appended
;
; OUTPUT: to fit files        
;
; VERSION:
;       05-NOV-2002 written, based on older routines
;       ... several changes in older version
;       12-FEB-2004: new version, renamed
;
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

PRO  pg_imseq,time_intv,n_intv,basefilename,energy_band=energy_band $
     ,image_dim=image_dim,pixel_size=pixel_size,xyoffset=xyoffset $
     ,det_index_mask=det_index_mask $
     ,image_algorithm=image_algorithm,noscreen=noscreen





   checkvar,energy_band,[6,12]
   checkvar,xyoffset,[0,0]
   checkvar,pixel_size,[16,16]
   checkvar,image_dim,[128,128]
   checkvar,det_index_mask,[0,0,0,0,0,0,1,1,1]
   checkvar,image_algorithm,'back projection'


   checkvar,n_intv,1

   IF NOT exist(time_intv) THEN BEGIN
      print,'Please input a time interval!'
      RETURN
   ENDIF

   time_intv=anytim(time_intv)

   IF NOT exist(basefilename) THEN BEGIN
      print,'Please input a base file name!'
      RETURN
   ENDIF

 
   im=hsi_image()
   im->set,obs_time_interval=time_intv
   im->set,energy_band=energy_band
   im->set,det_index_mask=det_index_mask
   im->set,xyoffset=xyoffset
   im->set,pixel_size=pixel_size
   im->set,image_dim=image_dim
   im->set,image_algorithm=image_algorithm

   IF keyword_set(noscreen) THEN im->set_no_screen_output


   duration=(time_intv[1]-time_intv[0])/n_intv

   FOR i=0,n_intv-1 DO BEGIN

      print,'Now doing frame '+strtrim(i+1,2)
      time_range=duration*[i,i+1]

      im->set,time_range=time_range       
         
      im->fitswrite,fitsfile=basefilename+'_'+strtrim(string(i),2)+'.fits'
      
   ENDFOR

   
   obj_destroy,im


   RETURN

END











