;+
; NAME:
;      pg_orderdata
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      returns ok data in a meningful structure from a basis directory
;
;
; CALLING SEQUENCE:
;      pg_orderdata,basdir,alpha
;
; INPUTS:
;      basdir: root for the dir tree containing the sim results
;      alpha: the array with the alpha values (slope of line cutting
;             through the data)
;   
; OUTPUTS:
;      data structure: ...      
;      
; KEYWORDS:
;       
;
; HISTORY:
;       
;       27-MAR-2006 written PG
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-


FUNCTION pg_orderdata,basdir=basdir,alpha=alpha

IF size(basdir,/tname) NE 'STRING' THEN BEGIN 
   print,'Invalid input!'
   return,-1
ENDIF

IF NOT exist(alpha) THEN BEGIN 
   print,'Invalid input!'
   return,-1
ENDIF
 

dir=basdir+'a00/'

restore,dir+'inputpar.sav'

mc2=511.

temp=inputpar.temp
dens=inputpar.density
tkev=inputpar.threshold_escape_kev

ntemp=n_elements(temp)
ndens=n_elements(dens)
ntkev=n_elements(tkev)
nalph=n_elements(alpha)


npiv=intarr(ntemp,ndens,ntkev,nalph)
epiv=dblarr(ntemp,ndens,ntkev,nalph)
fpiv=epiv

parnames=['TEMP','DENSITY','THRESHOLD_ESCAPE_KEV','ALPHA']
parvalues=ptrarr(n_elements(parnames))
parvalues[0]=ptr_new(temp)
parvalues[1]=ptr_new(dens)
parvalues[2]=ptr_new(tkev)
parvalues[3]=ptr_new(alpha)


            
FOR ialpha=0,nalph-1 DO BEGIN 
   
   ;load basic data from dir
   dir=basdir+'a'+smallint2str(ialpha,strlen=2)+'/'
   print,'Scanning dir '+dir
   
   restore,dir+'photonspectra.sav'
   restore,dir+'inputpar.sav'

   psp=phspectra
   ip=inputpar
   iacc=ip.tauescape*ip.utdivbyub*ip.avckomega

   ;this is the starting point for further elaboration
   res=pg_phspectratoindex(psp,emin=30.,emax=50.,enorm=40. $
                           ,el_emin=30.,el_emax=80.,el_enorm=50. )
 
   ;check ialpha
   thisalpha=alpha[ialpha]


   IF (NOT finite(thisalpha)) OR (thisalpha EQ 0) THEN $
      couple_tau_ut=0 $ ;horizontal or vetical
   ELSE $
      couple_tau_ut=1   ;oblique
      
   FOR itemp=0,ntemp-1 DO BEGIN 
      FOR idens=0,ndens-1 DO BEGIN 
         FOR itkev=0,ntkev-1 DO BEGIN 

            IF ntemp EQ 1 THEN BEGIN 

               ans=pg_extractres(res,fixed_tagnames=['DENSITY','THRESHOLD_ESCAPE_KEV'] $
                                    ,fixed_tagind=[idens,itkev],couple_tau_ut=couple_tau_ut)

            ENDIF ELSE BEGIN 

               ans=pg_extractres(res,fixed_tagnames=['YTHERM','DENSITY','THRESHOLD_ESCAPE_KEV'] $
                                    ,fixed_tagind=[itemp,idens,itkev],couple_tau_ut=couple_tau_ut)
            ENDELSE

 
            f=ans.flux
            g=ans.gamma

            piv=pg_quickpivot(f,g,enorm=40.,maxspindex=10,minspindex=3.)

            epiv[itemp,idens,itkev,ialpha]=piv.epiv
            fpiv[itemp,idens,itkev,ialpha]=piv.fpiv
            npiv[itemp,idens,itkev,ialpha]=piv.numpoints
                  

         ENDFOR                 ;itkev
      ENDFOR                    ;idens
   ENDFOR                       ;itemp
ENDFOR                          ;ialpha



res={parnames:parnames,parvalues:parvalues, $
     fpiv:fpiv,epiv:epiv,npiv:npiv, $
     temp:temp,dens:dens,tkev:tkev,alpha:alpha}


RETURN,RES


END 



