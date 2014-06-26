;+
; NAME:
;
; pg_gbandstructinfo
;
; PURPOSE:
;
; reads in a g-band image file and prduces output info on brightness
;
; CATEGORY:
;
; gband dataproduct automatic creation
;
; CALLING SEQUENCE:
; 
; pg_gbandstructinfo,file,spotmap=spotmap,dx=dx,dy=dy
;
; INPUTS:
;
; file: an IDL save file containing the daily images
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
;
;
; MODIFICATION HISTORY:
; 29-APR-2008 written PG
;
;-

FUNCTION pg_gbandstructinfo,data,index,spotmap=spotmap,dx=dx,dy=dy

s=size(data)

IF (s[0] EQ 2) OR (s[0] EQ 3) THEN BEGIN 
   nx=s[1]
   ny=s[2]

   xrange=nx/2+[-dx,dx]/2
   yrange=ny/2+[-dy,dy]/2

   IF s[0] EQ 2 THEN BEGIN 
      stemp={time:0d,nonsplum:0.0,splum:0.0}

      im=data[xrange[0]:xrange[1],yrange[0]:yrange[1]]
      ind1=where(spotmap[xrange[0]:xrange[1],yrange[0]:yrange[1]] EQ 1,complement=ind2)
      stemp.splum=total(im[ind1])/n_elements(ind1)/index.chip_sum^2.
      stemp.nonsplum=total(im[ind2])/n_elements(ind2)/index.chip_sum^2.
      stemp.time=anytim(index.date_obs)
   ENDIF $ 
   ELSE BEGIN 
      stemp=replicate({time:0d,nonsplum:0.0,splum:0.0},s[3])

      FOR i=0,s[3]-1 DO BEGIN 
         im=data[xrange[0]:xrange[1],yrange[0]:yrange[1]]
         ind1=where(spotmap[xrange[0]:xrange[1],yrange[0]:yrange[1]] EQ 1,complement=ind2)
         stemp[i].splum=total(im[ind1])/n_elements(ind1)/index[i].chip_sum^2.
         stemp[i].nonsplum=total(im[ind2])/n_elements(ind2)/index[i].chip_sum^2.
         stemp[i].time=anytim(index[i].date_obs)
      ENDFOR
   ENDELSE
   return,stemp
ENDIF $
ELSE return,-1



END


