;+
; NAME:
;
;   pg_extractres
;
; PURPOSE:
;
;   extract results from res in a nice fashion
;
; CATEGORY:
; 
;   stochastic acceleration simulation project
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
;
;   Paolo Grigis
;   pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
;   01-MAR-2006 written PG
;
;-

FUNCTION pg_extractres,res,fixed_tagnames=fixed_tagnames $
        ,fixed_tagind=fixed_tagind,couple_tau_ut=couple_tau_ut




  simpar0=res.simpar[0]
  
  ntags=n_tags(simpar0)
  tagnames=tag_names(simpar0)

  
;;; get list of avilable tag (that means all variables with more than one value
;;; in simpar)

  available_tags=''
  indtag=0
  uniqtag=ptr_new()

  FOR i=0L,ntags-1 DO BEGIN 
     
     dummy=simpar0.(i)

     IF n_elements(dummy) EQ 1 THEN BEGIN 
        ad=res.simpar[*].(i);all data
        ads=sort(ad);sorted
        uniqdata=ad[ads[uniq(ad[ads])]]

        IF n_elements(uniqdata) GT 1 THEN BEGIN 

           IF keyword_set(couple_tau_ut) THEN BEGIN
              IF tagnames[i] NE 'TAUESCAPE' THEN BEGIN 
                 available_tags=[available_tags,tagnames[i]]
                 indtag=[indtag,i]
                 uniqtag=[uniqtag,ptr_new(uniqdata)]
              ENDIF $
              ELSE BEGIN
                 tauind=i
                 tauall=uniqdata
              ENDELSE   
           ENDIF $ 
           ELSE BEGIN  
              available_tags=[available_tags,tagnames[i]]
              indtag=[indtag,i]
              uniqtag=[uniqtag,ptr_new(uniqdata)]
           ENDELSE

        ENDIF

     ENDIF
     
  ENDFOR

  navt=n_elements(available_tags)-1

  IF navt LE 0 THEN BEGIN 
     print,'NO VAR TAGS FOUND, RETURNING...'
     RETURN,-1
  ENDIF

  indtag=indtag[1:navt]
  available_tags=available_tags[1:navt]
  uniqtag=uniqtag[1:navt]
  
;;; check which tags are fixed and which aren't

  nft=n_elements(fixed_tagnames)
  indfix=lonarr(nft)
;  indvar=lonarr(navt-n_elements(fixed_tags))

  FOR i=0L,nft-1 DO BEGIN 
     indfix[i]=where(available_tags EQ fixed_tagnames[i],count)
     IF count EQ 0 THEN BEGIN 
        print,'FIXED TAG '+fixed_tags[i]+' NOT FOUND! RETURNING...'
        RETURN,-1
     ENDIF
  ENDFOR

  indvar=cmset_op(indfix,'AND',/not1,lindgen(navt))
  nvar=n_elements(indvar)

;;; identify list of elements with fixed var in input index

  nsim=n_elements(res.simpar)
  list_keep=-1L

  FOR i=0L,nsim-1 DO BEGIN 
     this_simpar=res.simpar[i]

     keep_this=1

     FOR j=0L,nft-1 DO BEGIN 
        IF this_simpar.(indtag[indfix[j]]) NE  (*uniqtag[indfix[j]])[fixed_tagind[j]] THEN keep_this=0
     ENDFOR

     IF keep_this EQ 1 THEN list_keep=[list_keep,i]
     
  ENDFOR

  IF n_elements(list_keep) EQ 1 THEN RETURN,-1

  list_keep=list_keep[1:n_elements(list_keep)-1]

  arrval=dblarr(n_elements(list_keep),nvar)
  FOR i=0,nvar-1 DO BEGIN 
     arrval[*,i]=res.simpar[list_keep].(indtag[indvar[i]])
  ENDFOR

  dimension=lonarr(nvar)
  FOR i=0,nvar-1 DO dimension[i]=n_elements(*uniqtag[indvar[i]])


  dummy=pg_arraysort(arrval,out_index=out_index)
  ans_indices=list_keep[out_index]
  
  gamma=res.spindex_thin[ans_indices]
  flux=res.fnorm_thin[ans_indices]
  
  ans1=make_array(/double,dimension=reverse(dimension))
  ans2=make_array(/double,dimension=reverse(dimension))
  ans1[*]=gamma
  ans2[*]=flux
 
  IF keyword_set(couple_tau_ut) THEN BEGIN 
     out={gamma:transpose(ans1),flux:transpose(ans2),emin:res.emin,emax:res.emax, $
          enorm:res.enorm,varpar:uniqtag[indvar],fixpar:uniqtag[indfix], $
          fix_tagnames:fixed_tagnames,fix_tagind:fixed_tagind, $
          var_tagnames:tagnames[indtag[indvar]], $
          couple_tau_ut:1,tauescape:tauall}
  ENDIF ELSE BEGIN 
     out={gamma:transpose(ans1),flux:transpose(ans2),emin:res.emin,emax:res.emax, $
          enorm:res.enorm,varpar:uniqtag[indvar],fixpar:uniqtag[indfix], $
          fix_tagnames:fixed_tagnames,fix_tagind:fixed_tagind, $
          var_tagnames:tagnames[indtag[indvar]], $
          couple_tau_ut:0}
  ENDELSE


  RETURN,out

END
