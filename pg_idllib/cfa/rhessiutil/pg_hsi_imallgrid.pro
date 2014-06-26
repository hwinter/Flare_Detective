;+
; NAME:
;
; pg_hsi_imallgrid
;
; PURPOSE:
;
; produces a nice plot of all single grid back projection RHESSI images
;
; CATEGORY:
;
; RHESSI util
;
; CALLING SEQUENCE:
;
; pg_hsi_imallgrid
;
; INPUTS:
;
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
; pg_hsi_imallgrid,time_intv='26-Feb-2002 '+['10:26','10:27'],energy_band=[18,30],xyoffset=[925,-225]
;
; AUTHOR:
;
; Paolo Grigis, CfA
; pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 21-SEP-2007 written
;
;-

PRO pg_hsi_imallgrid,time_intv=time_intv,energy_band=energy_band,xyoffset=xyoffset

im=hsi_image()

im->set,im_time_interval=time_intv,im_energy_binning=energy_band,xyoffset=xyoffset

detpixsize=[0.5,0.8,1,2,3.5,6,10,18,28]

im->set,image_algorithm='back projection',image_dim=128

oldp=!P

!P.multi=[0,3,3]
wdef,1,1200,1200

tvlct,r,g,b,/get

loadct,5

FOR i=0,8 DO BEGIN 
   dim=bytarr(9,3)
   dim[i,0]=1
   im->set,pixel_size=detpixsize[i]
   im->set,det_index_mask=dim
   im->plot,/limb,charsize=2.5,legend_loc=0,/square,title='Grid # '+smallint2str(i+1,strlen=1),/no_timestamp
ENDFOR

tvlct,r,g,b
!P=oldp

END





