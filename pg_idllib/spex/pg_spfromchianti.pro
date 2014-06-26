;+
; NAME: 
;
; pg_spfromchianti
;
; PURPOSE:
;
; compute an isothermal spectrum (lines + continuum) using the chianti
; routines and transform it in the same form as used by the SPEX
; models, i.e. gives photons s^-1 cm^-2 kev^-1
;
; CATEGORY:
;        
; spectral utilities
;
; CALLING SEQUENCE:
;
; spectrum=pg_spfromchianti(em_49,temp_keV,el_dens,e_edges)
;
; INPUTS:
; 
; em_49: emission measure, in units of 10^49 cm^-3
; temp_keV: plasma temerature in keV
; el_dens: electron density in electrons cm^-3
; e_edges: energy edges (n or 2 by n matrix), assumes CONTIGOUS and
; INCREASING edges for now!!!
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
; 
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
;e_edges=3+findgen(37)/3
;temp_kev=1.
;em_49=0.01
;el_dens=1e10
;spectrum=pg_spfromchianti(em_49,temp_keV,el_dens,e_edges)
;
; AUTHOR:
;
; Paolo C. Grigis, Institute for Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; written 21-JAN-2004 PG
;
;-

FUNCTION pg_spfromchianti,em_49,temp_keV,el_dens,e_edges,nstep=nstep,abundancefile=abundancefile,ioneqfile=ioneqfile,distance=distance

;number of points to use for the spectrum calculation
nstep=fcheck(nstep,3000d)

;abundance and ionisation equilibrium files
abundancefile=fcheck(abundancefile,!xuvtop+'/abundance/sun_photospheric.abund')
ioneqfile=fcheck(ioneqfile,!xuvtop+'/ioneq/arnaud_raymond.ioneq')


print,'Using abundance  file: '+abundancefile
print,'Using ioniz. eq. file: '+ioneqfile


;variable initializations

r=fcheck(distance,1.5d13)   ;distance source-detector (earth-sun default) in cm
el_dens=fcheck(el_dens,1d10);electron density cm^-3
em=em_49*1d49               ;emission measure in cm^-3
temp=kev2kel(temp_kev)      ;temperature in K

edge_products,e_edges,edges_1=kev_edges_1,edges_2=kev_edges_2,width=widths

wvl_1=reverse(wvl2nrg(kev_edges_1))
;lambda increases from lambda[0] to lambda[last]
;but kev_edges_1 also increases from 0 to last, therefore wvl_1
;decreases and must be reversed if one want to use it togheter with lambda




;the routine 'isothermal' needs a min and max wavelenght + a step
;here we transform from the keV spectrum and compute the step
;based on the number of elements (nstep)
wmin=min(wvl_1)
wmax=max(wvl_1)
wavestep=(wmax-wmin)/nstep
wmin=wmin-wavestep; this make sure that the lambda bins overlap
wmax=wmax+wavestep; the kev bins --> make rebinning afterwards safer...

;with continuum
isothermal,wmin,wmax,wavestep,temp,lambda,spectrum,list_wvl,list_ident $
           ,/cont,edensity=el_dens,abund_name=abundancefile $
           ,ioneq_name=ioneqfile,em=em


;without continuum
isothermal,wmin,wmax,wavestep,temp,lambda_noc,spectrum_noc,list_wvl_noc $
           ,list_ident_noc,edensity=el_dens,abund_name=abundancefile $
           ,ioneq_name=ioneqfile,em=em

;this should be optimized --> call isothermal only once and then the
;single continuum functions


;transform the output spectrum to the wanted form

;this is the continuum only
continuum=spectrum-spectrum_noc

;step 1: rebins the continuum spectrum
;        since the content of the bins is *photons* per bin,
;        only need to integrate. If a boundary split over
;        more bins, it is assumed that the flux is uniform
;        in the bins (on could implement parabolic int. with next
;        and prviuos bin)
;        There should be an already done ssw or idl routine for that!
;        found one: david smith's hsi_rebinner!
;
;        check hsi_rebinner: example
;        edgesin=[3,3.4,3.8,4.2,4.6,5.]
;        edgesout=[3,4,4.5,5]
;        specin=[5,4,3,2,1]
;
;        hsi_rebinner, specin, edgesin, specout, edgesout
;        print,specout
;        10.500001       2.9999996       1.4999994
;        seems just right!

lambda1=[lambda,wmax] ;this is necessary because of the different
                      ;convention (lambda: min(pixel), wvl: energy edge_1)

hsi_rebinner,continuum,lambda1,cont_kev,wvl_1

;step 2: add line emission

;extract line info
nlines=n_elements(list_ident)
line_intensity=dblarr(nlines)
FOR i=0,nlines-1 DO BEGIN
   string=strsplit(list_ident[i],' ',/extract)
   line_intensity[i]=double(string[n_elements(string)-1])
ENDFOR


;insert line emissivities in the spectrum at the right place
bin_position=value_locate(wvl_1,list_wvl)
okpos=where(bin_position GE 0 AND bin_position LE n_elements(wvl_1)-2,count)

IF count GT 0 THEN BEGIN

   bin_position=bin_position[okpos]
   line_intensity=line_intensity[okpos]
   FOR i=0,n_elements(bin_position)-1 DO $
       cont_kev[bin_position[i]]=cont_kev[bin_position[i]]+line_intensity[i]

ENDIF



spectrum_kev=reverse(cont_kev)/widths 
; since count_kev has now the lambda ordering we must reverse it to use
; with kev_edges_1 division by widths take care of the photon per kev part


;step 3: transform emission at source to flux at detector

spectrum_kev=spectrum_kev/(r^2);surface divided by r^2 <-> sterad


RETURN,spectrum_kev

END

