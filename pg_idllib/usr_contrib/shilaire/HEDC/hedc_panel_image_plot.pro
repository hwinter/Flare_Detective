;	2002/05/08, PSH : heavily modified....
;-
;============================================================================

pro hedc_panel_image_plot, image, struct, STAMP=STAMP,_extra=_extra


control={xyoffset:struct.xyoffset,					$
		 pixel_size:struct.pixel_size,				$
		 det_index_mask:struct.det_index_mask,		$
		 a2d_index_mask:struct.a2d_index_mask,		$
		 front_segment:struct.front_segment,		$
		 rear_segment:struct.rear_segment,			$
		 energy_band:struct.energy_band				}
	
info={	absolute_time_range:struct.absolute_time_range,	$
		binned_n_event:struct.binned_n_event			}
	
alg=struct.image_algorithm
		 
; get parameters that will be used for labels
xyoffset = control.xyoffset
pixel_size = control.pixel_size
time_interval = info.absolute_time_range
det = control.det_index_mask
a2d = reform (control.a2d_index_mask, 9, 3)
front = control.front_segment
rear = control.rear_segment
enb = control.energy_band
n_event = info.binned_n_event
detector_list = hsi_coll_segment_list(det, a2d, front, rear, colls_used=colls_used)
; use image_units if exists - older quicklook images don't have it.
cb_title = tag_exist(info,'image_units') ? info.image_units : ''
if cb_title ne '' then cb_title = '(' + cb_title + ')'

; create map structure that plot_map expects to see

map =  make_map( image, $
                 xc=xyoffset[0], $
                 yc=xyoffset[1], $
                 dx=pixel_size[0], $
                 dy=pixel_size[1], $
                 time=anytim(time_interval[0],/tai) )

xtitle = 'Heliocentric X (arcsec)'
ytitle = 'Heliocentric Y (arcsec)'
title = 'Reconstructed HESSI Image'

if is_hessi_color (_extra=_extra) then begin
        ;print,'Using a hessi color, so scaling is symmetric around 0.0'
        maxval = max(abs(image))
        drange = [-maxval, maxval]
        ; make sure plot_map doesn't ever rescale the image when using hessi colors.
        ; This seems backward, but if rescale_image = 0 then plot_map will use full range of image to scale instead
        ; of dmin and dmax, so set rescale_image to 1, but pass in dmin,dmax to force it to use dmin,dmax in zoom
        if size(_extra,/tname) eq 'STRUCT' then if tag_exist(_extra, 'rescale_image') then _extra.rescale_image=1
        ;print,'rescale_image = ', _extra.rescale_image
endif

if tag_exist(_extra, 'mark_point', /quiet) then if _extra.mark_point eq 1 then begin
        p = (hsi_qlook_pointing(obs_time_interval=time_interval)) -> getdata(/de_bytescale)
        axis = [ mean(p[0,*]), mean(p[1,*]) ]
        _extra = rep_tag_value (_extra, axis, 'mark_point')
        message, 'Pointing axis=' + arr2str(trim(axis)) + ' arcsec', /cont
endif

Plot_Map, map, $
        _EXTRA=_extra, drange=drange,  $
        xtitle=xtitle, ytitle=ytitle, title=title, cb_title=cb_title, $
        status=status, err_msg=err_msg

if not status then return

; put labels on image
fm = '(f12.1)'
en_string = strtrim ( string(enb(0),format=fm), 2) + ' - ' + strtrim ( string(enb(1),format=fm), 2)

fm = '(g12.3)'
total_events = strupcase (strtrim (string(total(n_event[where(colls_used),0]), format=fm),2))
total_events = 'Total counts: ' + str_replace (total_events, 'E+00', 'E+0')

label_size = ch_scale(.8, /xy)
color = !p.color
time_size = ch_scale(.8, /xy)
legend_loc = 1
if keyword_set(_extra) then begin
        if tag_exist (_extra, 'charsize') then  label_size = _extra.charsize
        if tag_exist(_extra, 'acolor') then color = _extra.acolor
        if tag_exist (_extra, 'charsize') then time_size = _extra.charsize * .8
        if tag_exist (_extra, 'legend_loc') then legend_loc = _extra.legend_loc
        if tag_exist (_extra, 'legend_color') then textcolor = _extra.legend_color
endif

if legend_loc ne 0 then begin

		deltachar=N_ELEMENTS(map.data(*,0)) * map.dx * 5. /!D.X_SIZE
		IF !D.NAME EQ 'Z' THEN deltachar=deltachar*12. ELSE deltachar=deltachar*10.
		upperleft=[map.xc-map.dx*N_ELEMENTS(map.data(*,0))/2,map.yc+map.dy*N_ELEMENTS(map.data(0,*))/2]
		lowerleft=[map.xc-map.dx*N_ELEMENTS(map.data(*,0))/2,map.yc-map.dy*N_ELEMENTS(map.data(0,*))/2]
		
		text=anytim(time_interval(0),/ECS,/time,/trunc)+' to '+anytim(time_interval(1),/ECS,/time,/trunc)
		XYOUTS,upperleft(0),upperleft(1)-deltachar,/DATA,text, charsize=charsize
		
		text=detector_list
		XYOUTS,upperleft(0),upperleft(1)-2*deltachar,/DATA,text, charsize=charsize
		
		text=total_events 
		XYOUTS,lowerleft(0),lowerleft(1),/DATA,text, charsize=charsize

endif

IF KEYWORD_SET(STAMP) THEN timestamp, /bottom, charsize=time_size

END


