; if files is not used, means SPEX has already been loaded and everything...
;
; LIST of info tags:
;		file1:'Ebudget2/20020226/hsi_spectrum_20020226_102400.fits'
;		dfile:'Ebudget2/20020226/hsi_srm_20020226_102400.fits'
;		;the two above tags mean recomputing everything...
;		xselect:5
;		backgnd:0
;		Eedges:[4,5,6,7,8,9,10,12,25]	;don't start below 4 or above 17MeV!
;
;
; EXAMPLE:
;	info={file1:'Ebudget2/20020226/hsi_spectrum_20020226_102400.fits',dfile:'Ebudget2/20020226/hsi_srm_20020226_102400.fits',xselect:5,backgnd:0}
;	info={file1:'Ebudget2/20020421/hsi_spectrum_20020421_003500.fits',dfile:'Ebudget2/20020421/hsi_srm_20020421_003500.fits',backgnd:0}
;	spexmovie, movie, info=info
;
;
 

PRO spexmovie, movie, info=info

	IF tag_exist(info,'file1',/QUIET) THEN BEGIN
		
		spex_proc,/cmode, input='data,hessi,front'
		spex_proc,/cmode, input='_1file,'+info.file1
		spex_proc,/cmode, input='dfile,'+info.dfile
		;spex_proc,/cmode, input='read_drm'
		spex_proc,/cmode, input='preview'
		spex_proc,/cmode, input='graph'
	
	;BACKGROUND
		IF tag_exist(info,'backgnd',/QUIET) THEN BEGIN
			spex_proc,/cmode, input='back_order,'+STRING(info.backgnd) 
			spex_proc,/cmode, input='background'	
		ENDIF ELSE spex_proc,/cmode, input='background,null'	

		spex_proc,/cmode, input='graph'

	;XSELECT
		IF tag_exist(info,'xselect',/QUIET) THEN BEGIN
			IF N_ELEMENTS(info.xselect) GT 1 THEN BEGIN
				spex_proc,/cmode, input='xselect=['+strn(info.xselect[0,0])+','+strn(info.xselect[1,0])+']'
				FOR i=1,N_ELEMENTS(info.xselect[0,*])-1 DO spex_proc,/cmode, input='xselect=[[xselect],['+strn(info.xselect[0,i])+','+strn(info.xselect[1,i])+']]'	
			ENDIF ELSE BEGIN
				m=info.xselect
				time_array=spex_current('ut')
				spex_proc,/cmode, input='xselect=['+strn(time_array[0,0])+','+strn(time_array[1,m-1])+']'
				FOR i=1,N_ELEMENTS(time_array[0,*])/m-1 DO spex_proc,/cmode, input='xselect=[[xselect],['+strn(time_array[0,i*m])+','+strn(time_array[1,(i+1)*m-1])+']]'	
			ENDELSE
		ENDIF ELSE spex_proc,/cmode, input='xselect=ut'	
		PRINT,'>>>>>>   Choose "XSELECT, non-graphic", then  "As boundaries for discrete intervals" !!'
		spex_proc,/cmode, input='select_interval'
	ENDIF
	
; going on...	
	time_array=spex_current('ut')
	utbase=getutbase()
	iselect=spex_current('iselect')
	n_intvs=N_ELEMENTS(iselect[0,*])
	

; fitting to properly set all obsi & backi & convi...
	IF tag_exist(info,'file1',/QUIET) THEN BEGIN
		FOR i=0, n_intvs-1 DO BEGIN
			spex_proc,/cmode, input='ifirst,'+strn(i)
			spex_proc,/cmode, input='ilast,'+strn(i)		

;			;optional fitting stuff
;			IF KEYWORD_SET(fitinfo) THEN BEGIN
;				n_apar=6
;				IF tag_exist(fitinfo,'model',/QUIET) THEN spex_proc,/cmode, input=fitinfo.model ELSE spex_proc,/cmode, input='f_model,f_vth_bpow'
;				IF tag_exist(fitinfo,'a_cutoff',/QUIET) THEN spex_proc,/cmode, input='a_cutoff=['+strn(fitinfo.a_cutoff[0])+','+strn(fitinfo.a_cutoff[1])+']' ELSE spex_proc,/cmode, input='a_cutoff=[1.,1.5]'
;				IF tag_exist(fitinfo,'apar',/QUIET) THEN BEGIN
;					input='apar=['+strn(fitinfo.apar[0])
;					FOR i=1,n_apar-1 DO input=input+','+strn(fitinfo.apar[i])
;					input=input+']'
;					spex_proc,/cmode, input=input
;				ENDIF ELSE spex_proc,/cmode, input='apar=[1,1,1,3,400,4]'
;				IF tag_exist(fitinfo,'free',/QUIET) THEN BEGIN
;					input='free=['+strn(fitinfo.free[0])
;					FOR i=1,n_apar-1 DO input=input+','+strn(fitinfo.free[i])
;					input=input+']'
;					spex_proc,/cmode, input=input
;				ENDIF ELSE spex_proc,/cmode, input='apar=[1,1,1,3,400,4]'
;				IF tag_exist(fitinfo,'erange',/QUIET) THEN spex_proc,/cmode, input='erange=['+strn(fitinfo.erange[0])+','+strn(fitinfo.erange[1])+']' ELSE spex_proc,/cmode, input='erange=[9,100]'
;
;				spex_proc,/cmode, input='spyrange,0.01,1e6'
;				spex_proc,/cmode, input='energy_bands,3,12,12,25,25,50,50,100'
;	
;				spex_proc,/cmode, input='graph'
;				spex_proc,/cmode, input='fitting'	
;				spex_proc,/cmode, input='fitting'	
;			ENDIF
			spex_proc,/cmode, input='fitting'
		ENDFOR
	ENDIF
		
	flux=spex_current('flux')
	obsi=spex_current('obsi')
	convi=spex_current('convi')
	backi=spex_current('backi')
	edges=spex_current('edges')

;use raw data from spex...
	times=REFORM(time_array[0,*] + time_array[1,*])/2. + utbase
	itimes=REFORM(time_array[0,iselect[0,*]] + time_array[1,iselect[1,*]])/2. + utbase
	edge_products,edges,mean=Eph
	phflux=(obsi-backi)/convi

;some graphical output parameters...
	nx=1
	ny=3
	xs=512*nx
	ys=256*ny
	IF tag_exist(info,'Eedges',/QUIET) THEN utplotEedges=info.Eedges ELSE utplotEedges=[6,12,25]
	utplotyrng=[0.01,1e4]
	utplotyrng2=[0.01,MAX((obsi-backi)/convi)]	;[0.01,1e6]
	charsize=.8*ny*nx

;let's rock'n'roll
	movie=BYTARR(xs,ys,n_intvs)
	psh_win,xs,ys,nb=1
	!P.MULTI=[0,nx,ny]
		;linecolors 
		;rainbow_linecolors
	FOR i=0, n_intvs-1 DO BEGIN	
	;plot countrate lightcurve (not background-subtracted)
		ss1=WHERE(edges[1,*] GE utplotEedges[0])
		ss1=ss1[0]
		utplot,times-utbase, TOTAL(flux[0:ss1,*],1) ,utbase,/YLOG,ytit='Countrate [cts s!U-1!N cm!U-2!N]', $
			xstyle=1,yr=utplotyrng,ymar=[2,1],color=1,charsize=charsize
		plot_label,/DEV,[0.7,-1],'< '+strn(utplotEedges[0])+' keV',color=1
		ss1=ss1+1

		FOR j=1,N_ELEMENTS(utplotEedges)-1 DO BEGIN			
			ss2=WHERE(edges[1,*] GE utplotEedges[j])
			ss2=ss2[0]
			outplot,times-utbase, TOTAL(flux[ss1:ss2,*],1),color=j+1			
			plot_label,/DEV,[0.7,-j-1],strn(utplotEedges[j-1])+'-'+strn(utplotEedges[j])+' keV',color=1+j
			ss1=ss2
		ENDFOR
		ss1=WHERE(edges[0,*] GE utplotEedges[N_ELEMENTS(utplotEedges)-1])
		ss1=ss1[0]
		outplot,times-utbase, TOTAL(flux[ss1:*,*],1),color=N_ELEMENTS(utplotEedges)+1
		plot_label,/DEV,[0.7,-j-1],'> '+strn(utplotEedges[N_ELEMENTS(utplotEedges)-1])+' keV',color=1+j
		PLOTS,time_array[0,iselect[0,i]],utplotyrng,linestyle=2,thick=2		
		PLOTS,time_array[1,iselect[1,i]],utplotyrng,linestyle=2,thick=2		

	;plot photon lightcurve (background-subtracted)
		ss1=WHERE(edges[1,*] GE utplotEedges[0])
		ss1=ss1[0]
		utplot,itimes-utbase, TOTAL((obsi[0:ss1,*]-backi[0:ss1,*])/convi[0:ss1,*],1) ,utbase,/YLOG,ytit='Photon flux [ph s!U-1!N cm!U-2!N]', $
			xstyle=1,ymar=[2,1],color=1,yr=utplotyrng2,charsize=charsize
		utplotyrng2=10^!Y.CRANGE
		ss1=ss1+1

		FOR j=1,N_ELEMENTS(utplotEedges)-1 DO BEGIN			
			ss2=WHERE(edges[1,*] GE utplotEedges[j])
			ss2=ss2[0]
			outplot,itimes-utbase,TOTAL((obsi[ss1:ss2,*]-backi[ss1:ss2,*])/convi[ss1:ss2,*],1) ,color=j+1			
			ss1=ss2
		ENDFOR
		ss1=WHERE(edges[0,*] GE utplotEedges[N_ELEMENTS(utplotEedges)-1])
		ss1=ss1[0]
		outplot,itimes-utbase, TOTAL((obsi[ss1:*,*]-backi[ss1:*,*])/convi[ss1:*,*],1),color=N_ELEMENTS(utplotEedges)+1
		PLOTS,time_array[0,iselect[0,i]],utplotyrng2,linestyle=2,thick=2		
		PLOTS,time_array[1,iselect[1,i]],utplotyrng2,linestyle=2,thick=2		

	;plot spectrum
		PLOT,Eph,phflux[*,i],/XLOG,/YLOG,xr=[1,100],yr=[1e-3,1e5],psym=1,xtit='!7e!3 [keV]',ytit='Flux [photons s!U-1!N cm!U-2!N keV!U-1!N]',ymar=[4,1],charsize=charsize
		OPLOT,Eph,phflux[*,0],color=1
		IF KEYWORD_SET(fitinfo) THEN BEGIN
			tmp=spex_current('chi['+strn(i)+']')
			plot_label,[0.7,-2],/DEV,/NOLINE,'!3V!U2!N!7 = '+strn(tmp),charsize=2
		ENDIF
		movie[*,*,i]=TVRD()
	ENDFOR
	!P.MULTI=0
END

