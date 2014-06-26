;
;
;


;load files

file1='~/machd/gbandauto/level0/gband_day_2008_088_bin2.sav'
file0='~/machd/gbandauto/level1/gband_day_2008_088_bin2.sav'

IF file_exist(file0) THEN restore,file0
IF file_exist(file1) THEN restore,file1

wdef,1,1024,1024
pg_plotimage,datap2[*,*,0],/iso,xstyle=1+4+8,ystyle=1+4+8
oplot,512+32*[-1,1,1,-1,-1],512+32*[-1,-1,1,1,-1]

im=tvrd(/true)
write_png,'~/gbandstuff/gbandim.png',im

plot_image,datap2[512-32:512+32,512-32:512+32,0]



