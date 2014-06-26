;
; TO TEST MY METHOD OF FITTING...
;	sp_nth=forward_spectrum_thick(/EARTH,Eph=Eph,/LOUD,el={delta:4,Eto:20})
;	sp_th=f_vth(Eph,[1,1])
;	PLOT,Eph,sp_nth,linestyle=1,/XLOG,/YLOG,xr=[1,100],yr=[0.1,1e6]
;	OPLOT,Eph,sp_th,linestyle=2
;	sp=sp_nth+sp_th
;	OPLOT,Eph,sp,linestyle=0
;	.comp psh_mpfit_stuff
;	psh_mpfit, Eph, sp
;	
; PSH 2004/02/06: HURRAY!!! I consistently get Eph_TO ~= 0.6* E_TO !!!!
;
; TO TEST MY METHOD OF FITTING...
;	Eph=6.5+DINDGEN(29)
;	psh_mpfit_th_nth, Eph, par
;	PLOT,Eto,par[2,*]/Eto,xtit='E!Dto!N',ytit='!7e!3!Dto,fit!N/E!Dto!N', tit='EM=1, kT=1.5, !7d!3=4'
;
;
; PSH ~2004/02/20: )_*^%#!&%... it looks like the whole stuff breaks down when Eto is near the thermal part....!!!
;

;-------------------------------------------------------------------------------
PRO psh_mpfit, Eph, sp, start_params=start_params	;EM,kT,Eph_to,gamma,F50
	IF NOT KEYWORD_SET(start_params) THEN start_params=[1,1,30,3,2.18]
	params = MPFITFUN('f_log10_vth_bpow', Eph, ALOG10(sp), ERR,WEIGHT=1d/ALOG10(sp)^2, start_params, YFIT=YFIT)
	PRINT,params
	OPLOT,Eph,10^YFIT,linestyle=2,thick=3
END
;-------------------------------------------------------------------------------


;-------------------------------------------------------------------------------
;the following tries to find by how much Epsilon_TO is bad when we add a thermal part to the non-thermal power-law...
PRO psh_mpfit_th_nth, Eph, par, EM=EM,kT=kT,d=d,A50=A50, FIXED=FIXED, Eto=Eto, LOUD=LOUD
	
	IF NOT EXIST(EM) THEN EM=1d	;0.05
	IF NOT EXIST(kT) THEN kT=1d
	IF NOT EXIST(d) THEN d=4d
	IF NOT EXIST(A50) THEN A50=1.295d33
	IF NOT EXIST(Eto) THEN Eto=3+DINDGEN(53)
	IF NOT KEYWORD_SET(LOUD) THEN LOUD=0

	sp_th=f_vth(Eph,[EM,kT])

	parinfo=REPLICATE({VALUE:0d,FIXED:0,LIMITED:[1,1],LIMITS:[0d,100]},5)
	parinfo[0].LIMITS=EM*[0.2,5]
	parinfo[1].LIMITS=kT*[0.5,2.]
	parinfo[2].LIMITS=[3,100]	;EphTO
	parinfo[3].LIMITS=[2,10]	;gamma: [2,10] ; (d-1)+[-0.3,0.3]
	parinfo[4].LIMITS=[0.1,10]*A50*BETA(d-2.,0.5)/(d-1.)/(d-2.)/1.3245d32	;F50
	
	IF KEYWORD_SET(FIXED) THEN BEGIN
		parinfo[0].FIXED=1
		parinfo[1].FIXED=1
	ENDIF

	FOR i=0,N_ELEMENTS(Eto)-1 DO BEGIN
		PRINT,"Cutoff/Turnover: "+strn(Eto[i])
		sp_nth=forward_spectrum_thick(/EARTH,Eph=Eph,el={delta:d,Eto:Eto[i],A50:A50},/HAUG,/BETHE)
		sp=sp_th+sp_nth
		IF LOUD THEN BEGIN
			PLOT,Eph,sp_nth,linestyle=1,/XLOG,/YLOG,xr=[1,100],yr=[0.001,1e6],title='E!DTO!N='+strn(Eto[i])+' EM='+strn(EM)+' kT='+strn(kT)+' !7d!3='+strn(d)+' A!D50!N='+strn(A50,format='(e10.1)')
			OPLOT,Eph,sp_th,linestyle=2
			OPLOT,Eph,sp
		ENDIF

		start_params=[EM,kT,Eto[i]>30,d-1,A50*BETA(d-2.,0.5)/(d-1.)/(d-2.)/1.3245d32]	

		x=Eph
		y=sp
		
		params = MPFITFUN('f_log10_vth_bpow', x, ALOG10(y), ERR,WEIGHT=1d/ALOG10(y)^2, start_params, YFIT=YFIT, parinfo=parinfo)
		PRINT,params
		IF LOUD THEN OPLOT,Eph,10^YFIT,linestyle=2,thick=3
		
		IF i EQ 0 THEN par=params ELSE par=[[par],[params]]			
	ENDFOR	
END
	; Eto=3+FINDGEN(53)
	; PLOT,Eto,par[2,*],xtit='E!Dto!N',ytit='!7e!3!Dto,fit!N', tit='EM='+strn(EM,format='(f10.1)')+', kT='+strn(kT,format='(f10.1)')+', !4d!3='+strn(d,format='(f10.1)')+', A!D50!N='+strn(A50,format='(e10.1)')+' fit: 1-100'
;-------------------------------------------------------------------------------
PRO psh_mpfit_do_fittings, out=out
	linecolors
	Eph=1+DINDGEN(100)
	Eto=3+DINDGEN(53)	;Eto=3+3*DINDGEN(17)
curEM=[0.01,0.03,0.1,0.3,1.,3.]
FOR i=0,N_ELEMENTS(curEM)-1 DO BEGIN
	psh_mpfit_th_nth, Eph, par, EM=curEM[i],kT=1d,d=5d,A50=1d30, FIXED=0, Eto=Eto, LOUD=0
	IF i EQ 0 THEN PLOT,Eto,par[2,*],xtit='E!Dto!N',ytit='!7e!3!Dto,fit!N' ELSE OPLOT,Eto,par[2,*],color=i
	IF i EQ 0 THEN out=par[2,*] ELSE out=[[[out]],[par[2,*]]]
ENDFOR
END
;-------------------------------------------------------------------------------
PRO psh_mpfit_findind_Etco_from_Ephto, infitsfile, outfitsfile, INTERACTIVE=INTERACTIVE
	Eph=1+DINDGEN(100)
	Eto=3+DINDGEN(53)	;Eto=3+3*DINDGEN(17)

;get the kT,EM,gamma, and F50 arrays...
	data=mrdfits(infitsfile,1)

IF KEYWORD_SET(INTERACTIVE) THEN BEGIN
	PRINT,"================MIN/MAX in this data======================"
	PRINT,'EM:'
	PRINT,minmax(data.fitpar[0,*])
	PRINT,'kT:'
	PRINT,minmax(data.fitpar[1,*])
	PRINT,'F50:'
	PRINT,minmax(data.fitpar[2,*])
	PRINT,'EphTO:'
	PRINT,minmax(data.fitpar[4,*])
	PRINT,'Gamma:'
	PRINT,minmax(data.fitpar[5,*])
	PRINT,"================================ OK ?: "
	tmp=GET_KBRD(1)
ENDIF
	
FOR i=0L,N_ELEMENTS(data.chi2)-1 DO BEGIN	
	PRINT,"--------------We're at data point # "+strn(i)+" of "+strn(N_ELEMENTS(data.chi2))
	g=data.fitpar[5,i]+1.
	psh_mpfit_th_nth, Eph, par, EM=data.fitpar[0,i],kT=data.fitpar[1,i],d=g,A50=data.fitpar[2,i]*1.3245d32*g*(g-1)/BETA(g-1,0.5), FIXED=0, Eto=Eto, LOUD=0
		;the returned par array is a [5,N] array, where N is N_ELEMENTS(Eto), and par[*,0]=[EM,kT,EphTO,g,F50]
	IF i EQ 0 THEN PLOT,Eto,par[2,*],xtit='E!Dto!N',ytit='!7e!3!Dto,fit!N' ELSE OPLOT,Eto,par[2,*],color=i
	tmp={EphTO:REFORM(par[2,*])}
	IF i EQ 0 THEN out=tmp ELSE out=[out,tmp]
ENDFOR
mwrfits,out,outfitsfile,/CREATE
END

