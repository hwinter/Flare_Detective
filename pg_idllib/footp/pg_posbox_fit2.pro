;+
; NAME:
;      pg_posbox_fit2
;
; PURPOSE: 
;      fit image source position, given input boxes for different
;      sources
;
; CALLING SEQUENCE:
;
;      pos=pg_posbox_fit,ptr,framelist,pbox
;
; INPUTS:
;      
;      ptr:  pointer to an array of maps
;      framelist: array [2,M]. This is the set of frames corresponding
;      to each disconnected fitting  
;      pbox: pointer to an array [N,M] of boxes, N sources for M set
;      of frames
;  
; OUTPUTS:
;      
;      
; KEYWORDS:
;      quiet: suppress info messages  
;
; HISTORY:
;
;      15-NOV-2004 written PG
;      06-DEC-2004 adapted to new framelist input format
;      13-DEC-2004 added n_totframes tag
;      20-DEC-2004 added forward fit position capabilities
;      10-JAN-2005 added error in image capabilities and error
;                  output...
;      12-JAN-2004 added mpfit raw output
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

FUNCTION pg_posbox_fit2,ptr,framelist,pbox,fitmethod=fitmethod

IF NOT exist(ptr) THEN BEGIN
   print,'Invalid input'
   RETURN,-1
ENDIF

ntotframes=n_elements(ptr)
frametimes=dblarr(2,ntotframes)
FOR i=0,ntotframes-1 DO BEGIN
   frametimes[*,i]=(*ptr[i]).pg_time_range
ENDFOR

M=n_elements(framelist[*,0])
N=n_elements(pbox[*,0])

is_forward_fit=(*ptr[0]).pg_image_algorithm EQ 'forward fit'

fitmethod=fcheck(fitmethod,'GAUSSFIT')

qpos=ptrarr(N,M)
qposerr=qpos
tpos=ptrarr(N,M)
rawfitoutput=ptrarr(N,M)

FOR i=0,N-1 DO BEGIN
   FOR j=0,M-1 DO BEGIN 

      print,'Now doing source '+strtrim(string(i),2)+' and frame set ' $
         +strtrim(string(j))
      
      sourceflist=*framelist[j,i]
      nframes=n_elements(sourceflist)
      pos=fltarr(2,nframes)
      poserr=pos
      time=dblarr(2,nframes)
      fitoutput=ptrarr(nframes)

      FOR k=0,nframes-1 DO BEGIN

         map=*ptr[sourceflist[k]]
         IF tag_exist(map,'PG_TIME_RANGE') THEN time[*,k]=map.pg_time_range

         IF finite((*pbox[i,j])[0]) THEN BEGIN 

            IF is_forward_fit THEN BEGIN

               allposx=map.xc+map.pg_ff_fitpar[2,0:N-1]
               allposy=map.yc+map.pg_ff_fitpar[3,0:N-1]

               ;check which sources are inside the box
               dummy=where((allposx GE (*pbox[i,j])[0]) AND $
                           (allposx LE (*pbox[i,j])[1]) AND $
                           (allposy GE (*pbox[i,j])[2]) AND $
                           (allposy LE (*pbox[i,j])[3]),count)

               print,count

               IF count EQ 0 THEN pos[*,k]=[!Values.f_nan,!Values.f_nan]
               IF count EQ 1 THEN pos[*,k]=[allposx[dummy],allposy[dummy]]
               IF count EQ 2 THEN pos[*,k]=[allposx[(sort(allposx))[i]] $
                                           ,allposy[(sort(allposx))[i]]]
               IF count GE 3 THEN BEGIN
                  print,'Sorry, more than 2 sources in Forward Fit not allowed'
                  return,-1
               ENDIF
               

            ENDIF ELSE BEGIN
               pg_mapcfit,map,x,y,xerr=xerr,yerr=yerr,roi=*pbox[i,j] $
                         ,method=fitmethod,/rdata,/geterror,fitout=fitout
               pos[*,k]=[x,y]
               poserr[*,k]=[xerr,yerr]
               fitoutput[k]=ptr_new(fitout)
            ENDELSE

         ENDIF ELSE pos[*,k]=!values.f_nan*[1,1]
         
      ENDFOR 

      qpos[i,j]=ptr_new(pos)
      qposerr[i,j]=ptr_new(poserr)
      tpos[i,j]=ptr_new(time)
      rawfitoutput[i,j]=ptr_new(fitoutput)
      print,' '

   ENDFOR
ENDFOR




return,{pos:qpos,poserr:qposerr,tpos:tpos,framelist:transpose(framelist) $
       ,pbox:pbox,n_sources:N,n_setframes:M,n_totframes:ntotframes $
       ,frametimes:frametimes,rawfitoutput:rawfitoutput}

END
