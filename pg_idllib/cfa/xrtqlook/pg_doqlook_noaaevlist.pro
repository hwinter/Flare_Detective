;+
; NAME:
;
; pg_doqlook_noaaevlist
;
; PURPOSE:
;
; generates quicklooks based on NOAA GOES events
;
; CATEGORY:
;
; qlook uitl for XRT
;
; CALLING SEQUENCE:
;
; pg_doqlook_noaaevlist,time_intv,noaadir=noaadir,outdir=outdir
;
; INPUTS:
;
; time_intv: a time_interval over which the quiclooks should be generated
; noaadir: dir where the noaa event list are residing
; outdir: output dir for the quiclokk images
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
;
; MODIFICATION HISTORY:
;
; 10-SEP-2007 PG written 
; 12-SEP-2007 PG added sdac keyword
; 
;-

;.comp pg_doqlook_noaaevlist

PRO  pg_doqlook_noaaevlist,intime_intv,noaadir=noaadir,outdir=outdir,sdac=sdac

  noaadir=fcheck(noaadir,'~/work/noaa_event_reports/')
  outdir=fcheck(outdir,'~/work/noaaevent_xrtqlook/')

  time_intv=anytim(intime_intv,/date_only)

  sdac=fcheck(sdac,1)

  ndays=(time_intv[1]-time_intv[0])/86400.

  linecolors

  FOR i=0,ndays-1 DO BEGIN 
     
     thisdate=time_intv[0]+i*86400.

     startime=anytim(thisdate,/ex)
     startyear=smallint2str(startime[6],strlen=4)
     startmonth=smallint2str(startime[5],strlen=2)
     startday=smallint2str(startime[4],strlen=2)

     filedir=outdir+startyear+'/'+startmonth+'/'+startday+'/'
     IF NOT file_exist(filedir) THEN file_mkdir,filedir

     evtime_intv=pg_read_noaa_eventlist(thisdate,basdir=noaadir)     
     n=n_elements(evtime_intv)


     IF n GT 1 THEN BEGIN 


        FOR j=0,n/2-1 DO BEGIN 


           wdef,1,1024,1024

           ;ptim,evtime_intv[*,j]

           thistime=evtime_intv[*,j]
           IF thistime[1] LT thistime[0] THEN thistime[1]=thistime[1]+86400

           ;stop

           pg_xrtrhessigoes,thistime+60.*[-15,30],xrttickcol=2,hsicol=12,hsithick=3,/xstyle $
                           ,additionaltime=thistime,additionalcolor=5,position=[0.075,0.075,0.975,0.85] $
                           ,charsize=1.5,sdac=sdac

           plots,[0.1,0.3],[0.965,0.965],/normal,thick=3
           xyouts,0.35,0.96,'GOES 0.1-0.8 nm',/normal,charsize=1.75
 
           plots,[0.1,0.3],[0.965,0.965]-0.04,/normal,color=12,thick=3
           xyouts,0.35,0.96-0.04,'RHESSI OBSERVATIONS',/normal,charsize=1.75,color=12
  
           plots,[0.1,0.3],[0.965,0.965]-0.08,/normal,color=5,thick=3
           xyouts,0.35,0.96-0.08,'NOAA GOES EVENT',/normal,charsize=1.75,color=5

           plots,[0.65,0.65],[0.96,0.89],color=2,/normal,thick=2
           xyouts,0.7,0.92,'XRT Image',/normal,charsize=1.75,color=2
           
           filename=filedir+'event'+smallint2str(j+1,strlen=4)+'.png'

           im=tvrd(/true)

           write_png,filename,im
   
 
        ENDFOR


     ENDIF


  ENDFOR


END


