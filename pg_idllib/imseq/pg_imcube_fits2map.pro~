;+
;
; NAME:
;        hsi_pg_fits2map
;
;        please note that hsi_fits2map already exist, but do not
;        exactly does what I would like it to do, and therefore I
;        wrote this "pg" version. It does return a pointer array
;        instead of a map array
;
;
; PURPOSE: 
;        return an array of pointers to map objects taken from RHESSI
;        images stored in a fit file. NOTE: the time of the image (map.time)
;        represent the middle of the int time, the end is given by
;        map.time+0.5*map.dur,the beginning by map.time-0.5*map.dur
;
;
; CALLING SEQUENCE:
;
;        ptr=hsi_pg_fits2map(filename)
;
; INPUTS:
;        filename: fits file name
;
; OUTPUT:
;
; VERSION:
;       30-JAN-2003 written
;       18-MAR-2003 modified the map.time tag such that now gives the
;       middle of the integration time instead of the beginning, for
;       compatibility with other routines and easier plotting
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION  hsi_pg_fits2map,filename

IF file_exist(filename) THEN BEGIN
       
    im=mrdfits(filename,0,h0,status=err0)
    index=mrdfits(filename,1,h1,status=err1)

    IF err0 EQ 0 AND err1 EQ 0 THEN BEGIN
        IF (size(im))[0] EQ 0 THEN BEGIN
            ptr=ptr_new()
        ENDIF ELSE BEGIN

            map=make_map( im, $
                    xc   = index.xyoffset[0], $
                    yc   = index.xyoffset[1], $
                    dx   = index.pixel_size[0], $
                    dy   = index.pixel_size[1], $
                    time = anytim(0.5*(anytim(index.time_range[0])+ $
                           anytim(index.time_range[1])),/yohkoh), $
                    id     = 'RHESSI ', $
                    dur    = anytim(index.time_range[1]) - $
                                       anytim(index.time_range[0]), $
                    xunits = 'arcsec', $
                    yunits = 'arcsec' )

                ptr=ptr_new(map)
        ENDELSE
        ;index2map, h0, im, map
    ENDIF $
    ELSE RETURN, ptr_new()

    map.id='RHESSI '
 
    ptr=ptr_new(map)

    n=2

    REPEAT BEGIN

        index=mrdfits(filename,n,h,status=err)

        CASE err OF

            0: BEGIN
                IF (size(index.image))[0] EQ 0 THEN BEGIN
                    ptr=[ptr,ptr_new()]
                ENDIF ELSE BEGIN

                map=make_map( index.image, $
                    xc   = index.xyoffset[0], $
                    yc   = index.xyoffset[1], $
                    dx   = index.pixel_size[0], $
                    dy   = index.pixel_size[1], $
                    time = anytim(0.5*(anytim(index.time_range[0])+ $
                           anytim(index.time_range[1])),/yohkoh), $
                    id     = 'RHESSI ', $
                    dur    = anytim(index.time_range[1]) - $
                                       anytim(index.time_range[0]), $
                    xunits = 'arcsec', $
                    yunits = 'arcsec' )

                ptr=[ptr,ptr_new(map)]

                ENDELSE
            END

            -1: ptr=[ptr,ptr_new()]

            ELSE: ;print,err

        ENDCASE

        n=n+1                  
        
    ENDREP UNTIL err EQ -2

    RETURN,ptr

ENDIF $
ELSE BEGIN
RETURN,ptr_new()
ENDELSE


END
