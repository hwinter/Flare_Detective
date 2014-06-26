;---------------------------------------------------------------------------
; Document name: hsi_roll_db__define.pro
; Created by:   Andre Csillaghy
;
; Time-stamp: <Thu Jan 15 2004 12:06:17 csillag soleil.ifi.fh-aargau.ch>
;---------------------------------------------------------------------------
;
;+
; PROJECT:
;       HESSI
;
; NAME:
;       HESSI ROLL_DB CLASS DEFINITION
;
; PURPOSE:
;       Interface to access the roll database. Given a time range, the object
;       returns a structure containing the roll solution with a time interval
;       of 64 seconds. If there are no points available, the structure
;       contains zeroes (which are "filled" then with
;       pmtras_analysis).
;
; CATEGORY:
;       Utilities (idl/util)
;
; CONSTRUCTION:
;       obj = Obj_New( 'hsi_roll_db' )
;       obj = HSI_ROLL_DB()
;
; METHODS:
;       result = getdata( obs_time_interval = obs_time_interval )
;       returns the roll solution for the specified time interval.
;
; KEYWORDS:
;       obs_time_interval: an anytim 2-element time interval
;       specifying the times for which the roll solution is requested
;
; EXAMPLES:
;       o = hsi_roll_db() ; creates the roll dbase handler
;       roll = o->getdata( obs_time_int = '2002/05/31 ' + ['12:00', '13:00']
;       obj_destroy, o
;
; SEE ALSO:
;
; HISTORY:
;      2004-01-06 minor bug fixes showing up after putting in online, csillag@ssl.berkeley.edu
;      2003-10-21 changed for reading monthly files
;      2003-10-20 corrected the problem with out-of-range values
;      In development till summer 2003
;      Created in september 2002
;
;--------------------------------------------------------------------

FUNCTION HSI_Roll_Db::INIT, $
            FILENAME=filename, $
            _EXTRA=_extra

self.debug =  hsi_get_debug()

return, 1

END

;--------------------------------------------------------------------

PRO hsi_roll_db::CLEANUP

if self.debug then begin
    print,  'Closing roll database ' +  self.filename
endif

;IF (fstat( self.file_unit )).open THEN Free_lun, self.file_unit

Ptr_Free, self.dbsolution
Ptr_Free, self.valid_points

END

;--------------------------------------------------------------------

FUNCTION HSI_ROLL_DB::Time2Index, obs_time_interval

sc_time_range = hsi_any2sctime( obs_time_interval, /L64 )
file_start = sc_time_range MOD ( self.file_length*4*64 )

END

;--------------------------------------------------------------------

FUNCTION Hsi_roll_db::GetData, $
                    OBS_TIME_INTERVAL = obs_time_interval, $
                    DBSOLUTION = dbsolution,  $
                    DB_VERSION = db_version,  $
                    OUT_FILENAME =  out_filename

IF Keyword_Set( DBSOLUTION ) THEN BEGIN
    RETURN,  *self.dbsolution
ENDIF

IF NOT valid_range( obs_time_interval ) THEN BEGIN
    Message, 'Please specify an obs_time_interval', /info, /cont
    return, -1
ENDIF

; determine the nb of elements in the output array and fill in the times
this_obs_time = anytim( obs_time_interval )
start_time = (( (hsi_any2sctime( this_obs_time[0] )).seconds / 64L )-1)*64L
end_time = (( (hsi_any2sctime( this_obs_time[1] )).seconds / 64L )+1)*64L
n_els = (end_time-start_time)/64L+1
; here we decide to take one point more left and right of
; the interval just to be sure we are fully covered.

IF n_els GT 0 THEN BEGIN
; now we create the array that will contain the points
    points = Replicate( {hsi_roll_solution}, n_els )
ENDIF ELSE BEGIN
    return, -1
ENDELSE
points.sctime = Lindgen( n_els ) * 64 + start_time

; determine the files needed
this_time = datetime( hsi_sctime2any( {seconds: start_time, bmicro: 0} ) )
augmented_end_time = hsi_sctime2any( {seconds: end_time, bmicro: 0} )
this_time->round, /month
while this_time->lessthan( augmented_end_time ) do begin
    this_file_idx = this_time->time2file(/month_only)
    file_idx = append_arr( file_idx, this_file_idx )
    this_time->increment, /month
endwhile
obj_destroy, this_time
Checkvar, db_version,  '*'
db_version =  '_v' + strtrim( db_version,  2 )

; get a file reader
file_reader = fitsread()
file_reader->set,  path = ['.', getenv( 'HSI_ASPECT' ) ]

; check for tom's problem (2004-1-8 acs):
if self.debug gt 0 then begin
    message, /info, /cont, 'using env. var. hsi_aspect = ' +  getenv( 'HSI_ASPECT' )
endif

n_months = n_elements( file_idx )

points_idx = 0L
for i=0,n_months-1 do begin

; get the data from the file
  file_reader -> set, file_mask = 'hsi_roll_db_' + file_idx[i] + db_version + '.fits'

  if file_reader->getstatus() eq 0 then begin
    ;if self.verbose then begin
    ;    message, 'no roll data base found for this month, returning... ', /cont
    ;endif
    return, points
  endif

  data = file_reader -> getdata( /last_filename,  ext = 1)
  this_out_filename =  append_arr( this_out_filename,  file_reader->get( /filename,  /last) )

; do some checking acs 2004-1-8
  if self.debug gt 0 then begin
      message, /info, /cont, 'using roll database file(s) = '
      print, this_out_filename
  endif

; now assign the times to the data.
; i tried to do it by just computing the index of the entry,
; but i could not get it right, so i'll use the brute force.

  file_start_time = file_reader -> getpar( 'start_sc' )

; yes Richard I know it's not efficient that way. I'll get back to
; this later

; first locate where the data are in the file
    times = file_start_time + lindgen( n_elements( data ))*64
    minmax_idx = value_locate( times, [start_time, end_time] )
; the eliminate all other points
    data = data[(minmax_idx[0]>0):minmax_idx[1]]
    if n_months gt 1 then begin
        if minmax_idx[0] eq -1 then begin
            points_idx = value_locate( points.sctime, times[0] )
        endif
        temp_points = points[points_idx:points_idx+(minmax_idx[1]-(minmax_idx[0]>0))]
        struct_assign, data, temp_points, /nozero
        points[points_idx] = temp_points
        points_idx = points_idx + minmax_idx[1] - minmax_idx[0]
    endif else begin
        struct_assign, data, points, /nozero
    endelse

endfor

out_filename =  this_out_filename

return, points

END

;--------------------------------------------------------------------

PRO Hsi_roll_db::plot, $
       OBS_TIME_INTERVAL=obs_time_interval

urf =  self->getdata( OBS_TIME_INTERVAL=obs_time_interval )

utplot, hsi_sctime2any( {seconds: urf.sctime, bmicro:0} ), $
    urf.roll_phase, xs=3, ys=3, psym=10

END

;-----------------------------------------------------

PRO Hsi_roll_db__define

self = {hsi_roll_db, $
        dbsolution: Ptr_New(), $
        valid_points: Ptr_New(), $
        filename : '', $
        file_unit : 0L, $
        log_unit: 0L, $
        data_start_pos: 0L, $
        n_els: 0L, $
        debug: 0 }

END

