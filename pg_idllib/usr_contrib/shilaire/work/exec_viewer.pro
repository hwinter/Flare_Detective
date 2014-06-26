; to make a movie out of image movies, with a couple of spectrograms....

; pas encore termine !!!

pro view_one_big_image,spect1,spect2,img1,img2,outimg

window,1,xsize=1024,ysize=1024	; dimensions TBD by number of spectrograms and images...

spect1c=congrid(spect1,1000,250)
spect2c=congrid(spect2,1000,250)
img1c=congrid(img1,512,512)
img2c=congrid(img2,512,512)

tv,spect1c,0,768
tv,spect2c,0,512
tv,img1c,0,0
tv,img2c,512,0

end


pro exec_viewer,outmovie
view_one_big_image,spect1,spect2,img1,img2,outimg
end
