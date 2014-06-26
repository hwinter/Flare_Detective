;+
; NAME:
;
; pg_readephemfiles
;
; PURPOSE:
;
; read epemerides files
;
; CATEGORY:
;
;
;
; CALLING SEQUENCE:
;
;
;
; INPUTS:
;
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;-


FUNCTION pg_readephemfiles,infile


file=fcheck(infile,'~/varie/jup.txt')

dd=(rd_ascii(file))[3:*]

time=anytim(strmid(dd,0,20))

ras=strmid(dd,23,11)  
coord_ra=float(strmid(ras,0,2))*3600.0+float(strmid(ras,2,3))*60.0+float(strmid(ras,5,6))


ind=where(coord_ra GT 12.0*3600.0,ind)
coord_ra[ind]=coord_ra[ind]-24.0*3600.0

decs=strmid(dd,34,18)
;one=sign(coord_dec*0+1,coord_dec)

sign=strmid(decs,1,1)

indplus =where(sign EQ '+',countplus)
indminus=where(sign EQ '-',countminus)

one=replicate(1,n_elements(decs))
IF countplus GT 0 THEN one[indplus]=1.0
IF countminus GT 0 THEN one[indminus]=-1.0


coord_dec=float(strmid(decs,0,4))*3600.0+one*float(strmid(decs,4,3))*60.0+one*float(strmid(decs,8,4))
;one=sign(coord_dec*0+1,coord_dec+0.01)
;coord_dec*=3600.0
;coord_dec+=one*float(strmid(decs,4,3))*60.0+one*float(strmid(decs,8,4))

plot,coord_dec

plot,coord_ra,coord_dec

END 


