;+
; NAME:
;
;  pg_makeqtimemovie
;
; PURPOSE:
;
; Produces a quick-time movie from a 3dimensional array (nx x ny x nframes).
; This only work on Mac compouters with QuickTime Pro. Spawns an open source
; command line interface to Quicktime (QT_TOOLS, see http://omino.com/sw/qt_tools/).
;
; CATEGORY:
;
; Hollywood
;
; CALLING SEQUENCE:
;
; pg_makeqtmovie,imset,moviefile=moviefile [,tmpdir=tmpdir]
;
; INPUTS:
;
; imset: a NX x NY x NFRAMES image cube
; moviefilename: name of the output .mov file. Warning: if it already exist, it
;                will be overwritten. Default: /tmp/idlmovie.mov
;
; OPTIONAL INPUTS:
; 
; tmpdir: temporary directory, the single frames are temporarily stored there as
;         png images. Default: /tmp/tmpframedir
; qt_tolls_dir: the directort with the qt_tools. Normally, there is no reason
;               why you should change this from its default value.
; datarate: controls the quality and size of the movie. Higher values give
;           better quality and larger size (default 500 kilobytes/sec).
; framerate: frames per second of the movie (default 25 frames /sec)
; videocodec: the video compressor. Default is "avc1" (that is, H.264).
;             It is given as a 4-letter code, and the availability
;             of a given compressor may depend on your machine. You can find out
;             which compressors are available in your machine by going to the
;             qt_tools bin directory and issuing qt_thing --type='imco'
;             On my machine I get the following results:
;
;                8BPS   "Apple Planar RGB"
;                SVQ1   "Sorenson Videoª Compressor"
;                SVQ3   "Sorenson Video 3 Compressor"
;                WRLE   "Apple BMP"
;                avc1   "H.264"
;                cvid   "Apple Cinepak"
;                dv5n   "Apple DVCPRO50 - NTSC"
;                dv5p   "Apple DVCPRO50 - PAL"
;                dvc    "Apple DV/DVCPRO - NTSC"
;                dvcp   "Apple DV - PAL"
;                dvpp   "Apple DVCPRO - PAL"
;                h261   "Apple H.261"
;                h263   "H.263"
;                h263   "Apple VC H.263"
;                icod   "Apple Intermediate Codec"
;                jpeg   "Apple Photo - JPEG"
;                mjp2   "JPEG 2000 Encoder"
;                mjpa   "Apple Motion JPEG A"
;                mjpb   "Apple Motion JPEG B"
;                mp4v   "Apple MPEG4 Compressor"
;                png    "Apple PNG"
;                pxlt   "Apple Pixlet Video"
;                raw    "Apple None"
;                rle    "Apple Animation"
;                rpza   "Apple Video"
;                smc    "Apple Graphics"
;                tga    "Apple TGA"
;                tiff   "Apple TIFF"
;                yuv2   "Apple Component Video - YUV422"
;
; KEYWORD PARAMETERS:
;
; saveframes: if set, does not remove the png frames
; showmovie: if set, spawn QuickTime and plays the movie
;
; OUTPUTS:
;
; NONE
;
; OPTIONAL OUTPUTS:
;
; NONE
;
; COMMON BLOCKS:
;
; NONE
;
; SIDE EFFECTS:
;
; Warning: this routine will *overwrite* the input file given as "moviefile"!
; Creates temporary png images of each frame in a user-specified directory and
; creates a movie file.
;
; RESTRICTIONS:
;
; Only works on Macs that can run QuickTime Pro and qt_tools. A copy of qt_tools
; is available at SAO in ...
; Use set_plot,'Z' if this need to run from a cron job.
;
; PROCEDURE:
;
; Creates temporary png imags of each frame and spawns "qt_export".
;
; EXAMPLE:
;
; a=findgen(128,128,16)
; loadct,3
; pg_makeqtimemovie,a,/showmovie
;
; AUTHOR:
; Paolo Grigis, SAO
; pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
; 02-APR-2008 written PG
; 03-APR-2008 adapted for SSXG general use PG
;
;-

PRO pg_makeqtimemovie,imset,moviefile=moviefile,tmpdir=tmpdir,showmovie=showmovie $
                     ,datarate=datarate,framerate=framerate,videocodec=videocodec $
                     ,saveframes=saveframes,qt_tools_dir=qt_tools_dir,noscale=noscale


IF n_elements(datarate)  EQ 0 THEN datarate='500' ELSE datarate =strtrim(string(datarate) ,2)
IF n_elements(framerate) EQ 0 THEN framerate='25' ELSE framerate=strtrim(string(framerate),2)

IF n_elements(moviefile)    EQ 0 OR size(moviefile,/tname) NE 'STRING'    THEN moviefile='/tmp/idlmovie.mov'
IF n_elements(videocodec)   EQ 0 OR size(videocodec,/tname) NE 'STRING'   THEN videocodec='avc1'
IF n_elements(qt_tools_dir) EQ 0 OR size(qt_tools_dir,/tname) NE 'STRING' THEN qt_tools_dir='/proj/DataCenter/IDL_DIR/qt_tools'
IF n_elements(tmpdir)       EQ 0 OR size(tmpdir,/tname) NE 'STRING'       THEN tmpdir='/tmp/tmpframedir/'

s=size(imset)

IF s[0] NE 3 THEN BEGIN 
   print,'Invalid input. Needs a NX by NY by NFRAMES 3-dimensional array.'
   RETURN 
ENDIF

nx=s[1]
ny=s[2]
nt=s[3]

ndigit=ceil(alog10(nt+1))



IF NOT file_exist(tmpdir) THEN file_mkdir,tmpdir

filelist=strarr(nt)
thistime=time2file(!stime,/sec)

tvlct,r,g,b,/get

themin=min(imset)
themax=max(imset)

FOR i=0,nt-1 DO BEGIN 
   filelist[i]=tmpdir+'frame_'+thistime+'_'+smallint2str(i,strlen=ndigit)+'.png'
   IF keyword_set(noscale) THEN $
      im=imset[*,*,i] $
   ELSE $
      im=bytscl(imset[*,*,i],min=themin,max=themax)
   write_png,filelist[i],im,r,g,b
ENDFOR



commandstring=qt_tools_dir+'/pieces/bin/qt_export  --datarate='+datarate+' --sequencerate=' $
             +framerate+'  '+filelist[0]+' --video='+videocodec+' '+moviefile

IF file_exist(moviefile) THEN file_delete,moviefile
spawn,commandstring

IF keyword_set(showmovie) THEN BEGIN 
   spawn,"open "+moviefile
ENDIF

IF NOT keyword_set(saveframes) THEN file_delete,filelist

END



