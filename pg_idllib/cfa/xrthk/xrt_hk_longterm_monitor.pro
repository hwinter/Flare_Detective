;
; Quick script to monitor fron end temperatures....
;


PRO xrt_hk_longterm_monitor,avfiles_dir=avfiles_dir,npastdays=npastdays


loadct,0
linecolors

npastdays=fcheck(npastdays,10)

start_time='21-SEP-2006'
end_time=anytim(!stime)


hktaglist=['XRTD_P_GND','XRTD_P_M15BV','XRTD_P_P15BV','XRTD_P_P28IC', $ 
           'XRTD_P_P28IV','XRTD_P_P28OHIC','XRTD_P_P5AV','XRTD_P_P5BV', $
           'XRTD_TEMP0' ,'XRTD_TEMP10','XRTD_TEMP11','XRTD_TEMP12','XRTD_TEMP13','XRTD_TEMP14' $
          ,'XRTD_TEMP15','XRTD_TEMP16','XRTD_TEMP17','XRTD_TEMP18','XRTD_TEMP19','XRTD_TEMP1'  $
          ,'XRTD_TEMP20','XRTD_TEMP21','XRTD_TEMP22','XRTD_TEMP23','XRTD_TEMP2' ,'XRTD_TEMP3'  $
          ,'XRTD_TEMP4' ,'XRTD_TEMP5' ,'XRTD_TEMP6' ,'XRTD_TEMP7' ,'XRTD_TEMP8' ,'XRTD_TEMP9']


FOR i=0,n_elements(hktaglist)-1 DO BEGIN 

   print,'Now processing '+hktaglist[i]

   xrt_hk_create_daily_averages,hktaglist[i],start_time=start_time,end_time=end_time,avgfiledir=avfiles_dir, $
                                hkfileprefix='XRTD_STS',nforce=npastdays,res=res,/loud



   t=(res.time-anytim('01-JAN-2006'))/(24.0*3600.0*365.25)+2006
   xrange=[2006.5,max(t)+0.25]
   yrange=[min(res.value,/nan),max(res.value,/nan)]
   yrange=yrange+0.1*[-1,1]*(yrange[1]-yrange[0])

   !p.charsize=2

   plot,t,res.value,yrange=yrange,xrange=xrange,/xst,/yst,title=res.name+' last updated '+strmid(anytim(!stime,/vms),0,17)

   ps=path_sep()
   filename=avfiles_dir+ps+'longtermplot_'+res.name+'.png'

   tvlct,r,g,b,/get
   write_png,filename,tvrd(),r,g,b


   print,'a',string(hktaglist[i])

   IF hktaglist[i] EQ 'XRTD_TEMP12' THEN BEGIN 
      ;stop   
      print,'b1',string(hktaglist[i])
      xrange=[2007.5,max(t)+0.25]
      plot,t,res.value,yrange=[44,50],xrange=xrange,/xst,/yst,title=res.name+' last updated '+strmid(anytim(!stime,/vms),0,17)
      FOR j=30,60 DO oplot,!X.crange,[j,j],color=2,thick=1
      plot,t,res.value,yrange=[44,50],xrange=xrange,/xst,/yst,title=res.name+' last updated '+strmid(anytim(!stime,/vms),0,17),/noerase

      filename=avfiles_dir+ps+'longtermplot_'+res.name+'_zoom.png'

      tvlct,r,g,b,/get
      write_png,filename,tvrd(),r,g,b
 
      print,'b2',string(hktaglist[i])
 

   ENDIF



   print,'c',string(hktaglist[i])


   IF hktaglist[i] EQ 'XRTD_TEMP13' THEN BEGIN 
   
      xrange=[2007.5,max(t)+0.25]
      plot,t,res.value,yrange=[43,49],xrange=xrange,/xst,/yst,title=res.name+' last updated '+strmid(anytim(!stime,/vms),0,17)
      FOR j=30,60 DO oplot,!X.crange,[j,j],color=2,thick=1
      plot,t,res.value,yrange=[43,49],xrange=xrange,/xst,/yst,title=res.name+' last updated '+strmid(anytim(!stime,/vms),0,17),/noerase

      filename=avfiles_dir+ps+'longtermplot_'+res.name+'_zoom.png'

      tvlct,r,g,b,/get
      write_png,filename,tvrd(),r,g,b


   ENDIF




ENDFOR 

;flare related flags
;not ready yet!!!


;in XRT_STS

;; hktaglist=['MDP_XRT_FLD_FLG', $;one or zero if flare is/is not detected
;;         'MDP_XRT_FLD_HADR', $;h pos
;;         'MDP_XRT_FLD_VADR'];v pos


;; FOR i=0,n_elements(hktaglist)-1 DO BEGIN 

;;    print,'Now processing '+hktaglist[i]

;;    xrt_hk_create_daily_averages,hktaglist[i],start_time=start_time,end_time=end_time,avgfiledir=avfiles_dir, $
;;                                 hkfileprefix='XRT_STS',nforce=npastdays,res=res,/loud



;;    t=(res.time-anytim('01-JAN-2006'))/(24.0*3600.0*365.25)+2006
;;    xrange=[2006.5,max(t)+0.25]
;;    yrange=[min(res.value,/nan),max(res.value,/nan)]
;;    yrange=yrange+0.1*[-1,1]*(yrange[1]-yrange[0])

;;    !p.charsize=2

;;    plot,t,res.value,yrange=yrange,xrange=xrange,/xst,/yst,title=res.name+' last updated '+strmid(anytim(!stime,/vms),0,17)

;;    ps=path_sep()
;;    filename=avfiles_dir+ps+'longtermplot_'+res.name+'.png'

;;    tvlct,r,g,b,/get
;;    write_png,filename,tvrd(),r,g,b

;; ENDFOR 


;; ;in MDP STS
;; hktaglist=['MDP_PREFLR_WRT_STS',  $ ;0/1 if flare buffer are unfrozen/frozen
;;         'MDP_PREFLR_RST_CNT',  $ ;reset counters
;;         'MDP_PREFLR_OUT_CNT',  $ ;reset counters
;;         'MDP_PREFLR_STP_CNT',  $ ;reset counters
;;         'MDP_PREFLR_BUF1_CNT', $ ;space taken by PF buffer 1 (in blocks, 1 block= 768 kilobits)
;;         'MDP_PREFLR_BUF2_CNT', $ ;space taken by PF buffer 2
;;         'MDP_PREFLR_BUF3_CNT']   ;space taken by PF buffer 3


;; FOR i=0,n_elements(hktaglist)-1 DO BEGIN 

;;    print,'Now processing '+hktaglist[i]

;;    xrt_hk_create_daily_averages,hktaglist[i],start_time=start_time,end_time=end_time,avgfiledir=avfiles_dir, $
;;                                 hkfileprefix='MDP_STS',nforce=npastdays,res=res,/loud



;;    t=(res.time-anytim('01-JAN-2006'))/(24.0*3600.0*365.25)+2006
;;    xrange=[2006.5,max(t)+0.25]
;;    yrange=[min(res.value,/nan),max(res.value,/nan)]
;;    yrange=yrange+0.1*[-1,1]*(yrange[1]-yrange[0])

;;    !p.charsize=2

;;    plot,t,res.value,yrange=yrange,xrange=xrange,/xst,/yst,title=res.name+' last updated '+strmid(anytim(!stime,/vms),0,17)

;;    ps=path_sep()
;;    filename=avfiles_dir+ps+'longtermplot_'+res.name+'.png'

;;    tvlct,r,g,b,/get
;;    write_png,filename,tvrd(),r,g,b

;; ENDFOR 


END 



