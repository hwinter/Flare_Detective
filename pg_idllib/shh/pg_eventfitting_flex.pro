;
;Flexible event fitting routine
;
;
;

PRO pg_eventfitting_flex,savefiledir,allselectdata=allselectdata $
                     ,addbspectrum=addbspectrum,doplot=doplot $
                     ,verbose=verbose,flexst=flexst,filebase=filebase




IF NOT exist(savefiledir) THEN BEGIN
   print,'Please input a save file dir name!'
   RETURN
ENDIF

IF NOT exist(filebase) THEN BEGIN
   print,'Please input a filename base string!'
   RETURN
ENDIF

IF NOT exist(flexst) THEN BEGIN
   print,'Please input a model fitting flexible info structure!'
   RETURN
ENDIF

dir='~/work/shh_data/spsrmfiles/shhcandlist/'

sppile00files=file_search(dir+'sp*nopileupcorr*')
srmpile00files=file_search(dir+'srm*nopileupcorr*')
sppile06files=file_search(dir+'sp*pileup06*')
srmpile06files=file_search(dir+'srm*pileup06*')
sppile08files=file_search(dir+'sp*pileup08*')
srmpile08files=file_search(dir+'srm*pileup08*')
sppile10files=file_search(dir+'sp*pileup10*')
srmpile10files=file_search(dir+'srm*pileup10*')


;FOR i=0,n_elements(allselectdata)-1 DO BEGIN 
FOR i=0,n_elements(allselectdata)-1 DO BEGIN 

   thisspfile=sppile00files[(*allselectdata[i]).event]
   thissrmfile=srmpile00files[(*allselectdata[i]).event]

   spgin=pg_spfitfile2spg(thisspfile,/new,/edges,/filter,/error) ;units: counts s^(-1)
   spg=pg_spg_uniformrates(spgin,/convert_edges) ;units: count s^-1 keV^-1
   drm=pg_readsrmfitsfile(thissrmfile)

   cntedges=drm.cntedges
   enmean=sqrt(cntedges[*,0]*cntedges[*,1])

   ;background interval & spectra
   time=spg.x
   brange=(*allselectdata[i]).brange
   bind=where(time GE brange[0] AND time LE brange[1],count)

   IF count GT 0 THEN BEGIN 

      bspectrum=total(spg.spectrogram[bind,*],1)/n_elements(bind)
      bespectrum=sqrt(total(spg.espectrogram[bind,*]^2,1))/n_elements(bind)

   ENDIF ELSE BEGIN 

      bspectrum=addbspectrum.spectrum
      bespectrum=addbspectrum.bespectrum

   ENDELSE


   ;do fittings...
   fit_time_intv=(*allselectdata[i]).intrange

   thermrange=[12,25]
   nonthermrange=[30,60]

   fitresult00=pg_eventfit_flex(flexst,spg=spg,drm=drm,fitinterval=fit_time_intv $
                          ,bspectrum=bspectrum,bespectrum=bespectrum $
                          ,doplot=doplot,verbose=verbose)



   thisspfile=sppile06files[(*allselectdata[i]).event]
   thissrmfile=srmpile06files[(*allselectdata[i]).event]

   spgin=pg_spfitfile2spg(thisspfile,/new,/edges,/filter,/error) ;units: counts s^(-1)
   spg=pg_spg_uniformrates(spgin,/convert_edges) ;units: count s^-1 keV^-1
   drm=pg_readsrmfitsfile(thissrmfile)

   cntedges=drm.cntedges
   enmean=sqrt(cntedges[*,0]*cntedges[*,1])

   ;background interval & spectra
   time=spg.x
   brange=(*allselectdata[i]).brange
   bind=where(time GE brange[0] AND time LE brange[1],count)

   IF count GT 0 THEN BEGIN 

      bspectrum=total(spg.spectrogram[bind,*],1)/n_elements(bind)
      bespectrum=sqrt(total(spg.espectrogram[bind,*]^2,1))/n_elements(bind)

   ENDIF ELSE BEGIN 

      bspectrum=addbspectrum.spectrum
      bespectrum=addbspectrum.bespectrum

   ENDELSE


   ;do fittings...
   fit_time_intv=(*allselectdata[i]).intrange

   thermrange=[12,25]
   nonthermrange=[30,60]

 
   fitresult06=pg_eventfit_flex(flexst,spg=spg,drm=drm,fitinterval=fit_time_intv $
                          ,bspectrum=bspectrum,bespectrum=bespectrum $
                          ,doplot=doplot,verbose=verbose)




   thisspfile=sppile08files[(*allselectdata[i]).event]
   thissrmfile=srmpile08files[(*allselectdata[i]).event]

   spgin=pg_spfitfile2spg(thisspfile,/new,/edges,/filter,/error) ;units: counts s^(-1)
   spg=pg_spg_uniformrates(spgin,/convert_edges) ;units: count s^-1 keV^-1
   drm=pg_readsrmfitsfile(thissrmfile)

   cntedges=drm.cntedges
   enmean=sqrt(cntedges[*,0]*cntedges[*,1])

   ;background interval & spectra
   time=spg.x
   brange=(*allselectdata[i]).brange
   bind=where(time GE brange[0] AND time LE brange[1],count)

   IF count GT 0 THEN BEGIN 

      bspectrum=total(spg.spectrogram[bind,*],1)/n_elements(bind)
      bespectrum=sqrt(total(spg.espectrogram[bind,*]^2,1))/n_elements(bind)

   ENDIF ELSE BEGIN 

      bspectrum=addbspectrum.spectrum
      bespectrum=addbspectrum.bespectrum

   ENDELSE


   ;do fittings...
   fit_time_intv=(*allselectdata[i]).intrange

   thermrange=[12,25]
   nonthermrange=[30,60]


   fitresult08=pg_eventfit_flex(flexst,spg=spg,drm=drm,fitinterval=fit_time_intv $
                          ,bspectrum=bspectrum,bespectrum=bespectrum $
                          ,doplot=doplot,verbose=verbose)


   thisspfile=sppile10files[(*allselectdata[i]).event]
   thissrmfile=srmpile10files[(*allselectdata[i]).event]

   spgin=pg_spfitfile2spg(thisspfile,/new,/edges,/filter,/error) ;units: counts s^(-1)
   spg=pg_spg_uniformrates(spgin,/convert_edges) ;units: count s^-1 keV^-1
   drm=pg_readsrmfitsfile(thissrmfile)

   cntedges=drm.cntedges
   enmean=sqrt(cntedges[*,0]*cntedges[*,1])

   ;background interval & spectra
   time=spg.x
   brange=(*allselectdata[i]).brange
   bind=where(time GE brange[0] AND time LE brange[1],count)

   IF count GT 0 THEN BEGIN 

      bspectrum=total(spg.spectrogram[bind,*],1)/n_elements(bind)
      bespectrum=sqrt(total(spg.espectrogram[bind,*]^2,1))/n_elements(bind)

   ENDIF ELSE BEGIN 

      bspectrum=addbspectrum.spectrum
      bespectrum=addbspectrum.bespectrum

   ENDELSE


   ;do fittings...
   fit_time_intv=(*allselectdata[i]).intrange

   thermrange=[12,25]
   nonthermrange=[30,60]


   fitresult10=pg_eventfit_flex(flexst,spg=spg,drm=drm,fitinterval=fit_time_intv $
                          ,bspectrum=bspectrum,bespectrum=bespectrum $
                          ,doplot=doplot,verbose=verbose)


   fitres=[fitresult00,fitresult06,fitresult08,fitresult10]

   savefilename=savefiledir+filebase+'_intv_'+smallint2str(i,strlen=2)+'.sav'

   save,fitres,filename=savefilename

ENDFOR

RETURN

END

