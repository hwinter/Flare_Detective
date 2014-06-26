;to scale my 'themovie.dat' from 0 to 33 to 0 to 255 (with 5-layer contours...)

; later, I'll have to program something to up/down scale movies according to my specs ...

pro runner2,inmovie,outmovie
S=size(inmovie)
outmovie=inmovie
cont=bytarr(512,512,S[3])
for i=0,511 do begin
	for j=0,511 do begin
		for k=0,S[3]-1 do begin
					
			if inmovie(i,j,k) gt 28 then begin 
						cont(i,j,k)=inmovie(i,j,k)-28
						outmovie(i,j,k)=0
						print,'Percent done : ',(i+1)*(j+1)(k+1)/(512*512*S[3])
						end		
  				  end
			end
		end
outmovie=bytscl(temporary(outmovie),top=250)
for i=0,511 do begin
	for j=0,511 do begin
		for k=0,S[3]-1 do begin
			if cont(i,j,k) gt 0 then outmovie(i,j,k)=250+cont(i,j,k)
				end
			end
		end
end
