;+
; NAME:
;      pg_oplot_pos2
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
;      10-DEC-2004 converted to new pos format
;      14-DEC-2004 added some options (trendline,error,connectsources)
;      
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

;{pos:qpos,tpos:tpos,framelist:framelist,n_sources:N,n_setframes:M}

PRO pg_oplot_pos2,pos_st,psym=psym,pcol=pcol,lsources=lsources $
                 ,trendline=trendline,error=error,connectsources=connectsources

   pos=pos_st.pos

   N=n_elements(pos[*,0])
   M=n_elements(pos[0,*])

   psym=fcheck(psym,[1,4,2,5,6])
   pcol=fcheck(pcol,!P.color*[1,1,1,1,1])

   IF NOT exist(error) THEN BEGIN 

   FOR i=0,N-1 DO BEGIN
      FOR j=0,M-1 DO BEGIN
         oplot,(*pos[i,j])[0,*],(*pos[i,j])[1,*],psym=psym[i],color=pcol[i]
      ENDFOR
   ENDFOR

   ENDIF ELSE BEGIN

      FOR j=0,N-1 DO BEGIN 

      x=reform(pos_st.posxarr[j,*])
      y=reform(pos_st.posyarr[j,*])

         FOR i=0,pos_st.n_totframes-1 DO BEGIN 
         
            oplot,x[i]+error*[-1,1],y[i]*[1,1],color=pcol[j]
            oplot,x[i]*[1,1],y[i]+error*[-1,1],color=pcol[j]
         
         ENDFOR

      ENDFOR


   ENDELSE

   IF keyword_set(connectsources) THEN BEGIN
 
      FOR i=0,pos_st.n_totframes-2 DO $
        FOR j=0,N-2 DO BEGIN
         oplot,pos_st.posxarr[[j,j+1],i],pos_st.posyarr[[j,j+1],i]
        ENDFOR 

 
   ENDIF

  

   IF keyword_set(trendline) THEN BEGIN
      FOR i=0,N-1 DO BEGIN
         xrange=!X.crange
         yrange=xrange*pos_st.tlin_slope[i]+pos_st.tlin_intercept[i]
         oplot,xrange,yrange
      ENDFOR
   ENDIF


END
