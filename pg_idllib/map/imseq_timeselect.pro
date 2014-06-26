;+
;
; NAME:
;        imseq_timeselect
;
; PURPOSE: 
;
;        select a subrange of images from an image sequence
;
; CALLING SEQUENCE:
;
;        out_ptr=imseq_timeselect(ptr,time_intv)
; 
; INPUTS:
;
;        ptr: array of pointers to imseq
;        time_intv: time interval for the selection
;                
; OUTPUT:
;        out_ptr: a pointer to the restricted sequence of images
;
; CALLS:
;      
;
; VERSION:
;       
;       4-FEB-2002 written
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION imseq_timeselect,ptr,time_intv

time_intv=anytim(time_intv)


ind=validpointer(ptr)

IF ind[0] EQ -1 THEN RETURN,ptr_new()

N=n_elements(ind)

;starttime=anytim(*ptr[min(ind)].time)
;endtime=anytim(*ptrr[max(ind)].time)

;time_intv[0]=min([starttime,time-intv[0])
;time_intv[1]=max([endtime,time-intv[1])

time=dblarr(N)
FOR i=0,N-1 DO time[i]=anytim((*ptr[ind[i]]).time)

wh=where((time GT time_intv[0]) AND (time LT time_intv[1]))

IF wh[0] EQ -1 THEN RETURN,ptr_new()

N=n_elements(wh)
outptr=ptrarr(N)
FOR i=0,N-1 DO outptr[i]=ptr[ind[wh[i]]]

RETURN,outptr

END


