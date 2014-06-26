
PRO hedc_5x5_panel,ptr,img_per_eband, eband,	$	
	dim=dim,charsize=charsize

	IF NOT KEYWORD_SET(dim) THEN dim=900
	IF NOT KEYWORD_SET(charsize) THEN BEGIN
		IF !D.NAME EQ 'Z' THEN charsize=1.0 ELSE charsize=1.2
	ENDIF
			
	xmar=[0,1]
	ymar=[0,1]
	addxdim=25
	addydim=25

	hedc_win,dim,dim
	hessi_ct
	!P.MULTI=[0,5,5]

	cur=0
	FOR i=0,4 DO BEGIN
		CASE img_per_eband[i] OF
			1: BEGIN
				plot,[0,1],[0,1],color=0		
				plot,[0,1],[0,1],color=0
				hedc_panel_image_plot,*ptr(0,cur),*ptr(1,cur),charsize=charsize,/noax,title='',/iso,xmar=xmar,ymar=ymar,/LIMB
				plot,[0,1],[0,1],color=0
				plot,[0,1],[0,1],color=0
			END		
			2: BEGIN
				plot,[0,1],[0,1],color=0		
				hedc_panel_image_plot,*ptr(0,cur),*ptr(1,cur),charsize=charsize,/noax,title='',/iso,xmar=xmar,ymar=ymar,/LIMB
				plot,[0,1],[0,1],color=0
				hedc_panel_image_plot,*ptr(0,cur+1),*ptr(1,cur+1),charsize=charsize,/noax,title='',/iso,xmar=xmar,ymar=ymar,/LIMB
				plot,[0,1],[0,1],color=0
			END		
			3: BEGIN
				plot,[0,1],[0,1],color=0		
				hedc_panel_image_plot,*ptr(0,cur),*ptr(1,cur),charsize=charsize,/noax,title='',/iso,xmar=xmar,ymar=ymar,/LIMB
				hedc_panel_image_plot,*ptr(0,cur+1),*ptr(1,cur+1),charsize=charsize,/noax,title='',/iso,xmar=xmar,ymar=ymar,/LIMB
				hedc_panel_image_plot,*ptr(0,cur+2),*ptr(1,cur+2),charsize=charsize,/noax,title='',/iso,xmar=xmar,ymar=ymar,/LIMB
				plot,[0,1],[0,1],color=0
			END		
			4: BEGIN
				hedc_panel_image_plot,*ptr(0,cur),*ptr(1,cur),charsize=charsize,/noax,title='',/iso,xmar=xmar,ymar=ymar,/LIMB
				hedc_panel_image_plot,*ptr(0,cur+1),*ptr(1,cur+1),charsize=charsize,/noax,title='',/iso,xmar=xmar,ymar=ymar,/LIMB
				hedc_panel_image_plot,*ptr(0,cur+2),*ptr(1,cur+2),charsize=charsize,/noax,title='',/iso,xmar=xmar,ymar=ymar,/LIMB
				hedc_panel_image_plot,*ptr(0,cur+3),*ptr(1,cur+3),charsize=charsize,/noax,title='',/iso,xmar=xmar,ymar=ymar,/LIMB
				plot,[0,1],[0,1],color=0
			END		
			5: BEGIN
				hedc_panel_image_plot,*ptr(0,cur),*ptr(1,cur),charsize=charsize,/noax,title='',/iso,xmar=xmar,ymar=ymar,/LIMB
				hedc_panel_image_plot,*ptr(0,cur+1),*ptr(1,cur+1),charsize=charsize,/noax,title='',/iso,xmar=xmar,ymar=ymar,/LIMB
				hedc_panel_image_plot,*ptr(0,cur+2),*ptr(1,cur+2),charsize=charsize,/noax,title='',/iso,xmar=xmar,ymar=ymar,/LIMB
				hedc_panel_image_plot,*ptr(0,cur+3),*ptr(1,cur+3),charsize=charsize,/noax,title='',/iso,xmar=xmar,ymar=ymar,/LIMB
				hedc_panel_image_plot,*ptr(0,cur+4),*ptr(1,cur+4),charsize=charsize,/noax,title='',/iso,xmar=xmar,ymar=ymar,/LIMB
			END							
			ELSE: PRINT,'Problem -- not making panel...'
		ENDCASE
		cur=cur+img_per_eband[i]
	ENDFOR;i

	img1=TVRD()
	img2=BYTARR(dim+addxdim,dim+addydim)
	img2(addxdim:dim+addxdim-1,0:dim-1)=img1
	hedc_win,dim+addxdim,dim+addydim
	TV,img2
	
	info=*ptr(1,0)
	text='  Time vs. Energy panel   --   DATE: '+anytim(info.obs_time_interval(0),/date,/ECS)+'     Imaging algorithm: '+info.image_algorithm
	text=text+'        FOV: '+strn(info.pixel_size(0)*info.image_dim(0))+'"X'+strn(info.pixel_size(1)*info.image_dim(1))+'"'
	
	XYOUTS,/DEV,addxdim,dim+addydim-15,text,charsize=charsize
	
	FOR i=0,4 DO BEGIN
		;XYOUTS,/DEV,15,dim+addydim-i*dim/5-0.8*dim/5,strn(eband(0,i))+'-'+strn(eband(1,i))+' keV',charsize=charsize,ORIENTATION=90
		XYOUTS,/DEV,15,dim+addydim-i*dim/5-0.8*dim/5,strn(eband(0,i))+'-'+strn(eband(1,i))+' keV ('+strn(img_per_eband[i])+')',charsize=charsize,ORIENTATION=90
	ENDFOR

	;timestamp, charsize=charsize/2.	;,/bottom
	!P.MULTI=0

END	
