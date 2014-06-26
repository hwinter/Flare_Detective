;+
;
; NAME:
;        pg_brownmodel
;
; PURPOSE: 
;        return the flux for the stochastic acceleration model
;        proposed by brown and loran, 1984
;        It is given in a format suitable for use with mpfitfun
;
; CALLING SEQUENCE:
;
;        out=pg_brownmodel(x,par)
;
; INPUTS:
;
;        x: spectral index
;        par: array with:
;                   par[0]: C     ;normalization factor
;                   par[1]: alpha ;parameter depending on n*L of the
;                                  acceleration plasma slab 
; KEYWORDS:
;        log: set the output to log flux instead of flux
;
; OUTPUT:
;        out: flux
;
; KEYWORDS:
;        
;        
; EXAMPLE:
;
;        c=1.4e4
;        alpha=0.1
;        x=findgen(1000)/100+0.1
;        par=[c,alpha]
;        res=pg_brownmodel(x,par)
;        plot,x,res,/ylog,xrange=[1.5,8],/xstyle
;
; VERSION:
;
;        01-OCT-2003 written
;        
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION pg_brownmodel,x,par,log=log,fluxatthisenergy=fluxatthisenergy

c=par[0]
alpha=par[1]

logf=alog10(c)-2*alog10((x-1)*(x+1.5))+2*alog10(0.5+0.5*sqrt(1+4*alpha*(x+1.5)))

IF keyword_set(fluxatthisenergy) THEN logf=alog10(x/fluxatthisenergy)+logf

IF NOT keyword_set(log) THEN logf=10^logf


RETURN,logf

END

