

;----------- no cutoffs--------
Eph=0.5+DINDGEN(500)
sp0=forward_spectrum_thick(/EARTH,Eph=Eph,il=0.)
sp1=forward_spectrum_thick(/EARTH,Eph=Eph,il=0.,/SCREENING)

sp2=forward_spectrum_thick(/EARTH,Eph=Eph,il=0.,delta=3.)
sp3=forward_spectrum_thick(/EARTH,Eph=Eph,il=0.,/SCREENING,delta=3.)

sp4=forward_spectrum_thick(/EARTH,Eph=Eph,il=0.,delta=8.)
sp5=forward_spectrum_thick(/EARTH,Eph=Eph,il=0.,/SCREENING,delta=8.)

tit='Comparison of photon spectra from three electron power-laws with no cut-offs'
plot,Eph,sp1/sp0,yr=[0.99,1.01],/XLOG,xr=[1,300],xstyle=1,xtit='!7e!3 [keV]',ytit='Ratio of screened/unscreened',tit=tit
XYOUTS,/NORM,0.2,0.33,'!7d!3=4'
oplot,Eph,sp3/sp2,linestyle=1
XYOUTS,/NORM,0.2,0.23,'!7d!3=3'
oplot,Eph,sp5/sp4,linestyle=2
XYOUTS,/NORM,0.2,0.4,'!7d!3=8'

;----------- cutoff at 10 keV --------
Eph=0.5+DINDGEN(500)
sp0=forward_spectrum_thick(/EARTH,Eph=Eph,il=0.)
sp1=forward_spectrum_thick(/EARTH,Eph=Eph,il=0.,/SCREENING)

sp2=forward_spectrum_thick(/EARTH,Eph=Eph,il=0.,delta=3.)
sp3=forward_spectrum_thick(/EARTH,Eph=Eph,il=0.,/SCREENING,delta=3.)

sp4=forward_spectrum_thick(/EARTH,Eph=Eph,il=0.,delta=8.)
sp5=forward_spectrum_thick(/EARTH,Eph=Eph,il=0.,/SCREENING,delta=8.)

tit='Comparison of photon spectra from three electron power-laws with cut-off at 10 keV'
plot,Eph,sp1/sp0,yr=[0.99,1.01],/XLOG,xr=[1,300],xstyle=1,xtit='!7e!3 [keV]',ytit='Ratio of screened/unscreened',tit=tit
XYOUTS,/NORM,0.2,0.33,'!7d!3=4'
oplot,Eph,sp3/sp2,linestyle=1
XYOUTS,/NORM,0.2,0.23,'!7d!3=3'
oplot,Eph,sp5/sp4,linestyle=2
XYOUTS,/NORM,0.2,0.4,'!7d!3=8'

;----------- cutoff at 20 keV --------
Eph=0.5+DINDGEN(500)
sp0=forward_spectrum_thick(/EARTH,Eph=Eph,il=0.)
sp1=forward_spectrum_thick(/EARTH,Eph=Eph,il=0.,/SCREENING)

sp2=forward_spectrum_thick(/EARTH,Eph=Eph,il=0.,delta=3.)
sp3=forward_spectrum_thick(/EARTH,Eph=Eph,il=0.,/SCREENING,delta=3.)

sp4=forward_spectrum_thick(/EARTH,Eph=Eph,il=0.,delta=8.)
sp5=forward_spectrum_thick(/EARTH,Eph=Eph,il=0.,/SCREENING,delta=8.)

tit='Comparison of photon spectra from three electron power-laws with cut-off at 20 keV'
plot,Eph,sp1/sp0,yr=[0.99,1.01],/XLOG,xr=[1,300],xstyle=1,xtit='!7e!3 [keV]',ytit='Ratio of screened/unscreened',tit=tit
XYOUTS,/NORM,0.2,0.23,'!7d!3=4'
oplot,Eph,sp3/sp2,linestyle=1
XYOUTS,/NORM,0.25,0.2,'!7d!3=3'
oplot,Eph,sp5/sp4,linestyle=2
XYOUTS,/NORM,0.2,0.3,'!7d!3=8'


