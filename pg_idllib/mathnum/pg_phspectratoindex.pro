;+
;
; NAME:
;        pg_phspectratoindex
;
; PURPOSE: 
;        convert photon spectra from simulation to spectral indices
;        and fluxes
;
; CALLING SEQUENCE:
;
;        pg_phspectratoindex,resfile
;
; INPUTS:
;
;        phspectra: the structure produced by pg_convertelres2photsp
;        emin: minimal energy for the fitting (all energies in keV)
;        emax: maximal energy for the fitting
;        enorm: reference energy for fnorm
;
; KEYWORDS:
;
;        
;
; OUTPUT:
;        a structure, containing fit parameters, spectral indices etc. 
;
; EXAMPLE:
;
;        
;
; VERSION:
;
;        25-OCT-2005 written Paolo Grigis
;        15-NOV-2005 finalized PG
;        22-DEC-2005 also computes lectron spectral indices if available
;        01-MAR-2005 corrected bug in number of spectra available etc.
;        
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;-

FUNCTION pg_phspectratoindex,phspectra,emin=emin,emax=emax,enorm=enorm $
                            ,el_emin=el_emin,el_emax=el_emax,el_enorm=el_enorm 

emin=fcheck(emin,20.)
emax=fcheck(emax,50.)
enorm=fcheck(enorm,35.)
enormlog=alog(enorm)

el_emin=fcheck(el_emin,30.)
el_emax=fcheck(el_emax,80.)
el_enorm=fcheck(el_enorm,50.)
el_enormlog=alog(el_enorm)


s=size(phspectra.phspectra_thin)

nsp=s[2]

en=phspectra.energy_kev
el_en=phspectra.el_energy_kev

;        ,comment:comment,elspectra:dblarr(n_elements(ele),no),el_energy_kev:ele}

ind=where(en GE emin AND en LE emax,count)
el_ind=where(el_en GE el_emin AND el_en LE el_emax,el_count)

IF (count EQ 0) OR (el_count EQ 0) THEN BEGIN
   print,'Please input a valid energy range!'
   RETURN,-1
ENDIF

dbl=dblarr(nsp-1)

res={spindex_thin:dbl,fnorm_thin:dbl,  $
     spindex_thick:dbl,fnorm_thick:dbl, $
     emin:emin,emax:emax,enorm:enorm,simpar:phspectra.simpar[1:nsp-1], $
     thinpar:phspectra.thinpar,thickpar:phspectra.thickpar, $
     okres:bytarr(nsp-1), $
     el_spindex:dbl,el_fnorm:dbl, $
     el_emin:el_emin,el_emax:el_emax,el_enorm:el_enorm}

x=en[ind]
el_x=el_en[el_ind]

FOR i=1,nsp-1 DO BEGIN 
   ythin=phspectra.phspectra_thin[ind,i]
   ythick=phspectra.phspectra_thick[ind,i]
   el_y=phspectra.elspectra[el_ind,i]

   xlog=alog(x)
   el_xlog=alog(el_x)
   ylogthin=alog(ythin)
   ylogthick=alog(ythick)
   el_ylog=alog(el_y)

   sixlin,xlog,ylogthin,athin,sigathin,bthin,sigbthin
   sixlin,xlog,ylogthick,athick,sigathick,bthick,sigbthick
   sixlin,el_xlog,el_ylog,el_a,el_siga,el_b,el_sigb

   fnormthin=exp(athin[0])*exp(bthin[0]*enormlog)
   spindexthin=-bthin[0]

   fnormthick=exp(athick[0])*exp(bthick[0]*enormlog)
   spindexthick=-bthick[0]

   el_fnorm=exp(el_a[0])*exp(el_b[0]*el_enormlog)
   el_spindex=-el_b[0]

   res.spindex_thin[i-1]=spindexthin
   res.fnorm_thin[i-1]=fnormthin

   res.spindex_thick[i-1]=spindexthick
   res.fnorm_thick[i-1]=fnormthick

   res.el_fnorm[i-1]=el_fnorm
   res.el_spindex[i-1]=el_spindex

   IF finite(spindexthick) AND finite(spindexthin) AND finite(el_spindex) THEN res.okres[i-1]=1B

ENDFOR

RETURN,res

END

