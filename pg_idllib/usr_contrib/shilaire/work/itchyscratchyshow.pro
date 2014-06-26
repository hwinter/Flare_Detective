

PRINT,'Starting itschiscratchyshow.pro...'
img=dist(100)
cube=[[[img]],[[10-img]],[[ALOG(15+img)]]]
PRINT,'Starting psh_cube2mpeg.pro...'
psh_cube2mpeg, cube, '/global/pandora/home/shilaire/scratch.mpg'
END
