
;IDL5.5:
RESTORE,'~/psh_data/HXR_DCIMdata/movies_other_events.dat',/VERB
mwrfits,{data:M000621A},'tmp1.fits',/CREATE
mwrfits,{data:M000621B},'tmp2.fits',/CREATE
mwrfits,{data:M000707},'tmp3.fits',/CREATE
mwrfits,{data:M000712},'tmp4.fits',/CREATE
mwrfits,{data:M000825A},'tmp5.fits',/CREATE
mwrfits,{data:M000825B},'tmp6.fits',/CREATE
mwrfits,{data:M990611},'tmp7.fits',/CREATE
mwrfits,{data:M990612},'tmp8.fits',/CREATE



;IDL5.3:
myct3,ct=1

bla=mrdfits('tmp1.fits',1)
mpeg_maker,bla.data,filename='movie_20000621A.mpg'
bla=mrdfits('tmp2.fits',1)
mpeg_maker,bla.data,filename='movie_20000621B.mpg'
bla=mrdfits('tmp3.fits',1)
mpeg_maker,bla.data,filename='movie_20000707.mpg'
bla=mrdfits('tmp4.fits',1)
mpeg_maker,bla.data,filename='movie_20000712.mpg'
bla=mrdfits('tmp5.fits',1)
mpeg_maker,bla.data,filename='movie_20000825A.mpg'
bla=mrdfits('tmp6.fits',1)
mpeg_maker,bla.data,filename='movie_20000825B.mpg'
bla=mrdfits('tmp7.fits',1)
mpeg_maker,bla.data,filename='movie_19990611.mpg'
bla=mrdfits('tmp8.fits',1)
mpeg_maker,bla.data,filename='movie_19990612.mpg'

PRINT,"Don't forget to remove the tmp*.fits files, and displace the mpegs to my www directory !"
PRINT,"Then do other ones (if any...)"




