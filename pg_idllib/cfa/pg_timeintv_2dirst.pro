;+
; NAME:
;
; pg_timeintv_2dirst
;
; PURPOSE:
;
; convert a time interval to directory structures in form
; /path/to/file/2010/12/11/H1200 /path/to/file/2010/12/11/H1300
;
; CATEGORY:
;
; utils
;
; CALLING SEQUENCE:
;
; dir=pg_timeintv_2dirst(time_intv,dir=dir)
;
; INPUTS:
;
; time_intv: time interval
;
; OPTIONAL INPUTS:
;
; 
;
; KEYWORD PARAMETERS:
;
; dir: base dir for path
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
; time_intv=['14-DEC-2010 21:35','15-DEC-2010 02:14']
; d=pg_timeintv_2dirst(time_intv)                    
;
;
; AUTHOR:
;
; Paolo Grigis pgrigis@gmail.com
;
; MODIFICATION HISTORY:
;
; 2010/12/14 PG written (based on older material)
;-

FUNCTION pg_timeintv_2dirst,time_intv,dir=dir


t0=anytim(time_intv[0],/external)
t1=anytim(time_intv[1],/external)

;build directory list
dir=fcheck(dir, '/data/SDO/AIA/level1/')
                                
; OS dependent path separator
ps=path_sep()

;convert inputs to anytim format: external representation
s_time = anytim(time_intv[0])
e_time = anytim(time_intv[1])

;compute how many hours there are in the interval
n_hours=ceil((e_time-s_time)/3600.+1)
  
time=0d
value=0.0
trackvalue=-1
  
first=1

alldir=strarr(n_hours)

;hunt for files in the archive tree
FOR i=0L,n_hours-1 DO BEGIN 

     ;this hour
     thistime=anytim(s_time+3600.*i,/ex)

     ;create dir path and filename

     thisyear =strtrim(thistime[6],2)
     thismonth=string(thistime[5],format='(i2.2)')
     thisday  =string(thistime[4],format='(i2.2)')
     thishour =string(thistime[0],format='(i2.2)')
     
     thisdir=dir+ps+thisyear+ps+thismonth+ps+thisday+ps+'H'+string(thishour,format='(I02)')+'00'
     alldir[i]=thisdir

ENDFOR 

RETURN,alldir 

END


