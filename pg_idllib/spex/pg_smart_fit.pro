;+
; NAME: 
;
; pg_smart_fit  
;
; PURPOSE:
;
; tries to make a 'smart' fit to the SPEX data (I wrote 'try', so bear
; in mind that it will probably fail sometimes...)
;
; CATEGORY:
;        
; noninteractive spex utilities
;
; CALLING SEQUENCE:
;
; pg_smart_fit, actual_bin [,therm_range, nonth_range]
;
; INPUTS:
; 
; actual_bin: actual time bin for the fitting (actual_bin=ifirst=ilast)
;
; OPTIONAL INPUTS:
;
; therm_range: thermal energy range (default [6,15])
; nonth_range: nonthermal energy range 
;
; KEYWORD PARAMETERS:
;
; ecutoff: set initial estimate of low energy cutoff to this value
;
; --> here type of model whished could be implemented (double
; thermal,broken power_laws, ...)
;
; OUTPUTS:
;
; none (comunication with spex is done using common blocks and the
; spex_proc command)
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
; pg_spex_fitting
;
; SIDE EFFECTS:
;
; It will change the status of your current SPEX session
;
; RESTRICTIONS:
;
; *needs* an already set up SPEX session (--> you should call pg_setup_spex
; before calling pg_smart_fit!)
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
; 27-NOV-2003 written PG
;  1-DEC-2003 bug fixing PG        
; 15-DEC-2003 added ecutoff keyword PG
; 07-JAN-2003 added ecut_range keyword and fixed a bug that made the
;             very first fitting with the wrong f_model PG
; 08-JAN-2003 added emax keyword
;
;-

PRO pg_smart_fit, actual_bin, therm_range, nonth_range, ecutoff=ecutoff,ecut_range=ecut_range,emax=emax


   COMMON spex_proc_com
   COMMON FUNCTION_com
   COMMON pg_spex,pg_apar,pg_erange,pg_ibin


   spex_proc,/cmode,input='f_model,f_multi_spec'


   actual_bin=fcheck(actual_bin,0)
   therm_range=fcheck(therm_range,[6,15])
   nonth_range=fcheck(nonth_range,[20,50])
   ecut_range=fcheck(ecut_range,[6,30])

   emax=fcheck(emax,max(edges))

   pg_apar=[0.1,1.,0.,1.,0.,4.,nonth_range[1],4.,therm_range[0],1.5]
;   pg_apar=range[*,0] > pg_apar < range[*,1]
   pg_erange=therm_range
   pg_ibin=actual_bin


   ;;general settings....

   spex_proc,/cmode,input='range_lo[8]='+strtrim(string(ecut_range[0]),2)
   spex_proc,/cmode,input='range_hi[8]='+strtrim(string(ecut_range[1]),2)

   spex_proc,/cmode,input='range_hi[5]=12. !!' + $
             'range_hi[7]=12. !! range_lo[6]= 30.'

;   spex_proc,/cmode,input='range_lo[8]=6. !! range_hi[5]=12. !!' + $
;             'range_hi[7]=12. !! range_lo[6]= 30.'


   ;;begin with a thermal fit
   spex_proc,/cmode,input='idl, common pg_spex  !! ' + $
             'free,1,1,0,0,0,0,0,0,0,0!!' + $
             'erange=pg_erange !! apar=pg_apar !! ' + $
             'ifirst=pg_ibin !! ilast=pg_ibin !! a_cutoff=[1,1] !!' + $
             'force_apar !! spyrange=[1e-3,1e4] !! spxrange=[6,100] !!' + $
             ' fit !! pg_apar=apar'


   ;;check if nonthermal part exist
   ;;criteria:
   ;;in range nonth_range, is there any emission >5 times thermal but with
   ;;at least 0.1 ph per cm^2 kev sec?


   pg_photon_flux=(obsi[*,actual_bin]-backi[*,actual_bin])/convi[*,actual_bin]>0

   finind=where(finite(pg_photon_flux) EQ 0,fincount)
   IF fincount GT 0 THEN pg_photon_flux[finind]=0.

   ;;nonthrange --> edges
   lowind=min(where(edges GE nonth_range[0])>0)
   lowind=(1+lowind)/2
   higind=min(where(edges GE nonth_range[1])>0)
   higind=higind/2

   pg_edges=edges[*,lowind:higind]
   ;;edge_products,pg_edges,edges1=pg_mean_edges
   pg_obs_flux=pg_photon_flux[lowind:higind]
   pg_model_flux=f_multi_spec(pg_edges,pg_apar)

   pg_eff_nth=where(pg_obs_flux GE 0.1 AND pg_obs_flux GE 5*pg_model_flux,ntcount)

   IF ntcount GT 0 THEN BEGIN
      ntfitrange=[pg_edges[0,min(pg_eff_nth)],pg_edges[1,max(pg_eff_nth)]]
   ENDIF $
   ELSE BEGIN
      ntfitrange=nonth_range
      pg_eff_nth=[0,higind-lowind]
   ENDELSE  

   pg_erange=ntfitrange

   IF pg_erange[1]-pg_erange[0] LE 2 THEN BEGIN 
      pg_erange[0]=pg_erange[0]-1
      pg_erange[1]=pg_erange[1]+1
   ENDIF
      
   estdelta=(alog(pg_obs_flux[min(pg_eff_nth)])- $
             alog(pg_obs_flux[max(pg_eff_nth)])) / $
            (alog(ntfitrange[1])-alog(ntfitrange[0]))

   estfpiv=pg_obs_flux[min(pg_eff_nth)]*(ntfitrange[0]/epivot)^estdelta

   pg_apar[4]=estfpiv>1e-3
   pg_apar[5]=estdelta

   pg_apar[8]=ntfitrange[0]

   pg_apar[6]=emax
   pg_apar[7]=pg_apar[5]


   pg_apar[2]=0.


   pg_apar=range[*,1]<pg_apar>range[*,0]


   spex_proc,/cmode,input='idl, common pg_spex  !!' + $
             'free,0,0,0,0,1,1,0,0,0,0 !! erange=pg_erange !!' + $
             'apar=pg_apar !! force_apar !! fit !! pg_apar=apar'

   ;;now set thermal + 1 power_law + low_en_cutoff free

   pg_apar[7]=pg_apar[5]
   pg_apar[6]=emax
   pg_erange=[6,emax]
   pg_apar[8]=fcheck(ecutoff,ntfitrange[0])

;   pg_apar=range[*,0] > pg_apar < range[*,1]

   spex_proc,/cmode,input='idl, common pg_spex  !!' + $
             'free,1,1,0,0,1,1,0,0,1,0 !! erange=pg_erange !!' + $
             'apar=pg_apar !! force_apar !! fit !! pg_apar=apar'

;   ;;now set everything free and hope for the best...
;
;   pg_apar[7]=pg_apar[5]
;   pg_apar[6]=50.
;   pg_erange=[6,emax]
;
;   spex_proc,/cmode,input='idl, common pg_spex  !!' + $
;             'free,1,1,0,0,1,1,1,1,1,0 !! erange=pg_erange !!' + $
;             'apar=pg_apar !! force_apar !! fit !! pg_apar=apar'


   RETURN

END
