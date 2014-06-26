;+
; NAME:
;
; pgquicklook_model
;
; PURPOSE:
;
; plot/print some summary info for a model
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
; 30-AUG-2004 written P.G.
;
;-

;pg_quicklook_model,['pg_pivpoint','pg_fixedn','pg_fixede','pg_brown'],/cull

PRO pg_quicklook_model,model,cull=cull,labelbins=labelbins

filename='~/work/shs2/figs/summod.ps'
!P.multi=[0,1,4]
pg_set_ps,filename=filename
thick=3
cs=1.5
labcharsize=0.75

FOR k=0,n_elements(model)-1 DO  BEGIN
modelname=model[k]


dir='~/work/shs2/diffmodfit/'
filename=dir+modelname+'_fitresults.fits'
fpar=mrdfits(filename,1,/silent)

npar=n_elements(fpar.parnames)


IF keyword_set(cull) THEN BEGIN 
  find=where((fpar.flare_status GE 1) AND (fpar.flare_status LE 4)) 
  rind=where((fpar.r_status GE 1) AND (fpar.r_status LE 4))
  dind=where((fpar.d_status GE 1) AND (fpar.d_status LE 4))
ENDIF ELSE BEGIN
  find=indgen(n_elements(fpar.flare_status))
  rind=indgen(n_elements(fpar.flare_status))
  dind=indgen(n_elements(fpar.flare_status))
ENDELSE

;print,'FLARE'
;print,find
;print,'RISE'
;print,rind
;print,'DECAY'
;print,dind

;just print the data...


print,'------------------------------------------------------------'
print,'MODEL '+strupcase(modelname)
print,'------------------------------------------------------------'
print,' '

FOR i=0,npar-1 DO BEGIN
  
  print,'   ****************************************'
  print,'   PARAMETER '+strtrim(string(i),2)+': '+fpar.parnames[i]
  print,'   ****************************************'


  IF fpar.parfixed[i] THEN BEGIN
     print,'   FIXED AT VALUE: '+strtrim(string(fpar.parvalues[i],format='(E12.3)'),2)
     print,'   ****************************************'
  ENDIF ELSE BEGIN 

  ovpar=fpar.overall_parms[i]
  print,' '
  print,'   OVERALL'
  print,'                PARAM. VALUE  : '+strtrim(string(ovpar,format='(E12.3)'),2)
  print,' '

  flpar=fpar.flare_parms[find,i]
  mflpar=moment(flpar)
  medflpar=median(flpar,/even)

  print,'   FLARE VALUES'
  print,'                AVERAGE VALUE : '+strtrim(string(mflpar[0],format='(E12.3)'),2)
  print,'                MEDIAN  VALUE : '+strtrim(string(medflpar[0],format='(E12.3)'),2)
  print,'                MINIMUM VALUE : '+strtrim(string(min(flpar),format='(E12.3)'),2)
  print,'                MAXIMUM VALUE : '+strtrim(string(max(flpar),format='(E12.3)'),2)
  print,'                STANDARD DEV. : '+strtrim(string(sqrt(mflpar[1]),format='(E12.3)'),2)
  print,' '

  rpar=fpar.r_parms[rind,i]
  mrpar=moment(rpar)
  medrpar=median(rpar,/even)
  dpar=fpar.d_parms[dind,i]
  mdpar=moment(dpar)
  meddpar=median(dpar,/even)
  
  print,'   RISE VALUES'
  print,'                AVERAGE VALUE : '+strtrim(string(mrpar[0],format='(E12.3)'),2)
  print,'                MEDIAN  VALUE : '+strtrim(string(medrpar[0],format='(E12.3)'),2)
  print,'                MINIMUM VALUE : '+strtrim(string(min(rpar),format='(E12.3)'),2)
  print,'                MAXIMUM VALUE : '+strtrim(string(max(rpar),format='(E12.3)'),2)
  print,'                STANDARD DEV. : '+strtrim(string(sqrt(mrpar[1]),format='(E12.3)'),2)
  print,' '

  print,'   DECAY VALUES'                         
  print,'                AVERAGE VALUE : '+strtrim(string(mdpar[0],format='(E12.3)'),2)
  print,'                MEDIAN  VALUE : '+strtrim(string(meddpar[0],format='(E12.3)'),2)
  print,'                MINIMUM VALUE : '+strtrim(string(min(dpar),format='(E12.3)'),2)
  print,'                MAXIMUM VALUE : '+strtrim(string(max(dpar),format='(E12.3)'),2)
  print,'                STANDARD DEV. : '+strtrim(string(sqrt(mdpar[1]),format='(E12.3)'),2)
  print,' '

;plots of distribution of the parameters...

  medls=1
  avls=2

  fldpar=max(flpar)-min(flpar)
  flparrange=pg_extend_range([min(flpar),max(flpar)])

  xrange=[0.9*min(flpar),1.1*max(flpar)] 
 ; xrange=[min(flpar)-0.1*fldpar,max(flpar)+0.1*fldpar]
  
  
  nbins=8
  binsize=1.2*fldpar/nbins

  title='MODEL: '+strupcase(modelname)+' FLARES DISTRIBUTION OF ' $
        +fpar.parnames[i]

;  stop

  pg_plot_histo,flpar,min=flparrange[0],max=flparrange[1],nbins=nbins $
               ,xrange=xrange,thick=thick,title=title,labelbins=labelbins $
               ,charsize=cs,labcharsize=labcharsize,labelind=find 
;,histo=histo

  oplot,[medflpar,medflpar],!Y.crange,thick=thick,linestyle=medls
  oplot,[mflpar[0],mflpar[0]],!Y.crange,thick=thick,linestyle=avls

  pg_plot_histo,flpar,min=flparrange[0],max=flparrange[1],nbins=nbins $
                ,/xlog,xrange=xrange,thick=thick,title=title,labelind=find  $
                ,labelbins=labelbins,charsize=cs,labcharsize=labcharsize
 
  oplot,alog([medflpar,medflpar]),!Y.crange,thick=thick,linestyle=medls
  oplot,alog([mflpar[0],mflpar[0]]),!Y.crange,thick=thick,linestyle=avls

 
;  xrange=[0.9*min([rpar,dpar]),1.1*max([rpar,dpar])]
  xrange=[0.9*min(rpar),1.1*max(rpar)]
 
  ;xrange=[min([rpar,dpar])-0.1*fldpar,max([rpar,dpar])+0.1*fldpar]
 
  rdpar=max(rpar)-min(rpar)
  rparrange=pg_extend_range([min(rpar),max(rpar)])
  
  nbins=16

  title='MODEL: '+strupcase(modelname)+' RISE DISTRIBUTION OF '+fpar.parnames[i]

  pg_plot_histo,rpar,min=rparrange[0],max=rparrange[1],nbins=nbins $
                ,xrange=xrange,thick=thick,title=title,labelbins=labelbins $
                ,charsize=cs,labcharsize=labcharsize,labelind=rind

  oplot,[medrpar,medrpar],!Y.crange,thick=thick,linestyle=medls
  oplot,[mrpar[0],mrpar[0]],!Y.crange,thick=thick,linestyle=avls
 
  pg_plot_histo,rpar,min=rparrange[0],max=rparrange[1],nbins=nbins $
               ,xrange=xrange,/xlog,thick=thick,title=title,labelind=rind $
               ,labelbins=labelbins,charsize=cs,labcharsize=labcharsize 

  oplot,alog([medrpar,medrpar]),!Y.crange,thick=thick,linestyle=medls
  oplot,alog([mrpar[0],mrpar[0]]),!Y.crange,thick=thick,linestyle=avls

  ddpar=max(dpar)-min(dpar)
  dparrange=pg_extend_range([min(dpar),max(dpar)])
  
  nbins=16

  title='MODEL: '+strupcase(modelname)+' DECAY DISTRIBUTION OF '+fpar.parnames[i]

  xrange=[0.9*min(dpar),1.1*max(dpar)]

  pg_plot_histo,dpar,min=dparrange[0],max=dparrange[1],nbins=nbins $
                ,xrange=xrange,thick=thick,title=title,labelbins=labelbins $
                ,charsize=cs,labcharsize=labcharsize,labelind=dind

  oplot,[meddpar,meddpar],!Y.crange,thick=thick,linestyle=medls
  oplot,[mdpar[0],mdpar[0]],!Y.crange,thick=thick,linestyle=avls

  pg_plot_histo,dpar,min=dparrange[0],max=dparrange[1],nbins=nbins $
                ,xrange=xrange,/xlog,thick=thick,title=title,labelind=dind $
                ,labelbins=labelbins,charsize=cs,labcharsize=labcharsize 

  oplot,alog([meddpar,meddpar]),!Y.crange,thick=thick,linestyle=medls
  oplot,alog([mdpar[0],mdpar[0]]),!Y.crange,thick=thick,linestyle=avls


  ENDELSE


  print,' '
ENDFOR

;print,'   ****************************************'
;print,' '

print,'CHI SQUARE FROM FITTING'
print,'::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::'
print,' '

  ovchi=fpar.overall_chisq
  print,'OVERALL CHISQ           : '+strtrim(string(ovchi),2)
  print,' '

  flchi=fpar.flare_chisq[find]
  mflchi=moment(flchi)
  medflchi=median(flchi,/even)

  print,'AVERAGE CHISQ FOR FLARES: '+strtrim(string(mflchi[0]),2)
  print,'MEDIAN  CHISQ FOR FLARES: '+strtrim(string(medflchi[0]),2)
  print,'MINIMUM CHISQ FOR FLARES: '+strtrim(string(min(flchi)),2)
  print,'MAXIMUM CHISQ FOR FLARES: '+strtrim(string(max(flchi)),2)
  print,'STANDARD DEV. FOR FLARES: '+strtrim(string(sqrt(mflchi[1])),2)
  print,' '

  rchi=fpar.r_chisq[rind]
  mrchi=moment(rchi)
  medrchi=median(rchi,/even)
  dchi=fpar.d_chisq[dind]
  mdchi=moment(dchi)
  meddchi=median(dchi,/even)

  print,'AVERAGE CHISQ FOR RISE  : '+strtrim(string(mrchi[0]),2)
  print,'MEDIAN  CHISQ FOR RISE  : '+strtrim(string(medrchi[0]),2)
  print,'MINIMUM CHISQ FOR RISE  : '+strtrim(string(min(mrchi)),2)
  print,'MAXIMUM CHISQ FOR RISE  : '+strtrim(string(max(mrchi)),2)
  print,'STANDARD DEV. FOR RISE  : '+strtrim(string(sqrt(mrchi[1])),2)
  print,' '

  print,'AVERAGE CHISQ FOR DECAY : '+strtrim(string(mdchi[0]),2)
  print,'MEDIAN  CHISQ FOR DECAY : '+strtrim(string(meddchi[0]),2)
  print,'MINIMUM CHISQ FOR DECAY : '+strtrim(string(min(mdchi)),2)
  print,'MAXIMUM CHISQ FOR DECAY : '+strtrim(string(max(mdchi)),2)
  print,'STANDARD DEV. FOR DECAY : '+strtrim(string(sqrt(mdchi[1])),2)
  print,' '

  print,'++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'



ENDFOR


device,/close
set_plot,'X'




END
