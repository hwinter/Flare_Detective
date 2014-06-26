PRO psh_bremcross_comparisons
	;result (y-scale) is cm^2 keV^-1

	npts=100	
	Eel=[10,25,50,100,200,300,500,1000,2000,3000,5000,10000]
	charsize=2.0
	z=1.2
	
	;psh_win,800,600
	!P.MULTI=[0,4,3]
	FOR i=0,N_ELEMENTS(Eel)-1 DO BEGIN
		Eph=Eel[i]^(DINDGEN(npts)/(npts-1))	;from 1 keV to Eel keV.
	;NRBH
		y=betheheitler_brm_crosssection(Eel[i], Eph, z=z)
		PLOT,Eph,y,/XLOG,/YLOG,xr=[1,Eel[i]],xstyle=1,xmar=[5,1],ymar=[2,2],charsize=charsize,tit=strn(FIX(Eel[i]))+' keV electron',yr=[1d-32,1d-24]
		label_plot,0.05,3,/LINE,'NR B-H'
	;KRAMER
		y=7.9d-25*1.44/Eph/Eel[i]
		OPLOT,Eph,y,linestyle=3
		label_plot,0.05,4,/LINE,'Kramer',style=3
	;HAUG
		brm_bremcross,Eel[i],Eph,z,y
		y=y/510.98
		OPLOT,Eph,y,linestyle=2
		label_plot,0.05,2,/LINE,'Haug',style=2
	;HAUG+ee_brem
		FOR j=0L,npts-1 DO y[j]=y[j]+z*ee_bremcross(Eel[i],Eph[j])	
		OPLOT,Eph,y,linestyle=1
		label_plot,0.05,1,/LINE,'Haug + e-e brems.',style=1
	ENDFOR
	!P.MULTI=0
END
