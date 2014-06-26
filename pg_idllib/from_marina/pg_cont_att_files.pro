;+
; NAME:
;
; pg_cont_att_files
;
; PURPOSE:
;
; 
;
; CATEGORY:
;
; RHESSI automatic data processing
;
; CALLING SEQUENCE:
;
; 
;
; INPUTS:
;
; 
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
; EXAMPLE:
;
; 
;
; AUTHOR:
;
; Paolo Grigis, Institute for Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
;
; MODIFICATION HISTORY:
;
; 06-MAY-2004 written PG
;
;-

pro pg_cont_att_files,flarr

spsrmdir='~/spsrmfiles/'

for i=0,n_elements(flarr)-1 do begin
    if anytim(flarr[i].peak_time) GT 1 then begin

     attstate=flarr[i].attenuator_peak

     srmfilename=spsrmdir+'srm_'+strtrim(string(flarr[i].gbin),2) $
               +'_'+time2file(flarr[i].peak_time)+'.fits'

     if file_exist(srmfilename) then begin

         data=mrdfits(srmfilename,3,/silent)
         used_att=data.atten_state

         if used_att EQ attstate then $
           print,'Flare number '+strtrim(string(i),2)+' has ok atten state' $
         else $
           print,'Flare number '+strtrim(string(i),2)+' should have state '+$
           string(attstate)+' but has state '+string(fix(used_att))
         
     endif else print,'Flare number '+strtrim(string(i),2)+' has no srm file'

        
    endif
endfor


end
