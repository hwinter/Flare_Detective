; OK, this is a modification from the 'plot_gbl.pro' routine by PSH (07-dec-00)


pro mybatse, sttim, entim, event=event, _extra=plot_keywords
;
;+
;NAME:
;       mybatse
;PURPOSE:
;       To plot the GRO/BATSE light curve data
;SAMPLE CALLING SEQUENCE:
;       mybatse, '8-may-91 13:00', '8-may-91 13:15'
;       ;;;plot_gbl, event=1000  
;INPUT:
;       sttim   - The start time to plot
;       entim   - The end time to plot
;OPTIONAL KEYWORD INPUT:
;       event   - If set, plot the light curve for that event
;HISTORY:
;       Written 16-Apr-93 by M.Morrison
;        6-May-93 (MDM) - Added YRANGE
;       27-Oct-94 (DMZ) - Added keyword inheritance
;       27-Oct-94 (SLF) - removed explicit yrange (ok via _extra)
;	7-dec-00 - Modified by Pascal Saint-Hilaire
;-
;
if (keyword_set(event)) then begin
    rd_gbe, '1-jan-91', !stime, gbe
    ss = where(gbe.event eq event)
    if (ss(0) eq -1) then begin
        print, 'PLOT_GBL: Cannot find that event'
        return
    end else begin
        sttim = anytim2ints(gbe(ss(0)), off=-2*60.)                     ;back up 2 minutes
        entim = anytim2ints(gbe(ss(0)), off=gbe(ss(0)).duration+2*60.)  ;go forward 2 minutes
    end
end

rd_gbl, sttim, entim, gbl, status=status

if (status gt 0) then begin
    print, 'PLOT_GBL: Do data available for that time period'
    return
end

ytit = 'Counts/sec/2000 cm^2'
;tit = 'GRO/BATSE DISCLA Rates (1.024 sec averages)'

!X.thick=3
!Y.thick=3
utplot, gbl, gbl.channel1+gbl.channel2, timerange=[sttim,entim],ytit=ytit, psym=10, $
 xstyle=1,ystyle=2,charthick=1,thick=3.0,font=-1,/nolabel , $
 yrange=[0,80000]  , _extra=plot_keywords

;
end
