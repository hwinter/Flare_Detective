;
; m: number of accumlation intervals to use as bins for fitting
;
;
;EXAMPLE:
; get_utc,utc,/ECS
; outfil='Ebudget2/20020226/fastspexdata'+time2file(utc,/SEC)
;
; outfil='Ebudget2/20020226/scratch'
;
; psh_fast_spex_v1, 'Ebudget2/20020226/hsi_spectrum_20020226_102400.fits','Ebudget2/20020226/hsi_srm_20020226_102400.fits','2002/02/26 '+['10:26','10:29'],'2002/02/26 10:26:42',-1,1,outfil
; psh_fast_spex_v1, 'Ebudget2/20020226/hsi_spectrum_20020226_102400.fits','Ebudget2/20020226/hsi_srm_20020226_102400.fits','2002/02/26 '+['10:26','10:29'],'2002/02/26 10:26:42',-1,8,outfil
; 
; psh_fast_spex_v1, 'Ebudget2/20020226/hsi_spectrum_20020226_102400.fits','Ebudget2/20020226/hsi_srm_20020226_102400.fits','2002/02/26 '+['10:26','10:29'],'2002/02/26 10:26:42',1,1,outfil 
; psh_fast_spex_v1, 'Ebudget2/20020226/hsi_spectrum_20020226_102400.fits','Ebudget2/20020226/hsi_srm_20020226_102400.fits','2002/02/26 '+['10:26','10:29'],'2002/02/26 10:26:42',1,8,outfil
;

; get_utc,utc,/ECS
; outfil='Ebudget2/20020421/fastspexdata'+time2file(utc,/SEC)
; psh_fast_spex_v1, 'Ebudget2/20020421/hsi_spectrum_20020421_003530.fits','Ebudget2/20020421/hsi_srm_20020421_003530.fits','2002/04/21 '+['00:40:00','00:48'],'2002/04/21 00:47:50',1,1,outfil 
; psh_fast_spex_v1, 'Ebudget2/20020421/hsi_spectrum_20020421_004810.fits','Ebudget2/20020421/hsi_srm_20020421_004810.fits','2002/04/21 '+['00:48:10','00:50'],'2002/04/21 00:48:15',-1,1,outfil 
;
;-------------------------------------------------------------------------------------------------------------------------------
PRO psh_fast_spex_v1__fullauto, istart,iend,istep, fitparams, fitchisq, movie, cutoffminmax
	FOR i=istart,iend,istep DO BEGIN
		PRINT,"...........Doing interval: '+strn(i)
		
		spex_proc,/cmode, input='ifirst,'+strn(i)
		spex_proc,/cmode, input='ilast,'+strn(i)
		
		spex_proc,/cmode,input='a_cutoff[0]=1'
		spex_proc,/cmode,input='fitting'
		spex_proc,/cmode,input='fitting'
		spex_proc,/cmode,input='fitting'
	
		;GOTO,SKIP_CUTOFF_SEARCH
		n_versuch=FIX(cutoffminmax[1]-cutoffminmax[0])+1
		e_arr=DINDGEN(n_versuch) + cutoffminmax[0]
		chi2=DBLARR(n_versuch)
		FOR j=0,n_versuch-1 DO BEGIN
			spex_proc,/cmode,input='a_cutoff[0]='+strn(e_arr[j])
			spex_proc,/cmode,input='fitting'
			spex_proc,/cmode,input='fitting'
			spex_proc,/cmode,input='fitting'
			chi2[j]=spex_current('chi['+strn(i)+']')
		ENDFOR
	
		thebest=MIN(chi2,ss1)
		ss=WHERE(chi2 LE 1.1*thebest)
		ss=ss[N_ELEMENTS(ss)-1]
		spex_proc,/cmode,input='a_cutoff[0]='+strn(e_arr[ss])
		spex_proc,/cmode,input='fitting'
		spex_proc,/cmode,input='fitting'
		spex_proc,/cmode,input='fitting'

		SKIP_CUTOFF_SEARCH:		
		tmp=spex_current('apar')
		fitparams[*,i]=[tmp,spex_current('a_cutoff')]
		tmp=spex_current('chi['+strn(i)+']')
		fitchisq[i]=tmp
		
		;;wset,33
		;;movie[*,*,i]=TVRD()
	ENDFOR
END
;-------------------------------------------------------------------------------------------------------------------------------
PRO psh_fast_spex_v1, file1, dfile, time_intv, peaktime, back, m, outfile, cutoffminmax=cutoffminmax, start_apar=start_apar, erange=erange

	;spex_current
	;spex_proc,cmode=cmode, input=input
	
	spex_proc,/cmode, input='data,hessi,front'
	spex_proc,/cmode, input='_1file,'+file1
	spex_proc,/cmode, input='dfile,'+dfile
;	spex_proc,/cmode, input='read_drm'
	spex_proc,/cmode, input='preview'
	spex_proc,/cmode, input='graph'
	IF back GE 0 THEN BEGIN
		spex_proc,/cmode, input='back_order,'+STRING(back) 
		spex_proc,/cmode, input='background'
	ENDIF ELSE spex_proc,/cmode, input='background,null'
	;backgnd stuff....
	IF not keyword_set(cutoffminmax) THEN cutoffminmax=[6,21]
	

;beginning...
	IF NOT KEYWORD_SET(start_apar) THEN start_apar=[1,1,1,3,400,4]
	start_free=[1,1,1,1,0,0]
	
	spex_proc,/cmode, input='f_model,f_vth_bpow'
	spex_proc,/cmode, input='a_cutoff=[1.,1.5]'

	tmp='apar=['+strn(start_apar[0])
	FOR i=1,5 DO tmp=tmp+','+strn(start_apar[i])
	tmp=tmp+']'
	spex_proc,/cmode, input=tmp

	tmp='free,'+strn(start_free[0])
	FOR i=1,5 DO tmp=tmp+','+strn(start_free[i])
	spex_proc,/cmode, input=tmp
	
	;spex_proc,/cmode, input='erange=[9,100]'
	IF NOT KEYWORD_SET(erange) THEN spex_proc,/cmode, input='erange=[6,35]' ELSE BEGIN
		tmp='erange=['+strn(erange[0])+','+strn(erange[1])+']'
		spex_proc,/cmode, input=tmp
	ENDELSE
	spex_proc,/cmode, input='spyrange,0.01,1e6'
	spex_proc,/cmode, input='energy_bands,3,12,12,25,25,50,50,100'

	spex_proc,/cmode, input='graph'
;determining a few parameters:
	time_array=spex_current('ut')
	utbase=getutbase()
	ss_beg=WHERE(time_array[0,*] GE (anytim(time_intv[0])-utbase))
	ss_beg=ss_beg[0]-1
	IF ss_beg LT 0 THEN ss_beg=0
	ss_end=WHERE(time_array[1,*] GT (anytim(time_intv[1])-utbase))
	ss_end=ss_end[0]
	IF ss_end EQ -1 THEN ss_end=N_ELEMENTS(time_array[1,*])-1
	n_intvs=FIX((ss_end-ss_beg)/m)
	PRINT,'-------> N_INTVS: '+strn(n_intvs)

	;spex_proc,/cmode, input='xselect=ut'
	spex_proc,/cmode, input='xselect=['+strn(time_array[0,ss_beg])+','+strn(time_array[1,ss_beg+m-1])+']'
	FOR i=1,n_intvs-1 DO spex_proc,/cmode, input='xselect=[[xselect],['+strn(time_array[0,ss_beg+i*m])+','+strn(time_array[1,ss_beg+(i+1)*m-1])+']]'

	PRINT,'>>>>>>   Choose "XSELECT, non-graphic", then  "As boundaries for discrete intervals" !!'
	spex_proc,/cmode, input='select_interval'

	iselect=spex_current('iselect')
	tmp=WHERE(time_array[1,iselect[1,*]] GE (anytim(peaktime)-utbase))
	ipeak=tmp[0]
	IF ipeak EQ -1 THEN ipeak=0
	icur=ipeak	;0

	spex_proc,/cmode, input='ifirst,'+strn(icur)
	spex_proc,/cmode, input='ilast,'+strn(icur)
	
	times=time_array[0,ss_beg:ss_end-1]+time_array[1,ss_beg:ss_end-1]
	times=utbase+REFORM(times)/2.
	fitparams=DBLARR(8,n_intvs)-1d	; EM, T, norm, index1, breakE, index2, lowEcutoff, index below lowEcutoff
	fitchisq=DBLARR(n_intvs)-1d
	
;MAJOR LOOP:	
	finished=0
	domovie=0	
	WHILE finished EQ 0 DO BEGIN
		PRINT,'----------------------------------------------------------------------------'
		PRINT,'----------Interval: icur: '+strn(icur)+'   '+anytim(time_array[0,iselect[0,icur]],/ECS,/time)+ ' to '+anytim(time_array[1,iselect[1,icur]],/ECS,/time)
		PRINT,fitparams[*,icur]
		PRINT,'p : photon_spectrum'
		PRINT,'c : count_spectrum'
		PRINT,'a/A : change cutoff energy/change cutoff energy range for searching'
		PRINT,'s : search automatically best cutoff energy, by finding fitting with smallest chi-squared'
		PRINT,'f/F : fitting and storing fit parameters/same with AI'
		PRINT,'o : other SPEX command'
		;IF domovie EQ 0 THEN PRINT,'m : do a movie'
		PRINT,'k : ka-boum FULL-AUTO'
		PRINT,'S/R : SAVE/RESTORE fitting stuff...'
		PRINT,'b/n/q: previous/next interval or exit'
		PRINT,'----------------------------------------------------------------------------'
		input=GET_KBRD(1)
		
		CASE input OF
			'p': spex_proc,/cmode,input='photon_spectrum'
			'c': spex_proc,/cmode,input='count_spectrum'
			'f': BEGIN 
				spex_proc,/cmode,input='fitting'
				tmp=spex_current('apar')
				fitparams[*,icur]=[tmp,spex_current('a_cutoff')]
				fitchisq[icur]=spex_current('chi['+strn(icur)+']')
				IF domovie EQ 1 THEN movie[*,*,icur]=TVRD()
			END
			'F': BEGIN 
				spex_proc,/cmode,input='fitting'
				tmp=spex_current('apar')
				IF tmp[0] LT 0.001 THEN BEGIN
					inputline='apar=['+strn(start_apar[0])
					FOR i=1,5 DO inputline=inputline+','+strn(start_apar[i])
					inoutline=inputline+']'
					spex_proc,/cmode, input=inputline
					spex_proc,/cmode, input='force_apar'
					spex_proc,/cmode,input='fitting'

					tmp=spex_current('apar')
				ENDIF
				fitparams[*,icur]=[tmp,spex_current('a_cutoff')]
				fitchisq[icur]=spex_current('chi['+strn(icur)+']')
				IF domovie EQ 1 THEN movie[*,*,icur]=TVRD()
			END
			'a': BEGIN
				nbr=10d
				res=spex_current('a_cutoff')
				PRINT,'Current value: '+strn(res[0])
				PRINT,'Enter new one:'
				READ,nbr
				spex_proc,/cmode,input='a_cutoff=['+strn(nbr)+','+strn(res[1])+']'
			END
			'A': BEGIN
				nbr=10d
				PRINT,'Current start value: '+strn(cutoffminmax[0])
				PRINT,'Enter new one:'
				READ,nbr
				cutoffminmax[0]=nbr
				PRINT,'Current end value: '+strn(cutoffminmax[1])
				PRINT,'Enter new one:'
				READ,nbr
				cutoffminmax[1]=nbr
			END
			's':BEGIN
				n_versuch=FIX(cutoffminmax[1]-cutoffminmax[0])+1
				e_arr=DINDGEN(n_versuch) + cutoffminmax[0]
				chi2=DBLARR(n_versuch)
				FOR i=0,n_versuch-1 DO BEGIN
					spex_proc,/cmode,input='a_cutoff[0]='+strn(e_arr[i])
					spex_proc,/cmode,input='fitting'
					spex_proc,/cmode,input='fitting'
					spex_proc,/cmode,input='fitting'
					tmp=spex_current('ifirst')
					chi2[i]=spex_current('chi['+strn(tmp)+']')
				ENDFOR
				mwrfits,{e_arr:e_arr,chi2:chi2},'Ebudget2/last_chi2_search.fits',/CREATE				
				thebest=MIN(chi2,ss1)
				ss=WHERE(chi2 LE 1.1*thebest)
				ss=ss[N_ELEMENTS(ss)-1]
				spex_proc,/cmode,input='a_cutoff[0]='+strn(e_arr[ss])
				spex_proc,/cmode,input='fitting' & tmp=spex_current('apar') & fitparams[*,icur]=[tmp,spex_current('a_cutoff')]
				fitchisq[icur]=spex_current('chi['+strn(icur)+']')

				PRINT,'--------------------------------------------------------------------------------------'
				PRINT,'-------> BEST CHI^2: '+strn(thebest)+' for a cut-off energy of '+strn(e_arr[ss1])+'.'
				PRINT,'-------> Highest cutoff energy which does not change chi^2 sensibly (<=10%) compared to best value: '+strn(e_arr[ss])+' chi2:'+strn(chi2[ss])
								
			END
			'o': BEGIN
				cmd="PRINT,'blablabla'"
				PRINT,'Enter SPEX command: '
				READ,cmd
				spex_proc,/cmode,input=cmd
			END
			'n': BEGIN
				PRINT,'>>>>>>> Next time intv'
				icur=icur+1
				IF icur GT n_intvs-1 THEN icur=0
				spex_proc,/cmode, input='ifirst,'+strn(icur)
				spex_proc,/cmode, input='ilast,'+strn(icur)
				IF fitparams[0,icur] LT 0 THEN spex_proc,/cmode, input='a_cutoff=[1.,1.5]'
			END
			'b': BEGIN
				PRINT,'>>>>>>> Previous time intv'
				icur=icur-1
				IF icur LT 0 THEN icur=n_intvs-1
				spex_proc,/cmode, input='ifirst,'+strn(icur)
				spex_proc,/cmode, input='ilast,'+strn(icur)
				IF fitparams[0,icur] LT 0 THEN spex_proc,/cmode, input='a_cutoff=[1.,1.5]'
			END
			'k': BEGIN
				;domovie=1
				;wset,33
				;tmp=TVRD()
				;movie=BYTARR(N_ELEMENTS(tmp[*,0]),N_ELEMENTS(tmp[0,*]),n_intvs)
				
				psh_fast_spex_v1__fullauto, ipeak,0,-1, fitparams, fitchisq,movie,cutoffminmax
				psh_fast_spex_v1__fullauto, ipeak,n_intvs-1,+1, fitparams, fitchisq,movie,cutoffminmax
			END				
			'q': finished=1
			'S': BEGIN
				;save all relevant output in its current state...
				PRINT,'SAVING...'
				IF domovie EQ 0 THEN data={erange:[-1d,-1d], times:times, fitparams:fitparams, fitchisq:fitchisq} $
				ELSE data={erange:[-1d,-1d], times:times, fitparams:fitparams, fitchisq:fitchisq, movie:movie}
				data.erange=spex_current('erange')
				IF EXIST(outfile) THEN mwrfits,data,/CREATE,outfile+'.fits'			
			END
			'R': BEGIN
				;RESTORE
				PRINT,'RESTORING...'
				data=mrdfits(outfile+'.fits',1)
				spex_proc,/cmode,input='erange,'+strn(data.erange[0])+','+strn(data.erange[1])
				fitparams=data.fitparams
				fitchisq=data.fitchisq
			END
			ELSE: PRINT,'>>>>>>>>> NO ACTION'
		ENDCASE
	ENDWHILE
END

