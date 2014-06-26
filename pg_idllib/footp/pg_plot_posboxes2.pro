;+
; NAME:
;      pg_plot_posboxes2
;
; PURPOSE: 
;      plots the maps with posboxes (optionally positions)
;
; CALLING SEQUENCE:
;
;      pg_plot_posboxes,ptr,pbox,...
;
; INPUTS:
;      
;      ptr: array of pointer to maps
;      pos: the fitted positions
;
; OUTPUTS:
;      
;      
; KEYWORDS:
;      
;
; HISTORY:
;
;      17-NOV-2004 written PG
;      06-DEC-2004 changed a little to accomodate for new peaklist format
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-


PRO pg_plot_posboxes2,ptr,pos,psym=psym,pthick=pthick,_extra=_extra

flist=pos.framelist
pbox=pos.pbox

;nim=total(flist[1,*]-flist[0,*])+1

N=n_elements(pbox[*,0]);n of sources
M=n_elements(flist[0,*]);n peaks

psym=fcheck(psym,1)
pthick=fcheck(pthick,1)

FOR i=0,M-1 DO BEGIN;loops over peaks
   FOR j=0,N-1 DO BEGIN;loops over sources

      framelist=*flist[j,i]
      
      FOR k=0,n_elements(framelist)-1 DO BEGIN 
         
         thisframe=framelist[k]
      ;j0=flist[0,i]
         map=*ptr[thisframe]
      

         title='PEAK Nr. '+strtrim(string(i),2)+' , FRAME ' $
               +strtrim(string(thisframe),2) +' ID: '+map.pg_id

         plot_map,map,title=title,_extra=_extra

      
;         FOR k=0,N-1 DO BEGIN
         box=*pbox[j,i]
         oplot,box[[0,1,1,0,0]],box[[2,2,3,3,2]]
         posarr=*pos.pos[j,i]
         
         oplot,posarr[[0,0],k],posarr[[1,1],k],psym=psym,thick=pthick

      ENDFOR


   ENDFOR
ENDFOR



END
