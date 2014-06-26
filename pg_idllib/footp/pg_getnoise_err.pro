;+
; NAME:
;      pg_getnoise_err
;
; PURPOSE: 
;      noise error estimate (for clean images). Works as follows:
;         tpos contains boxes around the sources. The noise of the
;         image outside the sources is evaluated, and for each source
;         the peak flux is used to get a S/N ratio. The error is then
;         given as the FWHM of the (fitted) source divided by S/N.
;
;      LIMITATION for now: works just for the case where there are 2
;      (and only 2) SOURCES
;
; CALLING SEQUENCE:
;
;      pg_getnoise_err(tpos,imseq)
;
; INPUTS:
;      
;      tpos: tranformed position structure, the output from pg_transform_pos
;
;      imseq: the image sequence
;  
; OUTPUTS:
;      
;      
; KEYWORDS:
;      
;       increase_box_size: this specify how much the box has to be
;          increased to be sure that no part of the source is counted
;          in the noise. Default: 10 (in image units, typically
;          arcseconds)
;       notiltcorrection: if set, does *not* implement tilt correction
;          tilt correction is implementde by default
; HISTORY:
;
;      12-JAN-2004 written
;      18-JAN-2004 accounts for the tilt angle in the gaussian fit
;      
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

FUNCTION pg_getnoise_err,tpos,imseq,increase_box_size=increase_box_size $
                        ,notiltcorrection=notiltcorrection

increase_box_size=fcheck(increase_box_size,10)

flist=tpos.framelist

nsources=2;SPECIAL CASE instead of n_elements(flist[*,0])
npeaks=n_elements(flist[0,*])

possigma=ptrarr(2,npeaks)

;nim=n_elements(imseq)

FOR i=0,npeaks-1 DO BEGIN

   this_possigma1=fltarr(2,n_elements(*tpos.framelist[0,i]))
   this_possigma2=fltarr(2,n_elements(*tpos.framelist[1,i]))
   this_possigma1[*]=!values.f_nan
   this_possigma2[*]=!values.f_nan
   
   ;check if all the sources are present
   list1=*flist[0,i]
   list2=*flist[1,i]

   ;raw fit output

   rfo1=tpos.rawfitoutput[0,i]
   rfo2=tpos.rawfitoutput[1,i]

   ;pbox is in the format xmin,xmax,ymin,ymax
   pbox1=*tpos.pbox[0,i]
   pbox2=*tpos.pbox[1,i]

   dummy=where(finite(pbox1),count1)
   dummy=where(finite(pbox2),count2)
  
   okpbox=(count1+count2) EQ 8

   IF okpbox THEN BEGIN 

   ;increse box size: (larger pbox: lpbox)
   lpbox1=pbox1+increase_box_size*[-1.,1,-1,1]
   lpbox2=pbox2+increase_box_size*[-1.,1,-1,1]

 
   set=cmset_op(list1,'AND',list2)

   
   FOR j=0,n_elements(set)-1 DO BEGIN 

      print,set[j]

      map=*imseq[set[j]]
      im=map.data
      
      ;get the corners of the enlarged "good" part (conatining the sources)
      llc1=round(map_coor2pix(lpbox1[[0,2]],map))
      llc2=round(map_coor2pix(lpbox2[[0,2]],map))
      urc1=round(map_coor2pix(lpbox1[[1,3]],map))
      urc2=round(map_coor2pix(lpbox2[[1,3]],map))

      llc1[0]=llc1[0]>0
      llc2[0]=llc2[0]>0
      llc1[1]=llc1[1]>0
      llc2[1]=llc2[1]>0
 
      nbx=n_elements(im[*,0])-1
      nby=n_elements(im[0,*])-1

      urc1[0]=urc1[0]<nbx
      urc2[0]=urc2[0]<nbx
      urc1[1]=urc1[1]<nby
      urc2[1]=urc2[1]<nby
      
      ;set the contents of this boxes to NANs
      data=map.data
      data[llc1[0]:urc1[0],llc1[1]:urc1[1]]=!Values.f_nan
      data[llc2[0]:urc2[0],llc2[1]:urc2[1]]=!Values.f_nan

;  diagnostic: plot of image & boxes
;  map2=map
;  map2.data=data
;  plot_map,map2
;  oplot,pbox1[[0,1,1,0,0]],pbox1[[2,2,3,3,2]]
;  oplot,pbox2[[0,1,1,0,0]],pbox2[[2,2,3,3,2]]
 
 
      ;get indices of points outside boxes
      ind=where(finite(data),count)

      IF count LT 2 THEN BEGIN
         print,'NOT ENOUGH GOOD DATA! RETURNING.'
         print,"try decreasing the value of 'increase_box_size'"
         RETURN,-1
      ENDIF 

      mom=moment(data[ind])
      IF have_tag(map,'pg_im_error') THEN BEGIN
         noise=sqrt((moment(map.pg_im_error))[1])
      ENDIF $ 
      ELSE BEGIN 
         noise=sqrt(mom[1])
      ENDELSE

      ;for each source, get max signal (here use pbox, not lpbox)
      
      ;get the corners of the unenlarged "good" part (containing the sources)
      llc1=round(map_coor2pix(pbox1[[0,2]],map))
      llc2=round(map_coor2pix(pbox2[[0,2]],map))
      urc1=round(map_coor2pix(pbox1[[1,3]],map))
      urc2=round(map_coor2pix(pbox2[[1,3]],map))

 
      data=map.data
      data2=map.data
      data2[llc1[0]:urc1[0],llc1[1]:urc1[1]]=!Values.f_nan
 
      ;get indices of points inside box1
      ind=where(1-finite(data2),count)

      IF count LT 1 THEN BEGIN
         print,'NOT ENOUGH GOOD DATA! RETURNING.'
         print,"try enlarging the value of 'increase_box_size'"
         RETURN,-1
      ENDIF 

      flux1=max(data[ind])
      data2=map.data
      data2[llc2[0]:urc2[0],llc2[1]:urc2[1]]=!Values.f_nan
 
      ;get indices of points inside box2
      ind=where(1-finite(data2),count)

      IF count LT 1 THEN BEGIN
         print,'NOT ENOUGH GOOD DATA! RETURNING.'
         print,"try enlarging the value of 'increase_box_size'"
         RETURN,-1
      ENDIF 

      flux2=max(data[ind])
      
      ;have 2 S/N ratios now

      ;get sigma of peak
      sig1x=(*(*rfo1)[j])[2]
      sig1y=(*(*rfo1)[j])[3]
      sig2x=(*(*rfo2)[j])[2]
      sig2y=(*(*rfo2)[j])[3]

      tiltangle1=(*(*rfo1)[j])[6]
      tiltangle2=(*(*rfo2)[j])[6]

      ;add estimated error to data

      ;check where in this_possigma you need to put the value

      inpos1=where(list1 EQ set[j])
      inpos2=where(list2 EQ set[j])


      IF keyword_set(notiltcorrection) THEN BEGIN 
;--------> direct computation, no tilt angle with optional keyword
         this_possigma1[0,inpos1]=sig1x/(flux1/noise)
         this_possigma1[1,inpos1]=sig1y/(flux1/noise)
         this_possigma2[0,inpos2]=sig2x/(flux2/noise)
         this_possigma2[1,inpos2]=sig2y/(flux2/noise)
      ENDIF ELSE BEGIN  

      ;default correction
      ;convert the values to the values for tilt angle
      ;use geometric formula c^2=a^2*cos^2a+b^2*sin^2a
      ;don't know if this law has a name

          ;define temporary variables
          tp10=sig1x/(flux1/noise)
          tp11=sig1y/(flux1/noise)
          tp20=sig2x/(flux2/noise)
          tp21=sig2y/(flux2/noise)

          ;correct for tilt angle
          this_possigma1[0,inpos1]=sqrt((tp10*cos(tiltangle1))^2+$
                                        (tp11*sin(tiltangle1))^2)
          this_possigma1[1,inpos1]=sqrt((tp11*cos(tiltangle1))^2+$
                                        (tp10*sin(tiltangle1))^2)
          this_possigma2[0,inpos2]=sqrt((tp20*cos(tiltangle2))^2+$
                                        (tp21*sin(tiltangle2))^2)
          this_possigma2[1,inpos2]=sqrt((tp21*cos(tiltangle2))^2+$
                                        (tp20*sin(tiltangle2))^2)

      ENDELSE

      
   ENDFOR

   ENDIF


   possigma[0,i]=ptr_new(this_possigma1)
   possigma[1,i]=ptr_new(this_possigma2)

ENDFOR

;add pos sigma
out_tpos=add_tag(tpos,possigma,'POS_SIGMA')

;also add this as a simple array format of sigmax, sigmay
Ntotframes=tpos.n_totframes
Nsources=2

;output position array init
xpos=dblarr(Ntotframes,Nsources)
ypos=dblarr(Ntotframes,Nsources)

;set invalid pos as default
xpos[*]=!Values.F_NAN
ypos[*]=!Values.F_NAN
   
FOR i=0,npeaks-1 DO BEGIN 
   FOR j=0,nsources-1 DO BEGIN 

      actualframes=*(out_tpos.framelist[j,i])
      pos=*((out_tpos.pos_sigma)[j,i])

      FOR l=0,n_elements(actualframes)-1 DO BEGIN
         xpos[actualframes[l],j]=pos[0,l]
         ypos[actualframes[l],j]=pos[1,l]         
      ENDFOR

   ENDFOR
ENDFOR

out_tpos=add_tag(out_tpos,transpose(xpos),'POSSIGXARR')
out_tpos=add_tag(out_tpos,transpose(ypos),'POSSIGYARR')

RETURN,out_tpos

END
