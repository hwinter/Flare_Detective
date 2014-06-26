; PSH, 2001/06/11
;
; PURPOSE:
;		takes an array of image fits and nrh image file(s), overlays
;			nrh on images and makes a javascript movie out of it
; this routine is used to do a quick and dirty movie without any embellishments
;
;
; cmap & timerange : see contour_nrh_on_map.pro
;
;KEYWORDS:
;	/js : to make a javascript movie in lieu of an mpeg movie
;
;
; EXAMPLE:
;		nrh_on_fits_movie,fitsfiles,nrhdir,nrhfiles,/log,grid=10
;
;


PRO nrh_on_fits_movie,fitsfiles,nrhdir,nrhfiles,cmap=cmap,timerange=timerange, $
							outpath=outpath, js=js, _extra=_extra

if not keyword_set(outpath) then begin
				outpath='/global/helene/home/www/staff/shilaire/private/MOVIES/TEMP/'
	endif
if keyword_set(js) then outpngpath=outpath

Nimg=n_elements(fitsfiles)
for i=0,Nimg-1 do begin
fits2map,fitsfiles(i),map
if i eq 0 then maps=map else maps=[maps,map]
endfor

contour_nrh_on_map,maps,nrhdir,nrhfiles,cmap=cmap,timerange=timerange, $
	pixmap=pixmap,windowsize=windowsize,outmovie,$
	outpngpath=outpngpath,_extra=_extra

if keyword_set(js) then begin
				images='fr0000.png'
				for i=1,Nimg-1 do images=[images,'fr'+int2str(i,4)+'.png']				
				myjsmovie,outpath+'runme.html',images
endif else begin
				mpeg_maker,outmovie,filename=outpath+'runme.mpg'
	endelse
END


















;fitsfiles='/global/tethys/users/shilaire/TRACE/2000_08_25/tri20000825.1400_0'
;fitsfiles=fitsfiles+['107','113','119','133','139','145','153','161','169', $
; '173','177','181','189','197','205','213','221','229']
;fitsfiles=fitsfiles+'.pl'

;nrhdir='/global/carme/home/shilaire/mylepus/nrh/'

;nrhfiles=['nrh2_1640_h70_20000825_142759:03_c.fts','nrh2_2366_h70_20000825_142759:03_c.fts', $
; 'nrh2_3270_h70_20000825_142759:03_c.fts','nrh2_4105_h70_20000825_142759:03_c.fts', $
; 'nrh2_4320_h70_20000825_142759:03_c.fts']


