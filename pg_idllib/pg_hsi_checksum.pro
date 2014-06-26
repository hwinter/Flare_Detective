;+
; NAME:
;      pg_hsi_checksum
;
; PURPOSE: 
;      check the HSI data archive checksums
;
; CALLING SEQUENCE:
;      
;
; INPUTS:
;      
;
; KEYWORDS:
;      
;
; OUTPUT:
;     
;
; COMMENT:
;      
;
; EXAMPLE:   
;  
;
;
; VERSION:
;       18-NOV-2005 written PG
;
; AUTHOR:
;       pgrigis@astro.phys.ethz.ch
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

PRO pg_hsi_checksum

dir='/global/pandora/home/hedcdata/'

file1=dir+'checksums2003.txt'
file2=dir+'kimchecksum2003.txt'

readcol,file1,md5sum1,fname1,delimiter=' ',format='A,A'
readcol,file2,md5sum2,fname2,delimiter=' ',format='A,A'

ind1=sort(fname1)
ind2=sort(fname2)

fname1=fname1[ind1]
fname2=fname2[ind2]
md5sum1=md5sum1[ind1]
md5sum2=md5sum2[ind2]

res=where(md5sum1 NE md5sum2)

print,fname1[res]

END
