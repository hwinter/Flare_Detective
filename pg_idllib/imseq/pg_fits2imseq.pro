;+
;
; NAME:
;        pg_fits2imseq
;
; PURPOSE:
;        read in a set of FITS files and transform them into maps
;
; CALLING SEQUENCE:
;
;        imseq=pg_fits2imseq(filelist)
;
; INPUTS:
;
;        filelist: list of strings of filenames
;
; OUTPUT:
;
; EXAMPLE:
;
;        
;
; VERSION:
;
;        14-FEB-2007 written, based on imseq_manip
;        20-FEB-2007 changed logic of finding where files exist
;                    and output status line using wayne landsman's method
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;-

;.comp pg_fits2imseq

function pg_fits2imseq,filelist,xrt=xrt,verbose=verbose
  
  silent=1-exist(verbose)

  nfile=n_elements(filelist)

  okind=where(file_exist(filelist),count)
  
  IF count EQ 0 THEN RETURN,-1

  cr=string(13b)

  imseq=ptrarr(count)

  for i=0,count-1 do begin
     
     print,'Now reading file number '+strtrim(i+1,2)+' of '+strtrim(count,2),cr,f='($,a,a)'

     fits2map,filelist[okind[i]],map,header=h,silent=silent

     data=double(map.data)

     map2=rem_tag(map,'data')
     map=add_tag(map2,data,'data')

 
     if keyword_set(xrt) then begin

        index=fitshead2struct(h)

        map2=add_tag(map,index.ec_fw1_,'FW1')
        map=add_tag(map2,index.ec_fw2_,'FW2')

        map=add_tag(map,index.exptime,'exp_time')

        map.id='XRT: '+map.fw1+'/'+map.fw2

     endif

     imseq[i]=ptr_new(map)

  endfor
  
  print,cr

  return,imseq
  
end


