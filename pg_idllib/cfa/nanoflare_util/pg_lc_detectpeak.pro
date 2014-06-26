;+
; NAME:
;
;  pg_detectpeak
;
; PURPOSE:
;
; detects peaks in a lightcurve
;
; CATEGORY:
;
; timeseries utilities
;
; CALLING SEQUENCE:
;
;      pg_lc_detectpeak, LightCurve $
;                      , SmoothingFunctionName=SmoothingFunctionName $
;                      , SmoothingWidth=SmoothingWidth $
;                      , SmoothedDerivative=SmoothedDerivative $
;                      , SmoothedLightCurve=SmoothedLightCurve $
;                      , PeakStartTimes=InterleavedStartTimes,PeakEndTimes=InterleavedEndTimes $
;                      , Tr1EventList=Tr1EventList,Tr2EventList=Tr2EventList,Tr3EventList=Tr3EventList $
;                      , Threshold1=InputThreshold1, Threshold2=InputThreshold2,Threshold3=InputThreshold3 $
;                      , /DoPlot,NormalizationFactor=NormalizationFactor,SmoothingFunction=SmoothingFunction
;
;
; INPUTS:
;
; LightCurve: [array of floats or doubles] a lightcurve -for now assumes all datapoints
;             equally spaced in time - to be fixed (should be easy)
;
; OPTIONAL INPUTS:
;
; SmoothingFunctionName: [string] smoothing function name (user defined) - this is the name
;                        of an IDL function that taxes as input x and optional parameters "width" and "xc"
;                        For example, if the name is "f" then the function should work called as y=f(x,xc=0,width=1)
;                        width is the width of the smoothing function, xc the position of the peak of the smoothing function
;                        xc is set to 0 - because we want the smoothing function to be centered on 0 to avoid shifts of
;                        the lightcurve due to the convolution with a non-centered function 
; SmoothingWidth: [float] (input accepted by the smoothing function) this parameters controls the smoothing width
;
; Threshold1 : Threshold for the derivative to trigger a peak detection
; Threshold2 : Threshold for the derivative to start an event triggered by threshold 1
; Threshold3 : Threshold for the derivative to end an event triggered by threshold 2
;
; NormalizationFactor: the threhsolds are divided by this factor (default 0.002) - useful to keep the threshold
;                      values around unity and to simultaneously change the sensitivity without influenicng 
;                      the ratios of the different thresholds
;
; KEYWORD PARAMETERS:
;
; DoPlot: if set, plots the lightcurve and the smoothed derivative with the thresholds
;         (useful for debugging purposes)
;
; OUTPUTS:
; PeakStartTimes: indices to the starting times of all detected peaks
; PeakEndTimes: indices to the ending times of all detected peaks
;
; OPTIONAL OUTPUTS:
;
; SmoothedLightCurve: the smoothed version of the input lightcurve
; SmoothedDerivative: the derivative of the smoothed version of the input lightcurve
; SmoothingFuntion: the smoothing function used for the smoothing 
; Tr1EventList: the raw list of indices of the lightcurve where Treshold 1 is surpassed from below
; Tr2EventList: the raw list of indices of the lightcurve where Treshold 2 is surpassed from below
; Tr3EventList: the raw list of indices of the lightcurve where Treshold 3 is surpassed from below
;
; COMMON BLOCKS:
;
; NONE
;
; SIDE EFFECTS:
;
; NONE (unless /doplot is set - then produces a plot to the current graphic
;                               devices and sets up a color scale)
;
; RESTRICTIONS:
;
; NONE known
;
; PROCEDURE:
;
; The procedure is somewhat complex and explained in the main body of the
; program. In summary - 3 thresholds are used. Threshold 1 controls if a peak is
; detected or not. Threshold 2 controls the start of the detected peak.
; Threshold 3 controls the end of the detected peak. Output starts and end times
; matches i.e. there's the same number of starts and endings and the endings are always
; greateror equal the starts.
;
;
; EXAMPLE:
;
; ;create test noisy data
; n=1024
; x=findgen(n)/(n-1)*10
; y1=1/(1+4*(x-3)^2)
; y2=2/(1+5*(x-6)^2)
; y3=2/(1+8*(x-4)^2)
; y=y1+y2+y3+randomn(seed,n)*0.25
;
; pg_lc_detectpeak,y,SmoothingWidth=25,Threshold1=0.5,Threshold2=0.3,Threshold3=-0.15 $
;                ,NormalizationFactor=0.02,/doplot,PeakStartTimes=okstart,PeakEndTimes=okendtt
;
;
;
; AUTHOR:
;
; Paolo Grigis
; pgrigis@cfa.harvard.edu
;
;
; MODIFICATION HISTORY:
;
; 11-DEC-2009 PG documented and clean-up (based on version from about spring 2009)
;-


PRO   pg_lc_detectpeak, LightCurve $
                      , Threshold1=InputThreshold1 $
                      , Threshold2=InputThreshold2 $
                      , Threshold3=InputThreshold3 $
                      , NormalizationFactor=NormalizationFactor $
                      , PeakStartTimes=InterleavedStartTimes $
                      , PeakEndTimes=InterleavedEndTimes $
                      , SmoothingFunctionName=SmoothingFunctionName $
                      , SmoothingWidth=SmoothingWidth $
                      , SmoothingFunction=SmoothingFunction $
                      , SmoothedDerivative=SmoothedDerivative $
                      , SmoothedLightCurve=SmoothedLightCurve $
                      , Tr1EventList=Tr1EventList $
                      , Tr2EventList=Tr2EventList $
                      , Tr3EventList=Tr3EventList $
                      , DoPlot=DoPlot


;variable initialization
SmoothingWidth=fcheck(SmoothingWidth,6)

;creates x-axis for the lightcurve
nlc=n_elements(LightCurve)
x=findgen(nlc)/(nlc-1)*1-0.5
dx=1d/(nlc-1)

;defines smoothing function
SmoothingFunctionName=fcheck(SmoothingFunctionName,'pg_gauss_scale')
;get an instance of the smoothing curve
SmoothingFunction=call_function(SmoothingFunctionName,x,xc=0.,width=SmoothingWidth*dx)

;create smoothed version of light curve by convolution with smoothed curve
SmoothedLightCurve=reverse(reform(double(shift(fft(fft(LightCurve,-1)*fft(SmoothingFunction,-1)),-nlc/2-2))*nlc))

;compute numerical derivative of the smoothed version of the lightcurve
SmoothedDerivative=(shift(SmoothedLightCurve,-1)-shift(SmoothedLightCurve,1))/dx


;define parameters

;this algorith uses 3 thresholds
;all the thresholds are deined in derivative space



;normalization factor: allows to change the 3 thresholds without changing they relative ratios
NormalizationFactor=fcheck(NormalizationFactor,0.002)

;protects input threshold values
;threshold 1: positive derivative value that triggers a peak detection
Threshold1=fcheck(InputThreshold1, 0.5)/NormalizationFactor
;threshold 2: positive derivative value that defines the start of the peak triggered by threshold 1
Threshold2=fcheck(InputThreshold2, 0.1)/NormalizationFactor
;threshold 2: negative derivative value that defines the end of a peak
Threshold3=fcheck(InputThreshold3,-0.2)/NormalizationFactor

;the idea here is to first identify all data points where the derivative
;surpasses TR1, TR2 and TR3 from below - let's call these TRN events
;then define a peak as starting at the last TR2 event before a TR1 event
;and ending as the first TR3 event after a TR1 event
;the logic below accomplishes just that - optimized for IDL quirks :)


;first pass: identify where TR1, TR2, TR3 "events" i.e. location where the derivative
;goes from being lower than TRN to being larger then TRN
;this is accomplished comparing the array with the array at the next position
;which is found with IDL's SHIFT function

Tr1EventList=where(SmoothedDerivative LE Threshold1 AND shift(SmoothedDerivative,-1) GT Threshold1,CountTr1Events)
Tr2EventList=where(SmoothedDerivative LE Threshold2 AND shift(SmoothedDerivative,-1) GT Threshold2,CountTr2Events)
Tr3EventList=where(SmoothedDerivative LE Threshold3 AND shift(SmoothedDerivative,-1) GT Threshold3,CountTr3Events)

;build all intervals that satisfy the peak condition as described above

;initialize intervals: -1 means no peak detected
PeakStartTimes=-1
PeakEndTimes=-1

;detect events 2 occurring right before event 1
IF (CountTr1Events GT 0) AND (CountTr2Events GT 0) THEN BEGIN 
   

   onearr=replicate(1,CountTr1Events);flags for event 1
   twoarr=replicate(2,CountTr2Events);flags for event 2
   allarr=[Tr2EventList,Tr1EventList];unsorted events put together
   srtarr=bsort(allarr);sorts (in time) events 1 and 2
   ;note that by using bsort, 2s and 1s happening simultaneously are still ordered as 2,1
   ;because allarr above has 2s first and 1s later and bsort preserves original ordering
   ;unlike sort!
   resarr=([twoarr,onearr])[srtarr];order the flags in the same ordering as the events
   ;basically he last few commands produce an array with 1s and 2s in the same order
   ;as events 1 and 2 are detected in the lightcurve


   ;this is the key bit - from the list of ordered flags ( for example [2,2,2,1,2,2,1,2,1,2,2,2,1,2,2])
   ;finds where 2 is followed by 1 - these are indices to the sorted array
   PeakStartTimesind=where( resarr EQ 2 AND shift(resarr,-1) EQ 1,countPeakStartTimes)
   
   ;sets event start times using the events found above and the sorted array of events
   PeakStartTimes=allarr[srtarr[PeakStartTimesind]]

ENDIF


IF CountTr3Events GT 0 THEN BEGIN 
 
      ;end times are just given by threshold 3 events
      PeakEndTimes=Tr3EventList

ENDIF

  
;this is useful for debugging purposes - makes a plot
;of the data and thresholds
IF keyword_set(doplot) THEN BEGIN 

   x=findgen(nlc)

   wdef,1,1200,1200
   pmulti=!P.multi
   !P.multi=[0,1,2]
   loadct,0
   linecolors
   plot,x,LightCurve
   oplot,x,SmoothedLightCurve,color=12,thick=2
   plot,x,SmoothedDerivative,yrange=5*[-Threshold1,Threshold1]

   oplot,!X.crange,Threshold1*[1,1],color=12
   oplot,!X.crange,Threshold2*[1,1],color=2
   oplot,!X.crange,Threshold3*[1,1],color=5
   !p.multi=pmulti
   
ENDIF


;now we have a list of start and end times - however sometimes it is possible
;that there are more ends then starts (if there are multiple events 3 detected
;after an event 1) and also possibly multiple starts to an end
;in addition to that there may be events not properly terminated at the
;edges of the array
;therefore call the function "pg_interleave_array" that scans starts and ends
;and associated the latest possible starts with the earliest possible ends
; (see that routine header for more info)
;the outputs are the well ordered and properly associated "interleaved" times
;every start is associated with correct end in the final interleaved times

IF n_elements(PeakStartTimes) GT 1 AND n_elements(PeakEndTimes) GT 1 THEN BEGIN 
   ;good data to work with -> call the interleave function
   pg_interleave_array,PeakStartTimes,PeakEndTimes,x2=InterleavedStartTimes,y2=InterleavedEndTimes 
ENDIF $
ELSE BEGIN 
   ;if no peak are detected returns -1
   InterleavedStartTimes=-1
   InterleavedEndTimes=-1
ENDELSE


;done! :)
RETURN


END



