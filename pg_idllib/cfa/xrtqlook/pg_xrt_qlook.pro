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
; AUTHOR:
;
; Paolo Grigis, CfA
; pgrigis@cfa.harvard.edu
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

PRO pg_xrt_qlook,time_intv_in,outfilename=outfilename
 
  time_intv=anytim(time_intv_in)

  
  IF exist(outfilename) THEN set_plot,'Z'

  wdef,1,1600,1200

  pos1=[0.1,0.075,0.675,0.525]
  pos2=[0.1,0.525,0.675,0.95]
  pos3=[0.70,0.60,0.97,0.96]
  

  title='Time Interval: '+strmid(anytim(time_intv[0],/vms),0,20) $
        +' to '+strmid(anytim(time_intv[1],/vms),0,20)
  
  loadct,0
  linecolors

  pg_xrtrhessigoes,time_intv,position=pos1,charsize=1.5,title=' ',/xstyle,xrttickcol=2,hsicol=12 $
                  ,hsithick=3,cat=cat
  pg_xrt_plotfilters,time_intv,position=pos2,/noerase,timetitle=' ',title=title $
                    ,xtickname=replicate(' ',30),charsize=1.5,cat=cat
  
 
  pg_xrt_plotfov,time_intv,/plotar,charsize=1.5,/noerase,position=pos3,title=' ' $
                ,ytitle=' ',xtitle=' ',xstyle=1+4,ystyle=1+4,offset=[0,-130],offcharsize=1.2,cat=cat


  IF exist(outfilename) THEN BEGIN 
     tvlct,r,g,b,/get
     im=tvrd()
     write_png,outfilename,im,r,g,b
  ENDIF

  set_plot,'X'

;  plots,pos3[[0,2,2,0,0]],pos3[[1,1,3,3,1]],/normal

END 


