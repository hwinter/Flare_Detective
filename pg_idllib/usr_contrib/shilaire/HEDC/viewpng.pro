;PSH, May 1st,2001

PRO viewpng,filename
img=read_png('~/HESSI/hedc_data/'+filename,r,g,b)
tvlct,r,g,b
wdef
tv,img
END
