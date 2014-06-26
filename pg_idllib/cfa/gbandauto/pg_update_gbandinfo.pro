;+
; NAME:
;
; pg_update_gband_savefile
;
; PURPOSE:
;
; create a g-band IDL save file, given an input time interval
;
; CATEGORY:
;
; gband datraproduct automatic creation
;
; CALLING SEQUENCE:
; 
; pg_create_gband_savefile,time_intv
;
; INPUTS:
;
; tim_intv: a 2 elemnt array in anytim compatible format;
;           The file is created for that time.
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
; MODIFICATION HISTORY:
;
;-

PRO pg_update_gbandinfo,time_intv,filenamebase=filenamebase,datadir=datadir,st1=st1,st2=st2


datadir=fcheck(datadir,'~/machd/gbandauto/')
filenamebase=fcheck(filenamebase,'dummy')

lev0dir=datadir+'/level0/'
lev1dir=datadir+'/level1/'


;pg_update_gbandinfo,['01-OCT-2006','01-DEC-2006'],st1=st1,st2=st2

;read in all files in time_intv one by one...

startime=anytim(time_intv[0],/date_only)
endtime=anytim(anytim(time_intv[1])+24.*3600,/date_only)
ndays=round((endtime-startime)/(24.*3600.))

first1=1
first2=1

st1=-1
st2=-1

spmfile='~/ssw/hinode/xrt/idl/util/xrt_spotmasters.geny'
restgenx,file=spmfile,spotmap

spm1=spotmap[*,*,0]
spm2=spotmap[*,*,1]
spm1and2=(spm1 EQ 1 AND spm2 EQ 1)

spm1bin2=rebin(float(spm1),1024,1024) GT 0.
spm2bin2=rebin(float(spm2),1024,1024) GT 0.
spm1and2bin2=rebin(float(spm1and2),1024,1024) GT 0.


FOR i=0,ndays-1 DO BEGIN
   today=startime+24.*3600*i
   thisyear=(anytim(today,/ex))[6]

   fnb=filenamebase+strtrim(thisyear,2)+'_'+smallint2str(doy(today),strlen=3)
   
   f1=lev1dir+fnb+'_bin1.sav'
   f2=lev1dir+fnb+'_bin2.sav'

   IF file_exist(f1) THEN BEGIN 
      restore,f1
      ;plot_image,datap1[*,*,0]
      thisst1=pg_gbandstructinfo(datap1,indexp1,spotmap=spm2,dx=128,dy=128)
      IF first1 THEN BEGIN 
         st1=thisst1
         first1=0
      ENDIF $
      ELSE st1=[st1,thisst1]
   ENDIF
   IF file_exist(f2) THEN BEGIN 
      restore,f2
      thisst2=pg_gbandstructinfo(datap2,indexp2,spotmap=spm2bin2,dx=64,dy=64)
      IF first2 THEN BEGIN 
         st2=thisst2
         first2=0
      ENDIF $
      ELSE st2=[st2,thisst2]
   ENDIF

ENDFOR


END



