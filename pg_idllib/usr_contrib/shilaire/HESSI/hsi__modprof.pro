; by PSH, March, 15th, 2001

; purpose : to make plots for all nine detectors of the modulation profile
;		given by an image vimage


;example:	
;		IDL>a=fltarr(64,64)
;		IDL>a(30,45)=1
;		IDL>hsi_modprof,a



pro hsi__modprof,vimage,pixelsize=pixelsize,ps=ps

if not exist(pixelsize) then pixelsize=4.
if exist(ps) then set_plot,'ps'

o=hsi_image()
S=SIZE(vimage)
o->Set, DET_INDEX_MASK=bytarr(9)+1B, image_dim=[S(1),S(2)], pixel_size=pixelsize

if not exist(ps) then begin
			wdef,1
			o->plot
			end

!p.multi = [0,3,3]
wdef,2
for i=0,8 do begin
	modprof=o->GetData(CLASS_NAME='HSI_MODUL_PROFILE',VIMAGE=vimage,THIS_DET_INDEX=i)
	plot, modprof,xs=3
		endfor
obj_destroy,o

if exist(ps) then begin 
		device,/close
		set_plot,'X'	
		end

end

;-------------------> this doesn't work too well... look at Johns-Krull's sims...
