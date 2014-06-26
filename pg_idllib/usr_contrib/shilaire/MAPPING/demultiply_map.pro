

FUNCTION demultiply_map,map

nbmap=n_elements(map)

outmap=map(0)
for i=0,nbmap-2 do begin
	addmap=map(i)
	addmap.time=anytim((anytim(map(i).time)+anytim(map(i+1).time))/2.,/vms)
	tmpmap=[outmap,map(i)]
	outmap=[tmpmap,addmap]
endfor
outmap=[outmap,map(nbmap-1)]

nb=n_elements(outmap)
outmap=outmap(1:nb-1)

RETURN,outmap
END
