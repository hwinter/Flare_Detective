;+
; NAME:
;      pg_dotauoptim
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      optimize tau escape array from pivot points from sims
;
;
; CALLING SEQUENCE:
;      ???
;
; INPUTS:
; 
;   
; OUTPUTS:
;      
;      
; KEYWORDS:
;
;
; HISTORY:
;       01-FEB-2005 written PG 
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-


FUNCTION pg_dotauopt_fitness,epivlist,tau=tau,goalepiv=goalepiv,smoothfactor=smoothfactor,pivness=pivness

   npop=n_elements(epivlist)
   nbins=n_elements(tau[*,0])

   depiv=abs(epivlist-goalepiv)

   tausmooth=fltarr(npop)
  
   FOR i=0,npop-1 DO BEGIN 
 
      taufloat=float(tau[*,i])
      tausmooth[i]=total(abs(taufloat[0:nbins-2]-(shift(taufloat,-1))[0:nbins-2]))/nbins
        ;total(abs(taufloat[1:nbins-2]-(shift(taufloat,-1))[0:nbins-2]-(shift(taufloat,1))[1:nbins-1]))/nbins
       
      
   ENDFOR
   
   tausmooth=tausmooth/20.*smoothfactor ;20 chosen such that smoothfactor =1 corresponds
                                ;to reasonable penalty for optimization in epiv                

   fitness=depiv+tausmooth
   pivness=depiv

   return,fitness

END

FUNCTION pg_dotauopt_mutate,x,seed=seed

nx=n_elements(x)
mutprob=0.2
mutamp=15.

newx=x

coin=randomu(seed,nx)

ind=where(coin LE mutprob,count)


IF count GT 0 THEN BEGIN 
   change=mutamp*randomn(seed,count)
   newx[ind]=byte(x[ind]+change)
ENDIF


return,newx

END



FUNCTION pg_dotauopt_evolve,tau,fitness,seed=seed

   unchanged=5

   npop=n_elements(fitness)
   nbins=n_elements(tau[*,0])
   rank=sort(fitness)

   newtau=tau
   newtau[*,0:unchanged-1]=tau[*,rank[0:unchanged-1]]

   indlist=floor(npop*randomu(seed,2,npop-unchanged))

   indbest=where(rank[indlist[0,*]] GT rank[indlist[1,*]],count)
   indparent=indlist[0,*]
   IF count GT 0 THEN indparent[indbest]= indlist[1,indbest]
   ;parentlist=rank[indlist[0,*]] GT indlist[1,*]

   newtau[*,unchanged:npop-1]=pg_dotauopt_mutate(tau[*,reform(indparent)],seed=seed)

   return,newtau

END


FUNCTION pg_test,tau
   
   ;nbins=n_elements(tau)
   return,mean(float(tau))

END 

;example
;pg_dotauoptim,tau=tau


PRO pg_dotauoptim,tau=this_tau,npop=npop,ngen=ngen

;sim parameters:
dir='~/work2/tauoptimize/'

temp=10.;[1.,2.,5.,10.,25.,50.]
density=1d10;[1d9,1d10,1d11]
threshold_escape_kev=0.;[0.,1.,10.,50.,100.]

tauescape=1d-2;10^(dindgen(10)/(9)*3-4.5)
avckomega=1d
utdivbyub=10^(dindgen(5)/(4)-3)

clmblog=18.

eref=510.99892d

steps_per_decade=1000            ;number of grid points in a decade of energy
steps_per_decade=30            ;number of grid points in a decade of energy
minen=-18                        ;log_10 of the minimum energy in problem, in this case 10E-8 mc^2
maxen=10d                         ;log_10 of the maximum energy in problem, in this case 10E1  mc^2

;threshold_escape_kev=0.
collision_strength_scale=1.

niter=800L
dt=250.

inputpar={dir:dir,temp:temp,density:density,tauescape:tauescape,avckomega:avckomega, $
          utdivbyub:utdivbyub,clmblog:clmblog,eref:eref,steps_per_decade:steps_per_decade, $
          minen:minen,maxen:maxen,threshold_escape_kev:threshold_escape_kev, $
          collision_strength_scale:collision_strength_scale,niter:niter,dt:dt, $
          dimless_time_unit:2.09d-7}



;optimization method
nbins=10
npop=fcheck(npop,60)
ngen=fcheck(ngen,60)


firsttau=byte(floor(256*randomu(seed,nbins,npop)))
this_tau=firsttau


bestfitness=fltarr(ngen)
!p.multi=[0,1,2]

FOR i=0,ngen-1 DO BEGIN 

   ;this is the main simulation function
   epivlist=pg_optimize_tau(this_tau,inputpar=inputpar,time_out=time_out)

   ;this is now for testing purposes
   ;epivlist=fltarr(npop)
   ;FOR j=0,npop-1 DO epivlist[j]=pg_test(this_tau[*,j])

   ;compute fitness
   fitness=pg_dotauopt_fitness(epivlist,tau=this_tau,goalepiv=20.,smoothfactor=1.,pivness=pivness)
   bestfitness[i]=min(fitness)

   pg_plot_histo,fitness,min=0,max=255,binsize=5.
   plot,bestfitness,psym=10
   wait,0.1

   ;evolve population
   newtau=pg_dotauopt_evolve(this_tau,fitness,seed=seed)

   this_tau=newtau


ENDFOR


END




