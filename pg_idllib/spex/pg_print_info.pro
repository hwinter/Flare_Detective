;+
; NAME: 
;
; pg_print_info
;
; PURPOSE:
;
; prints some summary information on spex-fittings
;
; CATEGORY:
;        
; spex utilities
;
; CALLING SEQUENCE:
;
; pg_print_info,sp_st
;
; INPUTS:
; 
; sp_st: spex fitting outout structure
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
; detailed: print detailed info instead than averages, assumes
; f_multi_spec model has been used
;
; OUTPUTS:
;
; to the screen
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
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
; Paolo C. Grigis, Institute for Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 13-JAN-2004 written PG
; 21-APR-2004 added detailed keyword PG
;
;-

PRO pg_print_info,sp_st,detailed=detailed

n_fits=n_elements(sp_st.chi)
n_apar=(size(sp_st.apar_arr))[1]
tot_time_interval=anytim(sp_st.date)+[min(sp_st.xselect),max(sp_st.xselect)]
period=(tot_time_interval[1]-tot_time_interval[0])/n_fits
tot_time_interval=anytim(tot_time_interval,/vms)

print,''
print,'--------------------------------------------------------------------'
print,'SPEX fitting structure'
print,'--------------------------------------------------------------------'
print,''
print,'Number of fittings : '+strtrim(string(n_fits),2)
print,'Model fitted       : '+sp_st.f_model
print,'Total time_interval: '+tot_time_interval[0]+' - '+tot_time_interval[1]
print,'Average integration: '+strtrim(string(period),2)+' seconds'
print,'Fitted energy range: '+strtrim(string(sp_st.erange[0]),2)+' - ' $
                             +strtrim(string(sp_st.erange[1]),2)

IF NOT keyword_set(detailed) THEN BEGIN 

print,'Average chi square : '+strtrim(string(average(sp_st.chi)),2)
print,''

FOR i=0,n_apar-1 DO BEGIN
   print,'Average APAR '+strtrim(string(i),2)+'     : ' $
        +strtrim(string(average(sp_st.apar_arr[i,*])),2)
ENDFOR 

ENDIF ELSE BEGIN

   temp1=pg_apar2physpar(sp_st.apar_arr,/temp)
   temp2=pg_apar2physpar(sp_st.apar_arr,/bistemp)
   em1=pg_apar2physpar(sp_st.apar_arr,/em)
   em2=pg_apar2physpar(sp_st.apar_arr,/bisem)
   flux20=pg_apar2physpar(sp_st.apar_arr,eref=20)
   spindex=pg_apar2physpar(sp_st.apar_arr,/spindex)
   eturn=pg_apar2physpar(sp_st.apar_arr,/ecut)

   FOR j=0,n_fits-1 DO BEGIN 
      print,''
      print,'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
      print,''
      print,'TIME BIN '+strtrim(string(j),2)+': ' +$
            anytim(anytim(sp_st.date)+sp_st.xselect[0,j],/vms)+' -- '+ $
            anytim(anytim(sp_st.date)+sp_st.xselect[1,j],/vms)
      print,''
            

      IF em1[j] GT 1e-18 THEN BEGIN
      print,'Thermal component 1:'
      print,'TEMP: ' $
            +string(temp1[j]*1e-6,format='(f5.2)')+' MK'+ $
            ' EM: '+strtrim(string(em1[j]),2)+'*10^49 cm^-3'
      print,''
      ENDIF
      IF em2[j] GT 1e-18 THEN BEGIN
      print,'Thermal component 2:'
      print,'TEMP: ' $
            +string(temp2[j]*1e-6,format='(f5.2)')+' MK'+ $
            ' EM: '+strtrim(string(em2[j]),2)+'*10^49 cm^-3'
      print,''
      ENDIF

      IF flux20[j] GT 1e-10 THEN BEGIN 
      print,'Non-thermal component:'   
      print,'Spectral Index'+string(spindex[j],format='(f5.2)')
      print,'Non-thermal flux at 20 keV: '+string(flux20[j])+ $
            ' ph cm^-2 s^-1 keV^-1'
      print,'Low energy turnover: '+string(eturn[j],format='(f5.2)')
      ENDIF

      


   ENDFOR 
   
ENDELSE


RETURN

END
