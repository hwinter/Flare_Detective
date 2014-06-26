fil='/global/hercules/data2/archive/fil/47/HEDC_DP_pten_HXS310240234.fits

imgtess=mrdfits(fil,0)
bla1=mrdfits(fil,1)
maps=psh_fits2map(fil)

hessi_ct,/QUICK

;iwanted=[0,3,7,11,14,16,23,29,32,35]
iwanted=[0,3,7,14,16,23,29,35]
ni=N_ELEMENTS(iwanted)
jwanted=[1,2,3,4,5]
nj=N_ELEMENTS(jwanted)

basesize=100
xoffset=10
yoffset=10
psh_win,ni*basesize,nj*basesize
!P.MULTI=[0,ni,nj,0,1]
dynrngmode=1	;1 is as usual (each pict its own)
		;2 is each eband its own
		;3 is the same for all

.run
FOR i=0,ni-1 DO BEGIN
	FOR j=0,nj-1 DO BEGIN
		CASE dynrngmode OF
			1:drange=[-1.,1.]*MAX((*maps[jwanted[j],iwanted[i]]).DATA)
			2:drange=[-1.,1.]*MAX(imgtess[*,*,jwanted[j],iwanted])
			3:drange=[-1.,1.]*MAX(imgtess[*,*,jwanted,iwanted])
		ENDCASE

		plot_map,*maps[jwanted[j],iwanted[i]],/LIMB,/ISO, $
			xmar=[0,0],ymar=[0,0],drange=drange, $
			xtit='',ytit='',tit='', $
			XTICKNAME=REPLICATE(' ',10),YTICKNAME=REPLICATE(' ',10)
	ENDFOR
ENDFOR
END;.run

;add other info
img=TVRD()
psh_win,N_ELEMENTS(img[*,0])+xoffset,N_ELEMENTS(img[0,*])+yoffset
TV,img,xoffset,yoffset
FOR i=0,ni-1 DO XYOUTS,xoffset+basesize*(i+0.5),1,ALIGNMENT=0.5,/DEVICE,anytim((*maps[0,iwanted[i]]).time,/ECS,/time,/trunc)
FOR j=0,nj-1 DO XYOUTS,xoffset-3,yoffset+basesize*(j+0.5),ALIGNMENT=0.5,/DEVICE,strn(bla1.ebands_arr[0,jwanted[j]])+'-'+strn(bla1.ebands_arr[1,jwanted[j]])+' keV',ORI=90

TVLCT,r,g,b,/GET
WRITE_PNG,'idl.png',TVRD(),r,g,b



