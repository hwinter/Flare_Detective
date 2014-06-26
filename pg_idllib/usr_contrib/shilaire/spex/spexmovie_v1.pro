; meant to be run after psh_fast_spex_v1.pro...
;
 

PRO spexmovie_v1, movie, Eph, phflux, BYPASS=BYPASS, DIFF=DIFF, PHOTON=PHOTON
	
	time_array=spex_current('ut')
	utbase=getutbase()
	iselect=spex_current('iselect')
	n_intvs=N_ELEMENTS(iselect[0,*])
	IF NOT KEYWORD_SET(BYPASS) THEN BEGIN
	FOR i=0, n_intvs-1 DO BEGIN
		spex_proc,/cmode, input='ifirst,'+strn(i)
		spex_proc,/cmode, input='ilast,'+strn(i)		
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

;some parameters...
	nx=1
	IF KEYWORD_SET(PHOTON) THEN ny=3 ELSE ny=2
	xs=512*nx
	ys=256*ny
	utplotEedges=[6,12,25]	;[6,12,25,50]
	utplotyrng=[0.01,1e6]
	utplotyrng2=[0.01,MAX((obsi-backi)/convi)]	;[0.01,1e6]
	charsize=.8*ny*nx

;let's rock'n'roll
	movie=BYTARR(xs,ys,n_intvs)
	WINDOW,1, xs=xs,ys=ys
	!P.MULTI=[0,nx,ny]
	TVLCT,r_old,g_old,b_old,/GET
	;linecolors
	rainbow_linecolors
	FOR i=0, n_intvs-1 DO BEGIN	
	;plot countrate lightcurve (not background-subtracted)
		ss1=WHERE(edges[1,*] GE utplotEedges[0])
		ss1=ss1[0]
		utplot,times-utbase, TOTAL(flux[0:ss1,*],1) ,utbase,/YLOG,ytit='Countrate [cts s!U-1!N cm!U-1!N]', $
			xstyle=1,yr=utplotyrng,ymar=[2,1],color=1,charsize=charsize
		ss1=ss1+1

		FOR j=1,N_ELEMENTS(utplotEedges)-1 DO BEGIN			
			ss2=WHERE(edges[1,*] GE utplotEedges[j])
			ss2=ss2[0]
			outplot,times-utbase, TOTAL(flux[ss1:ss2,*],1),color=j+1			
			ss1=ss2
		ENDFOR
		ss1=WHERE(edges[0,*] GE utplotEedges[N_ELEMENTS(utplotEedges)-1])
		ss1=ss1[0]
		outplot,times-utbase, TOTAL(flux[ss1:*,*],1),color=N_ELEMENTS(utplotEedges)+1
		PLOTS,time_array[0,iselect[0,i]],utplotyrng,linestyle=2,thick=2		
		PLOTS,time_array[1,iselect[1,i]],utplotyrng,linestyle=2,thick=2		

	;plot photon lightcurve (background-subtracted)
		ss1=WHERE(edges[1,*] GE utplotEedges[0])
		ss1=ss1[0]
		utplot,itimes-utbase, TOTAL((obsi[0:ss1,*]-backi[0:ss1,*])/convi[0:ss1,*],1) ,utbase,/YLOG,ytit='Photon flux [ph s!U-1!N cm!U-1!N]', $
			xstyle=1,ymar=[2,1],color=1,yr=utplotyrng2,charsize=charsize
		ss1=ss1+1

		FOR j=1,N_ELEMENTS(utplotEedges)-1 DO BEGIN			
			ss2=WHERE(edges[1,*] GE utplotEedges[j])
			ss2=ss2[0]
			outplot,itimes-utbase,TOTAL((obsi[ss1:ss2,*]-backi[ss1:ss2,*])/convi[ss1:ss2,*],1) ,color=j+1			
			ss1=ss2
		ENDFOR
		ss1=WHERE(edges[0,*] GE utplotEedges[N_ELEMENTS(utplotEedges)-1])
		ss1=ss1[0]
		outplot,times-utbase, TOTAL((obsi[ss1:*,*]-backi[ss1:*,*])/convi[ss1:*,*],1),color=N_ELEMENTS(utplotEedges)+1
		PLOTS,time_array[0,iselect[0,i]],utplotyrng2,linestyle=2,thick=2		
		PLOTS,time_array[1,iselect[1,i]],utplotyrng2,linestyle=2,thick=2		


	;plot spectrum
		IF NOT KEYWORD_SET(DIFF) THEN BEGIN
			PLOT,Eph,phflux[*,i],/XLOG,/YLOG,xr=[1,100],yr=[0.01,1e6],psym=1,xtit='!7e!3 [keV]',ytit='Flux [photons s!U-1!N cm!U-2!N keV!U-1!N]',ymar=[4,1],charsize=charsize
			OPLOT,Eph,phflux[*,0],color=2,linestyle=2		
		ENDIF ELSE BEGIN
			IF i EQ 0 THEN PLOT,Eph,phflux[*,i],/XLOG,/YLOG,xr=[1,100],yr=[0.01,1e6],psym=1,xtit='!7e!3 [keV]',ytit='Flux [photons s!U-1!N cm!U-2!N keV!U-1!N]',ymar=[4,1],charsize=charsize $
			ELSE PLOT,Eph,Eph*(phflux[*,i]-phflux[*,i-1]),/XLOG,xr=[1,100],psym=1,xtit='!7e!3 [keV]',ytit='Energy flux [keV s!U-1!N cm!U-2!N keV!U-1!N]',ymar=[4,1],yr=[-1.,1.]*100,charsize=charsize 
		ENDELSE
		movie[*,*,i]=TVRD()
	ENDFOR
	!P.MULTI=0
	TVLCT,r_old,g_old,b_old
END

