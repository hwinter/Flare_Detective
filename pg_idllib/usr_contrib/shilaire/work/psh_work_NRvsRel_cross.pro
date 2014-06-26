sp0_25=forward_spectrum_thick(/EARTH,Eph=Eph,/LOUD,el={delta:2.5,Eto:20})
sp1_25=forward_spectrum_thick(/EARTH,Eph=Eph,/LOUD,el={delta:2.5,Eto:20},/HAUG,/BETHE)

sp0_4=forward_spectrum_thick(/EARTH,Eph=Eph,/LOUD,el={delta:4,Eto:20})
sp1_4=forward_spectrum_thick(/EARTH,Eph=Eph,/LOUD,el={delta:4,Eto:20},/HAUG,/BETHE)

sp0_7=forward_spectrum_thick(/EARTH,Eph=Eph,/LOUD,el={delta:7,Eto:20})
sp1_7=forward_spectrum_thick(/EARTH,Eph=Eph,/LOUD,el={delta:7,Eto:20},/HAUG,/BETHE)


!P.MULTI=[0,3,2,0,1]
charsize=1.5

PLOT,Eph,sp0_25,/XLOG,/YLOG,xtit='photon energy [keV]',ytit='[photons s!U-1!N cm!U-2!N keV!U-1!N]',xr=[1,100],tit='!7d!3=2.5',charsize=charsize
OPLOT,Eph,sp1_25,linestyle=2
label_plot,0.03,3,LINE=0.2,'NR'
label_plot,0.03,2,LINE=0.2,'Rel',style=2
PLOT,Eph,sp1_25/sp0_25,/XLOG,xtit='photon energy [keV]',ytit='Ratio Rel/NR',xr=[1,100],charsize=charsize,yr=[0,1.2]

PLOT,Eph,sp0_4,/XLOG,/YLOG,xtit='photon energy [keV]',ytit='[photons s!U-1!N cm!U-2!N keV!U-1!N]',xr=[1,100],tit='!7d!3=4',charsize=charsize
OPLOT,Eph,sp1_4,linestyle=2
label_plot,0.03,3,LINE=0.2,'NR'
label_plot,0.03,2,LINE=0.2,'Rel',style=2
PLOT,Eph,sp1_4/sp0_4,/XLOG,xtit='photon energy [keV]',ytit='Ratio Rel/NR',xr=[1,100],charsize=charsize,yr=[0,1.2]

PLOT,Eph,sp0_7,/XLOG,/YLOG,xtit='photon energy [keV]',ytit='[photons s!U-1!N cm!U-2!N keV!U-1!N]',xr=[1,100],tit='!7d!3=7',charsize=charsize
OPLOT,Eph,sp1_7,linestyle=2
label_plot,0.03,3,LINE=0.2,'NR'
label_plot,0.03,2,LINE=0.2,'Rel',style=2
PLOT,Eph,sp1_7/sp0_7,/XLOG,xtit='photon energy [keV]',ytit='Ratio Rel/NR',xr=[1,100],charsize=charsize,yr=[0,1.2]


;---------------------------------- IDEAL POWER-LAW FOR INJECTED ELECTRON SPECTRUM -----------------------------------sp0_25=forward_spectrum_thick(/EARTH,Eph=Eph,/LOUD,el={delta:2.5,Eto:20})
sp0_25=forward_spectrum_thick(/EARTH,Eph=Eph,/LOUD,el={delta:2.5})
sp1_25=forward_spectrum_thick(/EARTH,Eph=Eph,/LOUD,el={delta:2.5},/HAUG,/BETHE)

sp0_4=forward_spectrum_thick(/EARTH,Eph=Eph,/LOUD,el={delta:4})
sp1_4=forward_spectrum_thick(/EARTH,Eph=Eph,/LOUD,el={delta:4},/HAUG,/BETHE)

sp0_7=forward_spectrum_thick(/EARTH,Eph=Eph,/LOUD,el={delta:7})
sp1_7=forward_spectrum_thick(/EARTH,Eph=Eph,/LOUD,el={delta:7},/HAUG,/BETHE)


!P.MULTI=[0,3,2,0,1]
charsize=1.5

PLOT,Eph,sp0_25,/XLOG,/YLOG,xtit='photon energy [keV]',ytit='[photons s!U-1!N cm!U-2!N keV!U-1!N]',xr=[1,100],tit='!7d!3=2.5',charsize=charsize
OPLOT,Eph,sp1_25,linestyle=2
label_plot,0.03,3,LINE=0.2,'NR'
label_plot,0.03,2,LINE=0.2,'Rel',style=2
PLOT,Eph,sp1_25/sp0_25,/XLOG,xtit='photon energy [keV]',ytit='Ratio Rel/NR',xr=[1,100],charsize=charsize,yr=[0.5,1.5]

PLOT,Eph,sp0_4,/XLOG,/YLOG,xtit='photon energy [keV]',ytit='[photons s!U-1!N cm!U-2!N keV!U-1!N]',xr=[1,100],tit='!7d!3=4',charsize=charsize
OPLOT,Eph,sp1_4,linestyle=2
label_plot,0.03,3,LINE=0.2,'NR'
label_plot,0.03,2,LINE=0.2,'Rel',style=2
PLOT,Eph,sp1_4/sp0_4,/XLOG,xtit='photon energy [keV]',ytit='Ratio Rel/NR',xr=[1,100],charsize=charsize,yr=[0.5,1.5]

PLOT,Eph,sp0_7,/XLOG,/YLOG,xtit='photon energy [keV]',ytit='[photons s!U-1!N cm!U-2!N keV!U-1!N]',xr=[1,100],tit='!7d!3=7',charsize=charsize
OPLOT,Eph,sp1_7,linestyle=2
label_plot,0.03,3,LINE=0.2,'NR'
label_plot,0.03,2,LINE=0.2,'Rel',style=2
PLOT,Eph,sp1_7/sp0_7,/XLOG,xtit='photon energy [keV]',ytit='Ratio Rel/NR',xr=[1,100],charsize=charsize,yr=[0.5,1.5]


;--------------------------------------------------------------------------------------------------------------
Eph2=(DINDGEN(100)+0.5)/10
Eel2=(DINDGEN(20)+1)/5

!P.MULTI=[0,5,4]
.run
FOR i=0,N_ELEMENTS(Eel2)-1 DO BEGIN
	Brm_BremCross, Eel2[i], eph2, 1.2, cross
	;PLOT,Eph2,cross/510.98,/XLOG,/YLOG
	sp=1.44*7.9d-25/Eph2/Eel2[i]*ALOG((1+sqrt(1-Eph2/Eel2[i]))/(1-sqrt(1-Eph2/Eel2[i])))
	;OPLOT,Eph2,sp,linestyle=2

	PLOT,Eph2,/XLOG,cross/510.98/sp,charsize=2,tit=strn(Eel2[i]),yr=[0.5,1.5]
ENDFOR
END;.run


