;+
;
; NAME:
;        nan_pos_plot
;
; PURPOSE: 
;
;        plot an overview of nancay position in the 5 frequencies available
;
; CALLING SEQUENCE:
;
;        nan_pos_plot,filename=filename,time_range=time_range
;                    ,cent=cent,time=time
; 
; INPUTS:
;
;        filename : the filename of the output plot
;        time_range : time range for the plot
;        cent: center poitions to be plotted
;        time: time array for plotting
;                
; OUTPUT:
;        a plot 
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

PRO nan_pos_plot,filename=filename,cent=cent,time_data=time_data, $
                 time_intv=time_intv

nanfreq=['164','236','327','410','432']

time=time_data


oldp=!P

!P.MULTI=[0,0,5]
set_plot,'ps'
device,filename=filename,ysize=28,yoffset=1,xsize=18,xoffset=1

FOR i=0,4 DO $
utplot,time[i,*]-time[i,0],cent[i,*,0],time[i,0], $
       timerange=time_intv,xstyle=1, $
       title='Nancay x position at '+nanfreq[i]+' MHz',ystyle=1

FOR i=0,4 DO $
utplot,time[i,*]-time[i,0],cent[i,*,1],time[i,0], $
       timerange=time_intv,xstyle=1, $
       title='Nancay y position at '+nanfreq[i]+' MHz',ystyle=1

device,/close
set_plot,'x'
!P=oldp

END


