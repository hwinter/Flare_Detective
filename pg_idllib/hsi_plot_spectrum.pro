;+
; NAME:
;      hsi_plot_spectrum
;
; PURPOSE: 
;      plot a RHESSI spectrum
;
; INPUTS:
;      photons,ephotons,ebackground
;      apar
;    
;       
; KEYWORDS:
;      
;
; HISTORY:
;       
;       16-JAN-2003 written, based on older material
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

PRO hsi_plot_spectrum,x,photons,ephotons,ebackground,apar=apar $
                     ,convolve=convolve,filename=filename,_extra=_extra



factor=1.0                    ;line thickness factor for working with
                              ;the PS device

IF keyword_set(filename) THEN BEGIN
set_plot,'ps'

factor = 2.0

device,/landscape,xoffset=1,yoffset=28.7;
device,xsize=27.7,ysize=20.0    ;please don't ask WHY it works... it does!
device,ysize=psysize,xsize=psxsize
device,filename=filename
ENDIF

enrange=[3,100]
yrange=[1e-4,1e5]

maxen=100.


linecolors                ;smart colors for plotting
bremcolor=8
emlinecolor=3
powerlawcolor=10
totalcolor=1
rhessicolor=2

psxsize=24
psysize=18

temp=kev2kel(apar[1])/1.d6       ; temperature in MK
em=1.d5*apar[0]                   ; emission measure / 1E44 cm^-3
bremem=em*1.d-5                 ; emission measure / 1E49 cm^-3
binwidth=(maxen-1.)/(4000.)            ; delta_x for energy


delta1=apar[3]
delta2=apar[5]
breakpoint=apar[4]
ybreak=apar[2]*50^(delta1)*breakpoint^(-delta1)


en=findgen((maxen-1.)/binwidth)*binwidth+1 ;array of energies in keV
wave=wvl2nrg(en)                ;array of energies transformed in Angstroms

sp=em*mewe_kev(temp,wave,/photon,/earth)/binwidth ; spectrum with lines
bremsp=bremem*brem_49(en,kel2kev(temp*1d6)) ; continuum spectrum


spbpow=breakpowerlaw(en,-delta1,-delta2,breakpoint,ybreak)
spbpow2=rebin(spbpow,1000)


en2=rebin(en,1000)              ;rebinning data for the plots to 1000 points
wave2=rebin(wave,1000)          ;
sp2=rebin(sp,1000)              ;
bremsp2=rebin(bremsp,1000)      ;
spbpow2=rebin(spbpow,1000)      ;



;smoothed line spectrum 

IF keyword_set(convolve) THEN BEGIN

xx=en2-0.5*(max(en2)-min(en2))-min(en2)
g=expo(xx,0,1)                  ;produce a normalized gaussian centered in 0

;print,int_tabulated(xx,g); if you don't believe my word...

convsp=vect_convolve(en2,sp2,g) ;smooth the spectrum with the convolution
                                ;please note that the area is conserved!
                                ;(because g has area=1)

;smoothed line spectrum 

xx=en-0.5*(max(en)-min(en))-min(en)
xx2=en2-0.5*(max(en2)-min(en2))-min(en2)

g=expo(xx,0,1)                  ;produce a normalized gaussian centered in 0
g2=expo(xx2,0,1)
;print,int_tabulated(xx,g); if you don't believe my word...

convsp=vect_convolve(en,sp,g) ;smooth the spectrum with the convolution
                                ;please note that the area is conserved!
                                ;(because g has area=1)

convsp2=rebin(convsp,1000)    ; rebinned for plotting

convsp3=vect_convolve(en2,sp2,g2) ;quicker, but less good (?)

ENDIF ELSE $
BEGIN
convsp=sp2
convsp2=rebin(convsp,1000)
ENDELSE

;--------------------------------------------------------
;default values for plotting
;--------------------------------------------------------

tickvalues=[3,4,5,6,7,8,9,10,20,30,40,50,60,70,80,90,100]
ticknumber=16


;-------------------------------------------------------
;plotting of the data
;-------------------------------------------------------




;---------------------------------------------------
;actual RHESSI data
;--------------------------------------------------
;restore,'~/work/mfl3/photons.dat'
;restore,'~/work/mfl3/ephotons.dat'
;restore,'~/work/mfl3/ebackground.dat'

ex=replicate(0.5,n_elements(photons))
ey=2*sqrt(ephotons^2+ebackground^2)

ind=where(photons-ey LE 0)
eyminus=ey
eyminus[ind]=photons[ind]-1d-7


xphot=findgen(maxen-3)+3.5


;set_plot,'ps'

;IF !D.NAME EQ 'PS' THEN factor = 2.0 ELSE factor = 1.0

;device,/landscape,xoffset=1,yoffset=28.7;
;device,xsize=29.7,ysize=21.0    ;please don't ask WHY it works... it does!
;device,ysize=psysize,xsize=psxsize

;device,filename=dir+'RHESSI0.ps'


; plot,en2,photons,xrange=enrange,yrange=yrange,/xlog $
;      ,/ylog,xstyle=1,ystyle=1 $
;      ,ytitle='photons cm!A-2!N keV!A-1!N s!A-1!N',xtitle='Energy in keV' $
;      ,xticks=ticknumber,xtickv=tickvalues,thick=2*factor,psym=3

; eplot,xphot,photons,ex=ex,ey=ey,/upper,color=rhessicolor;,thick=2*factor
; eplot,xphot,photons,ex=ex,ey=eyminus,/lower,color=rhessicolor;,thick=2*factor

;device,/close



;device,filename=dir+'RHESSI1.ps'


plot,en2,convsp2,xrange=enrange,yrange=yrange,/xlog $
     ,/ylog,xstyle=1,ystyle=1 $
     ,ytitle='photons cm!A-2!N keV!A-1!N s!A-1!N',xtitle='Energy in keV' $
     ,xticks=ticknumber,xtickv=tickvalues,thick=2*factor,_extra=_extra


oplot,en2,convsp2,color=emlinecolor,thick=2*factor

oplot,en2,spbpow2,color=powerlawcolor,thick=2*factor

oplot,en2,spbpow2+convsp2,color=total,thick=2*factor

eplot,xphot,photons,ex=ex,ey=ey,/upper,color=rhessicolor;,thick=2*factor
eplot,xphot,photons,ex=ex,ey=eyminus,/lower,color=rhessicolor;,thick=2*factor

;device,/close


;device,filename=dir+'RHESSI2.ps'

; restore,'~/work/mfl3/photons.dat'
; restore,'~/work/mfl3/ephotons.dat'
; ex=replicate(0.5,47)
; plot,en2,spbpow2+convsp2,xrange=enrange,yrange=yrange,/xlog $
;      ,/ylog,xstyle=1,ystyle=1 $
;      ,ytitle='photons cm!A-2!N keV!A-1!N s!A-1!N',xtitle='Energy in keV' $
;      ,xticks=ticknumber,xtickv=tickvalues,thick=2*factor


;oplot,en2,convsp2,color=emlinecolor

;oplot,en2,spbpow2,color=powerlawcolor

; oplot,en2,spbpow2+convsp2,color=total


; eplot,xphot,photons,ex=ex,ey=ey,/upper,color=rhessicolor
; eplot,xphot,photons,ex=ex,ey=eyminus,/lower,color=rhessicolor

; device,/close

; set_plot,'x'
; factor=1.0



IF keyword_set(filename) THEN BEGIN
device,/close
set_plot,'x'
ENDIF





END
