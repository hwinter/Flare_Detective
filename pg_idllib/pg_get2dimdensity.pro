;+
;
; NAME:
;        pg_get2dimdensity
;
; PURPOSE: 
;        transform a two dimensional data set given by (x,y) in a
;        n by m density matrix
;
; CALLING SEQUENCE:
;
;        res=pg_get2dimdensity(x,y [,nbinsx=nbinsx,nbinsy=nbinsy $
;                              ,maxx=maxx,minx=minx,maxy=maxy,miny=miny ])
;
; INPUTS:
;
;        x,y: 2 arrays with the x and y coordinates
;        nbinsx: the number of bins in the x direction (default=100
;        nbinsy: the number of bins in the y direction (default=100)
;        minx,maxx,miny,maxy: the min and max x and y coordinate of
;        the subset to transform ( default: min and max of input data)
;        
;
; OUTPUT:
;        res: a structure {density,x,y} where density is a nbinsx by
;        nbinsy matrix, x a nbinsx vector with the coordinates of the
;        x bin centers and y a nbinsy vector with the coordinates of the
;        y bin centers
;
; KEYWORDS:
;        spectrogram: if set, the structure uses the tag name
;        'SPECTROGRAM" for the density array
;        
; EXAMPLE:
;
; n=1000L
; x=randomn(3,n)*3
; y=randomn(4,n)*3
; nbinsx=10.
; nbinsy=10.
; minx=-8.
; maxx=8.
; miny=-8.
; maxy=8.
; dx=(maxx-minx)/nbinsx
; dy=(maxy-miny)/nbinsy
; xc=maxx-0.5*(maxx-minx)
; yc=maxy-0.5*(maxy-miny)
; st=pg_get2dimdensity(x,y,nbinsx=nbinsx,nbinsy=nbinsy,minx=minx,maxx=maxx,miny=miny,maxy=maxy)      
;        
;
; VERSION:
;
;        24-SEP-2003 written
;        09-SEP-2004 added /spectrogram keyword
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

FUNCTION pg_get2dimdensity,x,y,nbinsx=nbinsx,nbinsy=nbinsy,spectrogram=spectrogram $
                          ,maxx=maxx,minx=minx,maxy=maxy,miny=miny


IF NOT exist(nbinsx) THEN nbinsx=100. ELSE nbinsx=double(nbinsx >1)
IF NOT exist(nbinsy) THEN nbinsy=100. ELSE nbinsy=double(nbinsy >1)

IF NOT exist(maxx) THEN maxx=max(x)
IF NOT exist(minx) THEN minx=min(x)
IF NOT exist(maxy) THEN maxy=max(y)
IF NOT exist(miny) THEN miny=min(y)


xbinsize=(maxx-minx)/nbinsx
ybinsize=(maxy-miny)/nbinsy

;xokind=where((x GE minx) AND (x LE maxx),countx)
;yokind=where((y GE miny) AND (y LE maxy),county)
;ind=where((histogram(xokind) GT 0) AND (histogram(yokind) GT 0))
;find the common subset of xokind and yokind

;much easier
ind=where((x GE minx) AND (x LE maxx) AND (y GE miny) AND (y LE maxy),count)

;stop

IF (count EQ 0) THEN BEGIN 
;   print,'Count zero!'
   RETURN,-1
ENDIF


x2=x[ind]
y2=y[ind]

hx=floor((x2-minx)/xbinsize);x coordinates --> bin index array
hy=floor((y2-miny)/ybinsize);same for y

h=hx+nbinsx*hy;transform the 2 dim bin indices in a single bin index array

out=histogram(h,min=0,max=nbinsx*nbinsy-1);get the number of points in each bin

res=reform(out,nbinsx,nbinsy) ; retransform back to a 2 dim array

xres=findgen(nbinsx)/nbinsx*(maxx-minx)+minx+xbinsize*0.5;x coor. of bin centers
yres=findgen(nbinsy)/nbinsy*(maxy-miny)+miny+ybinsize*0.5;y coor. of bin centers

IF keyword_set(spectrogram) THEN $
   RETURN,{spectrogram:res,x:xres,y:yres} $
ELSE $
   RETURN,{density:res,x:xres,y:yres}

END

