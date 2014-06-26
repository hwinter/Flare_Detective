;+
; NAME:
;      pg_plot_deltaflux
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      plot spectral indices & fluxes for photon spectra coming
;      computed from the ismulation electron spectra
;
; EXPLICATION:
;      
;
;
; CALLING SEQUENCE:
;     
;
; INPUTS:
;       
;     
; OUTPUTS:
;      
;      
; KEYWORDS:
;       
;
; HISTORY:
;       25-NOV-2005 written PG
;       10-JAN-2006 separated inner from outer part as a test toward
;       greater modularity (goal: should be possible to call it from
;       routine pg_cn_dooverviewplot) & others
;       11-JAN-2006 files separated -> now only needed for indrange culling
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;-



PRO pg_plot_deltaflux,res,indrange,thin=thin,thick=thick,xrange=xrange


   spindex_thin=res.spindex_thin[indrange[0]:indrange[1]]
   spindex_thick=res.spindex_thick[indrange[0]:indrange[1]]
   fnorm_thin=res.fnorm_thin[indrange[0]:indrange[1]]
   fnorm_thick=res.fnorm_thick[indrange[0]:indrange[1]]

   enorm=res.enorm

   simpar=res.simpar[indrange[0]]

   pg_plot_deltaflux_inner,res=res,spindex_thin=spindex_thin,spindex_thick=spindex_thick $
                          ,fnorm_thin=fnorm_thin,fnorm_thick=fnorm_thick,simpar=simpar $
                          ,enorm=enorm,thin=thin,thick=thick,xrange=xrange,circlesize=1.


END




