;+
; NAME:
;
; pg_dopsplot
;
; PURPOSE:
;
; Utility for the creation of a PS or EPS plot
;
; CATEGORY:
;
; plot utilities
;
; CALLING SEQUENCE:
;
; pg_dopsplot,routine_name
;
; INPUTS:
;
; routine_name: a string with the name of the routine to be called for
;               the plot creation. This routine should only accept
;               keyword parameter input and needs to be able to accept
;               at least one keyword
; sizex,y: postscript plot dimensions
; offsetx,y: postscript offset dimensions
;         
; OPTIONAL INPUTS:
;
; 
; KEYWORD PARAMETERS:
;
;
; OUTPUT:
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
; .comp 
; PRO aa,x=x,y=y,_extra=_extra
;   plot,x,y
; END
;
;pg_dopsplot,'~/test.ps','aa',xx=[1,2,3],yy=[3,4,2],ysize=10,yoffset=10;,dummy=1
;
;
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 16-JAN-2005 written P.G.
;
;-

PRO pg_dopsplot,filename,routine_name,sizex=sizex,sizey=sizey,psfonts=psfonts $
             ,offsetx=offsetx,offsety=offsety,encapsulated=encapsulated $
             ,_extra=_extra

oldp=!P
pg_set_ps,filename=filename+'~',xsize=sizex,ysize=sizey,psfonts=psfonts $
         ,xoffset=offsetx,yoffset=offsety,encapsulated=encapsulated



call_procedure,routine_name,_extra=_extra

device,/close
set_plot,'X'

newtitle='Created by '+routine_name+'.pro'

sedcommand="sed 's;^\(%%Title: *\).*$;\1"+newtitle+";'< "+filename+"~"+" > "+filename
rmcommand='rm '+filename+'~'

spawn,sedcommand
spawn,rmcommand

;sed command from the IDL newsgroup
;sed 's;^\(%%Title: *\).*$;\1NEWTITLE;' < test1.ps > test2.ps

!P=oldp


END
