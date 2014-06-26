;+
; NAME:
;      pg_reformstruct
;
; PURPOSE: 
;      changes a structure containing array fields to an array of identical
;      structures containing scalar fields
;
; CALLING SEQUENCE:
;      out_st=pg_reformstruct(in_st)
;
; INPUTS:
;      in_st: a structure containing n fields, each one being an m element
;      array 
;
; OUTPUT:
;      out_st: an array of m structures, each containing n scalar fields
;       
;
; COMMENT:
;      
;
; EXAMPLE:   
;
;
; VERSION:
;       30-OCT-2006 written pg
;
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;-


FUNCTION pg_reformstruct,in_st

  intype=size(in_st,/type)

  IF intype NE 8 THEN BEGIN 
     print,'Please input a structure'
     RETURN,-1
  ENDIF

  nel=n_elements(in_st)

  IF nel NE 1 THEN BEGIN 
     print,'Array of structures is not a valid input'
     RETURN,-1
  ENDIF

  tagnames=tag_names(in_st)
  n=n_elements(tagnames)

  thisdata=in_st.(n-1)
  m=n_elements(thisdata)

  out_st=create_struct(tagnames[n-1],thisdata[0])

  FOR i=2,n DO BEGIN 
     thisdata=in_st.(n-i)
     out_st=create_struct(tagnames[n-i],thisdata[0],out_st)
  ENDFOR

  out_st=replicate(out_st,m)

  FOR i=0,n-1 DO BEGIN 
     out_st[*].(i)=in_st.(i)
  ENDFOR
  
  return,out_st


END
