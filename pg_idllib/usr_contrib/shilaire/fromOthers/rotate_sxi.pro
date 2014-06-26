FUNCTION rotate_sxi,hmap

; rmap=rotate_sxi(hmap)


dim=n_elements(hmap)
rrmap=hmap 

for i=0,dim-1 do begin
  rangle=360.-hmap(i).roll_angle
  rmap=rot_map(hmap(i),rangle,center=[0.,0.])
  rrmap(i)=rmap
endfor

return,rrmap

END