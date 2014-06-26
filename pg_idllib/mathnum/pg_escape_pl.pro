;+
; NAME:
;      pg_cn_millerfix
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      this is a variable escape term to be implemented
;      by the acceleration model
;
;      ++++++++++ NOTATION: y=log_10(e)
;                           e= energy in units of mc^2
;
;
; CALLING SEQUENCE:
;     
;
; INPUTS:
;     egrid: energy of the points
;     grid:  values of the electron distribution function
;     tauescape: normalization term for the escape
;     ...  
;   
; OUTPUTS:
;      
;      
; KEYWORDS:
;
;
; HISTORY:
;       28-JUl-2005 written PG
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-

FUNCTION pg_escape_pl,egrid=egrid,grid=grid,tauescape=tauescape,plindex=plindex,dt=dt,th=th

     dgridescape=dt*(th/tauescape)*egrid^(plindex)*grid

     RETURN,dgridescape

END
