pro make_puff

infil = findfile('*.genx')
n_in = n_elements(infil)
for i = 0, n_in-1 do begin
  restgen,file=infil(i),index,data,xx,yy
  plots,xx,yy,/dev
endfor
end
