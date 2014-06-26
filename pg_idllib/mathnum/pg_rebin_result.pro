;+
; NAME:
;      pg_rebin_result
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      transform a simulation result in a more manageable form
;      especially useful for large grids
;
; EXPLICATION:
;      
;
;
; CALLING SEQUENCE:
;      newda=pg_rebin_result(da [,npoints=npoints])
;
; INPUTS:
;      da: the diagnostic array output from the sim run 
;      npoints: number of points in the output structure,
;               default is 1000
; OUTPUTS:
;      
;      
; KEYWORDS:
;       
;
; HISTORY:
;       06-OCT-2005 written PG
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-
FUNCTION pg_rebin_result,da,npoints=npoints

   split_struct,da,2,s1,s2

   npoints=fcheck(npoints,1000)

   diagnostic=da.diagnostic
   
   energy=da.energy
   grid=diagnostic.grid
   partnumber=diagnostic.partnumber
   iter=diagnostic.iter
   tottime=diagnostic.tottemp

   el=n_elements(energy)
   nsum=round(el/npoints)>1L
   rebenergy=rebin(energy[0:el/nsum*nsum-1],el/nsum)
   rebgrid=  rebin(grid[0:el/nsum*nsum-1,*],el/nsum,(size(grid))[2])
   
   newst={iter:iter,partnumber:partnumber,grid:rebgrid,tottime:tottime, $
          energy:rebenergy}

   outda=join_struct(newst,s2)
   
   RETURN,outda
  
END




