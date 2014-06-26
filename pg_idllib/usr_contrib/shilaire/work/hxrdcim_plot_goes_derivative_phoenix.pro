PRO hxrdcim_plot_goes_derivative_phoenix,time_intv

window,0,xs=768,ys=512
loadct,5
linecolors

clear_utplot
!P.MULTI=[0,1,2]
data=rapp_get_spectrogram(time_intv,/ELIM,/BACK,xaxis=xaxis,yaxis=yaxis,/despike,/LOG)
rapp_plt_spg,data,xaxis,yaxis,/UT,xtitle='',ytitle='Frequency [MHz]',xmar=[10,4],ymar=[2,1],charsize=1.0
plot_goes,anytim(time_intv[0],/ECS),anytim(time_intv[1],/ECS),/one_minute,color=[4,7],/nodeftitle,xtitle='',ytitle='GOES X-rays',xmargin=[10,4],ymargin=[2,0],charsize=charsize,thick=3

END
