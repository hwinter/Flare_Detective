; uses smooth_edge.pro on part of an image


FUNCTION smooth_edge_part,inimg,xmin,xmax,ymin,ymax,w=w,e=e

IF not keyword_set(w) then w=2
IF not keyword_set(e) then e=1

outimg=inimg

tmp=smooth_edge(outimg(xmin:xmax,ymin:ymax),w,e)
outimg(xmin:xmax,ymin:ymax)=tmp

RETURN,outimg
END
