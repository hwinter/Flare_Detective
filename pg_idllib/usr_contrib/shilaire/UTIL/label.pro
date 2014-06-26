; by PSH , March 20th, 2001 : from book "USING IDL" pp.183-184

pro label,text,color=color
if not keyword_set(color) then color=!D.table_size-1
cursor,x,y,/normal,/down
xyouts,x,y,text,/normal,/noclip,color=color
end
