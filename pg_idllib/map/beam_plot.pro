;+
;
; NAME:
;       beam_plot
;
; PROJECT: 
;       radio images
;
; PURPOSE: 
;       overplot a beam (i.e. an ellipse) over a map
;
;
; CALLING SEQUENCE:
;       beam_plot,beam
;
; INPUTS:
;       beam=[x_center,y_center,axis1,axis2,tilt_angle]
;
; OUTPUT:
;       on a plot window
;       
; KEYWORDS:
;       beamcolor: color for the beam
;       bgcolor: color for the background of the beam
;
; EXAMPLE:
;        
;
; VERSION:
;       13-MAR-2003 written
;       17-MAR-2003 corrected bug in beam angle and updated header
;
; COMMENT:
;       uses TVELLIPSE
;
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

PRO beam_plot,beam,bgcolor=bgcolor,beamcolor=beamcolor

IF NOT keyword_set(bgcolor) THEN bgcolor=0

IF NOT keyword_set(beamcolor) THEN beamcolor=0


graxis=max(beam[2:3])/2.

polyfill,[beam[0]-graxis,beam[0]+graxis, $
          beam[0]+graxis,beam[0]-graxis], $
         [beam[1]-graxis,beam[1]-graxis, $
          beam[1]+graxis,beam[1]+graxis], $
         color=bgcolor,/data


oplot,[beam[0]-graxis,beam[0]+graxis, $
          beam[0]+graxis,beam[0]-graxis,beam[0]-graxis], $
         [beam[1]-graxis,beam[1]-graxis, $
          beam[1]+graxis,beam[1]+graxis,beam[1]-graxis], $
          color=beamcolor

tvellipse,beam[2]/2.,beam[3]/2.,beam[0],beam[1],90+beam[4] $
         ,/data,color=beamcolor

polyfill,[100,200],[100,200],color=100,/device

END






















