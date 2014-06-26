;+
; NAME:
;       smallint2str
;
; PURPOSE: 
;       from an input integer i, return a string with the integer
;       and leading zero up to a length strlength (default 2)
;
; CALLING SEQUENCE:
;       s=smallint2str(i)
;
; INPUTS:
;       i: a small integer
;
; HISTORY:
;       17-DEC-2002 written
;       15-SEP-2002 added strlength functionality
;
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@cfa.harvard.edu
;
;       $Id: smallint2str.pro 12 2007-12-05 21:50:03Z pgrigis $
;
;-

FUNCTION smallint2str,i,strlength=strlength

n=fcheck(strlength,2)

str=strtrim(i,2)

FOR j=1,n-1 DO IF strlen(str) LE j THEN str='0'+str 

RETURN,str 

END
