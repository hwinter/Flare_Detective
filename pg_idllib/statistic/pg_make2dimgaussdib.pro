;+
; NAME:
;
;   pg_make2dimgaussdib
;
; PURPOSE:
;
;   returns random deviates with a 2-dimensional gaussian distribution
;
; CATEGORY:
;
;   statistics utilities
;
; CALLING SEQUENCE:
;
;   gdib=pg_make2dimgaussdib(xcenter=xcenter,ycenter=ycenter $
;           ,sigma1=sigma1,sigma2=sigma2,tiltangle=titltangle $
;           ,npart=npart [,seed=seed])
;
;
; INPUTS:
;
;   xcenter: x position of the center
;
;   ycenter: y position of the center
;
;   sigma1: sigma of the distribution along axis 1
;   
;   sigma2: sigma of the distribution along axis 2
;
;   tiltangle: angle between axis 1 and the x-axis in positive
;              direction (counterclockwise), in radiantes
;
;   npart: number of random deviates ("particles"). Default: 100
;
; OPTIONAL INPUTS:
;   seed: seed for the randomizer
;  
;
; KEYWORD PARAMETERS:
;
;   cutupx: if set, cut the gaussian distribution in direction 1
;           and folds it back around the axis 2.
;           
;
; OUTPUTS:
;
;   gdib: an array 2 by npart with the x and y position of each point
;
; OPTIONAL OUTPUTS:
;
;   seed: seed used by the randomizer
;   
;
; COMMON BLOCKS:
;
;   none
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
;   
; AUTHOR:
;
;   Paolo C. Grigis 
;   pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
;    18-MAY-2005 PG written
;
;-

FUNCTION pg_make2dimgaussdib,xcenter=xcenter,ycenter=ycenter $
                            ,sigma1=sigma1,sigma2=sigma2 $
                            ,tiltangle=tiltangle,npart=npart $
                            ,seed=seed,cutupx=cutupx

npart=fcheck(npart,100L)
xcenter=fcheck(xcenter,0.)
ycenter=fcheck(ycenter,0.)
sigma1=fcheck(sigma1,1.)
sigma2=fcheck(sigma2,1.)
tiltangle=fcheck(tiltangle,0.)

xvect=randomn(seed,npart)*sigma1
yvect=randomn(seed,npart)*sigma2

IF keyword_set(cutupx) THEN BEGIN
   xvect[*,0]=-abs(xvect[*,0])
ENDIF


cosa=cos(tiltangle)
sina=sin(tiltangle)
;rotmatrix=[[cosa,-sina],[sina,cosa]]
;gdib=transpose(rotmatrix##xvect)

gdib=transpose([[xvect*cosa-yvect*sina],[xvect*sina+yvect*cosa]])
gdib[0,*]=gdib[0,*]+xcenter
gdib[1,*]=gdib[1,*]+ycenter

RETURN,gdib

END
