img=DIST(600,300)
cube=img
FOR i=1,241 DO cube=[[[cube]],[[i*img-i]]]
cube=BYTSCL(cube)
PRINT,"Size: "+strn(sizeof(cube)/1024^2)
PRINT,"Hostname: "+GETENV('HOSTNAME')
psh_cube2mpeg, cube, '/global/pandora/home/shilaire/scratch.mpg'

END

