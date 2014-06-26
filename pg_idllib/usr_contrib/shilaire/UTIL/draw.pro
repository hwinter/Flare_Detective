; PSH, written March 20th,2001

pro draw , erase=erase, color=color

if keyword_set(erase) then erase
if not keyword_set(color) then color=!D.table_size-1

cursor,x,y,/normal,/down

while (!mouse.button NE 4) do begin
	cursor,x1,y1,/norm,/down
	plots,[x,x1],[y,y1],/normal,color=color
	x=x1 & y=y1
endwhile
end



