; by PSH - created on 25-nov-2000
; to display a movie/image whose top 5 color indices are reserved for contours
;	...using my own color table (see myct.pro)

;********** first version 25-nov-2000  **************
pro mystepper,movie,x=x
maxvalue=max(movie(*,*,0))
myct,nb=maxvalue+1
if not exist(x) then stepper,movie,/noscale
if exist(x) then xstepper,movie,/noscale
end
;*****************************************************

; other way to display a single contoured image: IDL>tvscl,image,top=max(image)
