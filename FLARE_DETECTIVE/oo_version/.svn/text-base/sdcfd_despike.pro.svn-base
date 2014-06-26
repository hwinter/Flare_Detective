;+
;NAME:    sdcfd_despike.pro    
;PURPOSE: despike an image using a median filter (default) that eliminates
;         spikes exceeding `threshold' percent (detault = 15%), or using a
;         statistical correction that corrects pixels diviating by more than
;         `statistics' sigma from the expected noise given the photon
;         statistics and electron-to-DN amplifiction.
;SUBROUTINES: none
;CALLING SEQUENCE: image=sdcfd_despike(image)
;OUTPUT: returns despiked image array
;EXAMPLE: 
;  imout=tracedespike(readfits('file'))        simple correction
;  imout=tracedespike(despike(image))          double correct. for faint fields
;  imout=tracedespike(image,statistics=6)      correct > 6sigma outliers
;  imout=tracedespike(image,minimum=100,ri=3)  low-quartile corr. above I=100
;  imout=tracedespike(image,nspikes=nspikes,imap=imap) to return the number of
;                                              spikes removed and a pixel map
;OPTIONAL KEYWORD INPUT:
;  nspikes	       number of spikes removed
;  imap                map of corrected pixels
;  ri                  replacement index: ri=7 or 8 for median filter
;  threshold           fractional threshold for brightness
;  minimum             do not correct pixels dimmer than minimum
;  statistics          use statistical correction beyond stat.. sigma
;  ampl                amplification of CCD signal
;HISTORY:
; Karel Schrijver, 20 May 1998.
; Revised: CJS     27 May 1998: changed loop counter to long word
; Revised: CJS     09 Mar 1999: changed to return repair mask
;          SLF     09 Mar 1999: added LOUD keyword (no function but interface
;                               compatible with earlier version)
; Paolo Grigis     19-MAY-2009: added quiet keyword, renamed to avoid ssw conflicts
;
; CPU time scales roughly linearly with the size of the array
;
; Note that there are two mutually exlusive keyword sets:
;  for criterion of relative intensity: threshold, minimum
;  for statistical correction:          statistics, ampl
;
;-
function sdcfd_despike,image,nspikes=nspikes,imap=imap,ri=ri,$
         threshold=threshold,minimum=minimum,statistics=statistics,ampl=ampl, $
         loud=loud,quiet=quiet

  ;replacement threshold
if keyword_set(threshold) then threshold=threshold else threshold=0.15
  ;replacement index
if keyword_set(ri) then ri=ri else ri=7 ; close to median
  ;minimal required brightness
if keyword_set(minimum) then minimum=minimum else minimum=140  
  ; number of standard deviations
if keyword_set(statistics) then sigma=statistics else sigma=6.
  ; electronic amplification
if keyword_set(ampl) then ampl=ampl else ampl=14.
  ; determine array dimensions, and expand the array with two rows and columns
  ; on all sides, and determine the 3x3 boxcar average
d=size(image) 
nx=d(1) 
ny=d(2) 
imout=replicate(1,nx+4,ny+4)
imout(2,2)=image 
imring=smooth(imout,3)       ; slower: ((smooth(imout,3)*9)<32000-imout)/8
  ; candidate replacement map
map=replicate(0.,nx+4,ny+4)
  ; find both exceptionally high and low values
if keyword_set(statistics) then begin
  IF keyword_set(quiet) EQ 0 THEN  print,'Eliminating outliers beyond ',fix(sigma+.5),' sigma using A=',ampl
  map(3,3)=((imout-imring))(3:nx,3:ny) 
  imap=where(map^2*(ampl/sigma^2) gt imout)
endif else begin
  IF keyword_set(quiet) EQ 0 THEN print,'Eliminating positive outliers deviating more than',fix(threshold*100),$ 
    ' percent.'
  map(3,3)=((imout-imring)/float(imout))(3:nx,3:ny) 
  imap=where(map gt threshold and imout gt minimum)
endelse
  ; ring array 5x5
five=[-2*nx-2,-2*nx-1,-2*nx,-2*nx+1,-2*nx+2,-nx-2,-nx+2,-2,2,nx-2,nx+2,$
       2*nx-2,2*nx-1,2*nx,2*nx+1,2*nx+2]
  ; replace hits by chosen value
imout(2,2)=image 
if imap(0) ge 0 then for i=0l,n_elements(imap)-1 do $
  imout(imap(i))=imout(imap(i)+five((sort(imout(imap(i)+five)))(ri))) 
  ; cutout the array and return
IF keyword_set(quiet) EQ 0 THEN print,'Corrected ',n_elements(imap),' radiation hits and bad pixels'
nspikes=n_elements(imap)
return,imout(2:1+nx,2:1+ny)
end
