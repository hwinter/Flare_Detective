;+
; NAME:
;
;   xrt_hk_plot_group
;
; PURPOSE:
;
;   Plot single housekeeping values
;
; CATEGORY:
;
;   XRT HK utils
;
; CALLING SEQUENCE:
;
;     xrt_hk_plot_1val,hkdata,thisgroup=thisgroup
;
; INPUTS:
;
;
; OPTIONAL INPUTS:
;
;   hkdata:         pointer to an array of data structure such as the one produced by by xrt_hk_getdata
;   thisgroup:      ID of group to plot
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
;   NONE 
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
;   Reads in the HK value and plots them.
;
; EXAMPLE:
;
;  
; AUTHOR
;
; Paolo C. Grigis  
; pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
;   17-NOV-2008 written PG (based on a routine by P. Jibben)
;
;-

PRO xrt_hk_plot_group,hkdata,intime,hk_outimdir=hk_outimdir,thisgroup=thisgroup,save=save $
                     ,dtime=dtime,gap=gap,_extra=_extra,verbose=verbose

gap=fcheck(gap,20.0)

dtime=fcheck(dtime,168)
time=fcheck(intime,anytim(systime(1,/utc))+anytim('01-JAN-1970'))

timerange=time-[dtime*3600.0,0]
t0=timerange[0]

valmax=-1d32
valmin= 1d32
FOR i=0,n_elements(hkdata)-1 DO BEGIN
   
   valmax=max([valmax,(*hkdata[i]).value])
   valmin=min([valmin,(*hkdata[i]).value])

ENDFOR

;;taken from P. Jibben's code without changes
;; don't ask P. Grigis about the color names!
;Define a new color table
; 0 = black
; 1 = Persian Pink
; 2 = green
; 3 = Tangerine
; 4 = Azure
; 5 = brown
; 6 = Khaki
; 7 = chartruse (sp?)
; 8 = Fuchsai
; 9 = Yellow
; 10 = red
ncolors=!d.table_size-11
loadct,0,ncolors=ncolors,bottom=11,/silent
tvlct, red, green, blue, /get
red(1:(10))=[247,0,255,0,150,189,127,244,255,255]
green(1:(10))=[127,255,168,127,75,183,255,0,255,0]
blue(1:(10))=[190,0,18,255,0,107,0,161,0,0]
tvlct,red,green,blue

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

IF dtime EQ 168 THEN thick=2 ELSE thick=1
 

;utplot,0,0,t0,timerange=timerange,yrange=[floor(valmin-1),ceil(valmax+1)] $
;      ,/xstyle,/ystyle,_extra=_extra,xmargin=[18,2],title='Group '+strtrim(thisgroup,2)

now=anytim(systime(1,/utc)+anytim('01-JAN-1970'),/vms)

titlestring=['Group 1: limits -28 / +55', $
             'Group 2: limits -28 / +35', $
             'Group 3: limits -28 / +35', $
             'Group 4: limits -45 / +60', $
             'Group 5: limits TMP 11,12: -28 / +47 TMP 13,14: -40 /+50 TMP 10: -60 / +55', $
             'Group 6: limits TMP 15,16: -35 / +35 TMP 17: -35 / +55']

midtime=(timerange[0]+timerange[1])*0.5
utplot,midtime-t0,0,t0,timerange=timerange,yrange=[floor(valmin-1),ceil(valmax+1)],/xstyle,/ystyle $
      ,labelpar=[0,14],xmargin=[20,2],xtitle='Plot created on '+now+' UT',_extra=_extra,title=titlestring[thisgroup-1]
       ;'Group '+strtrim(thisgroup,2)


FOR i=0,n_elements(hkdata)-1 DO BEGIN


   val=(*hkdata[i]).value
   time=(*hkdata[i]).time
   name=(*hkdata[i]).name
 
   IF strmid(name,0,3) EQ 'TMP' THEN BEGIN 
      
      tempnumstr=strmid(name,3,2)

      IF valid_num(tempnumstr) THEN BEGIN 

         tempnum=float(tempnumstr)

          tmplimit= $
              [[ -28.0 , +55.0 ], $ ;TMP00     	 
              [  -28.0 , +55.0 ], $ ;TMP01    	 
              [  -28.0 , +55.0 ], $ ;TMP02    	 
              [  -28.0 , +35.0 ], $ ;TMP03    	 
              [  -28.0 , +35.0 ], $ ;TMP04    	 
              [  -45.0 , +60.0 ], $ ;TMP05    	 
              [  -28.0 , +35.0 ], $ ;TMP06    	 
              [  -28.0 , +35.0 ], $ ;TMP07    	 
              [  -28.0 , +35.0 ], $ ;TMP08    	 
              [  -28.0 , +35.0 ], $ ;TMP09    	 
              [  -60.0 , +55.0 ], $ ;TMP10    	 
              [  -28.0 , +47.0 ], $ ;TMP11    	 
              [  -28.0 , +47.0 ], $ ;TMP12    	 
              [  -40.0 , +50.0 ], $ ;TMP13    	 
              [  -40.0 , +50.0 ], $ ;TMP14    	 
              [  -35.0 , +35.0 ], $ ;TMP15    	 
              [  -35.0 , +35.0 ], $ ;TMP16    	 
              [  -35.0 , +55.0 ], $ ;TMP17    	 
              [  -45.0 , +60.0 ], $ ;TMP18    	 
              [  -28.0 , +35.0 ], $ ;TMP19    	 
              [  -28.0 , +35.0 ], $ ;TMP20    	 
              [  -30.0 , +35.0 ], $ ;TMP21    	 
              [  -30.0 , +35.0 ], $ ;TMP22    	 
              [  -28.0 , +35.0 ]]   ;TMP23    	 

          oplot,!X.crange,tmplimit[0,tempnum]*[1,1],color=10,thick=1
          oplot,!X.crange,tmplimit[1,tempnum]*[1,1],color=10,thick=1

       ENDIF
    ENDIF

   
  ;expand values to account for missing data
   ;gaps longer than 30 seconds are filled with NANs
   ;therefore plots look nicer
   xrt_hk_fillgaps,time,val,gap=gap,xout=x,yout=y

   outplot,x-t0,y,t0,color=i,thick=thick

   plots,[10,60],[420-20*i,420-20*i],color=i,/device,thick=3,linestyle=0,psym=0
   xyouts,70,420-20*i,(*hkdata[i]).name,color=0,/device,charsize=1.3
   
   ;stop




ENDFOR

 
IF keyword_set(save) THEN BEGIN
 
   IF dtime EQ 168 THEN $
      filename=hk_outimdir+'Group_'+strtrim(thisgroup,2)+'_'+'launch.png' $
   ELSE $
      filename=hk_outimdir+'Group_'+strtrim(thisgroup,2)+'_'+string(dtime,format='(I02)')+'hr.png'

   tvlct,r,g,b,/get
   IF keyword_set(verbose) THEN print,'Saving '+filename
   write_png,filename,tvrd(),r,g,b
ENDIF


END

