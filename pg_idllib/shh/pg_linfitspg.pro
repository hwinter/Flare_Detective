;+
; NAME:
;      pg_linfitspg
;
; PURPOSE: 
;      fit a power-law model to spectrogram data
;
; CALLING SEQUENCE:
;      
;
; INPUTS:
;      emin: minimum energy for the fitting
;      emax: maximum energy for the fitting
;      enorm: normalization energy (for Fnorm)
;
;
; KEYWORDS:
;      
;
; OUTPUT:
;     a structure with tags time, spindex (spectral index gamma),
;     fnorm (flus at enorm), enorm (in keV) 
;       
;
; COMMENT:
;      
;
; EXAMPLE   
;  
;
;
; VERSION:
;       
;
;
; AUTHOR:
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;
; HISTORY:
;       31-OCT-2006 written PG
;
;-

function pg_linfitspg,spg,emin=emin,emax=emax,enorm=enorm,debug=debug

emin=fcheck(emin,40.)
emax=fcheck(emax,60.)
enorm=fcheck(enorm,50.)

eminlog=alog(emin)
emaxlog=alog(emax)
enormlog=alog(enorm)

ind=where(spg.y GE emin AND spg.y LE emax)

ebandlog=alog(spg.y[ind])


yarr=spg.spectrogram[*,ind]
errarr=spg.espectrogram[*,ind]

time=spg.x

nan=!values.f_nan

spindex=fltarr(n_elements(time))
fnorm=spindex

;xx=findgen(100)/10

for i=0,n_elements(time)-1 do begin 
    sp=yarr[i,*]
    errsp=abs(errarr[i,*]/sp)

    nonumbind=where(1-finite(sp+errsp),count)

    if count GE 1 then begin 

        ;print,'INTERVAL '+strtrim(i,2)+' NOT OK'
        spindex[i]=nan
        fnorm[i]=nan

    endif else begin

        nonpositive=where((sp LE 0) and (errsp LE 0),count)
        if count GT 0 then begin 

            ;print,'INTERVAL '+strtrim(i,2)+' NOT OK'
            spindex[i]=nan
            fnorm[i]=nan

        endif else begin


            if keyword_set(debug) then print,'INTERVAL '+string(i)

            ;if i EQ 75 then stop

            res=linfit(ebandlog,alog(sp),measure_errors=errsp)
            spindex[i]=res[1]
            fnorm[i]=enorm^res[1]*exp(res[0])

            ;plot,ebandlog,alog(sp),/xstyle
            ;oplot,xx,res[1]*xx+res[0],color=2,thick=2

            ;wait,0.25

        endelse
    endelse

endfor


result={time:time,spindex:spindex,fnorm:fnorm, $
        emin:emin,emax:emax,enorm:enorm}

return,result


END
