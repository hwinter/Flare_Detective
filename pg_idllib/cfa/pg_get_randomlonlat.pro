;
;retrieve random longitudes, latitudes on a sphere
;

PRO pg_get_randomlonlat,seed,n,lon=longitude,lat=latitude

   xpos=randomn(seed,n*3)
   ypos=randomn(seed,n*3)
   zpos=randomn(seed,n*3)

   r=sqrt(xpos*xpos+ypos*ypos+zpos*zpos)
   
   xpos=xpos/r
   ypos=ypos/r
   zpos=zpos/r

   ind=where(xpos GT 0)
   xpos=xpos[ind]
   ypos=ypos[ind]
   zpos=zpos[ind]

;covert from x,y,z to phi,theta spherical coordinates
   phi=atan(ypos,xpos)
   theta=atan(sqrt(xpos*xpos+ypos*ypos),zpos)

;compute heliographic longitude and latitude
   longitude=phi/!pi*180
   latitude=-theta/!Pi*180+90

   IF n_elements(longitude) LE n THEN $
      pg_get_randomlonlat,seed,n,lon=longitude,lat=latitude 
   
   longitude=longitude[0:n-1]
   latitude =latitude[0:n-1]

END
