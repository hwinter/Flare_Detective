;+
; NAME:
;
; pg_get_diagonal
;
; PURPOSE:
;
; retrieves the diagonal element of matrix (does not need to be a
; squre matrix). The keyword n_width allow to get the total of the
; diagonal and its next n_width lines
;
; CATEGORY:
;
; various utilities
;
; CALLING SEQUENCE:
;
; diago=pg_get_diagonal(a,n_width=n,...)
;
; INPUTS:
;
; a: the input array
;
; OPTIONAL INPUTS:
;
; n_width: number of lines (symmetric around the diagonal), default:1
;
; KEYWORD PARAMETERS:
;
;
; OUTPUT:
;
; NONE
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
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 16-JAN-2004 written P.G.
; I realized I don't really need it this way --> so I'll stop for now
; 
;
;-

PRO pg_plot_histo,a,n_width=n_width

n_width=fcheck(n_width,1)

siz_a=size(a)

nx=siz_a[1]
ny=siz_a[2]

n=min([nx,ny])
a_type=siz_a[n_elements(siz_a)-2]


diago=make_array(n,type=a_type)

FOR i=0,n DO BEGIN

list=[[findgen(n_width)]]
   
ENDFOR
 

END
