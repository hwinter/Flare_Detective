;+
; NAME:
;
;  pg_detectpeak
;
; PURPOSE:
;
; detects a peak in a lightcurve
;
; CATEGORY:
;
;
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
; MODIFICATION HISTORY:
;
;-


PRO pg_detectpeak,lc,func=func,width=width,threshold=threshold,smder=smder $
                  ,smlc=smlc,start=okstart,endtt=okendtt,tr1=tr1,tr2=tr2,tr3=tr3 $
                  ,indextr1=indextr1,indextr2=indextr2,indextr3=indextr3 $
                  ,doplot=doplot,normf=normf


;variable initiaization
width=fcheck(width,6)
threshold=fcheck(threshold,0.1)

nlc=n_elements(lc)
x=findgen(nlc)/(nlc-1)*1-0.5
dx=1d/(nlc-1)

func=fcheck(func,'pg_gauss_scale')
f=call_function(func,x,xc=0.,width=width*dx)

;create smoothed version of light curve
smlc=reverse(reform(double(shift(fft(fft(lc,-1)*fft(f,-1)),-nlc/2-2))*nlc))

;compute numerical derivative
smder=(shift(smlc,-1)-shift(smlc,1))/dx


;define parameters

normf=fcheck(normf,0.002)
ttr1=fcheck(tr1, 0.5)/normf
ttr2=fcheck(tr2, 0.1)/normf
ttr3=fcheck(tr3,-0.1)/normf


;first pass: identify where tr1, tr2, tr3 is reached

indextr1up  =where(smder LE ttr1 AND shift(smder,-1) GT ttr1,countr1up)
indextr2up  =where(smder LE ttr2 AND shift(smder,-1) GT ttr2,countr2up)

indextr2down=where(smder LE ttr2 AND shift(smder,-1) GT -ttr2,countr2down)
indextr3down=where(smder LE ttr3 AND shift(smder,-1) GT  ttr3,countr3down)

;treshold 1 up


;build all intervals...

start=-1
endtt=-1

IF (countr1up GT 0) AND (countr2up GT 0) THEN BEGIN 
   
;;   indtest1=where(indextr1up EQ indextr2up,counttest1)
;;   IF counttest1 GT 0 THEN BEGIN 
;;      indextr1up[indtest1]=(indextr1up[indtest1]+1)<(nlc-1)
;;   ENDIF

   onearr=replicate(1,countr1up)
   twoarr=replicate(2,countr2up)
   allarr=[indextr2up,indextr1up]
   srtarr=bsort(allarr)
   resarr=([twoarr,onearr])[srtarr]

   startind=where( resarr EQ 2 AND shift(resarr,-1) EQ 1,countstart)
   
   start=allarr[srtarr[startind]]

ENDIF

IF (countr2down GT 0) AND (countr3down GT 0) THEN BEGIN 
 
;;   indtest2=where(indextr3down EQ indextr2down,counttest2)
;;   IF counttest2 GT 0 THEN BEGIN 
;;      indextr3down[indtest2]=(indextr3down[indtest2]+1)<(nlc-1)
;;   ENDIF

   twoarr=replicate(2,countr2down)
   trearr=replicate(3,countr3down)
   allarr=[indextr2down,indextr3down]
   srtarr=bsort(allarr)
   resarr=([twoarr,trearr])[srtarr]

   endttind=where(resarr EQ 2 AND shift(resarr,-1) EQ 3,countendtt)

   endtt=allarr[srtarr[endttind]]
 

ENDIF

;stop

;   start=fltarr(countr1)
;   endtt=fltarr(countr1)

;   start=indextr2[value_locate(indextr2,indextr1)>0]

;  stop

   ;endtt=indextr3[(value_locate(indextr3,indextr1)+1)<(countr3-1)]
   ;endtt=indextr3[reverse((value_locate(reverse(indextr3),reverse(indextr1)))>0)]
   

IF keyword_set(doplot) THEN BEGIN 

   x=findgen(nlc)

   wdef,1,1200,1200
   pmulti=!P.multi
   !P.multi=[0,1,2]
   loadct,0
   linecolors
   plot,x,lc;,xrange=[0,300]
   oplot,x,smlc,color=12,thick=2
   plot,x,smder,yrange=15*[-ttr1,ttr1];,xrange=[0,300]

   oplot,!X.crange,ttr1*[1,1],color=12
   oplot,!X.crange,ttr2*[1,1],color=2
   oplot,!X.crange,ttr3*[1,1],color=5
   !p.multi=pmulti
   
ENDIF

;stop

;interleave start and end
IF n_elements(start) GT 1 AND n_elements(endtt) GT 1 THEN pg_interleave_array,start,endtt,x2=okstart,y2=okendtt $
ELSE BEGIN 
   okstart=-1;start
   okendtt=-1;endtt
ENDELSE




;find all local minima and local maxima

;work in steps
;a find all max and min candidates
;; lcright=shift(smlc,-1)
;; lcleft =shift(smlc,1)

;; locmincand=where((lcright-smlc) GE 0 AND (lcleft -smlc) GE 0,countlocmincand)
;; locmaxcand=where((lcright-smlc) LE 0 AND (lcleft -smlc) LE 0,countlocmaxcand)

;; ;compact candidates: if more than one close to each other, substitute them b
;; ;median candidate

;; IF countlocmincand GT 0 THEN BEGIN 
;;    locmin=pg_coalesce_indices(locmincand)
;; ENDIF
;; IF countlocmaxcand GT 0 THEN BEGIN 
;;    locmax=pg_coalesce_indices(locmaxcand)
;; ENDIF

;; IF (locmin[0] LT locmax[0]) AND (locmin[0] NE 0) THEN locmax=[0,locmax] ELSE $
;; IF (locmax[0] LT locmin[0]) AND (locmax[0] NE 0) THEN locmin=[0,locmin]

;; ;now all minima and maxima are found

;; locext=[locmin,locmax]

;; ;eliminate min or max too close to each other!
;; sind=sort(locext)
;; locext=locext[sind]
;; pg_winnow_lightcurve,locext,smlc[locext],xout=locout,winnowind=winnowind,threshold=threshold


;; ;create a list of events
;; evlist=replicate({time:-1,type:-1,intensity:0d,dintensity:1d2},n_elements(locout))

;; ;stop

;; ;stop

;; evlist.type=(([replicate(1,n_elements(locmin)),replicate(2,n_elements(locmax))])[sind])[winnowind]
;; evlist.time=locout
;; evlist.intensity=smlc[locout]

;; ;evlist.type=(sind GE n_elements(locmin)) +1;1 means min, 2 meand max
;; ;evlist.time=locext[sind]
;; ;evlist.intensity=smlc[evlist.time]
;; ;evlist.dintensity=abs(smlc[shift(evlist.time,-1)]-smlc[evlist.time])

;; ;stop

;; ;scan array and indentify elements
;; ;according to table page 66


;; ;two pass strategy
;; ;use function
;; ;;;;data=pg_winnow_lc(x,y,thershold=thershold).



;; peaklist={start:-1,peak:-1,stop:-1}
;; thispeaklist={start:-1,peak:-1,stop:-1}
;; done=0
;; thiselement=1
;; lasttype=evlist[0].type
;; lasttime=0
;; nevl=n_elements(evlist)-1

;; WHILE thiselement LE nevl DO BEGIN 

;   dx=evlist[thiselement].dintensity


;;    counter=1
;;    IF (thiselement+counter LT nevl) && (dx LT threshold) THEN BEGIN 

;;       print,evlist[thiselement].time,evlist[thiselement].intensity,thistype,lasttype,100
      

;;       baselevel=evlist[thiselement].intensity

;;       WHILE (thiselement+counter LT nevl) && (abs(evlist[thiselement+counter].intensity-baselevel) LT threshold)  DO BEGIN
;;          counter++
;;       ENDWHILE

  

;;       ;table decision what to do
;; ;      lasttype=evlist[thiselement+counter-1].type
;;       thistype=evlist[thiselement+counter-1].type
;;  ;     lasttype=evlist[thiselement].type
;;       print,evlist[thiselement+counter].time,evlist[thiselement+counter].intensity,thistype,lasttype,100


;;       IF thistype EQ 1 AND lasttype EQ 1 THEN BEGIN
;;          thiselement=thiselement+counter
;;       ENDIF
;;       IF thistype EQ 2 AND lasttype EQ 2 THEN BEGIN
;;          thiselement=thiselement+counter         
;;       ENDIF
 
;;       IF thistype EQ 1 AND lasttype EQ 2 THEN BEGIN
;;          ;print,'test',lasttime,counter
;;          thispeaklist.stop=evlist[thiselement].time
;;          peaklist=[peaklist,thispeaklist]
;;          thispeaklist={start:-1,peak:-1,stop:-1}
;;          thiselement=thiselement+counter
;;          thispeaklist.start=evlist[thiselement-1].time
;;          thispeaklist.peak=evlist[(thiselement+1)<nevl].time
;;       ENDIF
;;       IF thistype EQ 2 AND lasttype EQ 1 THEN BEGIN
;;          thispeaklist.peak=evlist[(thiselement+counter)/2].time
;;          thiselement=thiselement+counter
;;          thispeaklist.stop=evlist[(thiselement+1)<nevl].time
;;       ENDIF
 
;;       thistype=evlist[thiselement].type
 

;;    ENDIF $
;;    ELSE BEGIN 

;;    thistype=evlist[thiselement].type
;;    print,evlist[thiselement].time,evlist[thiselement].intensity,thistype,lasttype,0


;;       IF (thistype EQ 1) AND (lasttype EQ 2) THEN BEGIN
;;          peaklist=[peaklist,thispeaklist]
;;          thispeaklist={start:-1,peak:-1,stop:-1}
;;          thispeaklist.start=evlist[thiselement].time
;;          thispeaklist.peak=evlist[(thiselement+1)<nevl].time
;;       ENDIF

;;       IF (thistype EQ 1) AND (lasttype EQ 1) THEN BEGIN
;;          thispeaklist.peak=evlist[(thiselement+1)<nevl].time
;;       ENDIF

;;       IF (thistype EQ 2) AND (lasttype EQ 1) THEN BEGIN 
;;          thispeaklist.peak=evlist[thiselement].time
;;           thispeaklist.stop=evlist[(thiselement+1)<nevl].time
;;       ENDIF  
     
;;       IF (thistype EQ 2) AND (lasttype EQ 2) THEN BEGIN
;;          thispeaklist.stop=evlist[(thiselement+1)<nevl].time
;;       ENDIF
     
;;       thiselement++
;; ;;   ENDELSE
   
;;    lasttype=thistype
;;    ;lasttime=thiselement
   
;; ENDWHILE 

;; peaklist=peaklist[1:*]

;stop

;eliminate some maxima and minima
;; IF locmin[0] LT locmax[0] THEN BEGIN;starts with min
;;    ;d describes the absolute distance up and down
;;    ;is created by intertwining
;;    dup=smlc[locmax]-smlc[locmin]
;;    ddown=smlc[locmax]-smlc[(locmin+1)<nlc]
;; ENDIF $
;; ELSE BEGIN 
;;    dup=smlc[locmax]-smlc[locmin]
;;    ddown=smlc[shift(locmax,-1)]-smlc[locmin]
;; ENDELSE



;; d=[dup,ddown]*0
;; ind1=2*findgen(n_elements(dup))
;; ind2=2*findgen(n_elements(ddown))+1
;; d[ind1]=dup
;; d[ind2]=ddown


;; thiselement=0

;; lmin=-1
;; lmax=-1
;; nd=n_elements(d)
;; WHILE thiselement LT nd DO BEGIN 
;;    IF d[thiselement] LE threshold THEN BEGIN
;;       counter=1
;;       WHILE (d[thiselement+counter] LE threshold) AND (thiselement+counter LT (nd-1)) DO BEGIN 
;;          counter++
;;       ENDWHILE
;;       IF counter MOD 2 EQ 1 THEN BEGIN;odd, can remove everything
;;          ;do nothing
;;       ENDIF $ 
;;       ELSE BEGIN ;even: keep middle one
;;          ;max or min?
;;          IF thiselement MOD 2 EQ 0 THEN lmax=[lmax,locmax[(thiselement+counter/2)/2]] ELSE lmin=[lmin,locmin[(thiselement+counter/2)/2]]
;;       ENDELSE
         
;;       ;xout=[xout,x[thiselement+counter/2]]
;;       thiselement=thiselement+counter+1
;;    ENDIF ELSE BEGIN 
;;       IF thiselement MOD 2 EQ 0 THEN lmax=[lmax,locmax[thiselement/2]] ELSE lmin=[lmin,locmin[thiselement/2]]
  
;;      ;xout=[xout,x[thiselement]]
;;       thiselement++
;;    ENDELSE
;; ENDWHILE

;; IF n_elements(lmin) GE 1 THEN lmin=lmin[1:*]
;; IF n_elements(lmax) GE 1 THEN lmax=lmax[1:*]

;nokind=where(d GE threshold)
;locmin=locmin(nokind/2)


   ;find corresponding situation

;   stop

   ;coalesce indices
   ;complement?
;ENDIF;; $
;ELSE BEGIN ;starts with max
;   dup=lc[locmax]-lc[locmin]
;   ddown=lc[locmax]-lc[(locmin-1)>0]
;ENDELSE

;;ind1=pg_coalesce_indices(where(dup LT threshold))
;;ind2=pg_coalesce_indices(where(ddowm LT threshold))

;d1=abs(lc[locmax]-lc[locmin])
;;ind=where(dflux GT threshold,count)
;;IF count GT 0 THEN locmin=locmin[ind] ELSE locmin=0
;;IF count GT 0 THEN locmax=locmax[ind] ELSE locmax=0




RETURN

;; RETURN,{rise:rise,decay:decay,peak:peak,deep:deep,allpeakstart:allpeakstart,allpeakend:allpeakend}

END



