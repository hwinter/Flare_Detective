;+
; NAME:
;      pg_loadsim
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      load saved simulation results
;
; EXPLICATION:
;      
;
;
; CALLING SEQUENCE:
;     
;
; INPUTS:
;       nsim: number of the simulation run to retriev (starts from 1)
;     
; OUTPUTS:
;      
;      
; KEYWORDS:
;       wholedir: if set, retrieves the whole directory. The output  
;                 in this case is an array of pointers to structures
;
; HISTORY:
;       03-OCT-2005 written PG
;       28-NOV-2005 added ptr_free statement to prevent memory leaks PG
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-
PRO pg_loadsim,da=da,nsim=nsim,savedir=savedir,masterfile=masterfile $
              ,type=type,quiet=quiet,wholedir=wholedir,outptr=outptr

   type=fcheck(type,'MILLERFIX_RELESCAPE')

   savedir=fcheck(savedir,'~/work/accsimres/')
   masterfile=fcheck(masterfile,savedir+'masterindex.sav')

   IF NOT file_exist(masterfile) THEN BEGIN 
      print,'Could not find file '+masterfile
      RETURN
   ENDIF


   restore,masterfile

   n=n_elements(total_sim_record)

   IF NOT keyword_set(quiet) THEN BEGIN 
      IF NOT exist(nsim) THEN $
      FOR i=1,n-1 DO BEGIN
         data=*total_sim_record[i]
         print,' '
         print,'-------------------------'
         print,'Simulation '+smallint2str(i,strlen=3)+' in file '+savedir+data.filename
         print,'  TYPE:'+data.type
         
         tagnam=tag_names(data.simpar)
         FOR j=0,n_elements(tagnam)-1 DO BEGIN
            print,'  '+tagnam[j]+': ' +strtrim(string(data.simpar.(j)),2)
         ENDFOR
      ENDFOR $
      ELSE BEGIN
         data=*total_sim_record[nsim]
         print,' '
         print,'-------------------------'
         print,'Simulation '+smallint2str(nsim,strlen=3)+' in file '+savedir+data.filename
         print,'  TYPE:'+data.type
         
         tagnam=tag_names(data.simpar)
         FOR j=0,n_elements(tagnam)-1 DO BEGIN
            print,'  '+tagnam[j]+': ' +strtrim(string(data.simpar.(j)),2)
         ENDFOR
     ENDELSE
   ENDIF

   IF exist(wholedir) THEN BEGIN      
      outptr=ptrarr(n-1)
      FOR i=1,n-1 DO BEGIN      
         print,'Loading result '+string(i)
         restore,savedir+(*total_sim_record[i]).filename
         outptr[i-1]=ptr_new(pg_rebin_result(da))           
      ENDFOR
   ENDIF

   IF exist(nsim) THEN BEGIN 
      restore,savedir+(*total_sim_record[nsim]).filename
      da=pg_rebin_result(da)  

   ENDIF ELSE da=-1

   ptr_free,total_sim_record

END




