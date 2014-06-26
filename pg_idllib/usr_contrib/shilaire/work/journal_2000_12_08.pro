;******************* TO MAKE A NICE .ps PLOT OF TRACE, HXT AND NRH  **************
;read_nrh,'mylepus/nrh/nrh2_1640_h70_19990908_121459:07_c.fts',index,data,hbeg='12:15:10'
;index2map,index,data,nrh_164_map
;...etc...
;
;nrh_164_map.data=nrh_164_map.data/max(nrh_164_map.data)
;nrh_2366_map.data=nrh_2366_map.data/max(nrh_2366_map.data)
;nrh_327_map.data=nrh_327_map.data/max(nrh_327_map.data)   
;nrh_4105_map.data=nrh_4105_map.data/max(nrh_4105_map.data)
;nrh_432_map.data=nrh_432_map.data/max(nrh_432_map.data)   
;
;
;
myct2,nb=256

plot_map,trace_map(46),/log,grid=10,ncolors=250
			; xrange,yrange ???
xloadct,ncolors=250	;fiddle with the color table, to see best possible puff
tvlct,r,g,b,/get	; get the r,g,b settings (to make .ps file)
set_plot,'ps'
device,/color,filename='mylepus/DOCS/Berk_dec_2000/trace_nrh_hxt_1.ps',xsize=18,ysize=18
tvlct,r,g,b

plot_map,trace_map(46),/log,grid=10,ncolors=250		; xrange,yrange....
;and trace_map(94)

plot_map,nrh_164_map,/over,lcolor=250,cthick=5,levels=[0.98,0.99]
plot_map,nrh_2366_map,/over,lcolor=251,cthick=5,levels=[0.98,0.99]
plot_map,nrh_327_map,/over,lcolor=252,cthick=5,levels=[0.98,0.99] 
plot_map,nrh_4105_map,/over,lcolor=253,cthick=5,levels=[0.98,0.99]
plot_map,nrh_432_map,/over,lcolor=254,cthick=5,levels=[0.98,0.99]   

plot_map,hxt_map,/over,lcolor=0,cthick=1

device,/close
set_plot,'x'


