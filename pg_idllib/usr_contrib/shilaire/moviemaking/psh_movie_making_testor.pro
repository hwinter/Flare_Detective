PRO psh_movie_making_testor
	img=DIST(500)
	cube=img
	FOR i=1,200 DO cube=[[[cube]],[[i*img-i]]]
	cube=BYTSCL(cube)
	PRINT,"Size: "+strn(sizeof(cube)/1024^2)
	psh_cube2mpeg, cube, '/global/pandora/home/shilaire/scratch.mpg'
END


