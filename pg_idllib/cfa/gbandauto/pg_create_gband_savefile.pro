;+
; NAME:
;
; pg_create_gband_savefile
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
; AUTHOR:
;
; Paolo C. Grigis, pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 29-APR-2008 PG - written 
; 21-JUL-2008 PG - removed manual offset for 2x2 binned images, as xrt_prep now
;                  takes care of it.
;
;-

PRO pg_create_gband_savefile,time_intv,filenamebase=filenamebase,datadir=datadir


datadir=fcheck(datadir,'~/machd/gbandauto/')
filenamebase=fcheck(filenamebase,'dummy')



lev0dir=datadir+'/level0/'
lev1dir=datadir+'/level1/'

search = ['naxis1=2048','naxis2=2048','xcen=-64~64','ycen=-64~64','chip_sum=1', $
          'ec_fw1_=Open','ec_fw2_=Gband','ec_vl_=open','ec_imty_=normal']
xrt_cat,time_intv[0],time_intv[1],cat1,files1,search_array=search,sirius=0

search = ['naxis1=2048','naxis2=2048','xcen=-64~64','ycen=-64~64','chip_sum=1', $
          'ec_fw1_=Open','ec_fw2_=Gband','ec_vl_=open','ec_imty_=normal']
xrt_cat,time_intv[0],time_intv[1],cat1s,files1s,search_array=search,sirius=1

;find files in 1 and 1s, 1 and not 1s, 1s and not 1
filesaandb=cmset_op(files1,'AND',files1s)
IF size(filesaandb,/tname) NE 'STRING' THEN filesaandb=''
filesanotb=cmset_op(files1,'AND',/not2,files1s)
IF size(filesanotb[0],/tname) NE 'STRING' THEN filesanotb=''
filesbnota=cmset_op(/not1,files1,'AND',files1s)
IF size(filesbnota[0],/tname) NE 'STRING' THEN filesbnota=''

;IF time_intv[0] GT anytim('07-nov-2006') THEN stop

files1ok=[filesaandb,filesanotb,filesbnota]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

search = ['naxis1=1024','naxis2=1024','xcen=-64~64','ycen=-64~64','chip_sum=2', $
          'ec_fw1_=Open','ec_fw2_=Gband','ec_vl_=open','ec_imty_=normal']
xrt_cat,time_intv[0],time_intv[1],cat2,files2,search_array=search,sirius=0

search = ['naxis1=1024','naxis2=1024','xcen=-64~64','ycen=-64~64','chip_sum=2', $
          'ec_fw1_=Open','ec_fw2_=Gband','ec_vl_=open','ec_imty_=normal']
xrt_cat,time_intv[0],time_intv[1],cat2s,files2s,search_array=search,sirius=1

;find files in 2 and 2s, 2 and not 2s, 2s and not 2
filesaandb2=cmset_op(files2,'AND',files2s)
IF size(filesaandb2,/tname) NE 'STRING' THEN filesaandb2=''
filesanotb2=cmset_op(files2,'AND',/not2,files2s)
IF size(filesanotb2,/tname) NE 'STRING' THEN filesanotb2=''
filesbnota2=cmset_op(/not1,files2,'AND',files2s)
IF size(filesbnota2,/tname) NE 'STRING' THEN filesbnota2=''

files2ok=[filesaandb2,filesanotb2,filesbnota2]



IF total(file_exist(files1ok)) GE 1 THEN BEGIN 

   read_xrt,files1ok,index1,data1
   xrt_prep,index1,data1,indexp1,datap1,despike=0,/normalize,/float

   save,index1,data1,filename=lev0dir+filenamebase+'_bin1.sav'
   save,indexp1,datap1,filename=lev1dir+filenamebase+'_bin1.sav'

   data1=0
   datap1=0

ENDIF

IF total(file_exist(files2ok)) GE 1 THEN BEGIN 

   read_xrt,files2ok,index2,data2

;  xrt_prep,index2,(data2-104.98)>0,indexp2,datap2,despike=0,/normalize,/float
                                ;do to the new way xrt_prep works,
                                ;there's no need to manually subtract the
                                ;offset in case of 2x2 binning
   xrt_prep,index2,(data2)>0,indexp2,datap2,despike=0,/normalize,/float

   save,index2,data2,filename=lev0dir+filenamebase+'_bin2.sav'
   save,indexp2,datap2,filename=lev1dir+filenamebase+'_bin2.sav'
 
ENDIF


END



