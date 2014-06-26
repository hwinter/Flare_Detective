;+
; NAME:
;
;   pg_getplotpos
;
; PURPOSE:
;
;   returns the position of a plot in normalized coordinates, given a relative
;   position and two plot coordinates i,j out of n row and m columns
;
; CATEGORY:
;
;   plot util
;
; CALLING SEQUENCE:
;
;
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
;
;
; AUTHOR:
;
;   Paolo Grigis (pgrigis@astro.phys.ethz.ch)
;
;   written 10-JUL-2007
;
;-

;.comp pg_getplotpos


FUNCTION pg_getplotpos,i,j,nx=nx,ny=ny,aspect=aspect,shiftx=shiftx,shifty=shifty

  IF n_elements(shiftx) EQ 0 THEN shiftx=0.
  IF n_elements(shifty) EQ 0 THEN shifty=0.
  IF n_elements(aspect) EQ 0 THEN aspect=[0.1,0.1,0.9,0.9]

  dx=(1./nx)
  dy=(1./ny)

  thispos=[dx*i,1-dy*j,dx*i,1-dy*j]
  thisaspect=[aspect[0],1-aspect[1],aspect[2],1-aspect[3]]

  finalpos=thispos+thisaspect*[dx,-dy,dx,-dy]+[shiftx,shifty,shiftx,shifty]

  return,finalpos

END
