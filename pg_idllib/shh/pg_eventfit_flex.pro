;+
; NAME:
;
; pg_eventfit_flex
;
; PURPOSE:
;
; apply fitting to an event, using a more flexible model interface
;
; CATEGORY:
;
; rhessi spectrograms/fitting util
;
; CALLING SEQUENCE:
;
; 
;
; INPUTS:
;
; 
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
; 
;
; OUTPUTS:
;
; 
;
; OPTIONAL OUTPUTS:
;
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
;
;
; AUTHOR:
; Paolo Grigis, Institute for Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch 
;
; MODIFICATION HISTORY:
;
; 09-NOV-2006 pg written
;-

;.comp pg_eventfit_flex

FUNCTION pg_eventfit_flex_dostruct

fixed=bytarr(3,9)+1B
fixed[0,[6,7]]=0B
fixed[1,[0,1,3,4]]=0B
fixed[2,[0,1,3,4,6,7,8]]=0B


useprevious=bytarr(3,9)
useprevious[1,[6,7]]=1B
useprevious[2,[0,1,3,4,6,7]]=1B


startvalues=dblarr(3,9)
startvalues[0,*]=[3d, 1.5,3.,0.,20.,500.,1.,1.,1.]
startvalues[1,*]=[3d, 1.5,3.,1.,20.,500.,1.,1.,1.]
startvalues[2,*]=[3d, 1.5,3.,1.,20.,500.,1.,1.,1.]

parnames=['DELTA_MAIN','DELTA_LOW','DELTA_HIGH','FLUX_NORM', $
          'EBREAK_LOW','EBREAK_HIGH','EM','TEMP','LAMBDA_BACK']


limited=bytarr(2,9)+1B
limits=dblarr(2,9)

limited[*,0]=[1,1]
limits[*,0]=[1,25]
limited[*,1]=[1,1]
limits[*,1]=[1,3]
limited[*,2]=[1,1]
limits[*,2]=[1,25]
limited[*,3]=[1,1]
limits[*,3]=[0.,1d10]
limited[*,4]=[1,1]
limits[*,4]=[3.,60]
limited[*,5]=[1,1]
limits[*,5]=[30.,500.]
limited[*,6]=[1,1]
limits[*,6]=[0.,1d10]
limited[*,7]=[1,1]
limits[*,7]=[0.1,1000]
limited[*,8]=[1,1]
limits[*,8]=[0.5,2.]


partmodels=[ptr_new([0,1,2,3,4,5,8]),ptr_new([6,7,8])]
partmodelvalues=[ptr_new([1,1,1,0.,1,1,0]),ptr_new([0.,1,0.])]

flexst={ $
         modelfunction:'pg_modfit', $
         npar:n_elements(parnames), $
         parnames:parnames, $
         enorm: 50., $
         nfitrounds:3, $
         fitrange:[[12.,25],[40,70],[12,500]], $
         fixed:fixed, $
         useprevious:useprevious, $
         startvalues:startvalues, $
         limits:limits, $
         limited:limited, $
         partmodels:partmodels, $
         partmodelvalues:partmodelvalues, $
         partcol:[2,7] $
       }


;return,flexst

fixed=bytarr(3,6)+1B
fixed[0,[3,4]]=0B
fixed[1,[0,1,2,5]]=0B
fixed[2,[0,1,2,3,4,5]]=0B


useprevious=bytarr(3,6)
useprevious[1,[3,4]]=1B
useprevious[2,[0,1,2,3,4,5]]=1B


startvalues=dblarr(3,6)
startvalues[0,*]=[-0.1d,-2.,0,1.,1.,1.]
startvalues[1,*]=[-0.1d,-2.,1,1.,1.,1.]
startvalues[2,*]=[-0.1d,-2.,1,1.,1.,1.]

parnames=['A_PAR','B_PAR','EXPC_PAR', $
          'EM','TEMP','LAMBDA_BACK']


limited=bytarr(2,9)+1B
limits=dblarr(2,9)

limited[*,0]=[1,1]
limits[*,0]=[-5,0]
limited[*,1]=[1,1]
limits[*,1]=[-20,-1]
limited[*,2]=[1,1]
limits[*,2]=[0.,1d10]
limited[*,3]=[1,1]
limits[*,3]=[0.,1d4]
limited[*,4]=[1,1]
limits[*,4]=[0.1,1000]
limited[*,5]=[1,1]
limits[*,5]=[0.5,2.]


partmodels=[ptr_new([2,5]),ptr_new([3,4,5])]
partmodelvalues=[ptr_new([0.,1]),ptr_new([0.,1,1.])]

flexst={ $
         modelfunction:'pg_parabmod', $
         npar:n_elements(parnames), $
         parnames:parnames, $
         enorm: 50., $
         nfitrounds:3, $
         fitrange:[[12.,25],[40,70],[12,500]], $
         fixed:fixed, $
         useprevious:useprevious, $
         startvalues:startvalues, $
         limits:limits, $
         limited:limited, $
         partmodels:partmodels, $
         partmodelvalues:partmodelvalues, $
         partcol:[2,7] $
       }




;return,flexst


fixed=bytarr(3,6)+1B
fixed[0,[3,4]]=0B
fixed[1,[0,1,2,5]]=0B
fixed[2,[0,1,2,3,4,5]]=0B


useprevious=bytarr(3,6)
useprevious[1,[3,4]]=0B
useprevious[2,[0,1,2,3,4,5]]=1B


startvalues=dblarr(3,6)
startvalues[0,*]=[3.,1.,1.,1.,1.,1.]
startvalues[1,*]=[3.,1.,1.,1.,1.,1.]
startvalues[2,*]=[3.,1.,1.,1.,1.,1.]

parnames=['DELTA','FLUX_NORM','ESUB','EM','TEMP','LAMBDA_BACK']


limited=bytarr(2,9)+1B
limits=dblarr(2,9)

limited[*,0]=[1,1]
limits[*,0]=[1,25]
limited[*,1]=[1,1]
limits[*,1]=[0.,1d10]
limited[*,2]=[1,1]
limits[*,2]=[0.,100.]
limited[*,3]=[1,1]
limits[*,3]=[0.,1d10]
limited[*,4]=[1,1]
limits[*,4]=[0.1,1000]
limited[*,5]=[1,1]
limits[*,5]=[0.5,2.]


partmodels=[ptr_new([1,5]),ptr_new([3,4,5])]
partmodelvalues=[ptr_new([0.,1]),ptr_new([1.,1,1.])]

flexst={ $
         modelfunction:'pg_subenergy', $
         npar:n_elements(parnames), $
         parnames:parnames, $
         enorm: 50., $
         nfitrounds:3, $
         fitrange:[[12.,20],[30,70],[12,500]], $
         fixed:fixed, $
         useprevious:useprevious, $
         startvalues:startvalues, $
         limits:limits, $
         limited:limited, $
         partmodels:partmodels, $
         partmodelvalues:partmodelvalues, $
         partcol:[2,7] $
       }


return,flexst

END

PRO  pg_eventfit_flex_dostruct_test
;.comp pg_eventfit_flex

spdir='~/work/shh_data/spsrmfiles/shhcandlist/'

sp='sp_20050117_0835_pileup08.fits'
srm='srm_20050117_0835_pileup08.fits'

spgin=pg_spfitfile2spg(spdir+sp,/new,/edges,/filter,/error);units: counts s^(-1)
spg=pg_spg_uniformrates(spgin,/convert_edges);units: count s^-1 keV^-1
drm=pg_readsrmfitsfile(spdir+srm)

bspectrum=fitres[2].bspectrum
bespectrum=fitres[2].bespectrum


;fit_time_intv=anytim(['19-Jan-2005 08:27:56','19-Jan-2005 08:28:22'])+200
fit_time_intv=anytim(['17-Jan-2005 09:43:31.347'])+[-20,40]

flexst=pg_eventfit_flex_dostruct()
;help,flexst,/st


fitresult2=pg_eventfit_flex(flexst,spg=spg,drm=drm,fitinterval=fit_time_intv $
                    ,bspectrum=bspectrum,bespectrum=bespectrum $
                    ,/doplot,/verbose,mpquiet=0,/partialplot);/quiet

time=fitres[2].time
fit_time_intv=anytim(['17-Jan-2005 09:43:31.347'])+[-20,40]

fit_time_intv=anytim(['17-Jan-2005 09:36:48.046','17-Jan-2005 10:38:06.143'])

fitresult1=pg_eventfit_flex(flexst,spg=spg,drm=drm,fitinterval=fit_time_intv $
                    ,bspectrum=bspectrum,bespectrum=bespectrum $
                    ,/doplot,/verbose,/quiet)


END




FUNCTION pg_eventfit_flex,flexst,spg=spg,drm=drm,fitinterval=fitinterval $
                    ,bspectrum=bspectrum,bespectrum=bespectrum $
                    ,doplot=doplot,quiet=quiet,mpquiet=mpquiet $
                    ,delay=delay,verbose=verbose,partialplot=partialplot

IF NOT exist(flexst) THEN BEGIN 
   print,'Please input a flexible par table structure'
   return,-1
ENDIF


mpquiet=fcheck(mpquiet,1)

modelname=flexst.modelfunction
npar=flexst.npar
parnames=flexst.parnames


;sets fitting interval
t=spg.x
fitinterval=fcheck(fitinterval,[min(spg.x),max(spg.x)])
fitind=where(t GE anytim(fitinterval[0]) AND t LE anytim(fitinterval[1]))
time=spg.x[fitind]
nint=n_elements(time)


;plot settings
IF keyword_set(doplot) THEN BEGIN 

   linecolors
   spposition=[0.1,0.4,0.95,0.98]
   resposition=[0.1,0.1,0.95,0.4]
   window,0,xsize=1024,ysize=1024

   pg_setplotsymbol,'circle',SIZE=2.5

ENDIF

;input variables needed
matrix=drm.matrix
geom_area=drm.geom_area
cntedges=drm.cntedges
photedges=drm.photedges
cntmean=sqrt(cntedges[*,0]*cntedges[*,1])

cntbins=n_elements(cntedges[*,0])
;photbins=n_elements(photedges[*,0])



;warning for no background situation
IF NOT exist(bspectrum) THEN BEGIN 
   print,'Warning! No background spectrum given!'
   bspectrum=replicate(0d,cntbins)
   bespectrum=replicate(0d,cntbins)
ENDIF

IF NOT exist(bespectrum) THEN BEGIN 
   print,'Warning! No background error spectrum given!'
   bespectrum=replicate(0d,cntbins)
ENDIF


;results array
respar=dblarr(npar,nint)
respar[*]=!values.d_nan
allchisq=replicate(!values.d_nan,nint)
allmpfitstatus=replicate(-1,nint)
residuals=replicate(!values.d_nan,cntbins,nint)
allmodels=replicate(!values.d_nan,cntbins,nint)
allpartmodel=replicate(!values.d_nan,cntbins,n_elements(flexst.partmodels),nint)

allspectra=replicate(!values.d_nan,cntbins,nint)
allespectra=replicate(!values.d_nan,cntbins,nint)
parinfoarr=ptrarr(nint)

;setup correct dealing with atten states
allfilters=drm.filter_state
attindex=bytarr(4)-1
FOR i=0,n_elements(allfilters)-1 DO attindex[allfilters[i]]=i



;fitting loop
FOR i=0,nint-1 DO BEGIN 

   spectrum=spg.spectrogram[fitind[i],*]
   espectrum=spg.espectrogram[fitind[i],*]>(0.5*bspectrum)

;   indokesp=where(spectrum EQ 0.,countokesp)
;   IF countokesp GT 0 THEN BEGIN
;      espectrum[indokesp]=0.5
;   ENDIF


   allspectra[*,i]=spectrum
   allespectra[*,i]=espectrum

   attstate=spg.filter_state[fitind[i]]
   attuncert=spg.filter_uncert[fitind[i]]

   ;check if spectrum seems to be ok
   ok_spectrum=total(spectrum) GT 1.

   IF (attuncert NE 1) AND (ok_spectrum) THEN BEGIN
   ;near attenuator state changes no fitting is done
   ;also in times where the spectrum consits only of zeros
   ;the fit par will be NANs

      thisattstateind=attindex[attstate]

      previousv=flexst.startvalues[0,*]
      

      FOR j=0,flexst.nfitrounds-1 DO BEGIN 

         fitrange=flexst.fitrange[*,j]
         cntrange=where(cntedges[*,0] GE fitrange[0] AND cntedges[*,1] LE fitrange[1])

         ;set parinfo structure
         parinfo=replicate({value:0d,fixed:1.,limited:[0,0],limits:[0d ,0.],parname:' '},npar)
         
         FOR k=0,npar-1 DO BEGIN 
            IF flexst.useprevious[j,k] THEN startv=previousv[k] ELSE startv=flexst.startvalues[j,k]
            parinfo[k].value=startv
            parinfo[k].fixed=flexst.fixed[j,k] 
            parinfo[k].limited=flexst.limited[*,k]
            parinfo[k].limits=flexst.limits[*,k]
            parinfo[k].parname=flexst.parnames[k]            
         ENDFOR

         ;stop

         fitpar=mpfitfun(modelname,replicate(1,n_elements(cntrange)),spectrum[cntrange] $
             ,sqrt(espectrum[cntrange]^2+bespectrum[cntrange]^2) $
             ,functargs={photedges:photedges,drm:matrix[*,*, thisattstateind] $
                        ,geom_area:geom_area[thisattstateind] $
                        ,cntrange:cntrange,enorm:flexst.enorm,background:bspectrum} $
             ,bestnorm=bn,yfit=yfit,dof=dof,status=mpfitstatus,quiet=mpquiet $
             ,parinfo=parinfo);tol=1d-12)


         tempsp=pg_parabmod(dummy,fitpar,photedges=photedges,drm=matrix[*,*, thisattstateind] $
                        ,geom_area=geom_area[thisattstateind] $
                        ,cntrange=cntrange,enorm=flexst.enorm,background=bspectrum)
;seems ok


         chisq=bn/dof

         previousv=fitpar


         IF keyword_set(partialplot) THEN BEGIN     

            resulttot=call_function(modelname,dummy,fitpar,photedges=photedges,drm=matrix[*,*,thisattstateind] $
                                    ,geom_area=geom_area[thisattstateind],enorm=flexst.enorm $
                                    ,background=bspectrum)

            pg_plotsp,cntedges,spectrum,espectrum=espectrum,/xlog,/ylog,xstyle=1 $
                      ,yrange=[0.1,1d4],position=spposition,xtickname=replicate(' ',30)
            pg_plotsp,cntedges,resulttot,color=12,/overplot

            IF exist(delay) THEN BEGIN 
               ;stop
               wait,delay
            ENDIF

         ENDIF


      ENDFOR


      ;stop


      allchisq[i]=chisq
      allmpfitstatus[i]=mpfitstatus
      respar[*,i]=fitpar
      parinfoarr[i]=ptr_new(parinfo)

      resulttot=call_function(modelname,dummy,fitpar,photedges=photedges,drm=matrix[*,*,thisattstateind] $
                         ,geom_area=geom_area[thisattstateind],enorm=flexst.enorm $
                         ,background=bspectrum)

      residuals[*,i]=(spectrum-resulttot)/espectrum
      allmodels[*,i]= resulttot

 
      IF NOT keyword_set(quiet) THEN $ 
         print,'Interval '+strtrim(i,2)+' ATT: '+strtrim(fix(attstate),2) $
              +' MPFIT status '+strtrim(mpfitstatus,2)+' CHISQ: '+strtrim(chisq,2)

      IF keyword_set(verbose) THEN BEGIN 

         FOR ipar=0,npar-1 DO print,parnames[ipar]+': '+strtrim(fitpar[ipar],2)

      ENDIF
 
      FOR ipart=0,n_elements(flexst.partmodels)-1 DO BEGIN 


         tpar=fitpar
         tpar[*flexst.partmodels[ipart]]=*flexst.partmodelvalues[ipart]
         thisresult=call_function(modelname,dummy,tpar,photedges=photedges,drm=matrix[*,*,thisattstateind] $
                              ,geom_area=geom_area[thisattstateind],enorm=flexst.enorm $
                              ,background=bspectrum)

         allpartmodel[*,ipart,i]=thisresult

      ENDFOR
         
      
      IF keyword_set(doplot) THEN BEGIN 

 

         pg_plotsp,cntedges,spectrum,espectrum=espectrum,/xlog,/ylog,xstyle=1 $
                   ,yrange=[0.1,1d4],position=spposition,xtickname=replicate(' ',30)
         pg_plotsp,cntedges,resulttot,color=12,/overplot
 
         FOR ipart=0,n_elements(flexst.partmodels)-1 DO $
            pg_plotsp,cntedges,allpartmodel[*,ipart,i],/xlog,/ylog,/xstyle,color=flexst.partcol[ipart],/overplot 

        pg_plotsp,cntedges,bspectrum,espectrum=bespectrum,color=5,/overplot

        FOR ipar=0,flexst.npar-1 DO BEGIN 

           parval=flexst.parnames[ipar]+' : '+strtrim(string(fitpar[ipar]),2)
           xyouts,100,30*(ipar+1),parval,/device,charsize=1.5

        ENDFOR


;        parval=
 ;       xyouts,x,y,parval


;         ;show the breaks...
;          fitebreakl=par[4]
;          fitebreakh=par[5]
;          dummy=min(abs(cntmean-fitebreakl),indl)
;          dummy=min(abs(cntmean-fitebreakh),indh)

;          plots,cntmean[indl],resultnont[indl],psym=8,color=12
;          plots,cntmean[indh],resultnont[indh],psym=8,color=12
         

;          pg_plotspres,cntedges,spectrum=spectrum,modspectrum=resulttot,espectrum=espectrum $
;                      ,/xlog,/xstyle,yrange=[-4,4],/noerase,position=resposition

         IF exist(delay) THEN wait,delay

      ENDIF 

   ENDIF

ENDFOR


fitsresults={time:time,chisq:allchisq,fitstatus:allmpfitstatus,fitpar:respar,residuals:residuals $
            ,cntspectra:allspectra,cntespectra:allespectra,cntmodels:allmodels $
            ,cntpart:allpartmodel,matrix:matrix,geom_area:geom_area $
            ,atten_state:spg.filter_state[fitind],atten_uncert:spg.filter_uncert[fitind] $
            ,bspectrum:bspectrum,bespectrum:bespectrum,enorm:flexst.enorm $
            ,flexst:flexst,modelname:modelname $
            ,parinfo:parinfoarr,cntedges:cntedges,photedges:photedges $
            ,parnames:parnames}

return,fitsresults

END


