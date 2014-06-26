;+
; NAME:
;      pg_plot_2pos
;
; PURPOSE: 
;      plots the time evolution of the positions for 2 different fittings
;
; CALLING SEQUENCE:
;
;      pg_plot_2pos,pos1,pos2,time=time,flux=flux,posmin=posmin,posmax=posmax
;
; INPUTS:
;            
;      pos1,pos: fitted position structure
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

PRO pg_plot_2pos,pos1,pos2,time=time,flux=flux,titlearr=titlearr $
       ,posminrange=posminrange,posmaxrange=posmaxrange,perp=perp


M=n_elements(pos1.pos[0,*])
N=n_elements(pos2.pos[*,0])

pg_setplotsymbol,'STAR'
psym=8
psym2=4

posminrange=fcheck(posminrange,replicate(0.5,N))
posmaxrange=fcheck(posmaxrange,replicate(5.5,N))
titlearr=fcheck(titlearr,replicate(' ',N))
 
FOR i=0,N-1 DO BEGIN

   ;plot the flux first
   utplot,time-time[0],flux,time[0],/xstyle,ystyle=8,xmargin=[8,8] $
         ,title=titlearr[i]
      
   ;get the time of the disconnected piece peak frames in avtime
   t=*pos1.tpos[i,0]

   FOR j=1,M-1 DO BEGIN
      t=[[t],[*pos1.tpos[i,j]]]
   ENDFOR

   avtime=0.5*(t[0,*]+t[1,*])
   avtime=avtime[*pos1.nanind[i]]
   ;avvtime now ok

   ;index of the (dis-)connected piec pof avtime
   ind=pg_get_connession_index(avtime,tol=1.)

   ;parallel position
   parallelp=*pos1.parallp[i]
   parallelp2=*pos2.parallp[i]


   ;treat perp pos like parallel if needed
   IF keyword_set(perp) THEN BEGIN
      parallelp=*pos1.perpp[i]
      parallelp2=*pos2.perpp[i]
   ENDIF


   ;rescale it between the input range
   pparallelp=(parallelp-min(parallelp))/(max(parallelp)-min(parallelp)) $
             *(posmaxrange[i]-posminrange[i])+posminrange[i]
   pparallelp2=(parallelp2-min(parallelp))/(max(parallelp)-min(parallelp)) $
             *(posmaxrange[i]-posminrange[i])+posminrange[i]

   ;oplot the data piecewise
   outplot,avtime[0:ind[0]]-time[0],pparallelp[0:ind[0]],time[0],psym=psym
   outplot,avtime[0:ind[0]]-time[0],pparallelp2[0:ind[0]],time[0],psym=psym2
;   outplot,[1,1]*avtime[0:ind[0]]-time[0] $
;          ,[pparallelp[0:ind[0]],pparallelp2[0:ind[0]]],time[0]

   FOR k=0,n_elements(ind)-2 DO BEGIN
     outplot,avtime[ind[k]+1:ind[k+1]]-time[0],pparallelp[ind[k]+1:ind[k+1]] $
            ,time[0],psym=psym
     outplot,avtime[ind[k]+1:ind[k+1]]-time[0],pparallelp2[ind[k]+1:ind[k+1]] $
            ,time[0],psym=psym2
;     outplot,[1,1]*avtime[ind[k]+1:ind[k+1]]-time[0] $
;            ,[pparallelp[ind[k]+1:ind[k+1]],pparallelp2[ind[k]+1:ind[k+1]]] $
;            ,time[0]
   ENDFOR
   outplot,avtime[ind[n_elements(ind)-1]+1:n_elements(avtime)-1]-time[0] $
          ,pparallelp[ind[n_elements(ind)-1]+1:n_elements(avtime)-1] $
          ,time[0],psym=psym
   outplot,avtime[ind[n_elements(ind)-1]+1:n_elements(avtime)-1]-time[0] $
          ,pparallelp2[ind[n_elements(ind)-1]+1:n_elements(avtime)-1] $
          ,time[0],psym=psym2
;   outplot,[1,1]*avtime[ind[n_elements(ind)-1]+1:n_elements(avtime)-1]-time[0]$
;          ,[ pparallelp[ind[n_elements(ind)-1]+1:n_elements(avtime)-1]$
;           ,pparallelp2[ind[n_elements(ind)-1]+1:n_elements(avtime)-1]] $
;          ,time[0]

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
