;+
; NAME:
;      pg_oplot_pos
;
; PURPOSE: 
;      overplot the positions on a map
;
; CALLING SEQUENCE:
;
;      pg_oplot_pos,pos_st,...
;
; INPUTS:
;      
;      pos_st: position structure, the output from pg_posbox_fit

;
;  
; OUTPUTS:
;      
;      
; KEYWORDS:
;      
;
; HISTORY:
;
;      16-NOV-2004 written PG
;      
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

;{pos:qpos,tpos:tpos,framelist:framelist,n_sources:N,n_setframes:M}

PRO pg_oplot_pos,pos_st,psym=psym,pcol=pcol,lsources=lsources

   IF exist(lsources) THEN  pos=pos_st.pos[lsources,*] ELSE pos=pos_st.pos


   N=n_elements(pos[*,0])
   M=n_elements(pos[0,*])

   psym=fcheck(psym,[1,4,2,5,6])
   pcol=fcheck(pcol,!P.color*[1,1,1,1,1])

   FOR i=0,N-1 DO BEGIN
      FOR j=0,M-1 DO BEGIN
         oplot,(*pos[i,j])[0,*],(*pos[i,j])[1,*],psym=psym[i],color=pcol[i]
      ENDFOR
   ENDFOR



END
