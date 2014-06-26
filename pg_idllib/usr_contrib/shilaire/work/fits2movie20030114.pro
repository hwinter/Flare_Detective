
eventcode='HXS207230035'
n_intvs=48
n_ebands=5
basesize=150

set_plot,'Z'
device,set_resolution=basesize*[n_intvs,n_ebands]
!P.MULTI=[0,n_intvs,n_ebands]
hessi_ct
TVLCT,r,g,b,/GET

FOR j=0,n_ebands-1 DO BEGIN
	CASE j OF
		0: mvletter='F'
		1: mvletter='G'
		2: mvletter='H'
		3: mvletter='I'
		ELSE: mvletter='J'
	ENDCASE
	FOR i=0,n_intvs-1 DO BEGIN
		filename='NEWHEDCDATA/HEDC_DP_mov'+mvletter+'_frame'+int2str(i,4)+'_'+eventcode+'.fits'
		img=mrdfits(filename,0)		
		IF N_ELEMENTS(img) EQ 1 THEN plot_image,dist(100) ELSE plot_image,img,xtickname=REPLICATE(' ',10),ytickname=REPLICATE(' ',10),/iso,charsize=0.01,/VEL,ticklen=0
	ENDFOR ;i
ENDFOR ;j
WRITE_PNG,'NEWHEDCDATA/HEDC_DP_pten_'+eventcode+'.png',TVRD(),r,g,b
DEVICE,/CLOSE
SET_PLOT,'X'
END

