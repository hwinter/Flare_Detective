;+
;
; NAME:
;        pg_rebin
;
; PURPOSE: 
;
;        spectrum rebinner, use flux density instead of total flux
;
; CALLING SEQUENCE:
;
;        out_spectrum=pg_rebin(edges1,spectrum,edges2)
;    
; 
; INPUTS:
;
;        edges1,spectrum: spectrum with its edges
;        edges2: wanted edges
;
; KEYWORDS:
;        
;                
; OUTPUT:
;        out_spectrum: rebinned spectrum
;
; CALLS:
;        ssw_rebinner
;
; EXAMPLE:
; 
;       ein=[[1,2],[2,3],[3,4],[4,5],[5,6]] 
;       sp=[10,8,6,4,2]
;       eout=[[1,4],[4,6]]
;       outsp=pg_rebin(ein,sp,eout)
; 
; VERSION:
;       
;       21-NOV-2003 written
;       12-JAN-2004 corrected a bug which caused incorrect
;       normalization if the input bin was different than 1.0
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION pg_rebin,edges1,spectrum,edges2

binwidth1=edges1[1,*]-edges1[0,*]
binwidth2=edges2[1,*]-edges2[0,*]

spectrum=spectrum*binwidth1; such that tha flux is normalized to each bin

ssw_rebinner,spectrum,edges1,out_spectrum,edges2

RETURN,out_spectrum/binwidth2

END












