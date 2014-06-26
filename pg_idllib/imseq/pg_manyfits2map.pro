;+
; NAME:
;
;    pg_manyfits2map  
;
; PURPOSE:
;
;    general purpose FITS solar maps reader: transform an array of filenames in
;    an array of pointers to solar maps. An empty pointer is returned if the
;    file does not exist.
;
; CATEGORY:
;
;    image sequence utils
;
; CALLING SEQUENCE:
;
;    imseq=pg_manyfits2map(filenames [,datatype=datatype])
;
; INPUTS:
;
;    filenames an array of filenames
;
; OPTIONAL INPUTS:
; 
;    setnegtomax: if this keyword is set, the negative value of the images are
;                 set to the max value of the image.
;
;    datatype: a number between 0 and 15 defining the new type for the *data* of
;    the outputs map. The type code are IDL standard types:
;
;    Type Code Type Name Data Type 
;    0         UNDEFINED Undefined 
;    1         BYTE      Byte 
;    2         INT       Integer 
;    3         LONG      Longword integer 
;    4         FLOAT     Floating point 
;    5         DOUBLE    Double-precision floating 
;    6         COMPLEX   Complex floating 
;    7         STRING    String 
;    8         STRUCT    Structure 
;    9         DCOMPLEX  Double-precision complex 
;    10        POINTER   Pointer 
;    11        OBJREF    Object reference 
;    12        UINT      Unsigned Integer 
;    13        ULONG     Unsigned Longword Integer 
;    14        LONG64    64-bit Integer 
;    15        ULONG64   Unsigned 64-bit Integer 
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
;
;
; AUTHOR:
;
;    Paolo Grigis, Institute for Astronomy, ETH, Zurich
;    pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
;    22-MAR-2007
;-

;.comp pg_manyfits2map

FUNCTION pg_manyfits2map,filenames,datatype=datatype,setnegtomax=setnegtomax

  n=n_elements(filenames)
  
  valid=0

  IF n EQ 0 THEN BEGIN 
     print,'Please input an array of strings!'
     RETURN,ptr_new()
  ENDIF

  imseq=ptrarr(n)

  convert=exist(datatype)

  FOR i=0,n-1 DO BEGIN 

     IF file_exist(filenames[i]) THEN BEGIN

        valid=1

        fits2map,filenames[i],map,header=h

        IF convert THEN BEGIN 
           data=fix(map.data,type=datatype)
           map2=rem_tag(map,'data')
           map=add_tag(map2,data,'data',index=-1)
        ENDIF

        IF keyword_set(setnegtomax) THEN BEGIN 
           ind=where(map.data LT 0,count)
           IF count GT 0 THEN map.data[ind]=max(map.data)
        ENDIF

        imseq[i]=ptr_new(map)

     ENDIF ELSE BEGIN 

        imseq[i]=ptr_new()

     ENDELSE

  ENDFOR 

  IF valid EQ 0 THEN BEGIN
     print,'No valid files found!'
  ENDIF


  RETURN,imseq

END

