;+
; NAME:
;
; aia_snapview_plot
;
; PURPOSE:
;
; plots a graphic interface of AIA observations, similar to teh XRT snapview
; this routines works with FOTS headers as input
;
; CATEGORY:
;
; SDO/AIA -  observation summary 
;
; CALLING SEQUENCE:
;
; aia_snapview_plot,headers
;
; INPUTS:
;
; headers: an array of structres with AIA header info (such as the one returned
;          by mreadfits)
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
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
;
;
; MODIFICATION HISTORY:
;
;-

PRO aia_snapview_plot,headers

tvlct,r,g,b,/get
pc=!P.charsize

loadct,0
linecolors
!P.charsize=2


time=anytim(headers.date_d$obs)

StartTime=min(time)
EndTime=max(time)
DeltaTime=EndTime-StartTime

TimeRange=[StartTime-0.025*DeltaTime,EndTime+0.025*DeltaTime]

WaveLengths=[94L,131,171,193,211,304,335,1600,1700,4500]
WaveLabels=['  94',' 131',' 171',' 193',' 211',' 304',' 335','1600','1700','4500']
YOffset=12-[1,2,3,4,5,6,7,8,9,10]
DeltaY=[-0.2,0.2]

yrange=[1,12]

utplot,[0,0]-StartTime,[0,0],StartTime,timerange=TimeRange,/nodata,yrange=yrange,ystyle=1+4,xstyle=1,xmargin=[10,10],xtitle=' '
axis,TimeRange[0]-StartTime,0,yaxis=0,yticks=9,ytickv=YOffset,ytickname=WaveLabels,yminor=0,yrange=yrange,/save,ystyle=1
axis,TimeRange[1]-StartTime,0,yaxis=1,yticks=9,ytickv=YOffset,ytickname=WaveLabels,yminor=0,yrange=yrange,/save,ystyle=1


FOR i=0,n_elements(YOffset)-1 DO BEGIN 
   oplot,!X.crange,YOffset[i]*[1,1],linestyle=2
ENDFOR 

FOR i=0,n_elements(headers)-1 DO BEGIN
   index=headers[i]

   color=2
   IF index.img_type NE 'LIGHT' THEN color=10

   ind=where(index.wavelnth EQ WaveLengths,count)
   IF count EQ 1 THEN BEGIN 
      ;print,anytim(time[i],/vms),YOffset[ind]
      oplot,time[[i,i]]-StartTime,DeltaY+YOffset[ind[0]],color=color
   ENDIF 
ENDFOR


tvlct,r,g,b
!P.charsize=pc


END 


