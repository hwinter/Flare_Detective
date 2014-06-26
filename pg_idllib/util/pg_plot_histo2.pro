;+
; NAME:
;
; pg_plot_histo
;
; PURPOSE:
;
; computes and plots the distribution of an array
;
; CATEGORY:
;
; various utilities
;
; CALLING SEQUENCE:
;
; pg_plot_histo,y,min=min,max=max,binsize=binsize,xedges=xedges,histo=histo
;
; INPUTS:
;
; y: the input array
;
; OPTIONAL INPUTS:
;
; min: minimal value for the histogram DEFAULT: min(y)
; max: maximal value for the histogram DEFAULT: max(y)
; binsize: histogram bin size          DEFAULT: 0.1*(max(y)-min(y))
; nbins: can be used in alternative to binsize, number of bins. Is
;        ignored if binsize is present
; 
; KEYWORD PARAMETERS:
;
; xlog: if set, plots a logarithmic distribution...
;
; OUTPUT:
;
; NONE
;
; OPTIONAL OUTPUTS:
;
; xedges: edges of the histogram
; histo: values of the histogram
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
; 
; a=[0.2,0.5,0.9,1.1,4.3,5.1,5.1] & min=0. & max= 6. & binsize=1.
; pg_plot_histo,a,min=min,max=max,binsize=binsize,yrange=[-1,4],xrange=[-1,7]
;
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 07-JAN-2004 written P.G.
; 03-MAY-2004 corrected a bug which caused incorrect line styles/thicknesses
; 14-JUL-2004 corrected a bug which appeared if x axis increased
;             toward the left
; 31-AUG-2004 added nbins and xlog keyword
;
;-

;.comp ~/pand_rapp_idl/util/pg_plot_histo.pro

PRO pg_plot_histo,y,min=minn,max=maxx,binsize=binsize,nbins=nbins $
                 ,overplot=overplot,xlog=xlog,xrange=xrange $
                 ,x_edges=x_edges,histo=histo,color=color,ylog=ylog $
                 ,nan=nan,linestyle=linestyle,thick=thick,_extra=_extra

minn=fcheck(minn,min(y))
maxx=fcheck(maxx,max(y))
xrange=fcheck(xrange,[minn,maxx])

IF keyword_set(xlog) THEN BEGIN

   logy=alog(y)
   logmin=alog(minn)
   logmax=alog(maxx)

   IF NOT exist(binsize) AND exist(nbins) THEN $

      binsize=float(logmax-logmin)/(nbins>1)

      binsize=fcheck(binsize,0.1*(logmax-logmin))

      pg_plot_histo,logy,min=logmin,max=logmax,binsize=binsize $
                   ,xrange=alog(xrange),xstyle=1B+4+8,thick=thick

      axis,xaxis=0,xrange=xrange,xstyle=1,xlog=1
      axis,xaxis=1,xrange=xrange,xstyle=1,xlog=1 $
          ,xtickname=replicate(' ',32)

      pg_plot_histo,logy,min=logmin,max=logmax,binsize=binsize,xstyle=1,/over $
                   ,thick=thick,xrange=alog(xrange)
  
      RETURN
   ENDIF


IF NOT exist(binsize) AND exist(nbins) THEN binsize=float(maxx-minn)/(nbins>1)

binsize=fcheck(binsize,0.1*(maxx-minn))

nbins=ceil((maxx-minn)/binsize)

x_edges=transpose(reform(minn+[findgen(nbins)*binsize, $
             findgen(nbins)*binsize+binsize],nbins,2))
edge_products,x_edges,mean=x

histo=histogram(y,binsize=binsize,min=minn,max=minn+nbins*binsize,nan=nan)


IF NOT keyword_set(overplot) THEN BEGIN 
   plot,x,histo,psym=10,ylog=ylog,linestyle=linestyle,thick=thick $
               ,xrange=xrange,_extra=_extra
   IF n_elements(color) NE 0 THEN $
     oplot,x,histo,psym=10,color=color $
          ,linestyle=linestyle,thick=thick
ENDIF ELSE $
   oplot,x,histo,psym=10,color=color,linestyle=linestyle,thick=thick

IF keyword_set(ylog) THEN zero=(machar()).xmin ELSE zero=0.
;needed for plots with y log scale, otherwise it won't plot
;correctly!


;plot histogram boundaries!
oplot,[x_edges[0,0],x_edges[0,0]],[zero,histo[0]],color=color $
     ,linestyle=linestyle,thick=thick
oplot,[x_edges[0,0],x_edges[1,0]],[histo[0],histo[0]],color=color $
     ,linestyle=linestyle,thick=thick
oplot,[min(!X.crange),x_edges[0,0]],[0,0],color=color $
     ,linestyle=linestyle,thick=thick
oplot,[x_edges[1,nbins-1],x_edges[1,nbins-1]],[zero,histo[nbins-1]] $
     ,color=color,linestyle=linestyle,thick=thick
oplot,[x_edges[0,nbins-1],x_edges[1,nbins-1]],[histo[nbins-1],histo[nbins-1]] $
     ,color=color,linestyle=linestyle,thick=thick
oplot,[x_edges[1,nbins-1],max(!X.crange)],[0,0],color=color $
     ,linestyle=linestyle,thick=thick


END
