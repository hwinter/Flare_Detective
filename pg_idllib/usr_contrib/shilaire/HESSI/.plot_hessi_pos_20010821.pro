; purpose : to draw Hessi's subpoint position...
;   takes into account Earth's oblateness.

; Feb 22th,2001 by Pascal Saint-Hilaire 
; shilaire@astro.phys.ethz.ch OR psainth@hotmail.com

; INPUTS:  utc_time : an ANYTIM string
;  hmm, with nskip=1 no bizarre interpolation errors occur;
;	but with nskip=1, forget about differing linestyles
;	(which are particularly useful for B&W plots...)

;  EXAMPLE: plot_hessi_pos,'31-aug-00 '+['16:00','17:00']
;			plot_hessi_pos,'01-sep-00 '+['00:01','00:54'],/night,/saa
;			plot_hessi_pos,'01-sep-00 '+['00:01','00:54'],/all_science_flags	;this one is only OK for color plots...
;
;IMPROVEMENTS PLANNED :
; - could be improved easily (if I weren't so lazy) if I did NOT
;   need to go through positional arrays (ECI(3,ntimes), lat(ntimes),
;   lon(ntimes) and alt(ntimes)), but did the plotting on a step by 
;   step basis.
;
; - could be further improved to use other projections, or plotting
;	the actual position in space, instead of just the subpoint.
;	(after all, I do have the altitude alt...)
;		--> this is another .pro
;
; - some flags are more than just booleans (ex. COLD_PLATE_TEMP) : 
;   this will have to be addressed sometime ...!
;
; Modified 2001/03/22 : input can be either a UT time range (as before)
;			OR a Hessi fits data file.
; Modified 2001/03/22 : added the flags, /night and /saa keywords
;    flags is a bytarr(32) corresponding to OBSERVING SUMMARY flags:
;	0	SAA_FLAG                                                                        
;	1	ECLIPSE_FLAG 
;	2	FLARE_FLAG                                                                      
;	3	DECIMATION_STATE                                                                
;	4	IDPU_CONTROL_VERSION_NUMBER                                                     
;	5	CRYOCOOLER_POWER                                                                
;	6	COLD_PLATE_TEMP                                                                 
;	7	IDPU_TEMP                                                                       
;	8	COLD_PLATE_SUPPLY                                                               
;	9	HV28_SUPPLY                                                                     
;	10	ACTUATOR_SUPPLY                                                                 
;	11	FAST_HOUSEKEEPING                                                               
;	12	SC_TRANSMITTER                                                                  
;	13	SC_IN_SUNLIGHT                                                                  
;	14	SSR_STATE                                                                       
;	15	ATTENUATOR_STATE                                                                
;	16	FRONT_RATIO  
;	17	NON_SOLAR_EVENT                                                                 
;	18	GAP_FLAG
;	19 to 31 : reserved for now 
;putting a flag to a non-zero value actives it for drawing. It'll
; use its value as its color index (sorry, using color index 0 would 
; deactivate it ...)
; if the /nocol (nocolor) is activated, then the flags value
;   corresponds to the drawing psym...( 0 to 8 )

; Modified 2001/05/16 : MAJOR modifications : -can no longer input a file
;											  -uses my_hessi_ct.pro
;											  -added /all_science_flags keyword
;											  -no B&W drawing (removed /nocol keyword)


;*************************************************************************************************
;*************************************************************************************************


pro plot_hessi_pos, time_interval, nskip=nskip, 				$
		night=night, saa=saa, flare=flare, nonsolar=nonsolar,	$
		all_science_flags=all_science_flags

my_hessi_ct,col
hessicolor=col(4)
if not keyword_set(nskip) then nskip=15 ; one marker per 5 minute...except for events!
if keyword_set(all_science_flags) then begin
									saa=1		
									night=1
									flare=1
									decimation=1
									sunlight=1
									attenuator=1
									front=1
									nonsolar=1
									gap=1
									   endif
if keyword_set(saa) then saa=col(1)
if keyword_set(night) then night=col(5)
if keyword_set(flare) then flare=col(3)
if keyword_set(nonsolar) then nonsolar=col(6)
if keyword_set(decimation) then decimation=col(11)
if keyword_set(attenuator) then attenuator=col(12)
if keyword_set(sunlight) then sunlight=col(2)
if keyword_set(front) then front=col(10)
if keyword_set(gap) then gap=col(7)

map_set,0,0,/mercator,/isotropic,/continents,color=col(14)
xyouts,40,495,'HESSI Trajectory : '+anytim(time_interval(0),/yoh)+' to '+anytim(time_interval(1),/yoh),color=255,charsize=1.5,/device

;now getting the ECI coordinates....
hoso = obj_new('hsi_obs_summary') 
ECI=hoso->getdata(class_name='ephemeris',obs_time_interval=time_interval)
times=hoso->getdata(/time)
ntimes= n_elements(times)   

;convert ECI to latitude and longitude
lat=dblarr(ntimes)
lon=dblarr(ntimes)

alt=600.    ; I'm not using altitude, yet...
for i=0,ntimes-1 do begin
		 eci2geodetic,ECI(0,i),ECI(1,i),ECI(2,i),times(i),lati,longi,alt
		 lat(i)=lati
		 lon(i)=longi
		 end

; plotting HESSI trajectory...
oplot,lon,lat,color=hessicolor,thick=3.0

;OK now, getting the FLAGS...
;... and plot them !!!
flagdata=hoso->getdata(class_name='obs_summ_flag')
delta=2.	; latitude difference between plot lines for different flags...



xyouts,15,25,'FLAGS:',charsize=1.0,/device
delta=4.	; standard latitude difference betwwen flag curves/markers

if exist(saa) then begin
				xyouts,60,25,'SAA',charsize=1.0,color=saa,/device
				flag_ss=where(flagdata(0,*) ne 0)
				if flag_ss(0) ne -1 then oplot,lon(flag_ss),lat(flag_ss)+delta,psym=5,color=saa,nsum=nskip
end
if exist(night) then begin
				xyouts,100,25,'NIGHT',charsize=1.0,color=night,/device
				flag_ss=where(flagdata(1,*) ne 0)
				if flag_ss(0) ne -1 then oplot,lon(flag_ss),lat(flag_ss)-delta,psym=4,color=night,nsum=nskip
end
if exist(flare) then begin
				xyouts,60,15,'FLARE',charsize=1.0,color=flare,/device
				flag_ss=where(flagdata(2,*) ne 0)
				if flag_ss(0) ne -1 then oplot,lon(flag_ss),lat(flag_ss)+delta,psym=2,color=flare
end
if exist(nonsolar) then begin
				xyouts,100,15,'NON SOLAR',charsize=1.0,color=nonsolar,/device
				flag_ss=where(flagdata(17,*) ne 0)
				if flag_ss(0) ne -1 then oplot,lon(flag_ss),lat(flag_ss)+delta,psym=2,color=nonsolar
end
if exist(decimation) then begin
				xyouts,175,25,'DECIMATION',charsize=1.0,color=decimation,/device
				flag_ss=where(flagdata(3,*) ne 0)
				if flag_ss(0) ne -1 then oplot,lon(flag_ss),lat(flag_ss)-2*delta,psym=3,color=decimation				
end
if exist(attenuator) then begin
				xyouts,175,15,'ATTENUATION',charsize=1.0,color=attenuator,/device
				flag_ss=where(flagdata(15,*) ne 0)
				if flag_ss(0) ne -1 then oplot,lon(flag_ss),lat(flag_ss)-3*delta,psym=3,color=attenuator				
end
if exist(sunlight) then begin
				xyouts,300,25,'S/C in SUNLIGHT',charsize=1.0,color=sunlight,/device
				flag_ss=where(flagdata(13,*) ne 0)
				if flag_ss(0) ne -1 then oplot,lon(flag_ss),lat(flag_ss)-5*delta,psym=4,color=sunlight,nsum=nskip				
end
if exist(front) then begin
				xyouts,250,25,'FRONT',charsize=1.0,color=front,/device
				flag_ss=where(flagdata(16,*) ne 0)
				if flag_ss(0) ne -1 then oplot,lon(flag_ss),lat(flag_ss)-4*delta,psym=3,color=front				
end
if exist(gap) then begin
				xyouts,250,15,'GAP',charsize=1.0,color=gap,/device
				flag_ss=where(flagdata(18,*) ne 0)
				if flag_ss(0) ne -1 then oplot,lon(flag_ss),lat(flag_ss),psym=7,color=gap,nsum=nskip				
end






;*******************************************************************************
;OK, now the rest ...
map_continents,/countries,color=col(14)

lats = [ -90, -60, -30, 0, 30, 60, 90]
latnames = strtrim(lats, 2)
latnames(where(lats eq 0)) = 'Equator'
MAP_GRID, LABEL=2, LATS=lats, LATNAMES=latnames, LATLAB=7, $
   LONLAB=-2.5, LONDEL=30, LONS=-30, ORIENTATION=0,color=col(0)

obj_destroy,hoso
end





