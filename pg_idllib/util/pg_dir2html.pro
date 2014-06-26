;+
;
; NAME:
;        pg_dir2html
;
; PURPOSE: 
;
;        creates an HTML index of all files in a directory
;
; CALLING SEQUENCE:
;
;        pg_dir2html(dir)
;    
; 
; INPUTS:
;
;        dir: a string with a (valid) directory name
;
; KEYWORDS:
;        
;                
; OUTPUT:
;        a HTML file called dirindex.html
;
; CALLS:
;       
;
; EXAMPLE:
; 
;       
; 
; VERSION:
;       
;       01-SEP-2005 written
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

PRO pg_dir2html,dir_in

dir=dir_in

cd,dir,current=old_dir

res=file_search('*.*',count=count,/test_regular)

head=['<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN"> ', $
      '<HTML>', $
      '<HEAD>', $
      '<TITLE>Index of ' +dir+' </TITLE>', $
      '</HEAD>', $
      '<BODY>', $
      '<H1>Index of '+dir+' </H1>', $
      '<H1> Name </H1> <HR>', $
      '<PRE>  ']

body='<A HREF="'+res+'">'+res+'</A>'


tail=['<HR></PRE>', $
      '<ADDRESS> Created by  <A HREF="mailto:pgrigis@cfa.harvard.edu">Paolo Grigis</A> </ADDRESS> ', $
      '</BODY>', $
      '</HTML>']


htmlfile=[head,body,tail]


openw,lun,'dirindex.html',/get_lun,error=err
if err ne 0 then begin
   print,'Error opening file '+file
;   err_msg = !err_string
;   print,!err_string
   return
endif



printf,lun,htmlfile,format='(a)'


close,lun
free_lun,lun


cd,old_dir


END



