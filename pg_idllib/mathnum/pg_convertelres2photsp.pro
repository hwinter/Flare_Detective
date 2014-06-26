;+
;
; NAME:
;        pg_convertelres2photsp
;
; PURPOSE: 
;        convert simulation results from electron to photon spectra
;
; CALLING SEQUENCE:
;
;        pg_convertelres2photsp,dir
;
; INPUTS:
;
;        dir: directory where the simulation results are stored
;
; KEYWORDS:
;
;        resfile: filename to write results to (relative to dir)
;                 default: photonspectra.sav
;
; OUTPUT:
;        none, results are written to a file
;
; EXAMPLE:
;
;        
;
; VERSION:
;
;        24-OCT-2005 written Paolo Grigis
;        14-NOV-2005 updated to use ok version of el->routine
;        22-NOV-2005 corrected bug in normalization (factor 1/mc^2
;                    missing)
;        22-DEC-2005 includes electron spectra as well
;        31-JAN-2006 output of phspectra variable and nosave keyword added
;        
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;-

PRO pg_convertelres2photsp,dir,resfile=resfile,quiet=quiet $
       ,volumetar=volumetar,densitytar=densitytar,distance=distance,z=z $
       ,surfacetar=surfacetar,coulomblog=coulomblog,phspectra=phspectra $
       ,nosave=nosave


IF NOT file_exist(dir) THEN BEGIN 
   print,'Please input a valid directory name'
   RETURN
ENDIF

resfile=fcheck(resfile,dir+'/photonspectra.sav')

masterfile=fcheck(masterfile,dir+'/masterindex.sav')
restore,masterfile
totnsim=n_elements(total_sim_record)

;stop
pg_loadsim,nsim=1,da=da,savedir=dir,/quiet

niter=n_elements(da.iter)

mc2   = 510.998918d ;rest mass of the electron, in keV
elcharge=4.8032044d-10;electron charge in statcoulombs/esu (1C=2.998*10^9 statc)
c=2.99792458d10;speed of light
   

ele=da.energy*mc2
;check that electron spectrum is in ok range, discard everything else
ind=where(ele GT 1. AND ele LT 1d6,count)

IF count EQ 0 THEN BEGIN
   print,'Warning! Bad input electron energy! No photon plot possible'
   RETURN
ENDIF

ele=ele[ind]


;energy binning for the photon spectrum to compute
N=300
eph=10^(dindgen(N)/(N-1)*3)


comment='The simulation output electron spectrum has been converted into'+$
' a photon spectrum. Simulation parameters are stored in simpar. '+ $
'Thin  target conversion with params in thinpar. '+$
'Thick target conversion with params in thickpar.'

volumetar=fcheck(volumetar,1d27);target volume in cm^3
densitytar=fcheck(densitytar,1d10);target density, ions cm^-3
distance=fcheck(distance,1.496d13);distance from source, default: 1 AU
z=fcheck(z,1.2d )

surfacetar=fcheck(surfacetar,1d18);target surface in cm^2
coulomblog=fcheck(coulomblog,20.);coulomb logarithm

thinpar={volumetar:volumetar,densitytar:densitytar,distance:distance,z:z}
thickpar={surfacetar:surfacetar,coulomblog:coulomblog,distance:distance,z:z}

;output structure

no=totnsim;n_elements(o)
nph=n_elements(eph)


phspectra={energy_keV:eph,phspectra_thin:dblarr(nph,no),phspectra_thick:dblarr(nph,no) $
          ,simpar:replicate(da.simpar,no),thinpar:thinpar,thickpar:thickpar $
          ,comment:comment,elspectra:dblarr(n_elements(ele),no),el_energy_kev:ele}

FOR i=1,totnsim-1 DO BEGIN 
   pg_loadsim,nsim=i,da=da,savedir=dir,/quiet


;FOR i=0,no-1 DO BEGIN 
   ;   da=*o[i]
   ;ptr_free,o[i];needed to avoid excessive memory consumption

   y=da.grid[ind,niter-1]/mc2;simulation result, "last" electron spectrum
                             ;should be in equilibrium
   ;factor mc2 needed because the simulation gives electrons cm^-3 (mc2)^-1
   ;but input to electron->photon routin should be given in el. cm^-3 keV^-1
   ; and therefore (mc^2)^-1=(mc^2)^(-1)*(mc^2/511keV)=(1/511)*kev^-1   

   ;elfluxsp=y*pg_getbeta(ele/mc2)*c;convert to photon flux spectrum
   
   IF NOT keyword_set(quiet) THEN $
     print,'Now computing photon spectrum '+strtrim(string(i),2)+' in dir '+dir

   photspectrumthin=pg_el2phot_thin(elsp=y,ele=ele,phe=eph,/eldensity, $
      volumetar=volumetar,densitytar=densitytar,distance=distance,z=z)

   photspectrumthick=pg_el2phot_thick(elsp=y,ele=ele,phe=eph,/eldensity, $
      surfacetar=surfacetar,coulomblog=coulomblog,distance=distance,z=z)

   IF NOT keyword_set(quiet) THEN $
     print,'Done'

   phspectra.phspectra_thin[*,i]=photspectrumthin
   phspectra.phspectra_thick[*,i]=photspectrumthick
   phspectra.simpar[i]=da.simpar
   phspectra.elspectra[*,i]=y
 
ENDFOR

IF NOT keyword_set(nosave) THEN BEGIN 
   save,phspectra,filename=resfile
ENDIF

END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


