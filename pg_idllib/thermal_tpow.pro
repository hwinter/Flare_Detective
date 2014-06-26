;+
;
; NAME:
;        thermal_tpow
;
; PURPOSE: 
;        returns an emission spectrum for a thermal + triple powerlaw model
;        in logarithmic units or normal units
;
; CALLING SEQUENCE:
;
;        spectrum=thermal_tpow(energy,par [,nolog=nolog])
;
; INPUTS:
;
;        energy: array N of average energy values 
;
;        par: par[0]: emission measure in units of 10^49 cm-3
;             par[1]: plasma temperature in keV
;;
;             par[2]: power law value at 1 keV 
;             par[3]: negative slope of power law
;
;             par[4]: low_energy cutoff
;             par[5]: negative slope at E < cutoff
;
;             par[6]: high energy break
;             par[7]: negative slope at E > break
;
; KEYWORDS:
;        log: return the logarithm of the spectrum
;        noline: output the spectrum without lines
;
; OUTPUT:
;        spectrum: the logarithm of the spectrum
;        
; EXAMPLE:
;        energy=findgen(1000)/10+3.
;        par=[1e-2,1.5,1e5,4,40,2,70,1.5]
;        spectrum=thermal_tpow(energy,par)
;        plot,energy,spectrum,/xlog,/ylog,/xstyle
; 
; VERSION:
;
;        22-JUL-2003 written
;        
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-


;.comp thermal_tpow.pro

FUNCTION thermal_tpow,energy,par,log=log,noline=noline;,verbose=verbose

energy_edges=edge_transform(energy)

; IF keyword_set(verbose) THEN BEGIN
; print,energy_edges
; print,'par',[par[0],par[1]]
; print,'noline',noline
; ENDIF

thermalflux=f_vth(energy_edges,[par[0],par[1]],noline=noline)

powerlaw=par[2]*energy^(-par[3])

ind=where(energy LE par[4],count)

IF count GT 0 THEN powerlaw[ind]=(par[2]*par[4]^(par[5]-par[3]))* $
                                 (energy[ind])^(-par[5])

ind2=where(energy GE par[6],count)

IF count GT 0 THEN powerlaw[ind2]=(par[2]*par[6]^(par[7]-par[3]))* $
                                  (energy[ind2])^(-par[7])


spectrum=powerlaw+thermalflux

IF keyword_set(log) THEN $
    RETURN, alog(spectrum) $
ELSE $
    RETURN, spectrum


END

