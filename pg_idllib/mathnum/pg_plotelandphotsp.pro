;+
;
; NAME:
;        pg_plotelandphotsp
;
; PURPOSE: 
;        plot an electron and photon spectrum
;
; CALLING SEQUENCE:
;
;        pg_plotelandphotsp
;
; INPUTS:
;
;        
;
; KEYWORDS:
;
;        
;
; OUTPUT:
;        
;
; EXAMPLE:
;
;        
;
; VERSION:
;
;        16-NOV-2005 written PG        
;        
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;-

PRO pg_plotelandphotsp,da=da,res=res,phspectra=phspectra,nsp=nsp $
                      ,emin=emin,emax=emax,labelcharsize=labelcharsize

emin=fcheck(emin,1d-1)
emax=fcheck(emax,1d3)

labelcharsize=fcheck(labelcharsize,1.)
;print,labelcharsize

mc2=510.998918d ;keV

enmc2=da.energy
enkev=enmc2*mc2

ind=where(enkev GE emin AND enkev LE emax,count)

IF count EQ 0 THEN BEGIN 
   print,'Invalid input!'
   RETURN
ENDIF

xel=enmc2[ind]*mc2
yel=da.grid[ind,n_elements(da.iter)-1]

getpar=['YTHERM','TAUESCAPE','AVCKOMEGA','UTDIVBYUB']
valpar=pg_getsimparvalue(da.simpar,getpar)

tempvalue=10^(valpar[0])
temp=kev2kel(tempvalue*mc2)*1d-6

tauescape=valpar[1]
ckom=valpar[2]
utub=valpar[3]


ymaxw=1d10*pg_maxwellian(enmc2[ind],tempvalue)

plot,xel,yel,xrange=[emin,emax],/xstyle,/xlog,/ylog,psym=-4
oplot,xel,ymaxw,color=12,thick=2

cx=10^(alog10(emin)+alog10(emax/emin)*0.1)
dcy=(!Y.crange[1]-!Y.crange[0])
cy=10^(!Y.crange[0]+dcy*0.3)

dc=0.1

xyouts,cx,cy/dc,'SIMPAR',charsize=labelcharsize
xyouts,cx,cy*dc,'START TEMP: '+string(temp,format='(f7.2)')+' MK',/data,charsize=labelcharsize
xyouts,cx,cy*dc^2,'TAU ESCAPE: '+string(tauescape,format='(e8.2)')+' DIMLESS',/data,charsize=labelcharsize
xyouts,cx,cy*dc^3,'ckOMEGA: '+string(ckom,format='(e8.2)')+' DIMLESS',/data,charsize=labelcharsize
xyouts,cx,cy*dc^4,'UT/UB: '+string(utub,format='(e8.2)')+' DIMLESS',/data,charsize=labelcharsize

;photon plot

emin=1.
emax=1000.

energy=phspectra.energy_kev
ind=where(energy GE emin AND energy LE emax,count)
IF count EQ 0 THEN BEGIN 
   print,'Invalid input!'
   RETURN
ENDIF

x=energy[ind]
ythin=phspectra.phspectra_thin[ind,nsp]
ythick=phspectra.phspectra_thick[ind,nsp]


delta=res.spindex_thick[nsp]
fnorm=res.fnorm_thick[nsp]
enorm=res.enorm

xoplot=10^!X.crange
yoplot=fnorm*(xoplot/enorm)^(-delta)

;yrange...
indyr=where(x GE 3 AND x LE 400,count)

IF count EQ 0 THEN BEGIN 
   print,'Invalid input!'
   RETURN
ENDIF

yrange=[min([ythin[indyr],ythick[indyr]]),max([ythin[indyr],ythick[indyr]])]

plot,x,ythick,xrange=[emin,emax],/xstyle,/xlog,/ylog,yrange=yrange

oplot,res.emin*[1,1],10^!Y.crange,linestyle=2
oplot,res.emax*[1,1],10^!Y.crange,linestyle=2

oplot,xoplot,yoplot,color=12

cx=10^(alog10(emin)+alog10(emax/emin)*0.1)
dcy=(!Y.crange[1]-!Y.crange[0])
cy=10^(!Y.crange[0]+dcy*0.4)

ddc=0.25

xyouts,cx,cy/ddc,'THICK',charsize=labelcharsize
xyouts,cx,cy*ddc,'SURFACE: '+string(phspectra.thickpar.surfacetar,format='(e12.2)'),charsize=labelcharsize
xyouts,cx,cy*ddc^2,'LN('+textoidl('\Lambda')+') : ' $
       +string(phspectra.thickpar.coulomblog,format='(f8.1)'),charsize=labelcharsize
xyouts,cx,cy*ddc^3,textoidl('Z^2 :')+string(phspectra.thickpar.z^2,format='(f8.2)'),charsize=labelcharsize

xyouts,cx,cy*ddc^5,'Spectral index: '+string(delta,format='(f8.2)'),charsize=labelcharsize
xyouts,cx,cy*ddc^6,'FLUX at Enorm: '+string(fnorm,format='(e12.2)'),charsize=labelcharsize
xyouts,cx,cy*ddc^7,'Enorm: '+string(enorm,format='(f8.2)'),charsize=labelcharsize


plot,x,ythin ,xrange=[emin,emax],/xstyle,/xlog,/ylog,yrange=yrange
oplot,res.emin*[1,1],10^!Y.crange,linestyle=2
oplot,res.emax*[1,1],10^!Y.crange,linestyle=2

delta=res.spindex_thin[nsp]
fnorm=res.fnorm_thin[nsp]
enorm=res.enorm
xoplot=10^!X.crange
yoplot=fnorm*(xoplot/enorm)^(-delta)

oplot,xoplot,yoplot,color=12

cx=10^(alog10(emin)+alog10(emax/emin)*0.1)
dcy=(!Y.crange[1]-!Y.crange[0])
cy=10^(!Y.crange[0]+dcy*0.4)

xyouts,cx,cy/ddc,'THIN',charsize=labelcharsize
xyouts,cx,cy*ddc,'VOLUME: '+string(phspectra.thinpar.volumetar,format='(e12.2)'),charsize=labelcharsize
xyouts,cx,cy*ddc^2,'DENSITY : ' $
        +string(phspectra.thinpar.densitytar,format='(e12.2)'),charsize=labelcharsize
xyouts,cx,cy*ddc^3,textoidl('Z^2 :')+string(phspectra.thickpar.z^2,format='(f8.2)'),charsize=labelcharsize

xyouts,cx,cy*ddc^5,'Spectral index: '+string(delta,format='(f8.2)'),charsize=labelcharsize
xyouts,cx,cy*ddc^6,'FLUX at Enorm: '+string(fnorm,format='(e12.2)'),charsize=labelcharsize
xyouts,cx,cy*ddc^7,'Enorm: '+string(enorm,format='(f8.2)'),charsize=labelcharsize

END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


