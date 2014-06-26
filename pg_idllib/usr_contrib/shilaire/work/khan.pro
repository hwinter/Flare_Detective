

;time_intv='2000/08/25 '+['14:27:40','14:35:40']
;l300=rapp_get_spectrogram(time_intv,[298,302],xax=xax,yax=yax,/back)
;l300=l300(*,1)

;l550=rapp_get_spectrogram(time_intv,[549.5,550.5],xax=xax,yax=yax,/back)
;l550=l550(*,0)

s550=SMOOTH(l550,10,/EDGE)
s300=SMOOTH(l300,10,/EDGE)

utplot,xax,l550,xtitle='',yrange=[0,1400.],ymargin=[2,1],$
	ytitle='Flux [SFU]'
XYOUTS,/norm,0.8,0.1,'550 MHz'
outplot,xax,l300+1000
XYOUTS,/norm,0.8,0.8,'300 MHz'

end

clear_utplot
correl1d,[[l550],[l300]],xax,0,ccimg,ccxax
plot,ccxax,ccimg(*,1),xtitle='delay [seconds]',ytitle='crosscorrelation'
print,max(ccimg(*,1),ss_max)
print,ccxax(ss_max)
END
