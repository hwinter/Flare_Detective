;+
; NAME:
;
; pg_binhisto
;
; PURPOSE:
;
; put an array x of data into an histogram, with the condition
; that the number of elements in each bin is constant 
;
; CATEGORY:
;
; various utilities
;
; CALLING SEQUENCE:
;
; 
;
; INPUTS:
;
; x: original data
; n: number of elemnts per bin
;
; OPTIONAL INPUTS:
;
;
; 
; KEYWORD PARAMETERS:
;
;
;
;
; OUTPUT:
;
; x_edges: edges of bins
; histo: histogram
; ri: reverse indices
;
; NONE
;
; OPTIONAL OUTPUTS:
;
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
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
;
; 07-SEP-2004 written P.G.
;
;-

;.comp ~/pand_rapp_idl/util/pg_plot_histo.pro

PRO pg_binhisto,x,n,x_edges=x_edges,histo=histo,ri=ri

nx=n_elements(x)
nn=round(n)
 
IF nx LE nn THEN BEGIN
ENDIF


nbins= nx / nn
nmod = nx MOD nn

IF nmod GT float(n)/2. THEN nbins=nbins+1

sortind=sort(x)
xx=x[sortind]

x_edges=dblarr(2,nbins)

ri=lonarr(nbins+nx+1)
histo=lonarr(nbins)

FOR i=0,nbins-2 DO BEGIN
   x_edges[*,i]=xx[[i*nn,(i+1)*nn-1]]
   histo[i]=nn
   ri[i]=1+nbins+i*nn
   ri[ri[i]:ri[i]+nn-1]=sortind[i*nn:(i+1)*nn-1]
ENDFOR

x_edges[*,nbins-1]=xx[[(nbins-1)*nn,nx-1]]
histo[nbins-1]=nx-(nbins-1)*nn
ri[nbins-1]=1+nbins+(nbins-1)*nn
ri[nbins]=n_elements(ri)
ri[ri[nbins-1]:ri[nbins]-1]=sortind[(nbins-1)*nn:nx-1]


END
