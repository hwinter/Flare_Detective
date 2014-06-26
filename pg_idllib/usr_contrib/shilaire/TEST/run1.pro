
PRO run1

bandsize=5	;pixels



ragfile='/ftp/pub/hedc/fs/data1/rag/observations/1999/09/08/19990908121500i.fit.gz'
hessifile='hessifits/data/test/hsi_20000901_000000_000.fits'
outfile='test.fits'

ragfitsread,ragfile,image,xaxis,yaxis
bla=mrdfits(hessifile,7)
rates=bla(0:224).countrate

for i=0,224 do begin
	for j=0,39 do begin
		for k=0,8 do begin
			for l=0,bandsize-1 do begin
				image(i*40+j,bandsize*k+l)=rates(k,i)
			endfor
		endfor
	endfor
endfor

img=congrid(image,512,200)
tvscl,img

ragfitswrite,image,xaxis,yaxis,dateobs='1999/09/08',filename='test2.fits',scaling='byte'

END


















