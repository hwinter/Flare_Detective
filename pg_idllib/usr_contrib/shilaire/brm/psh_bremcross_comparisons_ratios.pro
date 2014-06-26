PRO psh_bremcross_comparisons_ratios

	npts=100	
	Eel=[10,25,50,100,200,300,500,1000,2000,3000,5000,10000]
	charsize=2.0
	z=1.2
	
	;psh_win,800,600
	!P.MULTI=[0,4,3]
	FOR i=0,N_ELEMENTS(Eel)-1 DO BEGIN
		Eph=Eel[i]^(DINDGEN(npts)/(npts-1))	;from 1 keV to Eel keV.
	;NRBH
		y0=betheheitler_brm_crosssection(Eel[i], Eph, z=z)
	;KRAMER
		y1=7.9d-25*1.44/Eph/Eel[i]
	;HAUG
		brm_bremcross,Eel[i],Eph,z,y2
		y2=y2/510.98
	;HAUG+ee_brem
		y=y2
		FOR j=0L,npts-1 DO y[j]=y[j]+z*ee_bremcross(Eel[i],Eph[j])	
	;PLOT RATIOS
		PLOT,Eph,y0/y,/XLOG,/YLOG,xr=[1,Eel[i]],xstyle=1,xmar=[5,1],ymar=[2,2],charsize=charsize,tit=strn(FIX(Eel[i]))+' keV electron',yr=[1d-3,2],ystyle=1
		OPLOT,Eph,y1/y,linestyle=1
		OPLOT,Eph,y2/y,linestyle=2
		IF i EQ 0 THEN BEGIN
			label_plot,0.05,2,/LINE,'NRBH/(Haug+ee)'
			label_plot,0.05,3,/LINE,'KRAMER/(Haug+ee)',style=1
			label_plot,0.05,1,/LINE,'HAUG/(Haug+ee)',style=2
		ENDIF
	ENDFOR
	!P.MULTI=0
END
