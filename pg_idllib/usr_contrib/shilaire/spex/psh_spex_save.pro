;+
; NAME: 
;
; pg_save_fit_result
;
; PURPOSE:
;
; saves to a FITS file the results of the SPEX fitting(s)
;
; CATEGORY:
;        
; noninteractive spex utilities
;
; CALLING SEQUENCE:
;
; pg_save_fit_result,filename
;
; INPUTS:
; 
; filename: FITS filename
;
; OPTIONAL INPUTS:
;
;
; KEYWORD PARAMETERS:
;
;
; OUTPUTS:
;
;
; OPTIONAL OUTPUTS:
;
;
; COMMON BLOCKS:
;
;
; SIDE EFFECTS:
;
; writes a file
;
; RESTRICTIONS:
;
; *needs* an already set up SPEX session + already done fittings!
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
; 12-JAN-2004 written P.G.
; 2004/08/03: modifications by PSH, and renamed.
;-

PRO psh_spex_save,filename,CREATE=CREATE

   IF keyword_set(CREATE) THEN BEGIN
	   spex_proc,/cmode,input= $
	          'spex_st = {xselect:xselect, apar_arr:apar_arr' + $
	 	  ',apar_sigma:apar_sigma ,chi:chi, convi:convi,obsi:obsi' + $
	          ',eobsi:eobsi, backi:backi, ebacki:ebacki ,f_model:f_model,' + $
	          ' free: free, erange:erange, tb:tb, ut:ut ,iselect:iselect,' + $
	          ' date:anytim(uts,/date_only,/vms), edges:edges, apar:apar ,' + $
	          'ifirst:ifirst,ilast:ilast,epivot:epivot,' + $
	          ' back_order:back_order ,style_sel:style_sel,iavg:iavg, ' + $
	          'energy_bands:energy_bands, th_ytype:th_ytype, th_yrange:th_yrange, spyrange:spyrange} !! '+ $
	          'idl,mwrfits,spex_st,"'+filename+'",/create'
 
   ENDIF ELSE BEGIN 

	   spex_proc,/cmode,input= $
	       	   'spex_st = {xselect:xselect, apar_arr:apar_arr' + $
       		   ',apar_sigma:apar_sigma ,chi:chi, convi:convi,obsi:obsi' + $
       		   ',eobsi:eobsi, backi:backi, ebacki:ebacki ,f_model:f_model,' + $
       		   ' free: free, erange:erange, tb:tb, ut:ut ,iselect:iselect,' + $
       		   ' date:anytim(uts,/date_only,/vms), edges:edges, apar:apar ,' + $
       		   'ifirst:ifirst,ilast:ilast,epivot:epivot,' + $
       		   ' back_order:back_order ,style_sel:style_sel,iavg:iavg, ' + $
       		   'energy_bands:energy_bands, th_ytype:th_ytype, th_yrange:th_yrange, spyrange:spyrange} !! '+ $
       		   'idl,mwrfits,spex_st,"'+filename+'"'
   ENDELSE
END
