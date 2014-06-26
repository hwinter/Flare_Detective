;+
; NAME:
;
; pg_readsrmfitsfile
;
; PURPOSE:
;
; read a spectral response matrix FITS file as written by RHESSI spectrum object using
; the fitswrite,/build method
;
; CATEGORY:
;
; rhessi spectrograms/fitting util
;
; CALLING SEQUENCE:
;
; srm=pg_readsrmfitsfile(filename)
;
; INPUTS:
;
; filename: name of the RHESSI srm fits file
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
; [...]
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
; 06-NOV-2006 pg written
; 07-NOV-2006 pg added geom_area tag
; 02-APR-2007 pg check for filename existence
;
;-

FUNCTION pg_readsrmfitsfile,filename

IF NOT exist(filename) THEN BEGIN
   print,'Please input a filename!'
   RETURN,-1
ENDIF

IF NOT file_exist(filename) THEN BEGIN
   print,'The file '+filename+' does not exist!'
   RETURN,-1
ENDIF


    filterstates=-1
    status=0
    this_extension=3

;tries to read extension number 4 --> if it works, than the files stores
;multiple filter states ant it will count them

    REPEAT BEGIN   

       filterstates=filterstates+1
       this_extension=this_extension+1
       srmdata=mrdfits(filename,this_extension,status=status,/silent)

    ENDREP $
    UNTIL status NE 0
   
;    print,filterstates

    data1=mrdfits(filename,1,header1,status=status,/silent)
    IF status NE 0 THEN BEGIN 
       print,'Error reading FITS files'
       RETURN,-1
    ENDIF
    head1=fitshead2struct(header1)

    data2=mrdfits(filename,2,header2,status=status,/silent)
    IF status NE 0 THEN BEGIN 
       print,'Error reading FITS files'
       RETURN,-1
    ENDIF

    matrix=data1.matrix
    filter_state=head1.filter
    geom_area=head1.geoarea

    cntedges=[[data2.e_min],[data2.e_max]]
    photedges=[[data1.energ_lo],[data1.energ_hi]]

    FOR i=0,filterstates-1 DO BEGIN 
       thisdata=mrdfits(filename,i+4,thisheader,status=status,/silent)
       IF status NE 0 THEN BEGIN 
          print,'Error reading FITS files'
          RETURN,-1
       ENDIF
       matrix=[[[matrix]],[[thisdata.matrix]]]
       thishead=fitshead2struct(thisheader)
       filter_state= [filter_state,thishead.filter]
       geom_area=[geom_area,thishead.geoarea]
    ENDFOR


    srmstruct={cntedges:cntedges,photedges:photedges,matrix:matrix $
              ,filter_state:filter_state,geom_area:geom_area}
    
    RETURN,srmstruct


END
