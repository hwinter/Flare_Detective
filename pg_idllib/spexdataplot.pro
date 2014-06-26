;+
; NAME:
;       spexdataplot
;
; PURPOSE: 
;       plot a spectrum from spex data
;
; CALLING SEQUENCE:
;       spexdataplot, [...]
;
; INPUTS:
;        
;
; OUTPUT:
; 
;
; EXAMPLE: first, restore a spex save data file
;          spexdataplot,....
;   
; spexdataplot,obsi,backi,convi,eobsi,ebacki,edges,apar,f_model,xrange=[3,100],yrange=[1e-3,1e4],xlog=1,ylog=1
;              
;
; HISTORY:
;       03-JUN-2003 written
;
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

PRO spexdataplot,obsi,backi,convi,eobsi,ebacki,edges,apar,f_model $
                ,xrange=xrange,yrange=yrange,_extra=_extra

y=(obsi-backi)/convi ; photon spectrum

ey=sqrt(eobsi^2+ebacki^2)/convi; error in the spectrum

;backphotons=backi/convi

x   = transpose(0.5*(edges[0,*]+edges[1,*])); energy bins       
ex  = transpose(0.5*(edges[1,*]-edges[0,*])); error in the bins =

;print,ex

ind=where(y-ey LE 0)
eyminus=ey
eyminus[ind]=y[ind]-1d-7


;IF !D.NAME EQ 'PS' THEN factor = 2.0 ELSE factor = 1.0


plot,x,y,xrange=enrange,yrange=yrange,/xlog,/ylog,xstyle=1,ystyle=1 $
     ,ytitle='photons cm!A-2!N keV!A-1!N s!A-1!N',xtitle='Energy in keV' $
     ,psym=3

;     ,xticks=ticknumber,xtickv=tickvalues,thick=2*factor,psym=3

;,xrange=enrange,yrange=yrange,/xlog $
;     ,/ylog,xstyle=1,ystyle=1 $
;     ,ytitle='photons cm!A-2!N keV!A-1!N s!A-1!N',xtitle='Energy in keV' $
;     ,xticks=ticknumber,xtickv=tickvalues,thick=2*factor,psym=3

eplot,x,y,ex=ex,ey=ey,/upper;,color=rhessicolor;,thick=2*factor
eplot,x,y,ex=ex,ey=eyminus,/lower;,color=rhessicolor;,thick=2*factor

IF f_model EQ 'f_2therm_pow' THEN BEGIN
oplot,x,1d-22*apar[0]*mewe_kev(kev2kel(apar[1])*1d-6,wvl2nrg(x))+1d-22*apar[2]*mewe_kev(kev2kel(apar[3])*1d-6,wvl2nrg(x));+f_pow(edges,apar[4:5])
ENDIF




;device,/close



;device,filename=dir+'RHESSI1.ps'


; plot,en2,convsp2,xrange=enrange,yrange=yrange,/xlog $
;      ,/ylog,xstyle=1,ystyle=1 $
;      ,ytitle='photons cm!A-2!N keV!A-1!N s!A-1!N',xtitle='Energy in keV' $
;      ,xticks=ticknumber,xtickv=tickvalues,thick=2*factor


; oplot,en2,convsp2,color=emlinecolor,thick=2*factor

; oplot,en2,spbpow2,color=powerlawcolor,thick=2*factor

; oplot,en2,spbpow2+convsp2,color=total,thick=2*factor

; eplot,xphot,photons,ex=ex,ey=ey,/upper,color=rhessicolor;,thick=2*factor
; eplot,xphot,photons,ex=ex,ey=eyminus,/lower,color=rhessicolor;,thick=2*factor

; device,/close


; device,filename=dir+'RHESSI2.ps'

; restore,'~/work/mfl3/photons.dat'
; restore,'~/work/mfl3/ephotons.dat'
; ex=replicate(0.5,47)
; plot,en2,spbpow2+convsp2,xrange=enrange,yrange=yrange,/xlog $
;      ,/ylog,xstyle=1,ystyle=1 $
;      ,ytitle='photons cm!A-2!N keV!A-1!N s!A-1!N',xtitle='Energy in keV' $
;      ,xticks=ticknumber,xtickv=tickvalues,thick=2*factor


; ;oplot,en2,convsp2,color=emlinecolor

; ;oplot,en2,spbpow2,color=powerlawcolor

; oplot,en2,spbpow2+convsp2,color=total


; eplot,xphot,photons,ex=ex,ey=ey,/upper,color=rhessicolor
; eplot,xphot,photons,ex=ex,ey=eyminus,/lower,color=rhessicolor

; device,/close

; set_plot,'x'
; factor=1.0



END


