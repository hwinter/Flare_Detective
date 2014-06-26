;+
; NAME:
;
; xrt_imsizeonsc
;
; PURPOSE:
;
; retrieve the image size on the spacecraft of XRT images
;
; CATEGORY:
;
; xrt utils
;
; CALLING SEQUENCE:
;
; result=xrt_imsizeonsc(filelist)
;
; INPUTS:
;
; filelist: a list of XRT images FITS files (works with QLraw, QickLook
; and level0 files)
;
; KEYWORD PARAMETERS:
;
; NONE
;
; OUTPUTS:
;
; result: an array of structures (one structure for each valid input file)
;         with the following TAGS
;         XSIZE:  number of columns in the image (*after* rebinning)
;         YSIZE:  number of rows    in the image (*after* rebinning)
;         BITSPP: bits per pixel of the image on the spacecraft
;         DSIZE:  total size, in bits, of the image on the spacecraft
;         TIME:   image time
;         COMTYPE : compression type (string, one of UNCOMPRESSED, DPCM, Q98, Q95, Q92, Q90, Q85, Q75, Q65, Q50)
;         COMTNUM : compression type (byte  , one of     0,           1,   2,   3,   4,   5,   6,   7,   8,   9)
;         COMCOTPER : compression % given by COT         100 ,       57,  52,  43,  35,  30,  27,  22,  20,  17)
;
; COMMON BLOCKS:
;
; NONE
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
; reads in the following keywords from the FITS headers: NAXIS1 NAXIS2 BITSPP 
; DATE_OBS IMGCOMP1 QTABLE1
;
;
; EXAMPLE:
;
; basdir='/archive/hinode/xrt/QLraw/'
; filelist=file_search(basdir+'2008/02/28/','*.fits')
; data=xrt_imsizeonsc(filelist)
; utplot,data.time-data[0].time,total(data.dsize,/cumulative)/(2d^20),data[0].time $
;        ,ytitle='Mbits (1Mbit=1048576 bits)',title='Total image size starting from ' $
;        +anytim(data[0].time,/vms),psym=-4
;
;
; AUTHOR:
;
; Paolo Grigis, SAO, pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 03-MAR-2008 written PG
; 05-MAR-2008 added option for getting compression level of the images PG
;
;-

FUNCTION xrt_imsizeonsc,filelist

  ;check for existence of files
  ind=where(file_exist(filelist) EQ 1,nfiles)
  
  ;need at least oine valid file to proceed
  IF nfiles EQ 0 THEN BEGIN 
     print,'No valid FITS file found. Check your input. Returning.'
     RETURN,-1
  ENDIF

  ;initialize output data structure
  data=replicate({xsize:0L,ysize:0L,bitspp:0d,dsize:0d,time:0d, $
                  comtype:'UNKNOWN',comtnum:255B,comcotper:255B, $
                  imtype:255B,imfw1:255B,imfw2:255B},nfiles)

;TO DO: add jpeg/dctm Qfactor <> percentage in COT language


  FOR i=0L,nfiles-1 DO BEGIN 
     
     header=headfits(filelist[ind[i]])

     IF size(header,/tname) EQ 'STRING' THEN BEGIN 

        ;Extract FITS keyword (first 8 chars) 
        keyword_list=strmid(header,0,8)

        ;look for the keyword wanted here (this is needed
        ; because the position of any given keyword may change
        ; from file to file)
        naxis1  =where(keyword_list EQ 'NAXIS1  ')
        naxis2  =where(keyword_list EQ 'NAXIS2  ')
        bitspp  =where(keyword_list EQ 'BITSPP  ',countbpp)
        dateob  =where(keyword_list EQ 'DATE_OBS')
        imgcomp1=where(keyword_list EQ 'IMGCOMP1')
        qtable1 =where(keyword_list EQ 'QTABLE1 ')

        ;info about observation type etc.
        imtype =where(keyword_list EQ 'EC_IMTYP')
        imfw1  =where(keyword_list EQ 'EC_FW1  ')
        imfw2  =where(keyword_list EQ 'EC_FW2  ')
        data[i].imtype=fix(strmid(header[imtype],20,12))
        data[i].imfw1=fix(strmid(header[imfw1],20,12))
        data[i].imfw2=fix(strmid(header[imfw2],20,12))



        ;compute desired output
        xsize=long(strmid(header[naxis1],26,4))
        ysize=long(strmid(header[naxis2],26,4))
        IF countbpp GT 0 THEN bitsperpixel=double(strmid(header[bitspp],20,12)) ELSE bitsperpixel=0.
        time=anytim(strmid(header[dateob],11,23))

        ;compression type & quant. level from FITS keyword
        compmode=fix(strmid(header[imgcomp1],20,12))
        comptable=fix(strmid(header[qtable1],20,12))

        ;values taken from the Hinode "Blue Book" page 1215 (16 MDP Table 4.3-8)

        CASE compmode OF 
           0: BEGIN
              comtnum=0B
              comtype='UNCOMPRESSED'
              comcotper=100B
           END
           3: BEGIN 
              comtnum=1B
              comtype='DPCM'
              comcotper=57B
           END
           7: BEGIN
              comtnum=2B+([0B,3,5,7,1,2,4,6])[comptable]
              comtype  =(['Q98','Q95','Q92','Q90','Q85','Q75','Q65','Q50'])[comtnum-2]
              comcotper=([ 52B,   43 , 35  ,  30 , 27  , 22  , 20  , 17  ])[comtnum-2]
           END
        ENDCASE


        ;fill in the structure
        data[i].xsize=xsize
        data[i].ysize=ysize
        data[i].bitspp=bitsperpixel
        data[i].dsize=bitsperpixel*xsize*ysize
        data[i].time=time
        data[i].comtype=comtype
        data[i].comtnum=comtnum
        data[i].comcotper=comcotper

     ENDIF

ENDFOR

RETURN,data

end



