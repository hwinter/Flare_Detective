;+
; NAME:
;       remove_frame
;
; PURPOSE:
;	returns original input image cube , minus one frame.
;
; CALLING SEQUENCE:
;       newcube=remove_frame(cube,pos)
;
; INPUT:
;	cube: an image cube (Xdim,Ydim,nbr)
;	pos : position of the frame to be removed
;
; KEYWORD INPUTS:
;	None
;
; OUTPUT:
;	original image cube minus selected frame.
;
; COMMON BLOCKS:
;	None
;
; RESTRICTIONS:
;       None
;
; EXAMPLE:
;	IDL> cube=INDGEN(64,64,128)
;	IDL> newcube=remove_frame(cube,12)
;       IDL> HELP,newcube
;
; HISTORY:
;	Written by Pascal Saint-Hilaire (Saint-Hilaire@astro.phys.ethz.ch) on 2003/02/10
;		
;-

;====================================================================================
FUNCTION remove_frame, cube, pos
	S=size(cube)
	IF S[3] LE 1 THEN RETURN,cube				;cube too small or inexistant!
	IF ((pos LT 0) OR (pos GE S[3])) THEN RETURN,cube	;pos is out of bounds...


	IF pos EQ 0 THEN RETURN,cube[*,*,1:*]
	IF pos EQ S[3]-1 THEN RETURN,cube[*,*,0:S[3]-2]
	RETURN,[[[cube[*,*,0:pos-1]]],[[cube[*,*,pos+1:*]]]]
END
;====================================================================================
