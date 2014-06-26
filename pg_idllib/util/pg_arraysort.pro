;+
; NAME:
;      pg_arraysort
;
; PROJECT:
;      array manip utilitites
;
; PURPOSE: 
;
;      sort the columns of the input array x [n,m] (m columns of n elements) in
;      this way: the first coumn is sorted. Equal elements in the first column
;      are ordered in such a way that the corresponding elements in the second
;      column are sorted. Equal elements in the second column are sorted
;      according to the third column etc...
;
;
; CALLING SEQUENCE:
;     sorted_array=pg_arraysort(array [,out_index=out)index])
;
; INPUTS:
;     array: a n by m array
;   
; OUTPUTS:
;     out_index: output of the sorting index for the first column 
;      
; KEYWORDS:
;
;
; HISTORY:
;       01-MAR-2006 written PG
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-


PRO pg_arraysort_test

  x=[[4,2,4,2,3,1,1,1,4], $
     [2,1,2,2,3,1,1,3,5], $
     [3,2,1,4,5,6,7,8,9]]

  x2=pg_arraysort(x)

END


FUNCTION pg_arraysort,x,out_index=out_index

  ans=x
  siz=size(x)

  
  IF siz[0] EQ 1 THEN BEGIN
     out_index=sort(x)
     RETURN,x[out_index] 
  ENDIF $
  ELSE BEGIN 
     IF siz[0] NE 2 THEN BEGIN
        print,'WRONG ARRAY SIZE. MUST BE 2-DIMENSIONAL'
        RETURN,-1
     ENDIF
  ENDELSE


  ncol=siz[2];numbers of columns
  nel=siz[1];numbers of elements in each column


  this_column=x[*,0];the first column

  tcs=sort(this_column)
  out_index=tcs

  ;sort all the columns according to the first
  FOR i=0,ncol-1 DO BEGIN 
     ans[*,i]=ans[tcs,i]
  ENDFOR


  untc=[-1L,uniq(this_column[tcs])];list of the unique elements in this_column

  ;recursively call pg_arraysort for all blocks of equal elements in the second column
  ;untc is a list of index of block boundaries
  FOR i=0,n_elements(untc)-2 DO BEGIN
     ans[untc[i]+1:untc[i+1],1:ncol-1]=pg_arraysort(ans[untc[i]+1:untc[i+1],1:ncol-1] $
                                                   ,out_index=new_out_index)
     out_index[untc[i]+1:untc[i+1]]=tcs[new_out_index+untc[i]+1]
  ENDFOR


  RETURN,ans

END

