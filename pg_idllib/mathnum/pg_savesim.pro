;+
; NAME:
;      pg_savesim
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      saves simulation results with contest information in
;      such a way that it should be relatively easy to restore
;      the relevant information afterwards
;
; EXPLICATION:
;      
;
;
; CALLING SEQUENCE:
;     
;
; INPUTS:
;      
;   
; OUTPUTS:
;      
;      
; KEYWORDS:
;
;
; HISTORY:
;       03-OCT-2005 written PG
;       28-NOV-2005 fixed memory leak problem due to missing ptr_free
;                   statements PG
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

PRO pg_savesim,diagnostic,savedir=savedir,masterfile=masterfile,type=type,verbose=verbose

type=fcheck(type,'MILLERFIX_RELESCAPE')

savedir=fcheck(savedir,'~/work/accsimres/')
masterfile=fcheck(masterfile,savedir+'masterindex.sav')

time=pg_current_time()
stamp=time2file(time,/seconds)


IF NOT file_exist(masterfile) THEN BEGIN 
   total_sim_record=ptr_new()
ENDIF $
ELSE BEGIN 
   restore,masterfile
   ;commented away on 28-FEB-2006 to save disk space
   ;file_copy,masterfile,masterfile+'_old_'+stamp
ENDELSE

filename='res_'+stamp+'.sav'

da=diagnostic


this_sim_record=ptr_new({time:pg_current_time(),stamp:stamp,type:type,simpar:diagnostic.simpar $
                        ,filename:filename})

save,da,this_sim_record,filename=savedir+filename

total_sim_record=[total_sim_record,this_sim_record]

save,total_sim_record,filename=masterfile
IF keyword_set(verbose) THEN print,'SAVED SIM TO FILE '+filename

ptr_free,this_sim_record,total_sim_record

END
