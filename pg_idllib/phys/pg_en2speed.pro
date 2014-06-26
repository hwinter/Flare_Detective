;
;
;returns the speed (in cm sec^-1) of a particle with energy 'energy' in keV
;
;


FUNCTION pg_en2speed,energy,mass=mass

mass=fcheck(mass,1)

kine=energy/(511d *mass )

voverc=sqrt(kine*(kine+2)/(1+kine)^2)

speed=3d10*voverc

return,speed

END

