;+
; NAME:
;      pg_plot_postime
;
; PURPOSE: 
;      plots the time evolution of the positions
;
; CALLING SEQUENCE:
;
;      pg_plot_postime,elpos,time=time,flux=flux,posmin=posmin,posmax=posmax
;
; INPUTS:
;            
;      elpos: fitted, elaborated positions (output of
;             pg_transform_pos)
;      flux,time: data array, position are overplotted on that
;      posmin,max: value used to rescale the positions between min and max
;
; OUTPUTS:
;      
;      
; KEYWORDS:
;      
;
; HISTORY:
;
;      17-NOV-2004 written PG
;      
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

PRO pg_plot_postime,elpos,time=time,flux=flux,titlearr=titlearr $
       ,posminrange=posminrange,posmaxrange=posmaxrange,perp=perp


M=n_elements(elpos.pos[0,*])
N=n_elements(elpos.pos[*,0])

pg_setplotsymbol,'STAR'
psym=-8

posminrange=fcheck(posminrange,replicate(0.5,N))
posmaxrange=fcheck(posmaxrange,replicate(5.5,N))
titlearr=fcheck(titlearr,replicate(' ',N))
 
FOR i=0,N-1 DO BEGIN

   ;plot the flux first
   utplot,time-time[0],flux,time[0],/xstyle,ystyle=8,xmargin=[8,8] $
         ,title=titlearr[i]
      
   ;get the time of the disconnected piece peak frames in avtime
   t=*elpos.tpos[i,0]

   FOR j=1,M-1 DO BEGIN
      t=[[t],[*elpos.tpos[i,j]]]
   ENDFOR

   avtime=0.5*(t[0,*]+t[1,*])
   avtime=avtime[*elpos.nanind[i]]
   ;avvtime now ok

   ;index of the (dis-)connected piec pof avtime
   ind=pg_get_connession_index(avtime,tol=1.)

   ;parallel position
   parallelp=*elpos.parallp[i]

   ;treat perp pos like parallel if needed
   IF keyword_set(perp) THEN parallelp=*elpos.perpp[i]

   ;rescale it between the input range
   pparallelp=(parallelp-min(parallelp))/(max(parallelp)-min(parallelp)) $
             *(posmaxrange[i]-posminrange[i])+posminrange[i]

   ;oplot the data piecewise
   outplot,avtime[0:ind[0]]-time[0],pparallelp[0:ind[0]],time[0],psym=psym
   FOR k=0,n_elements(ind)-2 DO BEGIN
     outplot,avtime[ind[k]+1:ind[k+1]]-time[0],pparallelp[ind[k]+1:ind[k+1]] $
            ,time[0],psym=psym
   ENDFOR
   outplot,avtime[ind[n_elements(ind)-1]+1:n_elements(avtime)-1]-time[0] $
          ,pparallelp[ind[n_elements(ind)-1]+1:n_elements(avtime)-1] $
          ,time[0],psym=psym
   ;done outplotting

   ;generate the vertical axis on the left side of the plot

   ;scale yrange
   yr=!Y.crange
   eyr=[posminrange[i],posmaxrange[i]]
   dyr=[min(parallelp),max(parallelp)]

   dxyfinal=(dyr[1]-dyr[0])*(yr[1]-yr[0])/(eyr[1]-eyr[0])
   xfinal=dyr[0]-dxyfinal*(eyr[0]-yr[0])/(yr[1]-yr[0])
   yfinal=xfinal+dxyfinal

   axis,/yaxis,yrange=[xfinal,yfinal],/ystyle
      
ENDFOR


END