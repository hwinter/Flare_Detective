;+
;NAME:
; phoenix_filedb_struct_define
;PROJECT:
;  PHOENIX-2, ETHZ
;CATEGORY:
; Phoenix-2 database generation
;PURPOSE:
; defines the filedb structure for Phoenix-2 fits files
;CALLING SEQUENCE:
; eth_phnx_filedb__struct_define
;INPUT:
; None
;OUTPUT:
; None
;HISTORY:
; 	2003/10/06: Pascal Saint-Hilaire, shilaire@astro.phys.ethz.ch
;			Inspired from Jimm's hsi_filedb__define.pro
;-

PRO phoenix_filedb_struct_define

   x = {phoenix_filedb, $
        version:0, $            ;version number
        start_time: anytim('16-aug-1998 08:35'), $ ;data start time
        end_time: anytim('16-aug-1998 15:15'), $ ;data end time
        filename: '20020309....', $
	type: 'I' } 		;I, P, L1, L2	
   RETURN
END
