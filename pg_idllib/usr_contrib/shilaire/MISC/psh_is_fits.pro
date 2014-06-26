;+
;
;MODIFICATION HISTORY:
;	2005/02/23: PSH, took first part of is_fits.pro
;
;.TITLE
; Routine IS_FITS
;-
;
; Check on input parameters
;
function psh_is_fits, filename, extension   

on_error, 2
!error = 0
;

; initialize simple to false
simple = 0b

if (n_params() eq 2) then extension = ''

; Open file and read first line of header
on_ioerror, never_opened
openr, unit, filename, /GET_LUN, /BLOCK

; Read the first header record
hdr = bytarr( 80, 36, /NOZERO )

if eof(unit) then goto, return_status
readu, unit, hdr

header = string( hdr > 32b )
endline = where( strmid(header,0,8) EQ 'END     ', Nend )
if Nend GT 0 then header = header( 0:endline(0) ) 

; setup to see what keywords there are (if any)
keywrd = strupcase(strmid(header(0),0,7))
value = strupcase( strtrim( strmid( header(0), 10, 20 ), 2 ))

; If the first keyword is 'SIMPLE' then get its value
; We have to check now (prior to getting the rest of the fits header) to
; be sure that this is a fits file and that there's a header out there to
; get....
if ( strtrim(keywrd, 2) eq 'SIMPLE' ) then begin
    simple = (value eq 'T')
endif else begin
    simple = 0b
endelse

; Return if simple not 'T'
if not simple then goto, return_status ELSE BEGIN
	close_lun,unit
	RETURN,1B
ENDELSE


return_status:
        close_lun,unit
        return, simple

;we come here if the file doesn't exist
never_opened:
        !error = 1
        return, simple

;
end


