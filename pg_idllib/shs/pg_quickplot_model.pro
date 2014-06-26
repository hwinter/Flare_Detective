;+
; NAME:
;
; pgquickplot_model
;
; PURPOSE:
;
; plot some summary info for a model
;
; CATEGORY:
;
; shs project util
;
; CALLING SEQUENCE:
;
;
; INPUTS:
;
;               
; 
; OUTPUTS:
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
; EXAMPLE:
;
;
;
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.pyhs.ethz.ch
; 
; MODIFICATION HISTORY:
;
; 1-SEP-2004 written P.G.
;
;-

;pg_quickplot_model,['pg_pivpoint','pg_fixedn','pg_fixede','pg_brown'],stp=stp,rise_mi=rise_mi,decay_mi=decay_mi

PRO pg_quickplot_model,model,stp=stp,rise_mi=rise_mi,decay_mi=decay_mi
  


;load all model parameters

totnmod=n_elements(model)
modpar=ptrarr(totnmod)

FOR i=0,totnmod-1 DO BEGIN 
  
   dir='~/work/shs2/diffmodfit/'
   filename=dir+model[i]+'_fitresults.fits'
   fpar=mrdfits(filename,1,/silent)
   modpar[i]=ptr_new(fpar)

ENDFOR




filename='~/work/shs2/figs/plotmod.ps'
!P.multi=[0,2,3]
pg_set_ps,filename=filename

ph_enorm=35.
el_enorm=60.


;plot overall
;!P.multi=[0,1,1]


;plot flares
;part 2: single flares

;     dir='~/work/shs2/diffmodfit/'
;     filename=dir+modelname+'_fitresults.fits'
;     fpar=mrdfits(filename,1,/silent)
;     parnames=fpar.parnames

;    flare_parms=fpar.flare_parms


;flare_parms=dblarr(24,npar)
;flare_chisq=dblarr(24)
;flare_status=intarr(24)

outmodname=1.00
outpar=0.7

cs=1.75
xrange=[1d30,1d33]
yrange=[3.5,11]
   
;user defined plot symbol: small filled circle
d=0.25                    ;circle radius
N=32.
A = FINDGEN(N+1) * (!PI*2./N)
USERSYM, d*COS(A), d*SIN(A), /FILL


j=0

outs=1.5

xx=findgen(N)/(N-1)*(alog(max(xrange))-alog(min(xrange)))+alog(min(xrange))
xx=exp(xx)

FOR i=0,n_elements(stp)-1 DO BEGIN
   IF ptr_valid(stp[i]) THEN BEGIN

      print,'PLOTTING FLARE NUMBER '+strtrim(string(i),2)

      tagname='APAR_ARR'
      apararr=pg_getptrstrtag(stp[i],tagname,/transpose)

      spindex=reform(pg_apar2physpar(apararr,/spindex))
      flux=pg_apar2physpar(apararr,eref=ph_enorm)

      res=pg_photon2electron(flux,spindex,ph_enorm,el_enorm)
      elflux=res.elflux
      elspindex=res.elspindex

      x=elflux
      y=elspindex

      plot,x,y,xrange=xrange,/xstyle $
        ,yrange=yrange,/ystyle,/xlog,ylog=1 $
        ,psym=8 $
           ,ytitle='Spectral index !7d!X ( N= ' $
           +strtrim(string(n_elements(x)),2)+' )' $
        ,xtitle='Flux Normalization !7U!X!D60!N' $
        ,ytickv=[4,5,6,7,8,9,10],yticks=6,charsize=cs $
        ,title='FLARE NUMBER '+strtrim(string(j),2)
      

      FOR nmod=0,totnmod-1 DO BEGIN 

         fpar=*modpar[nmod]
         oplot,xx,call_function(fpar.model,xx,fpar.flare_parms[j,*])

      ENDFOR



         plot,[0,0],[0,0],/nodata,xrange=[0,1],yrange=[0,1] $
            ,xstyle=13,ystyle=13 $
            ,xmargin=[0,0],ymargin=[0,0]


      FOR nmod=0,totnmod-1 DO BEGIN 
         
         fpar=*modpar[nmod]
         modelname=fpar.model
         parnames =fpar.parnames

         offsy=0.9
         offsx=0.05
         xyouts,offsx,offsy-nmod*0.2,'MODEL: '+strupcase(modelname)+ $
                ' !7r!X!U2!N: '+strtrim(string(fpar.flare_chisq[j]),2) $
                ,charsize=outmodname

         FOR ii=0,n_elements(fpar.overall_parms)-1 DO BEGIN
         
            xyouts,offsx+0.45*(ii MOD 2),offsy-0.05-nmod*0.2-0.05*(ii / 2) $
               ,parnames[ii]+': '+ $
               strtrim(string(fpar.flare_parms[j,ii],format='(e12.3)'),2) $
               ,charsize=outpar
         
         ENDFOR

      ENDFOR


      j=j+1

   ENDIF

ENDFOR
 

;user defined plot symbol: small filled circle
d=0.1                    ;circle radius
N=32.
A = FINDGEN(N+1) * (!PI*2./N)
USERSYM, d*COS(A), d*SIN(A), /FILL



;plot rise

!P.multi=[0,2,3]

FOR ri=0,n_elements(rise_mi)-1 DO BEGIN

   print,'RISE '+strtrim(string(ri),2)

   flarenum=rise_mi[ri].flarenum  
   phasenum=rise_mi[ri].phasenum
   ind=*rise_mi[ri].ind

 
   tagname='APAR_ARR'
   apararr=pg_getptrstrtag(stp[flarenum],tagname,/transpose)

   spindex=reform(pg_apar2physpar(apararr,/spindex))
   flux=pg_apar2physpar(apararr,eref=ph_enorm)

   res=pg_photon2electron(flux,spindex,ph_energy,el_enorm)
   flux=res.elflux
   spindex=res.elspindex


   plot,flux,spindex,xrange=xrange,/xstyle $
        ,yrange=yrange,/ystyle,/xlog,ylog=1 $
        ,psym=8 $
        ,ytitle='Spectral index !7d!X ( N= ' $
        +strtrim(string(n_elements(ind)),2)+' )' $
        ,xtitle='Flux Normalization !7U!X!D60!N' $
        ,ytickv=[4,5,6,7,8,9,10],yticks=6,charsize=cs $
        ,title='RISE PHASE NUMBER '+strtrim(string(ri),2)
 
 
   oplot,flux[ind],spindex[ind],psym=1



   FOR nmod=0,totnmod-1 DO BEGIN 

      fpar=*modpar[nmod]
      oplot,xx,call_function(fpar.model,xx,fpar.r_parms[ri,*])

   ENDFOR

        plot,[0,0],[0,0],/nodata,xrange=[0,1],yrange=[0,1] $
            ,xstyle=13,ystyle=13 $
            ,xmargin=[0,0],ymargin=[0,0]


      FOR nmod=0,totnmod-1 DO BEGIN 
         
         fpar=*modpar[nmod]
         modelname=fpar.model
         parnames =fpar.parnames

         offsy=0.9
         offsx=0.05
         xyouts,offsx,offsy-nmod*0.2,'MODEL: '+strupcase(modelname)+ $
                ' !7r!X!U2!N: '+strtrim(string(fpar.r_chisq[ri]),2) $
                ,charsize=outmodname

         FOR ii=0,n_elements(fpar.overall_parms)-1 DO BEGIN
         
            xyouts,offsx+0.45*(ii MOD 2),offsy-0.05-nmod*0.2-0.05*(ii / 2) $
               ,parnames[ii]+': '+ $
               strtrim(string(fpar.r_parms[ri,ii],format='(e12.3)'),2) $
               ,charsize=outpar
         
         ENDFOR

      ENDFOR

ENDFOR

;plot decay


!P.multi=[0,2,3]

FOR ri=0,n_elements(decay_mi)-1 DO BEGIN

   print,'DECAY '+strtrim(string(ri),2)

   flarenum=decay_mi[ri].flarenum  
   phasenum=decay_mi[ri].phasenum
   ind=*decay_mi[ri].ind

 
   tagname='APAR_ARR'
   apararr=pg_getptrstrtag(stp[flarenum],tagname,/transpose)

   spindex=reform(pg_apar2physpar(apararr,/spindex))
   flux=pg_apar2physpar(apararr,eref=ph_enorm)

   res=pg_photon2electron(flux,spindex,ph_energy,el_enorm)
   flux=res.elflux
   spindex=res.elspindex


   plot,flux,spindex,xrange=xrange,/xstyle $
        ,yrange=yrange,/ystyle,/xlog,ylog=1 $
        ,psym=8 $
        ,ytitle='Spectral index !7d!X ( N= ' $
        +strtrim(string(n_elements(ind)),2)+' )' $
        ,xtitle='Flux Normalization !7U!X!D60!N' $
        ,ytickv=[4,5,6,7,8,9,10],yticks=6,charsize=cs $
        ,title='DECAY PHASE NUMBER '+strtrim(string(ri),2)
 
 
   oplot,flux[ind],spindex[ind],psym=1



   FOR nmod=0,totnmod-1 DO BEGIN 

      fpar=*modpar[nmod]
      oplot,xx,call_function(fpar.model,xx,fpar.d_parms[ri,*])

   ENDFOR

        plot,[0,0],[0,0],/nodata,xrange=[0,1],yrange=[0,1] $
            ,xstyle=13,ystyle=13 $
            ,xmargin=[0,0],ymargin=[0,0]


      FOR nmod=0,totnmod-1 DO BEGIN 
         
         fpar=*modpar[nmod]
         modelname=fpar.model
         parnames =fpar.parnames

         offsy=0.9
         offsx=0.05
         xyouts,offsx,offsy-nmod*0.2,'MODEL: '+strupcase(modelname)+ $
                ' !7r!X!U2!N: '+strtrim(string(fpar.d_chisq[ri]),2) $
                ,charsize=outmodname

         FOR ii=0,n_elements(fpar.overall_parms)-1 DO BEGIN
         
            xyouts,offsx+0.45*(ii MOD 2),offsy-0.05-nmod*0.2-0.05*(ii / 2) $
               ,parnames[ii]+': '+ $
               strtrim(string(fpar.d_parms[ri,ii],format='(e12.3)'),2) $
               ,charsize=outpar
         
         ENDFOR

      ENDFOR


ENDFOR




device,/close
set_plot,'X'




END
