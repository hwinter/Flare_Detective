;+
; NAME:
;
; pg_plot_par
;
; PURPOSE:
;
; (ut)plots the time evolution of a parameter for one flare
;
; CATEGORY:
;
; util for shs project
;
; CALLING SEQUENCE:
;
; pg_plot_par,sp_st [,chi=chi,temp=temp,eref=eref,flux=flux,em=em,spindex=spindex
;                    ,_extra:_extra]
;
; INPUTS:
;
; ptrstr: spex fitting results structurr
; par keyword: parameter to plot if /flux is set, then need
; eref, if eref is set, /flux is assumed, the other keywords are
; mutually exclusive
;
; OPTIONAL KEYWORDS:
; disconnected: handle disconnected part of the plot separately
; _extra:optional par to plot
;
;
;
; OUTPUTS:
;
; none
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
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 06-JAN-2004 written
; 15-JAN-2004 added temp2,em2 keywords
; 16-FEB-2004 added thick keyword
; 17-FEB-2004 added disconnected keyword
;-

PRO pg_plot_par,sp_st,chi=chi,temp=temp,eref=eref,flux=flux,ecut=ecut,em=em $
                ,spindex=spindex,overplot=overplot,bistemp=bistemp $
                ,bisem=bisem,sqemt=sqemt,bissqemt=bissqemt,color=color $
                ,thick=thick,_extra=_extra,disconnected=disconnected $
                ,linestyle=linestyle



time_arr=anytim(sp_st.date)+0.5*(sp_st.xselect[0,*]+sp_st.xselect[1,*])

IF n_elements(time_arr) GT 1 THEN BEGIN 
   
   IF keyword_set(chi) THEN yarray=sp_st.chi 
   IF keyword_set(temp) THEN yarray=sp_st.apar_arr[1,*]
   IF keyword_set(em) THEN yarray=sp_st.apar_arr[0,*]
   IF keyword_set(spindex) THEN yarray=sp_st.apar_arr[5,*]
   IF keyword_set(ecut) THEN yarray=sp_st.apar_arr[8,*]
   IF keyword_set(bistemp) THEN yarray=sp_st.apar_arr[3,*]
   IF keyword_set(bisem) THEN yarray=sp_st.apar_arr[2,*]
   IF keyword_set(sqemt) THEN yarray=sqrt(sp_st.apar_arr[0,*]) $
                                     *sp_st.apar_arr[1,*]       
   IF keyword_set(bissqemt) THEN yarray=sqrt(sp_st.apar_arr[2,*]) $
                                        *sp_st.apar_arr[3,*]
   IF keyword_set(flux) OR keyword_set(eref) THEN BEGIN
      eref=fcheck(eref,35)
      flux_str=pg_apar2flux_fmultispec(sp_st,eref)
      yarray=flux_str.flux
   ENDIF


   IF NOT keyword_set(overplot) THEN BEGIN 
      IF keyword_set(disconnected) THEN BEGIN
         ind=pg_get_connession_ind(sp_st)

         IF ind[0] NE -1 THEN BEGIN

            nind=n_elements(ind)
            utplot,time_arr[0:ind[0]]-time_arr[0],yarray[0:ind[0]],time_arr[0],color=color $
                  ,thick=thick,_extra=_extra,linestyle=linestyle 

            FOR i=1,nind-1 DO BEGIN 
               outplot,time_arr[ind[i-1]+1:ind[i]]-time_arr[0],yarray[ind[i-1]+1:ind[i]] $
                      ,time_arr[0],color=color,thick=thick,linestyle=linestyle 
            ENDFOR

            outplot,time_arr[ind[nind-1]+1:n_elements(time_arr)-1]-time_arr[0] $
                   ,yarray[ind[nind-1]+1:n_elements(yarray)-1],time_arr[0],color=color $
                   ,thick=thick,linestyle=linestyle 
         ENDIF ELSE BEGIN 
            utplot,time_arr-time_arr[0],yarray,time_arr[0],color=color $
                  ,thick=thick,_extra=_extra,linestyle=linestyle 
         ENDELSE 

      ENDIF ELSE $
        utplot,time_arr-time_arr[0],yarray,time_arr[0],color=color $
              ,thick=thick,_extra=_extra,linestyle=linestyle 
   ENDIF $
   ELSE BEGIN

      IF keyword_set(disconnected) THEN BEGIN
         ind=pg_get_connession_ind(sp_st)
         
         IF ind[0] NE -1 THEN BEGIN

            nind=n_elements(ind)
            outplot,time_arr[0:ind[0]]-time_arr[0],yarray[0:ind[0]],time_arr[0],color=color $
                  ,thick=thick,_extra=_extra,linestyle=linestyle 

            FOR i=1,nind-1 DO BEGIN 
               outplot,time_arr[ind[i-1]+1:ind[i]]-time_arr[0],yarray[ind[i-1]+1:ind[i]] $
                      ,time_arr[0],color=color,thick=thick,linestyle=linestyle 
            ENDFOR

            outplot,time_arr[ind[nind-1]+1:n_elements(time_arr)-1]-time_arr[0] $
                   ,yarray[ind[nind-1]+1:n_elements(yarray)-1],time_arr[0],color=color $
                   ,thick=thick,linestyle=linestyle 
         ENDIF ELSE BEGIN 
            outplot,time_arr-time_arr[0],yarray,time_arr[0],color=color $
                  ,thick=thick,_extra=_extra,linestyle=linestyle 
         ENDELSE 

      ENDIF ELSE $
      outplot,time_arr-time_arr[0],yarray,time_arr[0],color=color $
              ,thick=thick,linestyle=linestyle 
   ENDELSE
  
ENDIF 

END





