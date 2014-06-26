
pro fft_fcm_write_failure_report, events, PATH_2_STACKS=PATH_2_STACKS, ERRMSG=ERRMSG
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

print, '!!!Writing Error Report!!!'





end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;	fft_fcm_create_pending_files.pro
;
; PURPOSE:
;	This program scans the Pending, Processing and Completed
;	stacks for a file based on the IVORN based file name.  If none
;	are found then the program creates the file containing the
;	event structure in a save file and performs a wget to get the
;	XML file associated with the event
;
; CATEGORY:
;	Part of the Feature Finding Team (FFT) Flare Characterization Module (FCM)
;
; CALLING SEQUENCE:
;	
;
; INPUTS:
;	
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	
;
; OUTPUTS:
;	
;
; OPTIONAL OUTPUTS:
;	
;
; COMMON BLOCKS:
;	
;
; SIDE EFFECTS:
;	None noted.  
;
; RESTRICTIONS:
;	Depends on other high-level programs to test the PATH_2_STACKS
;
; PROCEDURE:
;	
;
; EXAMPLE:
;	
;
; MODIFICATION HISTORY:
; 	Written by: Henry "Trae" D. Winter III	(HDWIII) 2012-04-11
;-
function fft_fcm_create_pending_files, events, PATH_2_STACKS=PATH_2_STACKS, ERRMSG=ERRMSG
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ERRMSG=''

;

  n_events=n_elements(events)
  if n_events lt 1 then begin
     return, -1
     ERRMSG=ERRMSG+'No event files passed to fft_fcm_create_pending_files. :'
     goto, end_jump
  endif
  
  for i_ind=0ul, n_events-1ul do begin
;Create a name based on a unique IVORN address
     ivo_name=events[i_ind].KB_ARCHIVID
     parts=STRSPLIT( ivo_name, '/' , COUNT=n_slash ,  /EXTRACT)
     ivo_name=''
     for j_ind=0, n_slash-1 do begin
        if j_ind ne n_slash-1 then $
           ivo_name=ivo_name+parts[j_ind]+'__' else $
              ivo_name=ivo_name+parts[j_ind]+'.sav'
     endfor
     
     case 1 of 
        FILE_TEST(strcompress(PATH_2_STACKS+'/Pending/'+ivo_name,/REMOVE)) :
        FILE_TEST(strcompress(PATH_2_STACKS+'/Processing/'+ivo_name,/REMOVE)) :
        FILE_TEST(strcompress(PATH_2_STACKS+'/Completed/'+ivo_name,/REMOVE)) :
        else: begin
           event=events[i_ind]
           save, event, file=strcompress(PATH_2_STACKS+'/Pending/'+ivo_name,/REMOVE)
           print, 'Saved file '+strcompress(PATH_2_STACKS+'/Pending/'+ivo_name,/REMOVE)
        endelse
     endcase

     
  endfor

  return, 1
end_jump:
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; NAME:
;	fft_fcm_event_scan.pro
;
; PURPOSE:
;	Scan a date range for Flare Detective triggered Heliophysics 
;	Knowledgebase Events.  Program will query the database at
;	LMSAL for new events.  The program will then scan the Pending,
;	Processing and Completed stack for an IVORN matching each
;	event. If none are found the program generates a file based on
;	the IVORN in the Pending Stack.  If a file with the same IVORN
;	already exists, then the program ignores the event.
;
; CATEGORY:
;	
;
; CALLING SEQUENCE:
;	
;
; INPUTS:
;	
;
; OPTIONAL INPUTS:
;	
;	
; KEYWORD PARAMETERS:
;	
;
; OUTPUTS:
;	
;
; OPTIONAL OUTPUTS:
;	
;
; COMMON BLOCKS:
;	
;
; SIDE EFFECTS:
;	
;
; RESTRICTIONS:
;	
;
; PROCEDURE:
;	
;
; EXAMPLE:
;	
;
; MODIFICATION HISTORY:
; 	Written by:	
;-

pro fft_fcm_event_scan, time_start, time_end, $
                        VERBOSE=VERBOSE, PATH_2_STACKS=PATH_2_STACKS,$
                        EVENTS=events, ERRMSG=ERRMSG
  ERRMSG=''
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check that a path to the Pending, Processing, and Completed stacks
;exist.

;Sets the default path to the stacks.  This will be overridden if
;the PATH_2_STACKS keyword is set
PATH_2_STACKS_in='./'
  if not keyword_set(PATH_2_STACKS) then begin
;Test the folder stacks
     case 0 of 
        FILE_TEST( PATH_2_STACKS_in+'Pending', /DIRECTORY) : begin
           ERRMSG= ERRMSG+'No Pending/ folder found. '+strcompress(PATH_2_STACKS_in+'/Pending. :',/REMOVE)
           goto, end_jump
        end
        
        FILE_TEST( PATH_2_STACKS_in+'Processing', /DIRECTORY): begin
           ERRMSG= ERRMSG+'No Processing/ folder found. '+strcompress(PATH_2_STACKS_in+'/Processing. :',/REMOVE)
           goto, end_jump
        end

        FILE_TEST( PATH_2_STACKS_in+'Completed', /DIRECTORY): begin
           ERRMSG= ERRMSG+'No Completed/ folder found. '+strcompress(PATH_2_STACKS_in+'/Completed. :',/REMOVE)
           goto, end_jump        
        end

        else: 

     endcase 
  endif else begin
;Test to see if the folder stacks exist
     case 0 of 
        FILE_TEST( strcompress(PATH_2_STACKS+'/Pending',/REMOVE), /DIRECTORY) : begin
           ERRMSG= ERRMSG+'No Pending/ folder found. '+strcompress(PATH_2_STACKS+'/Pending. :',/REMOVE)
           goto, end_jump
        end
        
        FILE_TEST( strcompress(PATH_2_STACKS+'/Processing',/REMOVE), /DIRECTORY) : begin
           ERRMSG= ERRMSG+'No Processing/ folder found. '+strcompress(PATH_2_STACKS+'/Processing. :',/REMOVE)
           goto, end_jump
        end

        FILE_TEST( strcompress(PATH_2_STACKS+'/Completed',/REMOVE), /DIRECTORY) : begin
           ERRMSG= ERRMSG+'No Completed/ folder found. '+strcompress(PATH_2_STACKS+'/Completed. :',/REMOVE)
           goto, end_jump
        end

        else: PATH_2_STACKS_in=PATH_2_STACKS
     endcase 

  endelse




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Handle the different possibilities to represent the time
  n_parameters=n_params()
  print, n_parameters
  case 1 of 
     n_parameters eq 0: begin
;If no times are set, then get all events within 24 hours
        GET_UTC, UTC, /external
        time_end_in=anytim2cal(UTC, form=10, /date,ERRMSG=ERRMSG_temp)
        if ERRMSG_temp ne '' then begin
           print, ERRMSG_temp
           ERRMSG=[ERRMSG,ERRMSG_temp]
        endif
;Get the day before
        day_of_year=doy(time_end_in)
        day_of_year--
        if day_of_year gt 0 then begin
           time_start_in=anytim2cal(doy2utc(day_of_year), form=10, /date,ERRMSG=ERRMSG_temp)
           if ERRMSG_temp ne '' then begin
              print, ERRMSG_temp
              ERRMSG=[ERRMSG,ERRMSG_temp]
           endif
;Make sure that you take care of the case of Jan. 1
        endif else time_start_in='31-Dec-'+strcompress(string(UTC.year-1),/REMOVE_ALL) 
        
     end                        ; n_parameters eq 0

     n_parameters eq 1: begin
        time_end_in=anytim2cal(time_start, form=10,ERRMSG=ERRMSG_temp)
        if ERRMSG_temp ne '' then begin
           print, ERRMSG_temp
           ERRMSG=[ERRMSG,ERRMSG_temp]
        endif
        utc=anytim2utc(time_start, /EXTERNAL,ERRMSG=ERRMSG_temp)
        if ERRMSG_temp ne '' then begin
           print, ERRMSG_temp
           ERRMSG=[ERRMSG,ERRMSG_temp]
        endif
        
        day_of_year=doy(time_end)
        day_of_year--
        if day_of_year gt 0 then begin
           time_start_in=anytim2cal(doy2utc(day_of_year), form=10,ERRMSG=ERRMSG_temp)
           if ERRMSG_temp ne '' then begin
              print, ERRMSG_temp
              ERRMSG=[ERRMSG,ERRMSG_temp]
           endif
        endif else time_start_in='31-Dec-'+strcompress(string(UTC.year-1),/REMOVE_ALL) 
        
     end                        ;n_parameters eq 1

     else:begin
        time_start_in=anytim2cal(time_start,ERRMSG=ERRMSG_temp)
        if ERRMSG_temp ne '' then begin
           print, ERRMSG_temp
           ERRMSG=[ERRMSG,ERRMSG_temp]
        endif
        
        time_end_in=anytim2cal(time_end,ERRMSG=ERRMSG_temp)
        help, time_end_in
        if ERRMSG_temp ne '' then begin
           print, ERRMSG_temp
           ERRMSG=[ERRMSG,ERRMSG_temp]
        endif
        
     end

  endcase
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Scan the HEK for events within the timeframe for flare events
  Print, "Querying LMSAL HEK"
  query_string=ssw_her_make_query(time_start_in,time_end_in, /FL )
  events=ssw_her_query(query_string)
  Print, "Finished querying LMSAL HEK"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Variables to keep up with the failed attempts to save event
;information, not including previously existing files
fail_indicies=-1
;Remove everything except for the events generated by the flare detective.
  flare_detective_events_index=where(events.fl.FRM_NAME eq 'Flare Detective - Trigger Module')
  if flare_detective_events_index[0] ne -1 then begin
     flare_detective_events= events.fl[flare_detective_events_index[0]]
     
     pass_fail=fft_fcm_create_pending_files(events.fl[flare_detective_events_index[0]], $
                                         PATH_2_STACKS=PATH_2_STACKS_in, ERRMSG=ERRMSG_temp)
        if ERRMSG_temp ne '' then begin
           print, ERRMSG_temp
           ERRMSG=[ERRMSG,ERRMSG_temp]
        endif
     
        if pass_fail lt 1 then begin
           fail_indicies=[fail_indicies, 0]
        endif

           
     for i_ind=1, n_elements(flare_detective_events_index)-1 do begin
        flare_detective_events=concat_struct(flare_detective_events, events.fl[flare_detective_events_index[i_ind]])
     
        pass_fail=fft_fcm_create_pending_files(events.fl[flare_detective_events_index[i_ind]], $
                                            PATH_2_STACKS=PATH_2_STACKS_in, ERRMSG=ERRMSG_temp)
        if ERRMSG_temp ne '' then begin
           print, ERRMSG_temp
           ERRMSG=[ERRMSG,ERRMSG_temp]
        endif
        
        if pass_fail lt 1 then begin
           fail_indicies=[fail_indicies, 0]
        endif
        
     endfor
     
  endif
  
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Write a failure report and save the unprocessed data to a save file
;if a failure occured.
if n_elements(fail_indicies) gt 1 then begin
   fail_indicies=fail_indicies[1:*] 
   print, 'There were '+strcompress(string( n_elements(fail_indicies)), /remove)+' failures to produce Pending files.'
   fft_fcm_write_failure_report, flare_detective_events[fail_indicies], PATH_2_STACKS=PATH_2_STACKS_in, ERRMSG=ERRMSG
   
endif

end_jump:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Collect all of the items for printing
  if keyword_set(VERBOSE) then begin
     if ERRMSG[0] ne '' then for i_ind=0, n_elements(ERRMSG)-1 do print,  ERRMSG[i_ind]
     if (size(time_start_in, /TYPE) ne 0 ) and (size(time_start_end, /TYPE) ne 0 ) then print, time_start_in, ' to ',time_end_in
     if size(events, /TYPE) ne 0  then help, events.fl
     if size(flare_detective_events, /TYPE) ne 0  then  help, flare_detective_events
     
  endif
END
