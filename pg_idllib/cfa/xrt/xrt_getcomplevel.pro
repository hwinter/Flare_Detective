;+
; NAME:
;
;  xrt_getcomplevel
;
; PURPOSE:
;
;  This function returns the type and level of compression of XRT images.
;
; CATEGORY:
;
;  Hinode/XRT utils
;
; CALLING SEQUENCE:
;
;  complev=xrt_getcomplev(index [,error=error])
;
; INPUTS:
;
;  index: an index structure produced by read_xrt
;
; KEYWORD PARAMETERS:
;          
;  error: optional, a value of 0 indicates success, any other value failure
;
; OUTPUTS:
;
;  complev: an array of structures (same number of elements as index) with the following TAGS:
;
;         BITSPP:      (FLOAT)  bits per pixel of the image on the spacecraft
;         IMSIZE:      (LONG)   total size, in bits, of the image on the spacecraft
;         EFFCOMPFACT: (FLOAT)  compression efficiency factor (percentage of uncompressed size)
;         TIME:        (DOUBLE) image time (anytim.pro format)
;         COMPTYPE :   (STRING) compression type, one of 'UNCOMPRESSED', 'DPCM LOSSLESS', 'DCT LOSSY', 'UNKNOWN'
;         COMPTNUM :   (STRING) compression type, one of             0 ,              1 ,          2 ,        -1 
;         COMPQFACT:   (INT)    compression quantization level, one of 98, 95, 92, 90, 85, 75, 65, 50, -1
;                               This values is meaningful only if the compression type is DCT, otherwise is set to -1.
;         COMPCOTPERCENT :      equivalent compression percentage value given by XRT planning's tool (COT).
;                               This number is only useful with observation planning, the real compression
;                               value is given in the EFFCOMPFACT tag. Translation table:
;    
;                               COMP TYPE     Q LEVEL  COT VALUE
;                               UNCOMPRESSED  N/A      100
;                               DPCM          N/A      57
;                               DCT           98       52
;                               DCT           95       43
;                               DCT           92       35
;                               DCT           90       30
;                               DCT           85       27
;                               DCT           75       22
;                               DCT           65       20
;                               DCT           50       17
;
;
;
; COMMON BLOCKS:
;
;  NONE
;
; CALLS:
;
;  STR_TAGVAL
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
;  Reads in the following tags from the INDEX structure: NAXIS1 NAXIS2 BITSPP DATE_OBS IMGCOMP1 QTABLE1.
;  The scheme for conversion from the values of IMGCOMP1 and QTABLE1 to the quantization levels is taken
;  from the "Hinode Blue Book" page 1215 (section 16:MDP, Table 4.3-8) 
;
; EXAMPLE:
;
;  xrt_cat,'20-FEB-2008 05:32:50','20-FEB-2008 06:00',cat,files,sirius=0
;  read_xrt,files,index
;  complev=xrt_getcomplevel(index)
;
; AUTHOR:
;
;  Paolo Grigis, SAO, pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
;  03-MAR-2008 written PG
;  05-MAR-2008 added option for getting compression level of the images PG
;  12-MAR-2008 finalized version for SSW PG
;
;-

FUNCTION xrt_getcomplevel,index,error=error


  ;initializations & error checking

  error=0

  nimages=n_elements(index)
  
  IF nimages EQ 0 OR size(index,/tname) NE 'STRUCT' THEN BEGIN 
     print,'Invalid INDEX input. Should be a structure produced by read_xrt. Returning.'
     error=1
     RETURN,-1
  ENDIF


  ;initialize output data structure
  complev_template={bitspp:0., $
                    imsize:0L, $
                    effcompfact:0., $
                    time:0d, $
                    comptype:'UNKNOWN', $
                    comptnum:-1, $
                    compqfact:-1, $
                    compcotpercent:-1} 

  ;the output is an array of structures
  complev=replicate(complev_template,nimages)



  FOR i=0L,nimages-1 DO BEGIN 
     
     thisind=index[i]

     ;Read index structure tags

     xsize=str_tagval(thisind,'NAXIS1')>0L
     ysize=str_tagval(thisind,'NAXIS2')>0L

     bitsperpixel=str_tagval(thisind,'BITSPP')>0.
     time =anytim(str_tagval(thisind,'DATE_OBS'))

     imsize=round(xsize*ysize*bitsperpixel)>0L
     effcompfact=bitsperpixel/12.*100.;12 bits/pixel is the uncompressed value

     ;compression type & quantization table
     compmode =str_tagval(thisind,'IMGCOMP1')
     comptable=str_tagval(thisind,'QTABLE1')
     
     ;check if comptable has an OK range, if not there is a problem
     ;with the FITS keyword values used to generate the index
     IF comptable LT 0 OR comptable GT 7 THEN compmode=-1

     ;conversion taken from the "Hinode Blue Book" page 1215 (section 16:MDP, Table 4.3-8)

     CASE compmode OF 
        0: BEGIN
           comptnum=0
           comptype='UNCOMPRESSED'
           compcotper=100B
           compqfact=-1
        END
        3: BEGIN 
           comptnum=1
           comptype='DPCM LOSSLESS'
           compcotper=57B
           compqfact=-1
        END
        7: BEGIN
           comptnum=2            
           comptype='DCT LOSSY'
           compqfact= ([98, 90, 75, 50, 95, 92, 85, 65])[comptable]  
           compcotper= ([52, 30, 22, 17, 43, 35, 27, 20])[comptable]
        END
        ELSE: BEGIN
           comptnum=-1
           comptype='UNKNOWN'
           compqfact=-1
           compcotper=-1
        END
        
     ENDCASE
     
     complev[i].bitspp=bitsperpixel
     complev[i].imsize=imsize
     complev[i].effcompfact=effcompfact
     complev[i].time=time

     complev[i].comptype=comptype
     complev[i].comptnum=comptnum
     complev[i].compqfact=compqfact
     complev[i].compcotpercent=compcotper
 
  ENDFOR

RETURN,complev

end



