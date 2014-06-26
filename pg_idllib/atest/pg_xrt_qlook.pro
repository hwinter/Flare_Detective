;+
; NAME:
;
; pg_xrt_qlook
;
; PURPOSE:
;
; produces a comprehensive quiclook image for XRT data
;
; CATEGORY:
;
; Hinode/XRT data quicklooks
;
; CALLING SEQUENCE:
;
; pg_xrt_qlook,time_intv 
;
; INPUTS:
;
; time_intv: a time interval in any format accepted by anytim
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
; xrt_use_qlook_catalog: if set, uses the quicklook catalog instead of the
; normal (level 0) catalog. The quicklook catalog should be used for recent
; (less than 7-10 day old) data.
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
; AUTHOR:
;
; Paolo Grigis, CfA
; pgrigis@cfa.harvard.edu
;
; $Id: pg_xrt_qlook.pro 44 2008-01-11 14:33:04Z pgrigis $
;
; MODIFICATION HISTORY:
;
; 19-SEP-2007 written
;
;-

;.comp pg_xrt_qlook

PRO pg_xrt_plotfov_test

  time_intv='06-Jun-2007 '+['06:00','07:00']
;  time_intv_in='06-Jun-2007 '+['06:00','07:00']
  pg_xrt_qlook,time_intv

  pg_xrt_qlook,time_intv,outfilename='~/test.png'
  

  time_intv='19-Nov-2006 '+['06:00','12:00']
  pg_xrt_qlook,time_intv

END

PRO pg_xrt_qlook,time_intv_in,outfilename=outfilename $
                ,background_color=background_color,plot_color=plot_color $
                ,xrt_image_color=xrt_image_color,xrt_dark_color=xrt_dark_color $
                ,hsi_color=hsi_color,goes_color=goes_color,zbuffer=zbuffer $
                ,linfiltthick=linfiltthick,lmthick=lmthick $
                ,xrt_use_qlook_catalog=xrt_use_qlook_catalog $
                ,imsize=imsize



  use_sirius_catalog=1-fcheck(xrt_use_qlook_catalog,0)

  background_color=fcheck(background_color,!P.background)
  plot_color=fcheck(plot_color,!P.color)
  xrt_image_color=fcheck(xrt_image_color,2)
  xrt_dark_color=fcheck(xrt_dark_color,10)
  goes_color=fcheck(goes_color,!P.color)
  hsi_color=fcheck(hsi_color,12)
  lmthick=fcheck(lmthick,1)
 
  time_intv=anytim(time_intv_in)

  imsize=fcheck(imsize,'LARGE')
  
  IF keyword_set(zbuffer) THEN BEGIN 
     oldp=!P
     oldx=!X
     oldy=!Y
     oldd=!D
     set_plot,'Z'

     !X.thick=3
     !Y.thick=2

  ENDIF

 
  !p.background=background_color
  !p.color=plot_color

  pos1=[0.12,0.075,0.675,0.525]
  pos2=[0.12,0.525,0.675,0.95]
  pos3=[0.70,0.60,0.97,0.96]
 

  IF imsize EQ 'LARGE' THEN BEGIN 

     !p.font=1
     DEVICE, SET_FONT='Helvetica', /TT_FONT

     wdef,1,1600,1200 
     charsize=2.3
  ENDIF $
  ELSE BEGIN 

     wdef,1,1200,700
     charsize=1.5

     !p.font=-1
     ;DEVICE, SET_FONT='Helvetica', /TT_FONT

     pos1=[0.12,0.075,0.675,0.425]
     pos2=[0.12,0.425,0.675,0.95]
     pos3=[0.70,0.502143,0.97,0.965]

  ENDELSE


;  DEVICE, SET_FONT='Monaco', /TT_FONT


  

  title='Time Interval: '+strmid(anytim(time_intv[0],/vms),0,20) $
        +' to '+strmid(anytim(time_intv[1],/vms),0,20)
  
  loadct,0
  linecolors

  IF NOT exist(cat) OR size(cat,/type) NE 8 THEN xrt_cat,time_intv[0],time_intv[1],cat,files,sirius=use_sirius_catalog

;  ptim,time_intv
  pg_xrtrhessigoes,time_intv,position=pos1,charsize=charsize,title=' ',/xstyle,hsicol=hsi_color $
                  ,hsithick=3,cat=cat,/noxrt,goes_color=goes_color,xtitle=' ',thick=3,plot_color=plot_color
  
;  ptim,time_intv
  pg_xrt_plotfilters,time_intv,position=pos2,/noerase,timetitle=' ',title=title,/xstyle $
                    ,xtickname=replicate(' ',30),charsize=charsize,cat=cat,linfiltthick=linfiltthick  $
                    ,imcolor=xrt_image_color,darkcolor=xrt_dark_color,plot_color=plot_color
 

  IF imsize EQ 'LARGE' THEN BEGIN 

;  ptim,time_intv
  pg_xrt_plotfov,time_intv,/plotar,charsize=1.5,/noerase,position=pos3,title=' ',lmthick=lmthick $
                ,ytitle=' ',xtitle=' ',xstyle=1+4,ystyle=1+4,offset=[0,-130],offcharsize=1.2,cat=cat

  ENDIF ELSE BEGIN 

     pg_xrt_plotfov,time_intv,/plotar,charsize=1.2,/noerase,position=pos3,title=' ',lmthick=lmthick $
                   ,ytitle=' ',xtitle=' ',xstyle=1+4,ystyle=1+4,offset=[0,-230],offcharsize=1.2,cat=cat

  ENDELSE


;  ptim,time_intv
  
  ;xyouts,0.7,0.5,'Red  ticks (   ) are normal XRT images',/normal
  ;xyouts,0.7,0.45,'Blue ticks (   ) are  dark  XRT images',/normal
  ;plots,0.79*[1,1],0.5+[-0.01,0.03],color=xrt_image_color,/normal
  ;plots,0.79*[1,1],0.45+[-0.01,0.03],color=xrt_dark_color,/normal


  IF exist(outfilename) THEN BEGIN 
     tvlct,r,g,b,/get
     im=tvrd()
     write_png,outfilename,im,r,g,b
  ENDIF

  IF keyword_set(zbuffer) THEN BEGIN 
     set_plot,oldd.name
     !P=oldp
     !X=oldx
     !Y=oldy
  ENDIF


;  set_plot,'X'

;  plots,pos3[[0,2,2,0,0]],pos3[[1,1,3,3,1]],/normal

END 


