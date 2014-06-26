; by Pascal Saint-Hilaire, March 19th,2001
;	shilaire@astro.phys.ethz.ch OR psainth@hotmail.com

; find_arrmax.pro returns location of the maximum of input 2D-array

;EXAMPLE : find_arrmax,inarr,maxloc


pro find_arrmax,inarr,maxloc

S=size(inarr)
maxval=max(inarr,i)
ix= i MOD S[1]
iy= i/S[1]
maxloc=[ix,iy]
end
