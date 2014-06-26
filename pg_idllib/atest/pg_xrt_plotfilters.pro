;+
; NAME:
;
; pg_xrt_plotfilters
;
; PURPOSE:
;
; plot an overview of the XRT filters used in a given time interval
;
; CATEGORY:
;
; Hinode/XRT data quicklooks
;
; CALLING SEQUENCE:
;
; pg_xrt_plotfilter,time_intv [ plus all keyword accepted by utplot minus all y-axis related stuff]
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
;   normal (level 0) catalog. The quicklook catalog should be used for recent
;   (less than 7-10 day old) data.
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
; $Id: pg_xrt_plotfilters.pro 26 2007-12-17 21:02:07Z pgrigis $
;
; MODIFICATION HISTORY:
;
; 19-SEP-2007 written
; 06-DEC-2007 adapted for use in XRT snapview images generation
;
;-

;.comp pg_xrt_plotfilters

PRO pg_xrt_plotfilters_test

  time_intv='06-Jun-2007 '+['06:00','07:00']
  pg_xrt_plotfilters,time_intv

END

PRO pg_xrt_plotfilters,time_intv_in,charsize=charsize,imcolor=imcolor,darkcolor=darkcolor $
           ,position=position,timetitle=timetitle,cat=cat,plot_color=plot_color $
           ,_extra=_extra,showimsize=showimsize,noerase=noerase,linfiltthick=linfiltthick  $
           ,xrt_use_qlook_catalog=xrt_use_qlook_catalog


  tvlct,r,g,b,/get
  linecolors

  ;check input variables

  use_sirius_catalog=1-fcheck(xrt_use_qlook_catalog,0)

  position=fcheck(position,[0.1,0.1,0.97,0.975])
  linfiltthick=fcheck(linfiltthick,2)

  time_intv=anytim(time_intv_in)
  charsize=fcheck(charsize,!p.charsize)

  imcolor=fcheck(imcolor,12)
  darkcolor=fcheck(darkcolor,10)

  ;get XRT image time in time_intv

  IF NOT exist(cat) OR size(cat,/type) NE 8 THEN xrt_cat,time_intv[0],time_intv[1],cat,files,sirius=use_sirius_catalog

  IF size(cat,/type) EQ 8 THEN BEGIN  ;structure returned
     nxrtimages=n_elements(cat)
  ENDIF ELSE BEGIN 
     nxrtimages=0
  ENDELSE

  timetitle=fcheck(timetitle,'Time Interval: '+strmid(anytim(time_intv[0],/vms),0,20) $
                   +' to '+strmid(anytim(time_intv[1],/vms),0,20))
  title=fcheck(title,' ')

  ;setting up filters etc...

;  fw1tickpos=[3,5,7,9,11];open not necessary
;  fw2tickpos=[4,6,8,10,12]

  fw1tickpos=[10,8,7,6,5]       ;open not necessary
  fw2tickpos=[11,9,12,4,3]
  fw1tickpos=15-[10,8,7,6,5]       ;open not necessary
  fw2tickpos=15-[11,9,12,4,3]

  fwtickpos=[fw1tickpos,fw2tickpos]

  fw1names=['Al_poly','C_poly','Be_thin','Be_med','Al_med']
  fw2names=['Al_mesh','Ti_poly','Gband','Al_thick','Be_thick']

  fwnames=([fw1names,fw2names])

  utplot,time_intv-time_intv[0],[-1,-1],time_intv[0],yrange=[2,13],ystyle=1,/xstyle,yticks=9 $
        ,ytickv=fwtickpos,ytickname=fwnames,position=position,charsize=charsize $
        ,yticklen=1d-6,xtitle=timetitle,title=title,noerase=noerase,_extra=_extra $
        ,color=plot_color 

;  axis,time_intv[1],/yaxis,yrange=[2,13],yticks=4,ytickv=fw2tickpos,/ystyle $
;       ,ytickname=fw2names,charsize=charsize,ticklen=0


  FOR i=0,4 DO BEGIN 
     oplot,!X.crange,fw1tickpos[[i,i]],linestyle=0,thick=linfiltthick,color=plot_color
     oplot,!X.crange,fw2tickpos[[i,i]],linestyle=2,thick=linfiltthick,color=plot_color
  ENDFOR


  IF nxrtimages GT 0 THEN BEGIN 

     fw1indices=xrt_fwstr2num(cat.ec_fw1_,fw=1)-1
     fw2indices=xrt_fwstr2num(cat.ec_fw2_,fw=2)-1
     time=anytim(cat.date_obs)

     IF n_elements(fw1indices) EQ nxrtimages AND $
        n_elements(fw2indices) EQ nxrtimages THEN BEGIN 

           FOR i=0L,nxrtimages-1 DO BEGIN 
              IF cat[i].ec_imtyp EQ 0 THEN thisimcolor=imcolor ELSE thisimcolor=darkcolor
              IF fw1indices[i] GE 0 THEN $
                 outplot,time[[i,i]]-time_intv[0],fw1tickpos[fw1indices[i]]+[-0.4,0.4],time_intv[0],color=thisimcolor
              IF fw2indices[i] GE 0 THEN $
                 outplot,time[[i,i]]-time_intv[0],fw2tickpos[fw2indices[i]]+[-0.4,0.4],time_intv[0],color=thisimcolor
           ENDFOR

        ENDIF

  ENDIF

  
  tvlct,r,g,b

END 


