;+
; NAME:
;
;   pg_update_events
;
; PURPOSE:
;
;   update the events from the list (i.e., generates new data products for
;   events not already in the list)
;
; CATEGORY:
;
;   RHESSI util
;
; CALLING SEQUENCE:
;
;   pg_update_events
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
;  as files on the disk
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
;   Paolo Grigis ( pgrigis@astro.phys.ethz.ch )
;
; MODIFICATION HISTORY:
;
;   15-JAN-2007 written PG
;
;-

;.comp  pg_update_events

PRO pg_update_events,flareinfo,listfilebasename,basdir=basdir

  basdir=fcheck(basdir,'~/hsiflaresforhinode/')
  ps=path_sep()

  datadir=basdir+'data'+ps
  
  IF NOT exist(listfilebasename) THEN listfilebasename='flarelist_done'

  txtfile=datadir+listfilebasename+'.txt'
  fitsfile=datadir+listfilebasename+'.fits'

  IF file_exist(txtfile) THEN BEGIN 

     idlistold=pg_readidfromfile(txtfile)

     idlist=flareinfo[*].id_number

     ;stop

     todoflares=cmset_op(/not1,idlistold,'and',idlist,/index,count=count)-n_elements(idlistold)
     
     IF count EQ 0 THEN BEGIN
        print,'No new event, no update needed!'
        RETURN
     ENDIF

  ENDIF ELSE BEGIN 
       todoflares=findgen(n_elements(flareinfo))
  ENDELSE


 
  FOR i=0,n_elements(todoflares)-1 DO BEGIN 


     print,'Now doing flare '+string(i)
     print,'Flare_id: '+string(flareinfo[todoflares[i]].id_number)

     pg_dataforoneevent,flareinfo[todoflares[i]],datadir,outdir=outdir

     openw,lun,txtfile,/get_lun,/append

     printf,lun,strtrim(string(flareinfo[todoflares[i]].id_number),2)+'  '+outdir $
           +'  '+togoes(flareinfo[todoflares[i]].goes_class)

     close,lun
     free_lun,lun

     IF NOT file_exist(fitsfile) THEN BEGIN
        data=flareinfo[todoflares[i]]
     ENDIF ELSE BEGIN 
        data0=mrdfits(fitsfile,1)
        data=[data0,flareinfo[todoflares[i]]]
     ENDELSE
     mwrfits,data,fitsfile,/create
     
  ENDFOR
  
  ;FITS file manipulation?



END
