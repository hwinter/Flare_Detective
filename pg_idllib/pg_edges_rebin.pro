;+
;
; NAME:
;        pg_edges_rebin
;
; PURPOSE: 
;
;        input a series of edges --> rebin them above E with a factor N
;
; CALLING SEQUENCE:
;
;        out_edges=pg_edges_rebin(edges,e,n)
;    
; 
; INPUTS:
;        edges: energy edges (2xN)
;        e: lower energy
;        n: rebin factor
;
; KEYWORDS:
;        
;                
; OUTPUT:
;        out_edges: new edges
;
; CALLS:
;        
;
; EXAMPLE:
; 
;       
; 
; VERSION:
;       
;       21-NOV-2003 written
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION pg_edges_rebin,edges,e,n

ind=where(edges[0,*] GE e,nreb)

IF nreb EQ 0 THEN RETURN, edges

newbins=nreb/round(n)
rest=nreb-newbins*round(n)

outedges=fltarr(2,n_elements(edges)/2-nreb+newbins)
outedges[*,0:n_elements(edges)/2-nreb-1]=edges[*,0:n_elements(edges)/2-nreb-1]

IF newbins GT 0 THEN BEGIN
    outedges[0,n_elements(edges)/2-nreb:n_elements(edges)/2-nreb+newbins-1]=$
      edges[0,n_elements(edges)/2-nreb+findgen(newbins)*round(n)]
    outedges[1,n_elements(edges)/2-nreb:n_elements(edges)/2-nreb+newbins-1]=$
      edges[1,n_elements(edges)/2-nreb+findgen(newbins)*round(n)+(n-1)]
ENDIF

RETURN,outedges

END












