;+
; NAME:
;      pg_load_imseq
;
; PURPOSE: 
;      this procedure loads an image cube or a series of images frames into
;      a pointer to an array of enhanced maps, with more TAGS than the
;      standard Zarro maps (all supplementary tag begin with 'PG_')
;
; INPUTS:
;      
;      filename: either the image cube filename, or the first image of
;         an image sequence. The routine assumes that FITS files of
;         image sequences all are of the form xxx_frame_nnnnn.fits
;         where xxx is a sequence which does not contains the word
;         frame and nnnn is the sequential number, and that image
;         cubes FITS file don't contain 'frame'
;
;      id: optional unique id for the cube to go in the PG_ID tag
;  
; OUTPUTS:
;      
;      
; KEYWORDS:
;      quiet: suppress info messages  
;
; HISTORY:
;
;      12-NOV-2004 written PG
;      10-JAN-2005 added image error support PG
;      
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

FUNCTION pg_load_imseq,filename,id=id,quiet=quiet

   IF NOT file_exist(filename) THEN BEGIN
      print,"Couldn't find file: "+filename
      print,'Aborting...'
      RETURN,-1
   ENDIF


   id_=fcheck(id,' ')

   ;find out if frame is contained in the file name string
   res=stregex(filename,'frame_*',length=length,/fold_case)
   imseq=res GE 0

   IF imseq THEN BEGIN ;we have an image sequence of different files
 
      ;decompose the string in its components
      endstring=strmid(filename,res+length)
      endparts=strsplit(endstring,'.',/extract)
      nums=endparts[0]
      sl=strlen(nums)
      filtype='.'+endparts[1]
      base=strmid(filename,0,res+length)
      
      num=long(nums)

      thisframe=filename
      nframes=1

      ;count how may frames are present
      WHILE file_exist(thisframe) DO BEGIN

         ;print,thisframe
         num=num+1
         nframes=nframes+1
         thisframe=base+smallint2str(num,strlength=sl)+filtype

      ENDWHILE

      num=long(nums)
      nframes=nframes-1
      mapptr=ptrarr(nframes)
      
      ;produce map structures
      FOR i=0,nframes-1 DO BEGIN

         IF NOT keyword_set(quiet) THEN $
            print,'Now loading frame '+strtrim(string(i),2)+' out of ' $
                                      +strtrim(string(nframes),2)

         framst=smallint2str(num+i,strlength=sl)
         thisframe=base+framst+filtype
         data=mrdfits(thisframe,0,header,/silent)
         index=fitshead2struct(header)
         index2map,index,data,map,/no_copy

         par=mrdfits(thisframe,1,/silent)
         ;get info parameters of the image...

         map=add_tag(map,float(par.im_energy_binning),'PG_ENERGY_RANGE')
         map=add_tag(map,par.time_range,'PG_TIME_RANGE')
         map=add_tag(map,par.time_range[1]-par.time_range[0],'PG_DURATION')
         map=add_tag(map,reform(par.det_index_mask[*,0:1],18),'PG_SEGMENTS')
         map=add_tag(map,hsi_seg2str(map.pg_segments),'PG_SEG_STRING')
         map=add_tag(map,par.image_algorithm,'PG_IMAGE_ALGORITHM')

         IF strupcase(par.image_algorithm) EQ 'PIXON' THEN BEGIN
            map=add_tag(map,par.pixon_sensitivity,'PG_PIXON_SENSITIVITY')
         ENDIF

         IF strupcase(par.image_algorithm) EQ 'FORWARD FIT' THEN BEGIN
            par3=mrdfits(thisframe,3)
            map=add_tag(map,par3.ff_coeff_ff,'PG_FF_FITPAR')
            map=add_tag(map,par.ff_npar,'PG_FF_NPAR')
         ENDIF

         map=add_tag(map,id_,'PG_ID')
         
         mapptr[i]=ptr_new(map)
         
      ENDFOR 
      
   ENDIF $
   ELSE BEGIN ;we have an image cube

      ;import code from psh_fits2map

      ;filename='~/work/footp/imcubes/im_8sec_1en_peak_cl_imcube.fits'

      print,'Now reading imcube FITS file'
      imcube=mrdfits(filename,0,header,/silent)
      par=mrdfits(filename,1,pheader,/silent)
      index=fitshead2struct(header)
      data=fltarr(index.naxis1,index.naxis2)
      index2map,index,data,temp_map,/no_copy

      par3=mrdfits(filename,3);third extension pars
      

      n_enbands=index.naxis3;number of enegry bands in the cube
      n_tbands=index.naxis4 ;number of time intervals in the cube

      mapptr=ptrarr(n_enbands,n_tbands)

      FOR i=0,n_tbands-1 DO BEGIN
         FOR j=0,n_enbands-1 DO BEGIN

            print,'Now loading frame ('+ $
               strtrim(string(i),2)+ ',' + $
               strtrim(string(j),2)+') out of (' + $
               strtrim(string(n_tbands-1),2) +','+ $
               strtrim(string(n_enbands-1),2) +')'

            map=temp_map

            map.data=imcube[*,*,j,i]
            map.time=anytim(par.im_time_interval[0,i],/vms)
            map.dur=par.im_time_interval[1,i]-par.im_time_interval[0,i]

            map=add_tag(map,float(par.im_energy_binning[*,j]), $
                        'PG_ENERGY_RANGE')
            map=add_tag(map,par.im_time_interval[*,i],'PG_TIME_RANGE')
            map=add_tag(map,map.dur,'PG_DURATION')
            map=add_tag(map,reform(par.det_index_mask[*,0:1],18),'PG_SEGMENTS')
            map=add_tag(map,hsi_seg2str(map.pg_segments),'PG_SEG_STRING')
            map=add_tag(map,par.image_algorithm,'PG_IMAGE_ALGORITHM')

            IF have_tag(par3,'IM_ERROR') THEN BEGIN
               extension=i+3
               extpar=mrdfits(filename,extension)
               map=add_tag(map,extpar.im_error,'PG_IM_ERROR')             
            ENDIF

  
            IF strupcase(par.image_algorithm) EQ 'PIXON' THEN BEGIN
               map=add_tag(map,par.pixon_sensitivity,'PG_PIXON_SENSITIVITY')
            ENDIF

            IF strupcase(par.image_algorithm) EQ 'FORWARD FIT' THEN BEGIN
               extension=4+j*n_tbands+(i>1)-1
               par3=mrdfits(filename,extension,/silent)
               map=add_tag(map,par3.ff_coeff_ff,'PG_FF_FITPAR')
               ;map=add_tag(map,par.ff_npar,'PG_FF_NPAR')
            ENDIF

          map=add_tag(map,id_,'PG_ID')
  
            mapptr[j,i]=ptr_new(map)

         ENDFOR
      ENDFOR

      IF n_enbands EQ 1 THEN mapptr=reform(mapptr)

   ENDELSE

   RETURN,mapptr

END

