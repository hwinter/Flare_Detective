;+
; NAME:
;      hsi_retrievespg.pro
;
; PURPOSE: 
;      restore a previously saved spectrogram in IDL save format 
;
; INPUTS:
;      basetime:the time when the specrogram begin
;      directory: the dir where the data are stored
;                 default: /global/tethys/data1/pgrigis/autodata
;  
; OUTPUTS:
;      spg: the spectrogram
;      spgsc: the semicalibrated spectrogram
;      
; KEYWORDS:
;        
;
; HISTORY:
;       9-OCT-2002 written
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;
;-

PRO hsi_retrievespg,basetime=basetime,spg=spg,scspg=scspg,directory=directory


   IF not keyword_set(directory) THEN $
      directory='/global/tethys/data1/pgrigis/autodata/' 

   IF keyword_set(basetime) THEN BEGIN
      restore,directory+'hsi_spg_'+ anytim(basetime,/ccsds)+'.dat'
      restore,directory+'hsi_spgsc_'+ anytim(basetime,/ccsds)+'.dat'
   ENDIF
   

END











