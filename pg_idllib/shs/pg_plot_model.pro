;+
; NAME:
;
; pg_plot_model
;
; PURPOSE:
;
; plots a given fitted model overlaid on the data points
;
; CATEGORY:
;
; shs project util, spex util
;
; CALLING SEQUENCE:
;
; 
;
; INPUTS:
;
; 
; 
; OUTPUTS:
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
; EXAMPLE:
;
;
;
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.pyhs.ethz.ch
; 
; MODIFICATION HISTORY:
;
; 06-JUL-2004 written
;
;-

PRO pg_plot_model,stp=stp,rise_mi=rise_mi,decay_mi=decay_mi,model=model $
    ,erefel=erefel,ph_energy=ph_energy,functargs=functargs,fitdata=fitdata $
    ,filename=filename,parnames=parnames,chiarr=chiarr,chinum=chinum,dof=dof $
    ,showchi=showchi              
   


erefel=fcheck(erefel,60.)
ph_energy=fcheck(ph_energy,35.)

dof=fcheck(dof,2);degree of freedom for the fitting(s)


;user defined plot symbol: small filled circle
d=0.15;circle radius
N=32.
A = FINDGEN(N+1) * (!PI*2./N)
USERSYM, d*COS(A), d*SIN(A), /FILL

;ps plot
pg_set_ps,filename=filename;'~/work/shs2/bmod_model.ps'

oldp=!P
!p.multi=[0,2,3]

cs=1.

chiarr=dblarr(n_elements(rise_mi)+n_elements(decay_mi))
chinum=intarr(n_elements(rise_mi)+n_elements(decay_mi))

mi=rise_mi

FOR i=0,n_elements(mi)-1 DO BEGIN 

print,'RISE '+strtrim(string(i),2)

;get flare/particular phase number
flarenum=mi[i].flarenum
phasenum=mi[i].phasenum
ind=*mi[i].ind


tagname='APAR_ARR'
apararr=pg_getptrstrtag(stp[flarenum],tagname,/transpose)

spindex=reform(pg_apar2physpar(apararr,/spindex))
flux=pg_apar2physpar(apararr,eref=fitdata.ph_energy)

res=pg_photon2electron(flux,spindex,fitdata.ph_energy,erefel)
flux=res.elflux
spindex=res.elspindex

x=flux[ind]
y=spindex[ind]

modely=call_FUNCTION(model,x,reform(fitdata.r_fitpar[i,*]),_extra=functargs)

n=n_elements(ind)
chinum[i]=n
chiarr[i]=1d/(n-dof)*total((y-modely)^2)

xrange=[1d30,7d32]
xtitle='ELECTRON FLUX at '+strtrim(string(round(erefel)),2)+' keV'

titlebasis=''
IF NOT exist(parnames) THEN $
FOR ii=0,n_elements(fitdata.r_fitpar[i,*])-1 DO BEGIN
   titlebasis=titlebasis+' P'+strtrim(string(ii),2)+': '+ $
     strtrim(string(fitdata.r_fitpar[i,ii],format='(g12.3)'),2)
ENDFOR $
ELSE $
FOR ii=0,n_elements(fitdata.r_fitpar[i,*])-1 DO BEGIN
   titlebasis=titlebasis+' '+parnames[ii]+': '+ $
     strtrim(string(fitdata.r_fitpar[i,ii],format='(g12.3)'),2)
ENDFOR 

IF keyword_set(showchi) THEN titlebasis=titlebasis+' !7v!X!U2!N :'+strtrim(string(chiarr[i]),2)

plot,flux,spindex,xrange=xrange,/xstyle $
     ,yrange=[3.5,11],/ystyle,/xlog,ylog=1 $
     ,psym=8,xtitle=xtitle $
     ,ytitle='Spectral index FLARE '+strtrim(string(flarenum),2)+' PHASE '+strtrim(string(phasenum),2) $
     ,ytickv=[4,5,6,7,8,9,10] $
     ,yticks=6,charsize=cs $
     ,title='RISE -'+titlebasis

 
oplot,x,y,psym=1

xx=10d^(dindgen(1001)/1001.*(!X.crange[1]-!X.crange[0])+!X.crange[0])
oplot,xx,call_FUNCTION(model,xx,reform(fitdata.r_fitpar[i,*]),_extra=functargs)

ENDFOR

mi=decay_mi

FOR i=0,n_elements(mi)-1 DO BEGIN 

print,'DECAY '+strtrim(string(i),2)

;get flare/particular phase number
flarenum=mi[i].flarenum
phasenum=mi[i].phasenum
ind=*mi[i].ind

tagname='APAR_ARR'
apararr=pg_getptrstrtag(stp[flarenum],tagname,/transpose)

spindex=reform(pg_apar2physpar(apararr,/spindex))
flux=pg_apar2physpar(apararr,eref=fitdata.ph_energy)

res=pg_photon2electron(flux,spindex,fitdata.ph_energy,erefel)
flux=res.elflux
spindex=res.elspindex

x=flux[ind]
y=spindex[ind]

modely=call_FUNCTION(model,x,reform(fitdata.d_fitpar[i,*]),_extra=functargs)

n=n_elements(ind)
chinum[i+n_elements(rise_mi)]=n
chiarr[i+n_elements(rise_mi)]=1d/(n-dof)*total((y-modely)^2)

titlebasis=''
IF NOT exist(parnames) THEN $
FOR ii=0,n_elements(fitdata.d_fitpar[i,*])-1 DO BEGIN
   titlebasis=titlebasis+' P'+strtrim(string(ii),2)+': '+ $
     strtrim(string(fitdata.d_fitpar[i,ii],format='(g12.3)'),2)
ENDFOR $
ELSE $
FOR ii=0,n_elements(fitdata.d_fitpar[i,*])-1 DO BEGIN
   titlebasis=titlebasis+' '+parnames[ii]+': '+ $
     strtrim(string(fitdata.d_fitpar[i,ii],format='(g12.3)'),2)
ENDFOR 

IF keyword_set(showchi) THEN titlebasis=titlebasis+' !7v!X!U2!N :'+strtrim(string(chiarr[i+n_elements(rise_mi)]),2)

xrange=[1d30,7d32]
xtitle='ELECTRON FLUX at '+strtrim(string(round(erefel)),2)+' keV'

plot,flux,spindex,xrange=xrange,/xstyle $
     ,yrange=[3.5,11],/ystyle,/xlog,ylog=1 $
     ,psym=8,xtitle=xtitle $
     ,ytitle='Spectral index FLARE '+strtrim(string(flarenum),2)+' PHASE '+strtrim(string(phasenum),2) $
     ,ytickv=[4,5,6,7,8,9,10] $
     ,yticks=6,charsize=cs $
     ,title='DECAY - '+titlebasis

oplot,x,y,psym=1

xx=10d^(dindgen(1001)/1001.*(!X.crange[1]-!X.crange[0])+!X.crange[0])
oplot,xx,call_FUNCTION('pg_bmod_inv',xx,reform(fitdata.d_fitpar[i,*]),_extra=functargs)

ENDFOR

print,'DONE, now closing ps file...'

device,/close
set_plot,'X'

!P=oldp

END



