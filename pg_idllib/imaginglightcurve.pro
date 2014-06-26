;+
;
; NAME:
;       imaginglightcurve
;
; PROJECT: 
;       vls/rhessi
;
; PURPOSE: 
;       plot lightcurves of selected regions
;
; CALLING SEQUENCE:
;       findpos,ptrim
;
; INPUTS:
;       ptrim: pointer to structure with images and hessi pars 
;
; OUTPUT:
;       by keywords
;       
; KEYWORDS:
;       lc,tim: lightcurve & time array 
;       q: array of pointers to arrays with pixe lpositions of the ROI
;
; EXAMPLE:
;        .comp work/vlahessi/imaginglightcurve
;        imaginglightcurve
;
; VERSION:
;       11-NOV-2002 written
;       13-NOV-2002 imported in rapp_idl
;
; COMMENT:
;       the idea is the following: for each image sequence and energy
;       interval find the time interval with the brightest pixel,
;       (or pixel region, say 2x2 or 4x4 -->not yet used),
;       define the region with (frmax)% of max flux there,
;       compute lightcurve for this region (ROI)
;
;       
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

PRO imaginglightcurve,ptrim,lc=lc,tim=tim,maxfr=maxfr,roi=roi

IF NOT exist(ptrim) THEN BEGIN

    bt='2002-10-01T14:45:00.000Z.dat'
    dir='/global/tethys/data1/pgrigis/vlahessi/autodata/'

    ptrim=ptrarr(2,3,50)

    restore,dir+'im1-36-'+bt
    ptrim[0,0,*]=ptr
    restore,dir+'im1-610-'+bt
    ptrim[0,1,*]=ptr
    restore,dir+'im1-1015-'+bt
    ptrim[0,2,*]=ptr

    restore,dir+'im2-36-'+bt
    ptrim[1,0,*]=ptr
    restore,dir+'im2-610-'+bt
    ptrim[1,1,*]=ptr
    restore,dir+'im2-1015-'+bt
    ptrim[1,2,*]=ptr

ENDIF


;-------------------------------------------------
; find max in the sequence
;-------------------------------------------------

dim=size(ptrim)

maxtime=intarr(dim[1],dim[2])
max=intarr(dim[1],dim[2])

FOR nim=0,dim[1]-1 DO BEGIN     ;number of images
    FOR en=0,dim[2]-1 DO BEGIN  ;energy bands
        max[nim,en]=0
        FOR t=0,dim[3]-1 DO BEGIN ;time intervals

            IF max((*ptrim[nim,en,t]).im) GT max[nim,en] THEN BEGIN
                max[nim,en]=max((*ptrim[nim,en,t]).im)
                maxtime[nim,en]=t
            ENDIF

        ENDFOR
    ENDFOR
ENDFOR



;------------------------------------------------------
;define region of interest (ROI)
;------------------------------------------------------


;======================================================
; first try...

; maxfr=0.5
; nim=0
; en=0
; wdef,0
; image=(*ptrim[nim,en,maxtime[nim,en]]).im
; im=congrid(image,512,512)
; tvscl,im

; q=where2((*ptrim[nim,en,maxtime[nim,en]]).im GT maxfr*max[nim,en])
; wdef,1
; image[q[0,*],q[1,*]]=max[nim,en]
; im=congrid(image,512,512)
; tvscl,im

;=======================================================


IF NOT exist(maxfr) THEN maxfr=0.5

IF NOT exist(roi) THEN BEGIN

;IF NOT exist(q) THEN BEGIN

    q=ptrarr(dim[1],dim[2])

    FOR nim=0,dim[1]-1 DO BEGIN       ;number of images
        FOR en=0,dim[2]-1 DO BEGIN    ;energy bands
  
            q[nim,en]=ptr_new(where2((*ptrim[nim,en,maxtime[nim,en]]).im GT maxfr*max[nim,en]))  

        ENDFOR
    ENDFOR

roi=q
;q gives the ROI for each energy band,time_intv

ENDIF ELSE q=roi


;----------------------------------------------------------
;generate lightcurve
;----------------------------------------------------------

lc=fltarr(dim[1],dim[2],dim[3])
tim=dblarr(dim[1],dim[2],dim[3])

FOR nim=0,dim[1]-1 DO BEGIN     ;number of images
    FOR en=0,dim[2]-1 DO BEGIN  ;energy bands
        max[nim,en]=0

        numpix=(size(*roi[nim,en]))[2]

        FOR t=0,dim[3]-1 DO BEGIN ;time intervals

       ;lc[nim,en,t]=total((*ptrim[nim,en,t]).im[q[0,*],q[1,*]])
            lc[nim,en,t]=total((*ptrim[nim,en,t]).im[(*q[nim,en])[0,*],(*q[nim,en])[1,*]])/numpix

            tim[nim,en,t]=0.5*total((*ptrim[nim,en,t]).hessipar.time_range)

        ENDFOR
    ENDFOR
ENDFOR

END






















