;.r fft_fcm_time_stepper.pro
start_index=0UL
PATH_2_STACKS= '/home/hwinter/programs/Flare_Detective/Event_Stacks/'
readcol, '/home/hwinter/programs/Flare_Detective/times.txt', start_times, end_times, FORMAT=['A,A'], delim='   '

help, start_times, end_times

print, start_times[start_index], ' ', end_times[start_index]

for iii=start_index, n_elements(start_times)-1 do begin

 fft_fcm_event_scan, start_times[iii], end_times[iii], $
                     VERBOSE=VERBOSE, PATH_2_STACKS=PATH_2_STACKS


 print, 'Completed #', string(iii)
endfor



END
