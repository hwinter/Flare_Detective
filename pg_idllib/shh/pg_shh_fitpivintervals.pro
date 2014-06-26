;+
;
; NAME:
;        pg_shh_ovplot
;
; PURPOSE: 
;        returns pivot points, slopes etc. from intervals of data
;
; CALLING SEQUENCE:
;
;        pg_shh_fitpivintervals,fitres,...
;
; INPUTS:
;
;        fitres: a sstructure with TAGS:
;   TIME            DOUBLE    Array[n]
;   CHISQ           DOUBLE    Array[n]
;   FITPAR          DOUBLE    Array[9, n]
;   RESIDUALS       DOUBLE    Array[x, n]
;   CNTSPECTRA      DOUBLE    Array[x, n]
;   CNTESPECTRA     DOUBLE    Array[x, n]
;   CNTMODELS       DOUBLE    Array[x, n]
;   BSPECTRUM       FLOAT     Array[x]
;   BESPECTRUM      FLOAT     Array[x]
;   ENORM           FLOAT           50.0000
;   ERANGE          INT       Array[2]
;   THERMRANGE      INT       Array[2]
;   NONTHERMRANGE   INT       Array[2]
;   PARINFO         POINTER   Array[n]
;
; OUTPUT:
;        
; EXAMPLE:
;
;        
;
; VERSION:
;
;     DEC-2003 written
;        
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;-

;.comp pg_shh_fitpivintervals

FUNCTION pg_shh_fitpivintervals,fitres,rise=rise,decay=decay,flat=flat,parplotst=parplotst



  r0=reform(rise[0,*])
  d0=reform(decay[0,*])
  f0=reform(flat[0,*])
  ind=sort([r0,d0,f0])
  allphases=[[rise],[decay],[flat]]
  allphases=allphases[*,ind]

  time=fitres.time


  ;select plot par here...

  p1=fitres.fitpar[parplotst.parplot[0],*]
  p2=fitres.fitpar[parplotst.parplot[1],*]

  p1range=parplotst.parrange[0:1]
  p2range=parplotst.parrange[2:3]

  xlog=parplotst.parlog[0]
  ylog=parplotst.parlog[1]

  pg_setplotsymbol,'CIRCLE'

  p1name=fitres.parnames[parplotst.parplot[0]]
  p2name=fitres.parnames[parplotst.parplot[1]]

  nap=n_elements(allphases)/2

  a_out=dblarr(6,nap)
  b_out=dblarr(6,nap)
  siga_out=dblarr(6,nap)
  sigb_out=dblarr(6,nap)
  epiv=dblarr(nap)
  fpiv=dblarr(nap)

  enorm=fitres.enorm
   

  this_time_intv=dblarr(2,nap)

  phastype=bytarr(nap)


     FOR i=0,nap-1 DO BEGIN 


        intv=allphases[*,i]
  

        p1s=xlog EQ 0 ? p1[intv[0]:intv[1]] : alog(p1[intv[0]:intv[1]])
        p2s=ylog EQ 0 ? p2[intv[0]:intv[1]] : alog(p2[intv[0]:intv[1]])

        indok=where(finite(p1s) AND finite(p2s),count)
        IF count GT 0 THEN BEGIN 
           p1s=p1s[indok]
           p2s=p2s[indok]
        ENDIF


        sixlin,p1s,p2s,a,siga,b,sigb
        
        a_out[*,i]=a
        siga_out[*,i]=siga
        b_out[*,i]=b
        sigb_out[*,i]=sigb

        dummy=where(r0 EQ intv[0],isrise)
        dummy=where(d0 EQ intv[0],isfall)
        dummy=where(f0 EQ intv[0],isflat)
     
        phastype[i]=1*isrise+2*isfall+3*isflat

      ;find pivot point

        epiv[i]=enorm*exp(-b[2])
        fpiv[i]=epiv[i]/enorm*exp(-a[2])
     

        this_time_intv[*,i]=time[[intv[0],intv[1]]]


     ENDFOR



  result={allphases:allphases,rise:rise,decay:decay,flat:flat $
         ,phastype:phastype,intercept:a_out,slope:b_out,siginter:siga_out,sigslope:sigb_out $
         ,epiv:epiv,fpiv:fpiv,enorm:enorm,xpar:p1,ypar:p2,xparname:p1name,yparname:p2name $
         ,time_intv:this_time_intv}


  return,result




END












