;+
; NAME:
;
; pg_plotNspectra
;
; PURPOSE:
;
; plot some spectra side by side
;
; CATEGORY:
;
; spectral plotting
;
; CALLING SEQUENCE:
;
; pg_plotNspectra,spst,indsp,[...]
;
; INPUTS:
;
; spst: a SPEX output structure
; indsp: index of the spectra to plot
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
;
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
; 
; MODIFICATION HISTORY:
;
; written 30-MAR-2003 P.G.
;
;-

PRO pg_plotNspectra,spst,indsp,xtitle=xtitle,ytitle=ytitle $
                    ,xrange=xrange,yrange=yrange,psym=psym $
                    ,xstyle=xstyle,ystyle=ystyle,xlog=xlog,ylog=ylog $
                    ,_extra=_extra

xlog=fcheck(xlog,1)
ylog=fcheck(ylog,1)
xtitle=fcheck(xtitle,'Energy (keV)')
ytitle=fcheck(ytitle,'Photon flux (photons s!A-1!N cm!A-2!N keV!A-1!N)')
xstyle=fcheck(xstyle,1)
ystyle=fcheck(ystyle,1)
psym=3
xrange=fcheck(xrange,[10,200])
yrange=fcheck(yrange,[1e-1,1e2])


FOR j=0,n_elements(indsp)-1 DO BEGIN

   n_spec=indsp[j]


   edge_products,spst.edges,mean=energybins,edges_2=energyedges
   n_el=n_elements(energyedges)/2.


   phflux = (spst.obsi[*,n_spec]-spst.backi[*,n_spec])/spst.convi[*,n_spec]

   errflux = sqrt(spst.eobsi[*,n_spec]^2 + spst.ebacki[*,n_spec]^2) $
             /spst.convi[*,n_spec]

   IF j EQ 0 THEN $
     plot,energybins, phflux[*],xlog=xlog,ylog=ylog,psym=psym $
         ,title=title,xtitle=xtitle,ytitle=ytitle $
         ,xrange=xrange,yrange=yrange,xstyle=xstyle,ystyle=ystyle $
         ,_extra=_extra



   model_par={name:'f_multi_spec',components:4, $
              comp_names:['temp1','temp2','nonthermal','total']}

   yspec=fltarr(model_par.components,n_el)

   yspec[0,*]=f_multi_spec(energyedges, [spst.apar_arr[0,n_spec] $
              ,spst.apar_arr[1,n_spec],0,1,0,0,0,0,0,0])
   yspec[1,*]=f_multi_spec(energyedges, [0,1,spst.apar_arr[2,n_spec] $
              ,spst.apar_arr[3,n_spec],0,1,0,0,0,0])
   yspec[2,*]=f_multi_spec(energyedges,[0,1,0,1,spst.apar_arr[4:9,n_spec]])
   yspec[3,*]=f_multi_spec(energyedges, spst.apar_arr[*,n_spec])

   IF j GT 0 THEN BEGIN 
      energybins=energybins*2*(j)
      energyedges=energyedges*2*(j)
   ENDIF 

   maxentemp=27
   oplot,  energybins[0:maxentemp], yspec[0,0:maxentemp] 

   FOR i=1,model_par.components-1 DO BEGIN 
      oplot,  energybins, yspec[i,*] 
   ENDFOR 

   FOR i = 0, n_elements(phflux)-1 do $
     oplot, energyedges[*, i], [phflux[i], phflux[i]]

   FOR i = 0, n_elements(phflux)-1 do $
     oplot, [energybins[i], energybins[i]], [phflux[i], phflux[i]+errflux[i]]
    
   FOR i = 0, n_elements(phflux)-1 do $
     oplot, [energybins[i], energybins[i]], $
            [phflux[i], (phflux[i]-errflux[i]) > (machar()).xmin]


ENDFOR


END
