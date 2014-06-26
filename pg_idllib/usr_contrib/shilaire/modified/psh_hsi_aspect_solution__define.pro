;---------------------------------------------------------------------------
; Document name: hsi_aspect_solution__define.pro
; Created by:    Andre, April 29, 1999
;
; Last Modified: Tue Feb  4 14:50:58 PST 2003 (mfivian@ssl.berkeley.edu)
; Mon Sep 30 18:11:19 PDT 2002
; Thu Oct 10 18:18:42 MET DST 2002
; 25-Oct-2002, Kim.  Added @hsi_insert_catch in getdata
; Mon Nov 18 18:56:08 PST 2002, Errors and Warnings in Getdata and Process
; Mon Dec  9 18:32:20 PST 2002, set 0's for /SASZERO
; Tue Feb  4 14:50:58 PST 2003, optionally return RAS solution
; Thu Jul 31 00:00:00 PDT 2003, various changes for off-pointing software
; Fri Aug 15 17:29:15 PDT 2003, no switches to ASPECT_SIM=1
;
; 2003/11/13, PSH: allows the retrieval of quality...
; 2004/02/04, PSH: commented out three lines....
;---------------------------------------------------------------------------

FUNCTION psh_Hsi_Aspect_Solution::INIT, $
            SOURCE=source, $
            _EXTRA=_extra

IF NOT Keyword_Set( SOURCE ) THEN source = HSI_Packet()

ret=self->Framework::INIT( CONTROL = HSI_Aspect_solution_Control(), $
                           INFO    = {hsi_aspect_solution_info}, $
                           SOURCE=source )


IF Keyword_Set( _EXTRA ) THEN self->Set, _EXTRA = _extra

RETURN, ret

END

;---------------------------------------------------------------------------

FUNCTION psh_Hsi_Aspect_Solution::AS_CHECK_TIME_RANGE

; return value =1 --> aspect_time_range is set successfully
; return value =0 --> no usefull time range found

; get all time ranges
;
abs_time_range=self->get(/absolute_time_range)
as_time_range=self->get(/aspect_time_range)
obs_time_interval=self->get(/obs_time_interval)

;check for absolute time range
;
if valid_range(abs_time_range) then begin
  if valid_range(as_time_range) then begin
    if (as_time_range[0] gt abs_time_range[0]  or $
        as_time_range[1] lt abs_time_range[1]) then begin
      self->framework::set,aspect_time_range=abs_time_range
    endif else $
      if valid_range(obs_time_interval) then begin
        if (as_time_range[0] lt obs_time_interval[0]  or $
            as_time_range[1] gt obs_time_interval[1]) then begin
          self->framework::set,aspect_time_range=abs_time_range
        endif
      endif
  endif else $
    self->framework::set,aspect_time_range=abs_time_range
  return,1
endif $

; check for obs_time_interval
;
else if valid_range(obs_time_interval) then begin
  if valid_range(as_time_range) then begin
    if (obs_time_interval[1]-obs_time_interval[0] ge as_time_range[0] and $
        obs_time_interval[1]-obs_time_interval[0] ge as_time_range[1]) then begin
      self->framework::set,aspect_time_range=obs_time_interval[0]+as_time_range
    endif else $
      if (as_time_range[0] lt obs_time_interval[0]  or $
          as_time_range[1] gt obs_time_interval[1]) then begin
        self->framework::set,aspect_time_range=obs_time_interval
      endif
  endif else $
    self->framework::set,aspect_time_range=obs_time_interval
  return,1
endif $

; check for file_time_range
;
else begin
  file_time_range=self->get(/file_time_range)
  if valid_range(file_time_range) then begin
    if valid_range(as_time_range) then begin
      if (as_time_range[0] lt file_time_range[0]  or $
          as_time_range[1] gt file_time_range[1]) then begin
        self->framework::set,aspect_time_range=file_time_range
      endif
    endif else $
      self->framework::set,aspect_time_range=file_time_range
    return,1
  endif
endelse

; there is no valid time range
; (one gets here only from the section where file_time_range is checked)
;
return,0

END

;---------------------------------------------------------------------------

FUNCTION psh_HSI_Aspect_Solution::GetData, $
            THIS_TIME=this_time, $
            THIS_UNIT_TIME=this_unit_time, $
            THIS_UT_REF=this_ut_ref, $
            SAS_only=SAS_only, RAS_only=RAS_only, $
            _EXTRA=_extra

@hsi_insert_catch

IF Keyword_Set( _EXTRA ) THEN self->Set, _EXTRA =  _extra

; set aspect_cntl_level to a minimum according to self.debug
;
if ( self.debug gt 0 and self->get(/aspect_cntl_level) lt 2 ) then $
  self->set,aspect_cntl_level=2
cntl_level=self->get(/ASPECT_CNTL_LEVEL)
debug     =self->get(/DEBUG)
verbose   =self->get(/VERBOSE)

if ( self->get(/SASZERO) ) then begin

  if (cntl_level gt 0) then message,'Creating SASZERO solution',/info

  if ( not self->as_check_time_range() ) then begin
    if (cntl_level gt -1) then $
      message,'Try to take aspect_time_range without checks',/info
  endif

  time_range=self->get(/aspect_time_range)

  if valid_range(time_range) then begin
    spin_period = self->get(/as_spin_period)
    delta_time  = hsi_any2sctime(time_range[1],/L64) $
                 -hsi_any2sctime(time_range[0],/L64)

    aspect_data = {time: long( [0,ishft(delta_time,-13)] ), $
                   t0: hsi_any2sctime(time_range[0],/ful), $
                   pointing: fltarr(2,2), $
                   roll: [ 0, delta_time*2d^(-19)*!DPI/spin_period ] }
  endif else $
    aspect_data = -1

endif else begin

  aspect_data = self->Framework::GetData( _EXTRA=_extra, $
                                          SAS_only=SAS_only, RAS_only=RAS_only)

endelse

; interpolate the data points
;
IF ( (n_elements(THIS_TIME) ne 0) and (size(aspect_data,/type) eq 8) ) THEN BEGIN

    ; calculate difference between UT_REF and aspect t0 in bms S/C time
    ;
    time_ref_shift = hsi_sctime_convert(hsi_any2sctime(this_ut_ref),/L64) $
                    -hsi_sctime_convert(aspect_data.t0,/L64)

    ; convert the relative aspect solution times to be relative to the time
    ; given by UT_REF
    ;
    as_time = ( aspect_data.time*2d^13 - time_ref_shift ) / this_unit_time

    as_inter=replicate({hsi_aspect}, n_elements(this_time) )

    if not (str_index(self->get(/as_interpol),'quad') lt 0) then $
      int_q=1 $
    else $
      int_q=0

    if (keyword_set(SAS_only) OR not keyword_set(RAS_only)) then begin
      as_inter.dx  =Interpol( aspect_data.pointing[*,0], as_time, this_time, quadratic=int_q )
      as_inter.dy  =Interpol( aspect_data.pointing[*,1], as_time, this_time, quadratic=int_q )
    endif
    if ( self->get(/SASZERO) ) then begin
      as_inter[*].dx = 0  ; quadr. interpol. returns NaN if all inputs are 0's
      as_inter[*].dy = 0
    endif
    if (keyword_set(RAS_only) OR not keyword_set(SAS_only)) then begin
      as_inter.phi =Interpol( aspect_data.roll, as_time, this_time )
    endif

    RETURN, as_inter

ENDIF ELSE BEGIN

    RETURN, aspect_data

ENDELSE

END

;---------------------------------------------------------------------------

PRO psh_HSI_Aspect_Solution::Process, _EXTRA = _extra, $
                                  ras_sol= ras_sol, $
                                  no_range_test=no_range_test

cntl_level=self->get(/ASPECT_CNTL_LEVEL)
debug     =self->get(/DEBUG)
verbose   =self->get(/VERBOSE)

aspect_sim = self->Get( /ASPECT_SIM )

; set the output structure to a default value
;   indicating is has not been calculated yet
;
aspect_str=-1

IF aspect_sim NE 0 THEN BEGIN

  message,'Simulate Aspect Solution',/info

  ; find the appropriate time range
  ; 1. check methode as_check_time_range()
  ; 2. check for aspect_time_range
  ; if still not set: return -1.
  ;

  if ( not self->as_check_time_range() ) then begin
    if (cntl_level gt -1) then $
      message,'Try to take aspect_time_range without checks',/info
  endif

  time_range=self->get(/aspect_time_range)

  if valid_range(time_range) then begin

    spin_period = self->get(/as_spin_period)

    hsi_as_sim_packet, time_range=time_range, t0=t0, $
                       pointing=pointing, roll=roll, $
                       /no_packet, $
                       omega=1.0/spin_period
    time=lindgen(n_elements(roll))

    aspect_str= {time: Reform( time ), t0: t0, $
                 pointing: pointing, roll: Reform( roll ) }
  endif

endif else begin

  if self->as_check_time_range() then begin

;   after272 = self->Get( /AFTER272 )

    packet_obj = self->Get( /OBJECT, CLASS='HSI_PACKET' )

    ; make sure aspect packets are accessible
    ;
    if not obj_valid(packet_obj) then begin
        msg="Can't read aspect packets. Packet object not valid."
        @hsi_message
    endif else begin
        filename = packet_obj->Get( /FILENAME )
        if ( size( filename, /TYPE ) eq 10 ) THEN begin
          msg="Can't read aspect packets. File not found."
          @hsi_message
        endif else $
          if ( filename[0] eq '' ) then begin
            msg="Can't read aspect packets. File not found."
            @hsi_message
          endif
    endelse

    control_aspect={hsi_as_control}
    control_param =self->get(/control,/this_class)
    control=join_struct(control_aspect, control_param)
    if (strpos(strlowcase(self->get(/as_roll_solution)),'fix') ne -1) then $
      control.roll_offset_ref= (self->get(/file_time_range))[0]            ; can take a long time
;    control.simulated_data = self->get(/simulated_data)	;;;; PSH, 2004/02/04: commented out....
;    if (self->get(/simulated_data)) then control.test = 0 $	;;;; PSH, 2004/02/04: commented out....
;                                    else control.test = 1	;;;; PSH, 2004/02/04: commented out....

    HSI_Aspect, PACKET_OBJ=packet_obj, $
        TIME=time, tref=t0, POINTING=pointing, ROLL=roll, QUALITY=quality, $
        CONTROL=control, $
        t0ras=t0ras, sol_roll=ras_sol, $
        _EXTRA=_extra
;       AFTER272=after272

;   aspect_str = {time: Reform( time ), t0: t0, $
;                 pointing: pointing, roll: Reform( roll ), $
;                 quality: Reform( quality ) }

    if keyword_set(ras_sol) then begin
      aspect_str = {time: time , t0: t0, pointing: pointing, roll: roll, $
                    ras_sol: ras_sol, t0ras: t0ras, quality: Reform( quality )}
    endif else begin
      aspect_str = {time: time , t0: t0, pointing: pointing, roll: roll, quality: Reform( quality ) }
    endelse

    ; test if aspect solution covers the whole aspect time range
    ;
    time_range = self->get(/aspect_time_range)
    sol_range  = hsi_sctime2any( $
                 hsi_sctime_add( long64(minmax(time)*2d^3), t0, time_unit=2L^10) )
    if keyword_set(no_range_test) then $
      v_range=[0,0] $
    else $
      v_range    = value_locate( sol_range, time_range)
    if ( (v_range[0] ne 0) or (v_range[1] ne 0) ) then begin
      msg='Aspect solution not covering the full analysis time range'
      @hsi_message
    endif

  endif

endelse

self->SetData, aspect_str
self->set, as_quality=quality

END

;---------------------------------------------------------------------------

PRO psh_Hsi_Aspect_Solution__Define

self = {psh_Hsi_Aspect_Solution, $
        Absolute_Time_range: [0d,0d], $

        abs_pointing: [0d,0d], $
        SAS_only    : 0, $
        RAS_only    : 0, $

        INHERITS Framework }

END

;---------------------------------------------------------------------------
; End of 'hsi_aspect_solution__define.pro'.
;---------------------------------------------------------------------------
