;+
; PROJECT:
;	SDAC
; NAME:
;	Model_components
;
; PURPOSE:
;	This procedure provides information to the routines under SPEX
;	on the standard model functions available.
;
; CATEGORY:
;	SPEX
;
; CALLING SEQUENCE:
;	norm_par = MODEL_COMPONENTS(F_model [,Number_param, Param_ranges, $
;					      Free, Apar])
;
; CALLED BY: Spex_spec_plot in Spex directory
;
; CALLS TO:
;	none
; INPUTS:
;       f_model - string with model name, e.g. 'f_vth_bpow'
;
; OPTIONAL KEYWORD INPUTS:
;	EXIST- If set/unset and function defined, return 1/0.
;
; OUTPUTS:
;       result, norm_par, the index of the normalizing parameters of all
;			  the independent components of f_model
;
; OPTIONAL OUTPUTS:
;	number_param - number of adjustable parameters in the model
;	param_ranges - (number_param,2) - default lo and hi parameter bounds
;	free         - default free/fix, 1 or 0
;	apar         - default fitting parameters
; COMMON BLOCKS
;	model_components
;
; RESTRICTIONS:
;	if model is not predefined, then 0 is returned.
;	All defined models must take energy arguments defined on hi
;	and low edges, 2XN.
;	They may actually only use the mean energy, but they must accept 2XN.
;
; PROCEDURE:
;	scans a predetermined list to match with model name
;
; MODIFICATION HISTORY:
;	ras, 8-aug-94
;	ras, 8-mar-95, added f_multi_spec
;	ras, 1-nov-95, added f_3pow- triple power-law
;	Version 4, richard.schwartz@gsfc.nasa.gov, 13-aug-1997, added f_con_lin
;	Version 5, richard.schwartz@gsfc.nasa.gov, 11-sep-1997,
;	revised f_con_lin
;	Version 6, richard.schwartz@gsfc.nasa.gov, 28-jan-1998,
;       added comments on energy
;	arguments to all defined functions and keyword, NOREGISTER.
;	Version 7, richard.schwartz@gsfc.nasa.gov, 11-jan-2001, allow
;	any number of Gaussians in f_bpow_nline.  f_bpow_nline also modified.
;	Added f_pow
;       Paul Bilodeau, 23-July-2002, added support for f_vth_thick and
;         f_bpow_thick functions.
;       Paul Bilodeau, 21-aug-2002, added support for f_bpos_nline.
;       Paul Bilodeau, 30-sep-2002, changed defaults for f_nuclear and
;         f_bpos_nline to reflect change in definition of parameters.
;       Paul Bilodeau, 04-nov-2002, changed f_nuclear code to support
;         variable 2.223 MeV line centroid and width.
;       Paul Bilodeau, 20-nov-2002, added support for f_vth_thin and f_vth_ion.
;       Paul Bilodeau, 10-jan-2003, changed lower limits on 3rd and
;         5th (counting from 0) parameters in f_vth_thin and f_vth_thick
;         from 1.0 to 1.1.
;		Richard.schwartz@gsfc.nasa.gov, 26-jun-2003, added F_VTHC_BPOW_NLINE
;		Linhui Sui, 21-Sep-2003, added support for f_mth_pow_bpow and f_mth_exp_bpow
;
;	PSH, 2003/10/22 : added f_vth_pow_cutoff and f_vth_pow_turnover
;	PSH, 2004/07/08 : added f_2th_pow_c and f_2th_pow_t
;
;-
FUNCTION model_components, f_model, $
                           number_param, $
                           param_ranges, $
                           free, $
                           apar, $
                           exist=exist, $
                           nline = nline, $
                           _EXTRA=_extra

COMMON model_components, out, models, nparam, prange, dfree, dapar


IF n_elements(out) EQ 0 OR $
  keyword_set(nline) OR $
  Keyword_Set( _extra ) THEN BEGIN

    nline  = fcheck( nline, 8 ) > 1
    models = [ $
              'f_vth_bpow', $
              'f_2therm_pow', $
              'f_vth', $
              'f_nuclear', $
              'f_th_nt', $
              'f_multi_spec', $
              'f_bpow_nline', $
              'f_3pow', $
              'f_con_lin', $
              'f_pow', $
              'f_bpow_thick', $
              'f_vth_thick', $
              'f_vth_thin', $
              'f_bpos_nline', $
              'f_vth_ion',$
              'f_vthc_bpow_nline', $
              'f_mth_pow_bpow', $
              'f_mth_exp_bpow', $
              'f_vth_pow_cutoff', $
              'f_vth_pow_turnover', $
              'f_2th_pow_c', $
              'f_2th_pow_t' $
             ]

    ; How many nuclear line templates do we have?
    tmp = line_complex( $
            N_LINE=n_ltemp, $
            ERR_CODE=err_code, $
            ERR_MSG=err_msg, $
            _EXTRA=_extra )

    IF err_code THEN MESSAGE, err_msg, /CONTINUE

    ;; ras, 3-oct-2001, f_pow
    ;; Paul Bilodeau, 8-Feb-2002, f_nuclear with positronium
    nparam = [ $
              ;; f_vth_bpow
              6, $
              ;; f_2therm_pow
              6, $
              ;; f_vth
              2, $
              ;; f_nuclear
              12+n_ltemp, $
              ;; f_th_nt
              5, $
              ;; f_multi_spec
              10, $
              ;; f_bpow_nline
              4 + 3 * nline, $
              ;; f_3pow
              6, $
              ;; f_con_lin
              8, $
              ;; f_pow
              2, $
              ;; f_bpow_thick
              6, $
              ;; f_vth_thick
              8, $
              ;; f_vth_thin
              8, $
              ;; f_bpos_nline
              8 + 3 * nline, $
              ;; f_vth_ion
              5 ,$
              ;; F_VTHC_BPOW_NLINE
              6 + 3 * nline, $
              ;; f_mth_pow_bpow
              8, $
              ;; f_mth_exp_bpow
              8, $
	      ;; f_vth_pow_cutoff
	      5, $
	      ;; f_vth_pow_turnover
	      5, $
	      ;; f_2th_pow_c
	      7, $
	      ;; f_2th_pow_t
	      7 $
	      ]

    ;allow up to 10 more registered models for now
    prange = fltarr(max(nparam),2,8+n_elements(models))

    ;; default lower bound
    prange(*,0,*) = 1e-20

    ;; default upper bound
    prange(*,1,*) = 1e20

    ;; f_vth_bpow
    prange(0,0,0) = [1e-20,.5,1e-20,1.,10.,  1]
    prange(0,1,0) = [1e20,50.,1e20,10.,1000.,10.]

    ;; f_2therm_pow
    prange(0,0,1) = [1e-20,.5,1e-20,1.,1e-20,1.]
    prange(0,1,1) = [1e20,5.,1e20,50.,1e20,10.]

    ;; f_vth
    prange(0,0,2) = [1e-20,.5]
    prange(0,1,2) = [1e20,50.]

    ; f_nuclear parameter ranges depend on the number of line templates
    prange(0,0,3) = [ 1e-20, $
                      ;; positronium parameters
                      1e-20+fltarr(2), 1e-5, 509, $
                      ;; 2.223 MeV line parameters
                      1e-20, 2220, 1e-5*2.*Sqrt( 2*Alog(2) ), $
                      ;; Line complex parameters and power law normalization
                      1e-20+fltarr(n_ltemp+1), $
                      1., 10., 1. ]
    prange(0,1,3) = [ 1e20, $
                      1e20+fltarr(2), 2.5e2, 513, $
                      1e20, 2226, 1e1*2.*Sqrt( 2*Alog(2) ), $
                      1e20+fltarr(n_ltemp+1), $
                      10., 1000., 10. ]

    prange(0,0,4) = fltarr(5)+1e-20
    prange(0,1,4) = fltarr(5)+1e20
    prange(0,0,5) = [1e-20,.5,1e-20,1.,1e-20,1.,10.,  1.,5.,1.]
    prange(0,1,5) = [1e20,5., 1e20,50.,1e20,10.,1000.,10.,30.,2.5]

    ;; F_BPOW_NLINE
    ;; Gaussian line parameters are fluence (ph/cm2/s), centroid in keV,
    ;; sigma in keV
    prange(0,0,6) = [1.e-20, 0.5, 10., 0.5,  $
      ([1e-5, 1., 1.0]#(fltarr(1,nline)+1.))(*)]
    prange(0,1,6) = [1.e20,  12, 10000., 12, $
      ([1e5, 1.e4, 400.]#(fltarr(1,nline)+1.))(*)]

    ;; norm,pl1,break1,pl2,break2,pl3
    prange(0,0,7) = [1e-20,.5, 1., .5, 10., .5 ]
    prange(0,1,7) = [1e20, 12.,2e4,12.,2e4, 12.]
    prange(0,0,8) = [1e-20,.5,.2+fltarr(4),fltarr(2) ]
    prange(0,1,8) = [1e20,5.,3+fltarr(4), 0.01, fltarr(2)]

    ;; ras, 3-oct-2001 f_pow
    prange(0,0,9) = [1e-20, 1.0]
    prange(0,1,9) = [1e20, 12.0]

    ;; Paul Bilodeau, 19-Jul-2002 f_bpow_thick
    prange(0,0,10) = [ 1e15,  1e0, 1e0, 1e0, 1e0, 1e2  ]
    prange(0,1,10) = [ 1e35,  20,  1e5, 20,  1e3, 1e7 ]

    ;; Paul Bilodeau, 19-Jul-2002 f_vth_thick
    prange(0,0,11) = [ 1e-10, 5e-1, 1e-10,  1.1, 1e0, 1.1, 1e0, 1e2  ]
    prange(0,1,11) = [ 1e10, 5e1,  1e10,  20, 1e5, 20,  1e3, 1e7 ]

    ;; Paul Bilodeau, 20-nov-2002 f_vth_thin
    prange(0,0,12) = [ 1e-10, 5e-1, 1e-10,  1.1, 1e0, 1.1, 1e0, 1e2 ]
    prange(0,1,12) = [ 1e10,  5e1,  1e15,  20,  1e5, 20,  1e3, 1e7 ]

    ;; Paul Bilodeau, 21-aug-2002 f_bpos_nline
    prange(0,0,13) = [ 1.e-20, 0.5, 1e1, 0.5, 1e-20, 1e-20, 1e-5, 509., $
                     ([1e-5, 1., 1.0]#(fltarr(1,nline)+1.))(*) ]
    prange(0,1,13) = [ 1.e20,  12,  1e5, 12,  1e20,  1e20, 1e5,  513., $
                     ([1e5, 1.e4, 400.]#(fltarr(1,nline)+1.))(*) ]

    ;; f_vth_ion
    prange(0,0,14) = [ 1e-10, 5e-2, 1e-20, 2.0002, 1e0  ]
    prange(0,1,14) = [ 1e10,  5e2,  1e26,  20,     5e4 ]

	;; F_VTHC_BPOW_NLINE
    ;; Gaussian line parameters are fluence (ph/cm2/s), centroid in keV,
    ;; sigma in keV
    prange(0,0,15) = [1.e-20, 0.5, 1.e-20, 0.5, 10., 0.5,  $
      ([1e-5, 1., 1.0]#(fltarr(1,nline)+1.))(*)]
    prange(0,1,15) = [1.e20, 50., 1.e20,  12, 10000., 12, $
      ([1e5, 1.e4, 400.]#(fltarr(1,nline)+1.))(*)]

	;; f_mth_pow_bpow
    prange(0,0,16) = [ 1e-10, 0.5, 1e0,  1e-2, 1e-20, 1e0, 1e1, 1e0 ]
    prange(0,1,16) = [ 1e2,  4.0,  1e4,  1e2, 1e20,  1e1, 1e3, 1e1 ]

	;; f_mth_exp_bpow
    prange(0,0,17) = [ 1e-10, 0.5, 1e0,  1e-2, 1e-20, 1e0, 1e1, 1e0 ]
    prange(0,1,17) = [ 1e2,  4.0,  1e4,  1e2, 1e20,  1e1, 1e3, 1e1 ]

    ;; f_vth_pow_cutoff
    prange(0,0,18) = [1e-5,	.6,	1e-10,	1.,	0.1]
    prange(0,1,18) = [1e5,50.,	100,	1e10,	20.,	500.]

    ;; f_vth_pow_turnover
    prange(0,0,19) = [1e-5,	.6,	1e-10,	1.,	0.1]
    prange(0,1,19) = [1e5,	100,	1e10,	20.,	500.]

    ;; f_2th_pow_c
    prange(0,0,20) = [1e-5,	.6,	1e-5,		.6,	1e-10,		1.,	0.1]
    prange(0,1,20) = [1e5,50.,	100,	1e5,50.,	100,	1e10,	20.,	500.]

    ;; f_2th_pow_t
    prange(0,0,21) = [1e-5,	.6,	1e-5,	.6,	1e-10,	1.,	0.1]
    prange(0,1,21) = [1e5,	100,	1e5,	100,	1e10,	20.,	500.]


    ;; ras, 3-oct-2001
    dfree = intarr(max(nparam),10+n_elements(models))

    ;; default free parameters for newly registered functions
    dfree(0:1,*) = 1
    dfree(0,0) = [0,0,1,1,0,0]
    dfree(0,1) = [0,0,1,1,0,0]
    dfree(0,2) = [1,1]
    dfree(0,3) = intarr(12+n_ltemp)+1
    dfree(0,4) = [0,0,1,1,0]
    dfree(0,5) = [0,0,0,0,1,1,0,0,0,0]
    dfree(0,6) = [1,1,0,0,intarr(3*nline)]
    dfree(0,7) = [1,1,0,0,0,0]
    dfree(0,8) = [1,1,0,0,0,0,0,0]

    ;; ras, 3-oct-2001, f_pow
    dfree(0,9) = [1,1]

    ;; Paul Bilodeau, 19-Jul-2002
    dfree(0,10) = [1,1,0,1,0,0]

    ;; f_vth_thick
    dfree(0,11) = [1,1,1,1,0,0,0,0]

    ;; f_vth_thin
    dfree(0,12) = [1,1,1,1,0,1,0,0]

    ;; f_bpos_nline
    dfree(0,13) = Intarr(8 + 3*nline) + 1

    ;; f_vth_thin - not really necessary, but useful as a reminder
    dfree(0,14) = Intarr(5) + 1

	;; f_vthc_bpow_nline
	dfree(0,15) = [1,1,0,0,0,0,1,0,0,  Intarr(3*(nline-1)) + 0]

	;; f_mth_pow_bpow
    dfree(0,16) = [1,0,1,1,1,1,0,0]

	;; f_mth_exp_bpow
    dfree(0,17) = [1,0,1,1,1,1,0,0]

	;; f_vth_pow_cutoff
    dfree(0,18) = [1,1,1,1,1]

	;; f_vth_pow_turnover
    dfree(0,19) = [1,1,1,1,1]

	;; f_2th_pow_c
    dfree(0,18) = [1,1,1,1,1,1,1]

	;; f_2th_pow_t
    dfree(0,19) = [1,1,1,1,1,1,1]


    dapar = fltarr(max(nparam),10+n_elements(models))

    ;; default  parameter values for newly registered functions
    dapar = dapar + 1.
    dapar(0,0) = [0,.5,1,4.,400.,5.]
    dapar(0,1) = [.1,.5,1.,2.,.1,4.]
    dapar(0,2) = [1.,2.]

    ;; f_nuclear defaults
    dapar(0,3) = [1., $
                  1e-2, 1e-2, 1., 511., $
                  ;; 2.223 MeV line shoudl be quite narrow.
                  1., 2223, 1e-2*2.*Sqrt( 2*Alog(2) ), $
                  1+fltarr(n_ltemp+1), 4, 4e2, 5]

    dapar(0,4) = [.01,3.5,30.,35.,50.]
    dapar(0,5) = [0,1.,0,2.,.5,4.,100.,5.,10.,1.5]
    dapar(0,6) = [1., 3., 1e4, 4., 1., 10., 1., $
      ([0., 30., 1.]#(fltarr(1,nline-1)+1.))(*)]
    ;; norm,pl1,break1,pl2,break2,pl3
    dapar(0,7) = [1., 3.,30.,4.,400.,2.]
    dapar(0,8) = [.01,.8,1.0,1.0,1.0,1.0,fltarr(2)]
    ;; ras, 3-oct-2001, f_pow
    dapar(0,9) = [1.0, 4.0]

    ;; f_bremthick
    dapar(0,10) = [1e27, 4e0, 1e2, 6e0, 1e1, 3.2e4]

    ;; f_vth_thick
    dapar(0,11) = [1e0, 1e0, 1e0, 4e0, 6e2, 6e0, 1e1, 3.2e4]

    ;; f_vth_thin
    dapar(0,12) = [1e0, 1e0,  1e2,  2e0, 1e2, 2e0, 1e1, 3.2e4]

    ;; f_bpos_nline - defaults per Gerry Share's recommendations
    dapar(0,13) = [1., 4., 4e2, 5., 1e-2, 1e-2, 1., 511., $
                   ([0., 30., 1.]#(fltarr(1,nline)+1.))(*)]

    ;; f_vth_ion
    dapar(0,14) = [ 1e0,1e0, 1e6, 5, 35 ]

	;; f_vthc_bpow_nline
	dapar(0,15) = [.1,1.0, .0, 4, 40., 6, $
					[1e4,6.7, 0.1], $
					([0., 30., 1.]#(fltarr(1,nline-1)+1.))(*)]

	;; f_mth_pow_bpow
    dapar(0,16) = [ 0.005, 0.5, 4e0, 1e0, 1.0e0, 4e0 ,4e2, 5e0 ]

	;; f_mth_exp_bpow
    dapar(0,17) = [ 0.005, 0.5, 4e0, 1e0, 1.0e0, 4e0 ,4e2, 5e0 ]

	;; f_vth_pow_cutoff	
    dapar(0,18) = [ 1., 1., 1., 3.5, 20]

	;; f_vth_pow_turnover	
    dapar(0,19) = [ 1., 1., 1., 3.5, 20]

	;; f_2th_pow_c
    dapar(0,20) = [ 1.,1.,1., 1., 1., 3.5, 20]

	;; f_2th_pow_t
    dapar(0,21) = [ 1.,1.,1., 1., 1., 3.5, 20]


    ;; up to 10 components per model
    out = intarr( (11 > 1+nline) > (5+n_ltemp), n_elements(models))

;
;	The array "OUT" describes the independently normalized components of
;	the model function.  The first parameter says how many there are,
;	and the succeeding numbers are the indices of the normalization
;	parameters.
;
    ;; f_vth_bpow
    out(0,0) = [2,0,2]

    ;; f_2therm_pow
    out(0,1) = [3,0,2,4]

    ;; f_vth
    out(0,2) = [1,0]

    ;; f_nuclear
    out(0,3) = n_ltemp GT 0 ? $
      [5+n_ltemp,0,1,2,5,indgen(n_ltemp)+8,n_ltemp+8] : $
      [5,0,1,2,5,8]

    ;; f_th_nt
    out(0,4) = [2,0,2]

    ;; f_multi_spec
    out(0,5) = [3,0,2,4]

    ;; f_bpow_nline
    out(0,6) = [1+nline,0,4+indgen(nline)*3]

    ;; f_3pow
    out(0,7) = [1,0]

    ;; f_con_lin Mewe continuum + line with variable abundances for
    ;; Fe, Si, S, Ca.
    out(0,8) = [1,0]

    ;; two thicknesses in cm for attenuation
    ;; ras, 3-oct-2001, f_pow
    out(0,9) = [1,0]

    ;; f_bpow_thick
    out(0,10) = [1,0]

    ;; f_vth_thick
    out(0,11) = [2,0,2]

    ;; f_vth_thin
    out(0,12) = [2,0,2]

    ;; f_bpos_nline
    out(0,13) = [ 3+nline, 0, 4, 5, 8+indgen(nline)*3 ]

    ;; f_vth_ion
    out(0,14) = [2,0,2]

	;; f_vthc_nline
	out(0,15) = [ 2+nline, 0, 2, 6+indgen(nline)*3 ]

	;; f_mth_pow_bpow
    out(0,16) = [2,0,4]

	;; f_mth_exp_bpow
    out(0,17) = [2,0,4]

	;; f_vth_pow_cutoff
    out[0,18] = [2,0,2]

	;; f_vth_pow_turnover
    out[0,19] = [2,0,2]

	;; f_2th_pow_c
    out[0,20] = [3,0,2,4]

	;; f_2th_pow_t
    out[0,21] = [3,0,2,4]
ENDIF

result = intarr(1)
which = where( strlowcase(f_model) eq models, ncount)

IF Keyword_Set(exist) THEN RETURN, ncount<1

IF ncount EQ 0  THEN BEGIN
    message = [ 'The model function, '+f_model+ $
      ' has not been registered in model_components.pro',$
      'Please enter the number of adjustable fitting parameters, ',$
      'number of independent components and their respective positions in ',$
      'the parameter lists.  As an example, the model f_vth_bpow, ' + $
      'thermal plus broken power-law,', $
      'has 6 adjustable fitting parameters', $
      "and has two independent components with each one's normalization " + $
      "parameter at 0 and 2."]
    printx,string(/print,message)
    n_parameters = 1
    n_components = 1
    IF f_use_widget(/test) THEN BEGIN
        option_changer,'Number of Parameters','n_parameters', $
                       direct=n_parameters,message=message,digit=2,/snu
        option_changer,'Number of Components','n_components', $
                       direct=n_components,message=message,digit=2,/snu
        out_sub = intarr(n_components)
        option_changer,'Position of Normalization Parameters','out_sub', $
                       direct=out_sub
	n_parameters=FIX(n_parameters)
	n_components=FIX(n_components)
	out_sub=REFORM(FIX(out_sub))
    ENDIF ELSE BEGIN
        print,message
        n_parameters = 1
        n_components=1
        read, prompt='Enter number of fitting parameters in model: ', $
              n_parameters
        read, prompt='Enter number of independent components in model: ', $
              n_components
        out_sub = intarr(n_components)
        read, prompt='Enter position of '+strtrim(n_components,2)+ $
              ' normalization parameters in model: ',out_sub
    ENDELSE
    out_line = fltarr(N_ELEMENTS(out[*,0]),1)
    out_line(0) = [n_components,out_sub]
    out = [[out],[out_line]]
    models = [models, strlowcase(f_model)]
    which = n_elements(models) -1
    nparam = [nparam, n_parameters]
ENDIF

which = which(0)
result = out(1:out(0,which),which)
;Also return number_param, param_ranges
number_param = nparam(which)
param_ranges = prange(0:number_param-1, *, which)
free = dfree(*,which)
apar = dapar(*,which)

RETURN, result

END
