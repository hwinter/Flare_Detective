	
	
set_plot,'Z'
psh_win,512
hessi_ct,/QUICK
rainbow_linecolors
!P.MULTI=[0,1,3]	
ostimes=DINDGEN(1000)
osrates=DINDGEN(9,1000)
clear_utplot
utplot,ostimes,TOTAL(osrates[0:1,*],1),ytit='Corrected !CCts/s/det',/YLOG,yr=[1,10000],xtit='',charsize=1.5,xstyle=1,xmar=[6,1],ymar=[2,1],thick=5

img=TVRD()
DEVICE,/CLOSE
X
wdef,0
!p.MULTI=0
plot_image,img

STOP
END
