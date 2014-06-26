; dessine_un_symbole writes a certain symbol TYPE in an IMG array.
; this symbol has a SIZE, and XPOS and XPOS, and a VALUE (color)

; here, size is the length of one of the sides (diameter for circle)




;*******************
pro trace_un_cercle,img,xpos,ypos,size=size,value=value
pi=3.1415926
a=findgen(360)
img(xpos+size*cos(a*2*pi/360)/2, ypos+size*sin(a*2*pi/360)/2)=value
end
;*******************
pro trace_un_triangle,img,xpos,ypos,size=size,value=value
for i=0,size do begin
	x=xpos-size/2+i/2
	y=ypos-size*sqrt(3)/4+sqrt(3)*i/2
	if (x ge 0) AND (x lt 512) AND (y ge 0) AND (y lt 512) then img(x,y)=value
	x=xpos-size/2+i
	y=ypos-size*sqrt(3)/4
	if (x ge 0) AND (x lt 512) AND (y ge 0) AND (y lt 512) then img(x,y)=value
	x=xpos+size/2-i/2
	y=ypos-size*sqrt(3)/4+sqrt(3)*i/2
	if (x ge 0) AND (x lt 512) AND (y ge 0) AND (y lt 512) then img(x,y)=value
	end
end
;*******************
pro trace_un_carre,img,xpos,ypos,size=size,value=value
for i=-size/2.,size/2. do begin 
	x=xpos+i
	y=ypos+size/2.
	if (x ge 0) AND (x lt 512) AND (y ge 0) AND (y lt 512) then img(x,y)=value
	x=xpos+i
	y=ypos-size/2.
	if (x ge 0) AND (x lt 512) AND (y ge 0) AND (y lt 512) then img(x,y)=value
	x=xpos+size/2.
	y=ypos+i
	if (x ge 0) AND (x lt 512) AND (y ge 0) AND (y lt 512) then img(x,y)=value
	x=xpos-size/2.
	y=ypos+i
	if (x ge 0) AND (x lt 512) AND (y ge 0) AND (y lt 512) then img(x,y)=value
	end
end

;*******************
pro trace_un_losange,img,xpos,ypos,size=size,value=value
for i=0,size/sqrt(2) do begin
	x=xpos+i
	y=ypos+size/sqrt(2)-i
	if (x ge 0) AND (x lt 512) AND (y ge 0) AND (y lt 512) then img(x,y)=value
	x=xpos+size/sqrt(2)-i
	y=ypos-i
	if (x ge 0) AND (x lt 512) AND (y ge 0) AND (y lt 512) then img(x,y)=value
	x=xpos-i
	y=ypos-size/sqrt(2)+i
	if (x ge 0) AND (x lt 512) AND (y ge 0) AND (y lt 512) then img(x,y)=value
	x=xpos-size/sqrt(2)+i
	y=ypos+i
	if (x ge 0) AND (x lt 512) AND (y ge 0) AND (y lt 512) then img(x,y)=value
	end
end
;*******************
pro trace_un_nabla,img,xpos,ypos,size=size,value=value
for i=0,size do begin
		x=xpos-size/2.+i/2.
		y=ypos+size*sqrt(3)/4-sqrt(3)*i/2
		if (x ge 0) AND (x lt 512) AND (y ge 0) AND (y lt 512) then img(x,y)=value
		x=xpos-size/2.+i
		y=ypos+size*sqrt(3)/4
		if (x ge 0) AND (x lt 512) AND (y ge 0) AND (y lt 512) then img(x,y)=value
		x=xpos+size/2.-i/2.
		y=ypos+size*sqrt(3)/4-sqrt(3)*i/2.
		if (x ge 0) AND (x lt 512) AND (y ge 0) AND (y lt 512) then img(x,y)=value
		end
end
;*******************
pro trace_une_croix,img,xpos,ypos,size=size,value=value
for i=0,size do begin
		x=xpos-size/sqrt(2)/2+i/sqrt(2)
		y=ypos+size/sqrt(2)/2-i/sqrt(2)
		if (x ge 0) AND (x lt 512) AND (y ge 0) AND (y lt 512) then img(x,y)=value
		x=xpos-size/sqrt(2)/2+i/sqrt(2)
		y=ypos-size/sqrt(2)/2+i/sqrt(2)
		if (x ge 0) AND (x lt 512) AND (y ge 0) AND (y lt 512) then img(x,y)=value
		end
end
;*******************








pro dessine_un_symbole,img,type=type,xpos,ypos,size=size,value=value
if not exist(type) then type =0
if not exist(size) then size =10
if not exist(value) then value=255   ; ou bien max(img)... 
				     ; ou bien (!D.table_size-1)...

;so far, I presume that img=bytarr(512,512)...
if type eq 1 then trace_un_carre,img,xpos,ypos,size=size,value=value
if type eq 0 then trace_un_cercle,img,xpos,ypos,size=size,value=value
if type eq 2 then trace_un_losange,img,xpos,ypos,size=size,value=value
if type eq 3 then trace_un_triangle,img,xpos,ypos,size=size,value=value
if type eq 4 then trace_un_nabla,img,xpos,ypos,size=size,value=value
if type eq 5 then trace_une_croix,img,xpos,ypos,size=size,value=value
end



