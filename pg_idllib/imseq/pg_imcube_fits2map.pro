;+
;
; NAME:
;        pg_imcube_fits2map
;
; PURPOSE: 
;        reads an image cube FITS file
;
;
; CALLING SEQUENCE:
;
;        ans=pg_imcube_fits2map(filename)
;
; INPUTS:
;
;        filename: FITS file name
;
; OUTPUT:
;
;        array of pointers to solar maps
;
; VERSION:
;
;       29-JAN-2007 written
;
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;-

;.comp pg_imcube_fits2map

PRO pg_imcube_fits2map_test

filename='~/hyd/hsiflaresforhinode/data/2006/12/05/6120521/imcube/imcube_clean_01.fits'

res=pg_imcube_fits2map_test(filename)

print,file_exist(file)

data0=mrdfits(file,0,header0)
data1=mrdfits(file,1,header1)
data2=mrdfits(file,2,header2)
;data3=mrdfits(file,3,header3) not sur whether necessary...

;  INFO on data3  ALGORITHM_USED  STRING    'HSI_CLEAN'
;   ALGORITHM_UNITS STRING    'Counts sc!u-1!n'
;   ALG_UNIT_SCALE  FLOAT           5627.79
;   PIXEL_AREA      FLOAT           4.00000
;   IMAGE_UNITS     STRING    'photons cm!u-2!n s!u-1!n asec!u-2!n'

print,data1.energy_axis
ptim,data1.energy_axis
print,data2.image_atten_state
;ok, seems to be possible to do the image cube reading stuff without too much troubles...


;ok, do nice file


END


FUNCTION  pg_imcube_fits2map,filename

IF file_exist(filename) THEN BEGIN
       
    imcube=mrdfits(filename,0,h0,status=err0)
    data1=mrdfits(filename,1,h1,status=err1)
    data2=mrdfits(filename,2,h2,status=err2)

    IF err0 EQ 0 AND err1 EQ 0 AND err2 EQ 0 THEN BEGIN

       enbins=data1.energy_axis
       tbins=data1.time_axis

       nenb=n_elements(enbins)/2
       ntb=n_elements(tbins)/2

       ptr=ptrarr(ntb,nenb)

       FOR i=0,ntb-1 DO BEGIN 
          FOR j=0,nenb-1 DO BEGIN 
             
             im=imcube[*,*,j,i]
             index=data2[i*nenb+j]

             map=make_map( im, $
                    xc   = index.used_xyoffset[0], $
                    yc   = index.used_xyoffset[1], $
                    dx   = data1.pixel_size[0], $
                    dy   = data1.pixel_size[1], $
                    time_intv=index.absolute_time_range, $
                    energy_intv=index.im_eband_used, $
                    time = anytim(0.5*(anytim(index.absolute_time_range[0])+ $
                           anytim(index.absolute_time_range[1])),/yohkoh), $
                    id     = 'RHESSI ', $
                    dur    = anytim(index.absolute_time_range[1]) - $
                                       anytim(index.absolute_time_range[0]), $
                    xunits = 'arcsec', $
                    yunits = 'arcsec' )

             ptr[i,j]=ptr_new(map)

          ENDFOR
       ENDFOR

       RETURN,ptr

    ENDIF 
ENDIF

;else
RETURN,ptr_new()

END
