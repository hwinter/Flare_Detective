
nbrlist='0'
FOR i=1,19 DO nbrlist=[nbrlist,strn(i)]
filelist='/global/helene/home/benz/Science/soho/new/'+nbrlist+'.gif'


n_imgs=N_ELEMENTS(filelist)
;reading images
READ_GIF,filelist[0],img,r,g,b
TVLCT,r,g,b
images=BYTARR(N_ELEMENTS(img[*,0]),N_ELEMENTS(img[0,*]),n_imgs)
FOR i=0,n_imgs-1 DO BEGIN			&$
	READ_GIF,filelist[i],img,r,g,b		&$
	images[*,*,i]=img			&$
	WRITE_GIF,'/global/saturn/data1/www/staff/shilaire/private/MOVIES/ABmovie/'+strn(i)+'.gif',movie[*,*,i],r,g,b	&$
ENDFOR					


orig_imgs=images
;cut the image array to the right portion of the image
xr=[87,508]
yr=[58,479]
imgs=images[xr[0]:xr[1],yr[0]:yr[1],*]


n=1
;making movie array, with each image appearing n times
movie=BYTARR(xr[1]-xr[0]+1,yr[1]-yr[0]+1,n_imgs*n)
FOR i=0,n_imgs-1 DO BEGIN				&$
	FOR j=0,n-1 DO BEGIN				&$
		movie[*,*,j+i*n]=imgs[*,*,i]		&$
	ENDFOR						&$
ENDFOR


; bytscale them....
;movie=BYTSCL(movie)
;loadct,5

;making javascript movie
;imagecube2jsmovie, movie, '/global/saturn/data1/www/staff/shilaire/private/MOVIES/ABmovie/'
jsmovie,'/global/saturn/data1/www/staff/shilaire/private/MOVIES/ABmovie/runme.html',nbrlist+'.gif'

;making mpeg
mpeg_maker,movie,filename='/global/saturn/data1/www/staff/shilaire/private/MOVIES/ABmovie/movie4.mpg'
