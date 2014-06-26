;+
; NAME:
;
; aia_zoomimage_fitline
;
; PURPOSE:
;
; widget to show AIA images on screen with less then 4096 pixels resolution,
; with a couple of useful tools.
; A reduced small AIA image is shown, and a part of it is shown zoomed.
;
; CATEGORY:
;
; SDO/AIA - image visualization
;
; CALLING SEQUENCE:
;
; aia_zoomimage_fitline,image [,WindowSize=WindowSize $
;                 ,ImageSizeX=ImageSizeX,ImageSizeY=ImageSizeY $
;                 ,ZoomImageSizeX=ZoomImageSizeX,ZoomImageSizeY=ZoomImageSizeY]
;
;
; INPUTS:
;
; image: an AIA image (or any image actuallly - but should be larger then the
;        window size)
;
; OPTIONAL INPUTS:
;
; WindowSize : this specifies the size of the images in pixels (both the small
; and zoomed ones). One dimension, assumes square imeages. Default to 1024.
;
; ImageSizeX, ImageSizeY: control the size in pixels of the small image.
;
; ZoomImageSizeX, ZoomImageSizeY: control the ize in pixels of the zoomed image.
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
;
; EXAMPLE:
;
;
;
; AUTHOR:
;
; Paolo Grigis
; pgrigis@cfa.harvard.edu
;
; MODIFICATION HISTORY:
;
; 29-MAR-2010 written PG
; 30-MAR-2010 added color scaling PG
; 12-APR-2010 added fitline functionality PG
;-




FUNCTION aia_zoomimage_fitline_scaleimage,WidgetData,full=full,zoom=zoom


IF keyword_set(full) THEN BEGIN 

   CASE WidgetData.ColorScaling OF 

      'Linear': BEGIN 

         print,'linscale'
         RETURN,bytscl(WidgetData.SmallImage,min=WidgetData.ScaleMin,max=WidgetData.ScaleMax)
   
      END 

      'Logarithmic': BEGIN 
         print,'logscale'
         RETURN,bytscl(alog(WidgetData.SmallImage>WidgetData.ScaleMin<WidgetData.ScaleMax),min=alog(WidgetData.ScaleMin),max=alog(WidgetData.ScaleMax))
      END

     'Square Root': BEGIN 
         print,'sqrtscale'
         RETURN,bytscl(sqrt(WidgetData.SmallImage>WidgetData.ScaleMin<WidgetData.ScaleMax),min=sqrt(WidgetData.ScaleMin),max=sqrt(WidgetData.ScaleMax))
      END

     'Quadratic': BEGIN 
         print,'quadscale'
         RETURN,bytscl((WidgetData.SmallImage>WidgetData.ScaleMin<WidgetData.ScaleMax)^2,min=(WidgetData.ScaleMin)^2,max=(WidgetData.ScaleMax)^2)
      END


      ELSE : BEGIN 

         RETURN,bytscl(WidgetData.SmallImage,min=WidgetData.ScaleMin,max=WidgetData.ScaleMax)

      END

   ENDCASE 

ENDIF 

IF keyword_set(zoom) THEN BEGIN 

  CASE WidgetData.ColorScaling OF 

      'Linear': BEGIN 

         print,'linscale'
         RETURN,bytscl(WidgetData.ZoomedImage,min=WidgetData.ScaleMin,max=WidgetData.ScaleMax)
   
      END 

      'Logarithmic': BEGIN 
         print,'logscale'
         RETURN,bytscl(alog(WidgetData.ZoomedImage>WidgetData.ScaleMin<WidgetData.ScaleMax),min=alog(WidgetData.ScaleMin),max=alog(WidgetData.ScaleMax))
      END

     'Square Root': BEGIN 
         print,'sqrtscale'
         RETURN,bytscl(sqrt(WidgetData.ZoomedImage>WidgetData.ScaleMin<WidgetData.ScaleMax),min=sqrt(WidgetData.ScaleMin),max=sqrt(WidgetData.ScaleMax))
      END

     'Quadratic': BEGIN 
         print,'quadscale'
         RETURN,bytscl((WidgetData.ZoomedImage>WidgetData.ScaleMin<WidgetData.ScaleMax)^2,min=(WidgetData.ScaleMin)^2,max=(WidgetData.ScaleMax)^2)
      END


      ELSE : BEGIN 


         RETURN,bytscl(WidgetData.ZoomedImage,min=WidgetData.ScaleMin,max=WidgetData.ScaleMax)

      END

   ENDCASE 




   
ENDIF 



END 

PRO aia_zoomimage_fitline_display,WidgetData,EventTop


;gets the ID of the widgets for the small and zoomed image
drawwidget=widget_info(EventTop,find_by_uname='drawwin')
drawwidget2=widget_info(EventTop,find_by_uname='drawwin2')

;get the ID of the direct graphic window
widget_control,drawwidget,get_value=winmap
widget_control,drawwidget2,get_value=winmap2
wset,winmap
tv,aia_zoomimage_fitline_scaleimage(WidgetData,/full)

tvlct,r,g,b,/get
tvlct,255,0,0,1

ZoomRatioX=WidgetData.ImageSizeX/float(WidgetData.nx)
ZoomRatioY=WidgetData.ImageSizeY/float(WidgetData.ny)

CenterX=WidgetData.ZoomBoxCenterX*ZoomRatioX
CenterY=WidgetData.ZoomBoxCenterY*ZoomRatioY

plots,CenterX+0.5*ZoomRatioX*WidgetData.ZoomBoxSizeX*[-1,1,1,-1,-1] $
     ,CenterY+0.5*ZoomRatioY*WidgetData.ZoomBoxSizeY*[-1,-1,1,1,-1] $
     ,color=1,/device,thick=2

tvlct,r,g,b

wset,winmap2
tv,aia_zoomimage_fitline_scaleimage(WidgetData,/zoom)

;oplot fit points

IF WidgetData.displayfittingpoints EQ 1 THEN BEGIN 
   tvlct,r,g,b,/get
   tvlct,255,0,0,2
   
   dx=20
   dy=20

   FOR i=0,WidgetData.NUmberOfFittingPoints-1 DO BEGIN 
      thisX=(*WidgetData.FittingPointX)[i]
      thisY=(*WidgetData.FittingPointY)[i]

      DisplayX=(thisX-WidgetData.ZoomBoxCenterX)*WidgetData.Zoomfactor+WidgetData.ZoomImageSizeX/2
      DisplayY=(thisY-WidgetData.ZoomBoxCenterY)*WidgetData.Zoomfactor+WidgetData.ZoomImageSizeY/2

      plots,DisplayX*[1,1],DisplayY+DY*[-1,1],color=2,/device
      plots,DisplayX+DX*[-1,1],DisplayY*[1,1],color=2,/device

   ENDFOR

   tvlct,r,g,b
ENDIF 

;oplot fit line

IF WidgetData.DisplayFittedLine EQ 1 THEN BEGIN 
   IF WidgetData.NumberOfFittingPoints GE 3 THEN BEGIN
      tvlct,r,g,b,/get
      tvlct,255,255,0,5
      sixlin,*(widgetData.FittingPointX),*(widgetData.FittingPointY),a,siga,b,sigb
      thisX=WidgetData.ZoomBoxCenterX+WidgetData.ZoomImageSizeX/(2*WidgetData.Zoomfactor)*[-1,1]
      thisY=b[2]*thisX+a[2]

      DisplayX=(thisX-WidgetData.ZoomBoxCenterX)*WidgetData.Zoomfactor+WidgetData.ZoomImageSizeX/2
      DisplayY=(thisY-WidgetData.ZoomBoxCenterY)*WidgetData.Zoomfactor+WidgetData.ZoomImageSizeY/2

      print,DisplayX,DisplayY
      plots,DisplayX,DisplayY,color=5,/device
      tvlct,r,g,b
   ENDIF 
ENDIF 

END


PRO aia_zoomimage_fitline_setzoom,WidgetData,ZoomFactor=ZoomFactor


ZoomFactor=fcheck(ZoomFactor,1.0)

WidgetData.ZoomFactor=ZoomFactor

WidgetData.ZoomBoxSizeX=round(WidgetData.ZoomImageSizeX/WidgetData.ZoomFactor)
WidgetData.ZoomBoxSizeY=round(WidgetData.ZoomImageSizeY/WidgetData.ZoomFactor)

;makes sure the position of the box is not too close to the boundaries of the CCD
WidgetData.ZoomBoxCenterX=WidgetData.ZoomBoxCenterX>WidgetData.ZoomBoxSizeX/2<(WidgetData.nx-WidgetData.ZoomBoxSizeX/2)
WidgetData.ZoomBoxCenterY=WidgetData.ZoomBoxCenterY>WidgetData.ZoomBoxSizeY/2<(WidgetData.ny-WidgetData.ZoomBoxSizeY/2)

;extract the zoomed part of the image
ImageFraction=WidgetData.FullImage[WidgetData.ZoomBoxCenterX-WidgetData.ZoomBoxSizeX/2:WidgetData.ZoomBoxCenterX+WidgetData.ZoomBoxSizeX/2-1, $
                                   WidgetData.ZoomBoxCenterY-WidgetData.ZoomBoxSizeY/2:WidgetData.ZoomBoxCenterY+WidgetData.ZoomBoxSizeY/2-1]

WidgetData.ZoomedImage=congrid(ImageFraction,WidgetData.ZoomImageSizeX,WidgetData.ZoomImageSizeY)

print,WidgetData.ZoomBoxSizeX,WidgetData.ZoomBoxSizeY

END 



;
;Returns the text to display as information in the text widget
;
FUNCTION aia_zoomimage_fitline_outtext,WidgetData

zoomboxonoff=WidgetData.movingzoom EQ 0? 'OFF' : 'ON'

text=['Move Zoom Box '+zoomboxonoff]
text=[text,'Zoom Factor '+strtrim(WidgetData.Zoomfactor,2)]
text=[text,'Box center position: ('+strtrim(WidgetData.zoomboxcenterx,2)+','+strtrim(WidgetData.zoomboxcentery,2)+')']
text=[text,'Box size: X='+strtrim(WidgetData.zoomboxsizex,2)+'  Y='+strtrim(WidgetData.zoomboxsizey,2)]
text=[text,'Data range: '+strtrim(WidgetData.DataMin,2)+' - '+strtrim(WidgetData.DataMax,2)]

RETURN,text

END



;
;Returns the text to display as information in the line fitting widget
;
FUNCTION aia_zoomimage_fitline_linefit_text,WidgetData

LineFittingOnOff=WidgetData.FittingOn EQ 0? 'OFF' : 'ON'
DisplayFittingPointsOnOff=WidgetData.DisplayFittingPoints EQ 0? 'OFF' : 'ON'
DisplayFittedLineOnOff=WidgetData.DisplayFittedLine EQ 0? 'OFF' : 'ON'


text=['Line Fitting Functionality is: '+LineFittingOnOff]
text=[text,'NUmber of Fitting Points: '+strtrim(WidgetData.NumberOfFittingPoints,2)]
IF WidgetData.FittingOn EQ 1 THEN BEGIN 
   IF WidgetData.FirstPoint EQ 1 THEN BEGIN 
      text=[text,'Current Point not yet clicked']
   ENDIF $
   ELSE BEGIN 
      text=[text,'Current Point at ('+strtrim(WidgetData.ThisPointX,2)+','+strtrim(WidgetData.ThisPointY,2)+')']
   ENDELSE 
   FOR i=0,WidgetData.NumberOfFittingPoints-1 DO BEGIN 
      text=[text,'Point '+string(i,format='(i2.2)')+':  ('+strtrim((*WidgetData.FittingPointX)[i],2)+','+strtrim((*WidgetData.FittingPointY)[i],2)+')']
   ENDFOR 
   text=[text,' Display Fitting Points: '+DisplayFittingPointsOnOff]
   text=[text,' Display Fitted  Line  : '+DisplayFittedLineOnOff]


   IF WidgetData.NumberOfFittingPoints GE 3 THEN BEGIN 

      FormatString='(d8.4)'

      ;computes liner fitting
      sixlin,*(widgetData.FittingPointX),*(widgetData.FittingPointY),a,siga,b,sigb

      Slope=b[2]
      DSlope=sigb[2]
      Angle=atan(Slope)*180.0/!Pi
      DAngle=(DSlope/(1+Slope^2))*180.0/!Pi
      text=[text,'Angle = '+string(Angle,format=FormatString)+' STDEV = '+string(dAngle,format=FormatString)]
      

;;       sixlin,*(widgetData.FittingPointX),*(widgetData.FittingPointY),a,siga,b,sigb
;;       text=[text,'OLS  Y vs. X: Interc.='+strtrim(a[0],2)+' STDEV: '+strtrim(siga[0],2)]
;;       text=[text,'              Slope  ='+strtrim(b[0],2)+' STDEV: '+strtrim(sigb[0],2)]
;;       text=[text,'OLS  X vs. Y: Interc.='+strtrim(a[1],2)+' STDEV: '+strtrim(siga[1],2)]
;;       text=[text,'              Slope  ='+strtrim(b[1],2)+' STDEV: '+strtrim(sigb[1],2)]
;;       text=[text,'OLS bisector: Interc.='+strtrim(a[2],2)+' STDEV: '+strtrim(siga[2],2)]
;;       text=[text,'              Slope  ='+strtrim(b[2],2)+' STDEV: '+strtrim(sigb[2],2)]
      
   ENDIF 

ENDIF 




RETURN,text

END


;
;Widget event handler
;
PRO aia_zoomimage_fitline_event,event

widget_control,event.handler,get_uvalue=WidgetData

CASE event.ID OF 
    
   widget_info(event.top,find_by_uname='buttons') : BEGIN

      print,event.value

       CASE event.value OF

          
          0 : BEGIN ;Draw Images

             aia_zoomimage_fitline_display,WidgetData,event.top

          END 

          1: BEGIN ;sets zoom factors
             aia_zoomimage_fitline_setzoom,WidgetData,ZoomFactor=1
             widget_control,event.handler,set_uvalue=WidgetData
             aia_zoomimage_fitline_display,WidgetData,event.top
          END

          2: BEGIN ;sets zoom factors
             aia_zoomimage_fitline_setzoom,WidgetData,ZoomFactor=2
             widget_control,event.handler,set_uvalue=WidgetData
             aia_zoomimage_fitline_display,WidgetData,event.top
          END


          3: BEGIN ;sets zoom factors
             aia_zoomimage_fitline_setzoom,WidgetData,ZoomFactor=4
             widget_control,event.handler,set_uvalue=WidgetData
             aia_zoomimage_fitline_display,WidgetData,event.top
          END

 
          4: BEGIN ;sets zoom factors
             aia_zoomimage_fitline_setzoom,WidgetData,ZoomFactor=6
             widget_control,event.handler,set_uvalue=WidgetData
             aia_zoomimage_fitline_display,WidgetData,event.top
          END


          5: BEGIN ;sets zoom factors
             aia_zoomimage_fitline_setzoom,WidgetData,ZoomFactor=8
             widget_control,event.handler,set_uvalue=WidgetData
             aia_zoomimage_fitline_display,WidgetData,event.top
          END

          6: BEGIN ;sets zoom factors
             aia_zoomimage_fitline_setzoom,WidgetData,ZoomFactor=12
             widget_control,event.handler,set_uvalue=WidgetData
             aia_zoomimage_fitline_display,WidgetData,event.top
          END

          7: BEGIN ;sets zoom factors
             aia_zoomimage_fitline_setzoom,WidgetData,ZoomFactor=16
             widget_control,event.handler,set_uvalue=WidgetData
             aia_zoomimage_fitline_display,WidgetData,event.top
          END



          8: BEGIN ;sets zoom factors
             aia_zoomimage_fitline_setzoom,WidgetData,ZoomFactor=0.5
             widget_control,event.handler,set_uvalue=WidgetData
             aia_zoomimage_fitline_display,WidgetData,event.top
          END


          9: BEGIN ;sets zoom factors
             aia_zoomimage_fitline_setzoom,WidgetData,ZoomFactor=1.0/3
             widget_control,event.handler,set_uvalue=WidgetData
             aia_zoomimage_fitline_display,WidgetData,event.top
          END
          
          10: BEGIN 
             ;move zoom box center

             drawwidget=widget_info(Event.Top,find_by_uname='drawwin')

             IF WidgetData.MovingZoom EQ 0 THEN BEGIN 
                widget_control,drawwidget,/draw_button_events
                WidgetData.MovingZoom=1
             ENDIF $
             ELSE BEGIN
                widget_control,drawwidget,draw_button_events=0
                WidgetData.MovingZoom=0
             ENDELSE    

             widget_control,event.handler,set_uvalue=WidgetData

          END

          11: BEGIN  ;centers zoom window
             WidgetData.ZoomBoxCenterX=WidgetData.nx/2
             WidgetData.ZoomBoxCenterY=WidgetData.ny/2
             widget_control,event.handler,set_uvalue=WidgetData
             aia_zoomimage_fitline_setzoom,WidgetData,ZoomFactor=WidgetData.ZoomFactor
             aia_zoomimage_fitline_display,WidgetData,event.top
          END 

         12: BEGIN 
             widget_control,event.top,/destroy
             return
          END 

          ELSE : BEGIN 

          END
       ENDCASE 

       print,'Ciao'
    END 

   ;buttons that control the fitting of a linbe to the points are handled here
   widget_info(event.top,find_by_uname='fitline_buttons') : BEGIN

      print,'fitline_buttons: '+strtrim(event.value,2)

      CASE event.value OF
        
         0 : BEGIN   ;Toggle fitting ON/OFF
             
     
            drawwidgetZoom=widget_info(Event.Top,find_by_uname='drawwin2')

             IF WidgetData.FittingOn EQ 0 THEN BEGIN 
                widget_control,drawwidgetZoom,/draw_button_events
                WidgetData.FittingOn=1
                WidgetData.FirstPoint=1
             ENDIF $
             ELSE BEGIN
                widget_control,drawwidgetZoom,draw_button_events=0
                WidgetData.FittingOn=0
             ENDELSE    

             widget_control,event.handler,set_uvalue=WidgetData


         END 
         
         1 : BEGIN ;Reset Points

            WidgetData.NumberOfFittingPoints=0
            WidgetData.FittingPointX=ptr_new()
            WidgetData.FittingPointY=ptr_new()
            WidgetData.FittingParameters=ptr_new()
            WidgetData.FirstPoint=1
            widget_control,event.handler,set_uvalue=WidgetData
            aia_zoomimage_fitline_display,WidgetData,event.top

         END 

         2: BEGIN ;add point

            IF WidgetData.NumberOfFittingPoints EQ 0 THEN BEGIN 
               WidgetData.FittingPointX=ptr_new(WidgetData.ThisPointX)
               WidgetData.FittingPointY=ptr_new(WidgetData.ThisPointY)
               
           ENDIF $
           ELSE BEGIN 
              WidgetData.FittingPointX=ptr_new([*WidgetData.FittingPointX,WidgetData.ThisPointX])
              WidgetData.FittingPointY=ptr_new([*WidgetData.FittingPointY,WidgetData.ThisPointY])
              
           ENDELSE 

            WidgetData.NumberOfFittingPoints=WidgetData.NumberOfFittingPoints+1
            WidgetData.FirstPoint=1
            widget_control,event.handler,set_uvalue=WidgetData
            aia_zoomimage_fitline_display,WidgetData,event.top

         END 

       3: BEGIN ;remove point

            IF WidgetData.NumberOfFittingPoints LE 1 THEN BEGIN 
               ;remove one and only point - works also if no point is there
               WidgetData.FittingPointX=ptr_new()
               WidgetData.FittingPointY=ptr_new()
               WidgetData.NumberOfFittingPoints=0
               WidgetData.FirstPoint=1
              
           ENDIF $
           ELSE BEGIN 
              WidgetData.FittingPointX=ptr_new((*WidgetData.FittingPointX)[0:WidgetData.NumberOfFittingPoints-2])
              WidgetData.FittingPointY=ptr_new((*WidgetData.FittingPointY)[0:WidgetData.NumberOfFittingPoints-2])
              WidgetData.NumberOfFittingPoints=WidgetData.NumberOfFittingPoints-1
              WidgetData.FirstPoint=1
              
           ENDELSE
 
           widget_control,event.handler,set_uvalue=WidgetData
           aia_zoomimage_fitline_display,WidgetData,event.top
           
         END 

       4: BEGIN  ;display points
          WidgetData.DisplayFittingPoints=1- WidgetData.DisplayFittingPoints
          widget_control,event.handler,set_uvalue=WidgetData
          aia_zoomimage_fitline_display,WidgetData,event.top
       END 

       5: BEGIN  ;display line
          WidgetData.DisplayFittedLine=1- WidgetData.DisplayFittedLine
          widget_control,event.handler,set_uvalue=WidgetData
          aia_zoomimage_fitline_display,WidgetData,event.top
       END 
 
       6: BEGIN ;print summary
          
          IF WidgetData.NumberOfFittingPoints GE 3 THEN BEGIN 

             FOR i=0,WidgetData.NumberOfFittingPoints-1 DO BEGIN 
                print,'Point '+string(i,format='(i2.2)')+':  X='+strtrim((*WidgetData.FittingPointX)[i],2)+' Y='+strtrim((*WidgetData.FittingPointY)[i],2)
             ENDFOR

             sixlin,*(widgetData.FittingPointX),*(widgetData.FittingPointY),a,siga,b,sigb
             formatString='(e14.4)'
             print,'OLS  Y vs. X: Interc.='+string(a[0],format=FormatString)+' STDEV: '+string(siga[0],format=FormatString)
             print,'              Slope  ='+string(b[0],format=FormatString)+' STDEV: '+string(sigb[0],format=FormatString)
             print,'OLS  X vs. Y: Interc.='+string(a[1],format=FormatString)+' STDEV: '+string(siga[1],format=FormatString)
             print,'              Slope  ='+string(b[1],format=FormatString)+' STDEV: '+string(sigb[1],format=FormatString)
             print,'OLS bisector: Interc.='+string(a[2],format=FormatString)+' STDEV: '+string(siga[2],format=FormatString)
             print,'              Slope  ='+string(b[2],format=FormatString)+' STDEV: '+string(sigb[2],format=FormatString)
 

          ENDIF $
          ELSE BEGIN 
             print,'Need at least 3 points to fit a straight line!'
          ENDELSE 

       END 

         ELSE: BEGIN
            print,'Unrecognized Line Fitting button number! Oops....'
         ENDELSE
      ENDCASE 
         
  
   END



   ;this handles mouse click events for zoom setting
   widget_info(event.top,find_by_uname='drawwin') : BEGIN


      IF event.press EQ 1 THEN BEGIN 
         
         NewCoordX=event.X>0<(WidgetData.ImageSizeX-1)
         NewCoordY=event.Y>0<(WidgetData.ImageSizeY-1)

         ;convert coordinates
         CoordX=NewCoordX/float(WidgetData.ImageSizeX)*WidgetData.nx
         CoordY=NewCoordY/float(WidgetData.ImageSizeY)*WidgetData.ny

         WidgetData.ZoomBoxCenterX=CoordX>WidgetData.ZoomBoxSizeX/2<(WidgetData.nx-WidgetData.ZoomBoxSizeX/2-1)
         WidgetData.ZoomBoxCenterY=CoordY>WidgetData.ZoomBoxSizeY/2<(WidgetData.ny-WidgetData.ZoomBoxSizeY/2-1)


         aia_zoomimage_fitline_setzoom,WidgetData,ZoomFactor=WidgetData.ZoomFactor

         widget_control,event.handler,set_uvalue=WidgetData
         aia_zoomimage_fitline_display,WidgetData,event.top
 
 
     ENDIF 

   END 


   ;this handles mouse click events for line fitting
   widget_info(event.top,find_by_uname='drawwin2') : BEGIN


      IF event.press EQ 1 THEN BEGIN 
 
         ;need to convert coordinate position now!
         PointX= (event.X-WidgetData.ZoomImageSizeX/2)/WidgetData.ZoomFactor+WidgetData.ZoomBoxCenterX
         PointY= (event.Y-WidgetData.ZoomImageSizeY/2)/WidgetData.ZoomFactor+WidgetData.ZoomBoxCenterY
         print,PointX,PointY
      
         WidgetData.ThisPointX=PointX
         WidgetData.ThisPointY=PointY
         
         WidgetData.FirstPoint=0

         widget_control,event.handler,set_uvalue=WidgetData
 
 
     ENDIF 
         

   END 


   ;this handles minimum color level selection
   widget_info(event.top,find_by_uname='mincolsel') : BEGIN

      WidgetData.ScaleMin=event.value
      widget_control,event.handler,set_uvalue=WidgetData
      aia_zoomimage_fitline_display,WidgetData,event.top
 
   END

   ;this handles maximum color level selection
   widget_info(event.top,find_by_uname='maxcolsel') : BEGIN

      WidgetData.ScaleMax=event.value
      widget_control,event.handler,set_uvalue=WidgetData
      aia_zoomimage_fitline_display,WidgetData,event.top
 
   END

   ;this handles the color scaling
   widget_info(event.top,find_by_uname='ColorScalingSelection') : BEGIN

      print,"Color scaling: "+(['Linear','Logarithmic','Quadratic','Square Root'])[event.index]
      widgetData.ColorScaling=(['Linear','Logarithmic','Quadratic','Square Root'])[event.index]
      widget_control,event.handler,set_uvalue=WidgetData
      aia_zoomimage_fitline_display,WidgetData,event.top
   END



   ELSE : BEGIN
      print,'?'
   ENDELSE



ENDCASE

;updates the text information box
textwidget=widget_info(event.top,find_by_uname='frameinfo') 
widget_control,textwidget,set_value=aia_zoomimage_fitline_outtext(WidgetData) 

;updates the Line Fitting information box
textwidget2=widget_info(event.top,find_by_uname='LineFitInfo') 
widget_control,textwidget2,set_value=aia_zoomimage_fitline_linefit_text(WidgetData)


END



;main program - initializes data and sets up widget hierarchy
PRO aia_zoomimage_fitline,image,WindowSize=WindowSize $
                 ,ImageSizeX=ImageSizeX,ImageSizeY=ImageSizeY $
                 ,ZoomImageSizeX=ZoomImageSizeX,ZoomImageSizeY=ZoomImageSizeY


ImageInfo=size(image)

;if image not a valid variable, uses sample dataset instead
IF n_elements(image) LT 4 || ImageInfo[0] NE 2 THEN BEGIN
   print,'Invalid input! Using test data instead.'
   image=randomn(seed,4096,4096)
   ImageInfo=size(image)
ENDIF

;color scaling initial value determined by the data
ScaleMin=float(min(image))
ScaleMax=float(max(image))

;window size is deafult for big screens
;on smaller screens 512 is more appropriate
WindowSize=fcheck(WindowSize,1024)

;fine tuning of image ize is possible
;rectangular windows are possible (but will stretch square images)
ImageSizeX=(fcheck(ImageSizeX,WindowSize))[0]
ImageSizeY=(fcheck(ImageSizeY,WindowSize))[0]
ZoomImageSizeX=(fcheck(ZoomImageSizeX,WindowSize))[0];<ImageSizeX
ZoomImageSizeY=(fcheck(ZoomImageSizeY,WindowSize))[0];<ImageSizeY


;size of the input image (e.g. 4096x4096 for AIA)
nx=ImageInfo[1]
ny=ImageInfo[2]

;intial location of the zoom box in the middle of the original image
;note that this is measured in the orginal image
ZoomBoxCenterX=nx/2
ZoomBoxCenterY=ny/2

;initial size of zoom box correspond to zoom factor 1x
ZoomBoxSizeX=ZoomImageSizeX
ZoomBoxSizeY=ZoomImageSizeY

;zoomfactor is measures how many image pixel are shown in a screen pixel
;in the right-side image
Zoomfactor=1.0

;create smaller and zoomed image from original data
SmallImage=congrid(image,ImageSizeX,ImageSizeY)
ZoomedImage=image[ZoomBoxCenterX-ZoomBoxSizeX/2:ZoomBoxCenterX+ZoomBoxSizeX/2-1, $
                  ZoomBoxCenterY-ZoomBoxSizeY/2:ZoomBoxCenterY+ZoomBoxSizeY/2-1]



;create the structure with the data that is used to keep track of the widget
WidgetData={FullImage:image, $
            SmallImage:SmallImage, $
            ZoomedImage:ZoomedImage, $
            nx:nx, $
            ny:ny, $
            ImageSizeX:ImageSizeX, $
            ImageSizeY:ImageSizeY, $
            ZoomImageSizeX:ZoomImageSizeX, $
            ZoomImageSizeY:ZoomImageSizeY, $
            ZoomFactor:ZoomFactor, $
            ZoomBoxCenterX:ZoomBoxCenterX, $
            ZoomBoxCenterY:ZoomBoxCenterY, $
            ZoomBoxSizeX:ZoomBoxSizeX, $
            ZoomBoxSizeY:ZoomBoxSizeY, $
            ScaleMin:ScaleMin, $
            ScaleMax:ScaleMax, $
            MovingZoom:0, $
            DataMin:min(image), $
            DataMax:max(image), $
            ColorScaling:'Linear', $
            FittingOn:0, $
            NumberOfFittingPoints:0, $
            FittingPointX:ptr_new(), $
            FittingPointY:ptr_new(), $
            FittingParameters:ptr_new(), $
            NewPoint:0, $
            FirstPoint:0, $
            ThisPointX:0.0, $
            ThisPointY:0.0, $
            DisplayFittingPoints:0, $
            DisplayFittedLine:0}

;widget hierarchy creation
;
    base=widget_base(title='AIA Image Viewer',/row)
    root=widget_base(base,/row,uvalue=mapstr,uname='root')
    
    menu1=widget_base(root,group_leader=root,/column,/frame)

    drawsurf1=widget_base(root,group_leader=root,/column)
    drawsurf1a=widget_base(drawsurf1,group_leader=root,/row)

    buttonm1=widget_base(menu1,group_leader=menu1,/row,/frame)

;end widget hierarchy creation


;buttons
;
    values=['Draw Image','Zoom 1x','Zoom 2x','Zoom 4x','Zoom 6x','Zoom 8x','Zoom 12x','Zoom 16x', $
            'Zoom 1/2x','Zoom 1/3x','Move Zoom Box','Center Zoom Box','Exit']
    uname='buttons'
    bgroup=cw_bgroup(buttonm1,values,/column,uname=uname) 
;end buttons


;coloring scale etc.
sellab=widget_base(buttonm1,group_leader=buttonm1,/column)

;color scaling ranges
mincol=cw_field(sellab,value=ScaleMin,uname='mincolsel',/floating,/return_events $
                   ,title='Min color',xsize=10)
maxcol=cw_field(sellab,value=ScaleMax,uname='maxcolsel',/floating,/return_events $
                   ,title='Max color',xsize=10)

ScaleOffset=cw_field(sellab,value=0.0,uname='ScaleOffset',/floating,/return_events $
                   ,title='Scaling Offset',xsize=10)

;droplist for color scaling
ColorScalingSelection=widget_droplist(sellab,value=['Linear','Logarithmic','Quadratic','Square Root'],title='Color Scaling',uname='ColorScalingSelection')

;text widget
;
    text=widget_text(menu1,value=aia_zoomimage_fitline_outtext(WidgetData) ,ysize=20 $
                    ,uname='frameinfo')
;end text widget

;second set of buttons for fit line functionality
    buttonm2=widget_base(menu1,group_leader=menu1,/row,/frame)
    values=['Fitting On/Off','Reset Points', 'Add Point', 'Remove Point','Show points','Show Line','Print Summary']
    uname='fitline_buttons'
    bgroup=cw_bgroup(buttonm2,values,/column,uname=uname) 


;Line Fitting text widget
;
    LineFittingText=widget_text(menu1,value=aia_zoomimage_fitline_linefit_text(WidgetData) ,ysize=12 $
                    ,uname='LineFitInfo')



;draw surfaces for small and zoomed image
;
drawwin=widget_draw(drawsurf1a,xsize=ImageSizeX,ysize=ImageSizeY,uname='drawwin')
drawwin2=widget_draw(drawsurf1a,xsize=ZoomImageSizeX,ysize=ZoomImageSizeY,uname='drawwin2')

;loads the data for the widget
;it's attached to the root widget such that every part of the hierarchy
;can access the data by using ev.top or ev.handler as the case may be
widget_control,root,set_uvalue=WidgetData

;create the widgets  
widget_control,base,/realize

;display the images for the first time
aia_zoomimage_fitline_display,WidgetData,root

;makes the widget respond to events
;these are handeled by aia_zoomimage_fitline_event
xmanager,'aia_zoomimage_fitline',root,/no_block

END



