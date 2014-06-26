;+
; This routine plots the UV/EUV spectrum, given the F10 and F10AVG (SFU) values.
; have a look at http://www.ngdc.noaa.gov/stp/SOLAR/ftpsolaruv.html (3.b) for the whole story...
;
; F10 and F10AVG are the 10.7cm SFU fluxes
; EXAMPLE:
;	psh_uv_lines,w,f,lin,/QUIET,0,0
;	PLOT,w,f,/XLOG,/YLOG,xtit='[A]',ytit='[1E10 ph/s/m^2/A]'
;	psh_uv_lines,w,fa,lin,250,250
;	OPLOT,w,fa,color=127
;
;	fr=(fa-f)/f
;	PLOT,w,fr,/XLOG,/YLOG,xtit='[A]',ytit='Relative intensity increase (ACTIVE-QUIET/QUIET)'
;	ss=WHERE(fr GE 100)
;	PRINT,lin[ss]
;
; HISTORY:
;	PSH, 2005/02/16 written.
;-

PRO psh_uv_lines ,w,f,lin, QUIETSUN=QUIETSUN, F10, F10AVG

	psh_read_sc21refw, w,f, lin,k,c

	IF KEYWORD_SET(QUIETSUN) THEN RETURN 	;quiet Sun (Cycle 21)

	fa=f
	FOR i=0L,N_ELEMENTS(w)-1 DO BEGIN
		IF k[i] EQ 1 THEN r=0.0113*250 +0.496 ELSE r=0.625*250 -48.9
		fa[i]=f[i]+f[i]*(r*k[i]-1.)*c[i]
	ENDFOR
	f=fa
END
