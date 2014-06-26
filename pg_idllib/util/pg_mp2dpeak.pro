;+
; NAME:
;       pg_mp2dpeak
;
; PURPOSE: 
;       returns a 2-dimensional gaussian distribution     
;       
;       GAUSSIAN      A(0) + A(1)*exp(-0.5*u)
;       u = ( (x-A(4))/A(2) )^2 + ( (y-A(5))/A(3) )^2
;       where x and y are cartesian coordinates in a rotated
;       coordinate system
;   
;       The returned parameter array elements have the following meanings:
;
;       A(0)   Constant baseline level
;       A(1)   Peak value
;       A(2)   Peak half-width (x) -- gaussian sigma
;       A(3)   Peak half-width (y) -- gaussian sigma
;       A(4)   Peak centroid (x)
;       A(5)   Peak centroid (y)
;       A(6)   Rotation angle (radians) 
;
;
; HISTORY
;       written by Craig B. Markwardt, NASA/GSFC Code 662, Greenbelt, MD 20770
;       craigm@lheamail.gsfc.nasa.gov
;   
;       made a standalone version P.G. 10-SEP-2004                
;       
;
;-

; Compute the "u" value = (x/a)^2 + (y/b)^2 with optional rotation
function pg_mpfit2dpeak_u, x, y, p, tilt=tilt

  widx  = abs(p(2)) > 1e-20 & widy  = abs(p(3)) > 1e-20 
  xp    = x-p(4)            & yp    = y-p(5)
  theta = p(6)

  if keyword_set(tilt) AND theta NE 0 then begin
      c  = cos(theta) & s  = sin(theta)
      return, ( (xp * (c/widx) - yp * (s/widx))^2 + $
                (xp * (s/widy) + yp * (c/widy))^2 )
  endif else begin
      return, (xp/widx)^2 + (yp/widy)^2
  endelse

end

; Gaussian Function
function pg_mp2dpeak, x, y, p
  sz = size(x)
  if sz(sz(0)+1) EQ 5 then smax = 26D else smax = 13.

  u = pg_mpfit2dpeak_u(x, y, p, /tilt)
  mask = u LT (smax^2)  ;; Prevents floating underflow
  return, p(0) + p(1) * mask * exp(-0.5 * u * mask)
end
