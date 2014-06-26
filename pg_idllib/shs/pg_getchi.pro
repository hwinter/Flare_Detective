;+
; NAME:
;
; pg_getchi
;
; PURPOSE:
;
; compute the chi squared for an interval range
;
; CATEGORY:
;
; util for shs project
;
; CALLING SEQUENCE:
;
; chi=pg_shs_load(sp_st,erange=erange)
;
; INPUTS:
;
; sp_st: a spectral fitting structure
;
; OPTIONAL INPUTS:
;
; erange: energy range over which chi square is to be computed
;         default: sp_st.erange
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
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; 
;
; MODIFICATION HISTORY:
;
; 17-DEC-2003 written
;
;-

FUNCTION pg_getchi,sp_st,erange=erange

erange=fcheck(erange,sp_st.erange)

chi=sp_st.chi

edge_products,sp_st.edges,mean=energybins
rangind=where(energybins GE min(erange) AND energybins LE max(erange),count)

IF count LT 1 THEN RETURN,replicate(-1,n_elements(chi))

nn=n_elements(chi)
nrange=n_elements(rangind)

FOR n_spec=0, nn-1 DO BEGIN


phflux = (sp_st.obsi[*,n_spec]-sp_st.backi[*,n_spec])/sp_st.convi[*,n_spec]

errflux = sqrt(sp_st.eobsi[*,n_spec]^2 + sp_st.ebacki[*,n_spec]^2) $
          /sp_st.convi[*,n_spec]



model=f_multi_spec(sp_st.edges,sp_st.apar_arr[*,n_spec])

phflux=phflux[rangind]
errflux=errflux[rangind]
model=model[rangind]

;stop
;plot,energybins[rangind],phflux,/xlog,/ylog,psym=10,xrange=[3,300],yrange=[1e-3,1e5]
;oplot,energybins[rangind],phflux+abs(errflux),psym=10
;oplot,energybins[rangind],phflux-abs(errflux),psym=10
;oplot,energybins[rangind],model,color=12

;plot,energybins[rangind],(phflux-model)/errflux,yrange=[-5,5],psym=10,/xlog


chi[n_spec]=sqrt(total(((phflux-model)/errflux)^2)/nrange)

ENDFOR

RETURN,chi

END

