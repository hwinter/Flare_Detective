;+
; NAME:
;
; pg_imlist2html
;
; PURPOSE:
;
; convert an image list into an html file displaying them
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
; pg_imlist2html,imlist,htmlfilename
;
; INPUTS:
;
; imlist: a list of (image) file names
; htmlfilename: the output file name (will be overwritten if already exists)
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
; Paolo Grigis, CfA
; pgrigis@cfa.harvard.edu
;
; $Id: pg_imlist2html.pro 5 2007-12-04 21:15:49Z pgrigis $
;
; MODIFICATION HISTORY:
;
; 7-SEP-2007 written
;
;-

;.comp  pg_imlist2html

PRO pg_imlist2html,imlist,htmlfilename

head=['<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">', $
      '<html> <head>', $
      '<title>Created by IDL</title>', $
      '</head>', $
      ' ', $
      '<body>', $
      '<h1></h1>']



body=' '

FOR i=0,n_elements(imlist)-1 DO BEGIN 
   body=[body,'<IMG SRC="'+imlist[i]+'">']
ENDFOR



tail=['<hr>', $
      '<address></address>', $
      '<!-- hhmts start --> <!-- hhmts end -->', $
      '</body> </html>']

htmlfile=[head,body,tail]


openw,lun,htmlfilename,/get_lun,error=err

if err ne 0 then begin
   print,'Error opening file '+file
   return
endif


printf,lun,htmlfile,format='(a)'

close,lun
free_lun,lun
 

END

