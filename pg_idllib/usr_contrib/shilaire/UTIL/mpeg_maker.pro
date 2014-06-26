; created by PSH on 25 nov 2000
; to convert an image cube to a movie...
; movie is the data array
; mpegfile is the mpeg filename...
; one can rebin by the bin factor (positive integer!) (try CONGRID later on ?)

;******************* old version  (I keep it as a reminder...)
;pro mpeg_maker,movie,filename=filename,bin=bin 	
;if not exist(filename) then filename='/global/helene/home/www/staff/shilaire/private/scratch.mpg'
;if not exist(bin) then bin=1
;
;S=size(movie)
;id=mpeg_open([bin*S[1],bin*S[2]])
;myct,nb=max(movie(*,*,0))+1
;window,0,xsize=bin*S[1],ysize=bin*S[2]
;for i=0,s[3]-1 do begin
;		if bin eq 1 then tvscl,movie(*,*,i),top=max(movie(*,*,i))
;		if bin gt 1 then tvscl,rebin(movie(*,*,i),bin*S[1],bin*S[2],S[3]),top=max(movie(*,*,i))
;		mpeg_put,id,frame=i,window=0,/order,/color  		
;		end
;
;mpeg_save,id,filename=filename
;mpeg_close,id
;print,' DONE ! '
;end
;**********************

; one could increase size from (ex.) 64x64 to 512x512 like this :
; mpeg_maker,rebin(movie,512,512

;window=[!d.window,0,0,sx,sy]	




;************* NEWEST VERSION... ********************
; Here, one is supposed to input the movie, a byte array (already scaled...)
; the proper color table is already loaded...

pro mpeg_maker,movie,filename=filename
if not exist(filename) then filename='/global/helene/home/www/staff/shilaire/private/MOVIES/scratch.mpg'
tvlct,r,g,b,/get
S=size(movie)
id=mpeg_open([S[1],S[2]])
image=bytarr(3,S[1],S[2])
for i=0L,s[3]-1 do begin
		image(0,*,*)=r(movie(*,*,i))
		image(1,*,*)=g(movie(*,*,i))
		image(2,*,*)=b(movie(*,*,i))
		mpeg_put,id,frame=i,image=image,/order,/color  		
		print,'    Percent done : ', 100*(i+1)/s[3]
		end

mpeg_save,id,filename=filename
mpeg_close,id
print,' DONE ! '
end
