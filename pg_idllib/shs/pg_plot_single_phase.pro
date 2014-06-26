;+
; NAME:
;
; pg_plot_single_phase
;
; PURPOSE:
;
; plot a single rise/decay phase with an overlay model
;
; CATEGORY:
;
; util for shs project
;
; CALLING SEQUENCE:
;
; pg_plot_single_phase,...
;
; INPUTS:
;
;
;
; OPTIONAL KEYWORDS:
; 
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
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 28-JUN-2004 written
;-


PRO pg_plot_single_phase,stp,mi,phase=phase,fitpar=fitpar,eref=eref $
                        ,color=color,rise=rise,decay=decay,elenergy=elenergy

type='      '
IF keyword_set(decay) THEN type='DECAY '
IF keyword_set(rise) THEN type ='RISE  '

parttype='PHOTONS '
IF keyword_set(elenergy) THEN parttype='ELECTRONS '

color=fcheck(color,!p.color)

xrange=[0.0075,7.5]


;user defined plot symbol: small filled circle
d=0.15;circle radius
N=32.
A = FINDGEN(N+1) * (!PI*2./N)
USERSYM, d*COS(A), d*SIN(A), /FILL


;get flare/particular phase number
flarenum=mi[phase].flarenum
phasenum=mi[phase].phasenum
ind=*mi[phase].ind

tagname='APAR_ARR'
apararr=pg_getptrstrtag(stp[flarenum],tagname,/transpose)

spindex=reform(pg_apar2physpar(apararr,/spindex))
flux=pg_apar2physpar(apararr,eref=eref)


xtitle='PHOTON FLUX at '+strtrim(string(round(eref)),2)+' keV'

IF exist(elenergy) THEN BEGIN
   res=pg_photon2electron(flux,spindex,eref,elenergy)
   flux=res.elflux
   spindex=res.elspindex
   xrange=[1d30,5d33]
   xtitle='ELECTRON FLUX at '+strtrim(string(round(elenergy)),2)+' keV'
ENDIF


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;photon plot...
plot,flux,spindex,xrange=xrange,/xstyle $
     ,yrange=[2.5,11],/ystyle,/xlog,ylog=1 $
     ,psym=8,charsize=1.25,xtitle=xtitle $
     ,ytitle='Spectral index FLARE '+strtrim(string(flarenum),2)+' PHASE '+strtrim(string(phasenum),2) $
     ,ytickv=[3,4,5,6,7,8,9,10] $
     ,yticks=7 $
     ,title=type+'- EPIV: '+strtrim(string(fitpar[phase,1]),2) $
     +' FPIV: '+strtrim(string(fitpar[phase,0]),2)
 
oplot,flux[ind],spindex[ind],psym=1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;electron plot...

;photon-->electron

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;overplot fitting...

xx=10d^(dindgen(1001)/1001.*(!X.crange[1]-!X.crange[0])+!X.crange[0])

IF exist(elenergy) THEN $
  oplot,xx,alog(fitpar[phase,0]/xx)/alog(elenergy/fitpar[phase,1]) $
       ,color=color $
ELSE $
  oplot,xx,alog(fitpar[phase,0]/xx)/alog(eref/fitpar[phase,1]) $
       ,color=color


END 
