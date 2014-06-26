
PRO mycolortest

band=bindgen(256)
res=lindgen(256)

wdef,0
for i=0,255 do BEGIN
	 for j=0,2 do BEGIN 
		plots,[i,i+1],[50*j+10,50*j+40],color=band(i)*(256L^j)
		      ENDFOR
	bla=res(i)
	bla=bla+256L*(bla+256L*bla)
	plots,[i,i+1],[50*j+40,50*j+100],color=bla	
	       ENDFOR
END
