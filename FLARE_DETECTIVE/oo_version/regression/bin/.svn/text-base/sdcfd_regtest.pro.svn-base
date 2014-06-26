pro sdcfd_regtest, args

   timeFlag = 0 ; determine if times should be reported for each run
   filenames = ['']
   resetAfterInterval = 0L
   verbose = 6
   binx = 16
   biny = 16
   outDir = ''
   VOEventSpecFile = ''

   ii = 0
   while ii lt n_elements(args) do begin
      case args[ii] of
         '-time': begin
            timeFlag = 1
         end
         '-VODir': begin
            voDir = args[ii+1]
            ii++
         end
         '-outDir': begin
            outDir = args[ii+1]
            ii++
         end
         '-resetAfterInterval':begin
            resetAfterInterval = args[ii+1]+0
            ii++
         end
         '-verbose':begin
            verbose = args[ii+1]+0
            ii++
         end
         '-binx':begin
            binx = args[ii+1]+0
            ii++
         end
         '-biny':begin
            biny = args[ii+1]+0
            ii++
         end
         '-VOEventSpecFile':begin
            VOEventSpecFile = args[ii+1]
            ii++
         end 
         else: begin
            ; the rest of the list should be file names
            filenames = args[ii:n_elements(args)-1]
            ii = n_elements(args)
         end
      endcase
      ii++
   endwhile

   if n_elements(filenames) eq 1 and filenames[0] eq '' then begin
      print, "ERROR: Must have file names to run test"
      return
   endif


   ; run the test
   if timeFlag eq 1 then begin
      timeArray = fltarr (n_elements(filenames))
   endif

   statfile = outDir + '/sdcfd_trig_flaredet_struct.sav'
   for ii=0,n_elements(filenames)-1 do begin
      if timeFlag eq 1 then begin
         indivTimeStart = systime (/seconds)
      endif

      if resetAfterInterval gt 0 then begin
         sdcfd_trig_flaredet, filenames[ii], /rebin, /renormalize, $
                 VOEventFileDir=voDir,status=status, DerivativeThreshold=0.02, $ 
                 verbose=verbose, nx=binx, ny=biny, DespikeNpass=2, $
                 statfile=statfile, event=event, FlareXRange=3, FlareYRange=3, $
                 VOEventSpecFile=VOEventSpecFile, debug=1, $
                 ResetAfterInterval=resetAfterInterval
      endif else begin
         sdcfd_trig_flaredet, filenames[ii], /rebin, /renormalize, $
                 VOEventFileDir=voDir,status=status, DerivativeThreshold=0.02, $ 
                 verbose=verbose, nx=binx, ny=biny, DespikeNpass=2, $
                 statfile=statfile, event=event, FlareXRange=3, FlareYRange=3, $
                 VOEventSpecFile=VOEventSpecFile, debug=1
      endelse

      if timeFlag eq 1 then begin
         timeArray[ii] = systime (/seconds) - indivTimeStart 
      endif
   endfor

   ; print time results
   if timeFlag eq 1 then begin
      maxTime = max (timeArray, index)
      print, 'Max Time: '+string (maxTime)+' -- '+filenames[index]
      minTime = min (timeArray, index)
      print, 'Min Time: '+string (minTime)+' -- '+filenames[index]
      print, 'Med Time: '+string (median(timeArray))
      print, 'TotalTime ('+string(n_elements(filenames))+' files): '+string(total(timeArray))
   endif
end
