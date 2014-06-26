PRO aia_imbrowser_showimage,imagefile,evtop=evtop,evhandler=evhandler


read_sdo,imagefile,index,data,/uncomp_delete
;coord=aia_iminspect(data)
 
widget_control,evhandler,get_uvalue=WidgetData

d2=congrid(data,1024,1024)

;gets the ID of the widgets for the small and zoomed image
drawwidget=widget_info(evtop,find_by_uname='drawwin')
drawwidget2=widget_info(evtop,find_by_uname='drawwin2')

;get the ID of the direct graphic window
widget_control,drawwidget,get_value=winmap
widget_control,drawwidget2,get_value=winmap2
wset,winmap
tvscl,alog(d2>0+10)

;zx=2048
;zy=2048
cutout=data[(widgetdata.zx-512)>0:(widgetdata.zx+511)<4095,(widgetdata.zy-512)>0:(widgetdata.zy+511)<4095]

wset,winmap2
tvscl,alog(cutout>0+10)


END 

PRO aia_imbrowser_event,event

;widget_control,event.handler,get_uvalue=WidgetData

CASE event.ID OF 


   widget_info(event.top,find_by_uname='drawwin') : BEGIN

;      print,'Pressed!'


      IF event.press EQ 1 THEN BEGIN 
         

         widget_control,event.handler,get_uvalue=WidgetData

         print,event.x,event.y
         WidgetData.zx=event.x*4
         WidgetData.zy=event.y*4
         
         widget_control,event.handler,set_uvalue=WidgetData

         IF ptr_valid(widgetdata.allfiles) THEN BEGIN 
         
            imagefile=WidgetData.imagefile

            print,'Current selected file: '+imagefile

            aia_imbrowser_showimage,imagefile,evhandler=event.handler,evtop=event.top

      ENDIF 

;         aia_imbrowser_showimage,imagefile,evtop=evtop,evhandler=evhandler


         ;NewCoordX=event.X>0<(WidgetData.ImageSizeX-1)
         ;NewCoordY=event.Y>0<(WidgetData.ImageSizeY-1)

         ;convert coordinates
         ;CoordX=NewCoordX/float(WidgetData.ImageSizeX)*WidgetData.nx
         ;CoordY=NewCoordY/float(WidgetData.ImageSizeY)*WidgetData.ny

         ;WidgetData.ZoomBoxCenterX=CoordX>WidgetData.ZoomBoxSizeX/2<(WidgetData.nx-WidgetData.ZoomBoxSizeX/2-1)
         ;WidgetData.ZoomBoxCenterY=CoordY>WidgetData.ZoomBoxSizeY/2<(WidgetData.ny-WidgetData.ZoomBoxSizeY/2-1)


         ;aia_zoomimage_setzoom,WidgetData,ZoomFactor=WidgetData.ZoomFactor

         ;widget_control,event.handler,set_uvalue=WidgetData
         ;aia_zoomimage_display,WidgetData,event.top
 
 
     ENDIF 

         

   END 


   widget_info(event.top,find_by_uname='files') : BEGIN
      
      widget_control,event.handler,get_uvalue=WidgetData
      IF ptr_valid(widgetdata.allfiles) THEN BEGIN 
         
         imagefile=(*WidgetData.allfiles)[event.index]

         print,'Current selcted file: '+imagefile

         widgetData.imagefile=imagefile
         aia_imbrowser_showimage,imagefile,evhandler=event.handler,evtop=event.top
         widget_control,event.handler,set_uvalue=WidgetData

         textwidget=widget_info(event.top,find_by_uname='info')
         widget_control,textwidget,set_value=imagefile

      ENDIF 
   END 

   widget_info(event.top,find_by_uname='hour') : BEGIN

      widget_control,event.handler,get_uvalue=WidgetData
      hourWidget=widget_info(event.top,find_by_uname='hour')
      thisHour=(*widgetData.hourlist)[event.index]
      WidgetData.currentHour=thisHour
      widgetData.imagefile=''    

      ;print,WidgetData.currentYear+'/'+WidgetData.currentMonth+'/'+WidgetData.currentDay+' '+thishour

      path=WidgetData.path+path_sep()+ $
           WidgetData.currentYear+path_sep()+ $
           WidgetData.currentMonth+path_sep()+ $
           WidgetData.currentDay+path_sep()+ $
           WidgetData.currentHour+path_sep()

      pattern=path+'AIA*_'+WidgetDAta.CurrentWave+'.fits'


      ;print,pattern
;      stop


      filesWidget=widget_info(event.top,find_by_uname='files')
      allfiles=file_search(pattern)
      widgetData.allfiles=ptr_new(allfiles)
      widget_control,filesWidget,set_value=file_basename(allfiles)


      widget_control,event.handler,set_uvalue=widgetData

   END 

   widget_info(event.top,find_by_uname='day') : BEGIN

      widget_control,event.handler,get_uvalue=WidgetData
      dayWidget=widget_info(event.top,find_by_uname='day')
      hourWidget=widget_info(event.top,find_by_uname='hour')
      filesWidget=widget_info(event.top,find_by_uname='files')
 
      thisday=(*widgetData.daylist)[event.index]
      thisyear=widgetData.currentYear
      thismonth=widgetData.currentMonth

      hourList=file_search(widgetData.path+path_sep()+ $
                                  thisyear+path_sep()+ $
                                 thismonth+path_sep()+ $
                                   thisday+path_sep()+'*')
      hourlist=file_basename(hourlist)

      hourWidget=widget_info(event.top,find_by_uname='hour')
      widget_control,hourWidget,set_value=hourlist
      widget_control,filesWidget,set_value=['','','']
      widgetData.imagefile=''    
      
      widgetData.currentDay=thisday
      widgetData.currentHour=''

      widgetData.HourList=ptr_new(hourList)
      widget_control,event.handler,set_uvalue=widgetData

   END 


    
   widget_info(event.top,find_by_uname='month') : BEGIN

      widget_control,event.handler,get_uvalue=WidgetData
      monthWidget=widget_info(event.top,find_by_uname='month')
      dayWidget=widget_info(event.top,find_by_uname='day')
      hourWidget=widget_info(event.top,find_by_uname='hour')
      filesWidget=widget_info(event.top,find_by_uname='files')
     
      thismonth=(*widgetData.monthlist)[event.index]
      thisyear=widgetData.currentYear

      daylist=file_search(widgetData.path+path_sep()+thisyear+path_sep()+thismonth+path_sep()+'*')
      daylist=file_basename(daylist)

      dayWidget=widget_info(event.top,find_by_uname='day')
      widget_control,dayWidget,set_value=daylist
      widget_control,hourWidget,set_value=['','','']
      widget_control,filesWidget,set_value=['','','']
      widgetData.imagefile=''    
      

      widgetData.currentMonth=thismonth
      widgetData.currentDay=''
      widgetData.currentHour=''

      widgetData.dayList=ptr_new(daylist)
      widget_control,event.handler,set_uvalue=widgetData

   END 


 widget_info(event.top,find_by_uname='year') : BEGIN
    

    widget_control,event.handler,get_uvalue=WidgetData
    yearWidget=widget_info(event.top,find_by_uname='year')
    monthWidget=widget_info(event.top,find_by_uname='month')
    dayWidget=widget_info(event.top,find_by_uname='day')
    hourWidget=widget_info(event.top,find_by_uname='hour')
    filesWidget=widget_info(event.top,find_by_uname='files')
 



    ;widget_control,event.top,get_uvalue=widgetData
    thisyear=(*widgetData.yearlist)[event.index]

      
    monthlist=file_search(widgetData.path+path_sep()+thisyear+path_sep()+'*')
    monthlist=file_basename(monthlist)

    widget_control,monthWidget,set_value=monthlist
    widget_control,dayWidget,set_value=['','','']
    widget_control,hourWidget,set_value=['','','']
    widget_control,filesWidget,set_value=['','','']
    widgetData.imagefile=''    
 
    widgetData.currentYear=thisyear
    widgetData.currentMonth=''
    widgetData.currentDay=''
    widgetData.currentHour=''
    
    widgetData.monthList=ptr_new(monthlist)
    widget_control,event.handler,set_uvalue=widgetData

   END 

   widget_info(event.top,find_by_uname='wavesel') : BEGIN

      IF event.select EQ 1 THEN BEGIN 

         widget_control,event.handler,get_uvalue=WidgetData
         thiswave=WidgetData.wavelist[event.value]
         ;print,thiswave
         WidgetDAta.CurrentWave=thiswave
         widget_control,event.handler,set_uvalue=widgetData



         path=WidgetData.path+path_sep()+ $
              WidgetData.currentYear+path_sep()+ $
              WidgetData.currentMonth+path_sep()+ $
              WidgetData.currentDay+path_sep()+ $
              WidgetData.currentHour+path_sep()

         pattern=path+'AIA*_'+WidgetDAta.CurrentWave+'.fits'


         filesWidget=widget_info(event.top,find_by_uname='files')
         allfiles=file_search(pattern)
         widgetData.allfiles=ptr_new(allfiles)
         widget_control,filesWidget,set_value=file_basename(allfiles)

         IF widgetData.imagefile NE '' THEN BEGIN 
         
         ;find time of old image
            oldimage=widgetData.imagefile
            timstampold=anytim(file2time(strmid(oldimage,24,15,/reverse_offset)))
;         ptim,timstampold

            timstampall=anytim(file2time(strmid(allfiles,24,15,/reverse_offset)))

            dummy=min(abs(timstampall-timstampold),indmin)

            filesWidget=widget_info(event.top,find_by_uname='files')
            widget_control,fileswidget,set_list_select=indmin[0]
            widgetData.imagefile=allfiles[indmin[0]]

;         print,allfiles[indmin[0]]
;         ptim,timstampall[indmin]
;


            textwidget=widget_info(event.top,find_by_uname='info')
            widget_control,textwidget,set_value=widgetData.imagefile

         
;         IF widgetData.imagefile NE '' THEN BEGIN 
            aia_imbrowser_showimage,widgetData.imagefile,evhandler=event.handler,evtop=event.top
         ENDIF 
         


         widget_control,event.handler,set_uvalue=widgetData


;         print,pattern


;         print,'Button ID: '+string(event.value)+string(event.select)
      ENDIF 
         
   END 


ENDCASE 

END


PRO aia_imbrowser,path=path

path=fcheck(path,'/data/SDO/AIA/level1/')


wavelist=['0094','0131','0171','0193','0211','0304','0335','1600','1700','4500']

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
nx=4096;ImageInfo[1]
ny=4096;ImageInfo[2]

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

;color scaling initial value determined by the data
ScaleMin=1;float(min(image))
ScaleMax=1e4;float(max(image))


;create smaller and zoomed image from original data
;SmallImage=congrid(image,ImageSizeX,ImageSizeY)
;ZoomedImage=image[ZoomBoxCenterX-ZoomBoxSizeX/2:ZoomBoxCenterX+ZoomBoxSizeX/2-1, $
;                  ZoomBoxCenterY-ZoomBoxSizeY/2:ZoomBoxCenterY+ZoomBoxSizeY/2-1]

zx=2048
zy=2048

;create the structure with the data that is used to keep track of the widget
WidgetData={path:'', $
            imagefile:'', $
            yearList:ptr_new(), $
            monthList:ptr_new(), $
            dayList:ptr_new(), $
            hourList:ptr_new(), $
            currentYear:'', $
            currentMonth:'', $
            currentDay:'', $
            currentHour:'', $
            currentwave:'0171',$
            wavelist:wavelist, $
            allfiles:ptr_new(), $
            nx:nx, $
            ny:ny, $
            zx:zx, $
            zy:zy, $
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
            ScaleMax:ScaleMax $
            }



;widget hierarchy creation
;
base=widget_base(title='AIA Image Browser',/row)
root=widget_base(base,/column,uvalue=WidgetData,uname='root')
    
broot=widget_base(root,/row)
croot=widget_base(broot,/column)
menu1=widget_base(croot,group_leader=root,/row,/frame,xpad=3,uname='menu1')
menu2=widget_base(croot,group_leader=root,/row,/frame,xpad=3,uname='menu2')
menu3=widget_base(croot,group_leader=root,/row,/frame,xpad=3,uname='menu3')

yearlist=file_search(path+'*')
;print,yearlist
IF yearlist[0] EQ '' THEN BEGIN 
   print,'No files found in '+path
   return
ENDIF 

yearlist=file_basename(yearlist)

WidgetData.path=path
WidgetData.yearlist=ptr_new(yearlist)


vsize=52
hsize=10

;labelYear=widget_text(menu0,value='year',xsize=hsize,ysize=1,editable=0)
;labelMonth=widget_label(menu0,value='month')

byear=widget_base(menu1,group_leader=root,/column,/frame)
lyear=widget_label(byear,value='year')
year=widget_list(byear,value=yearlist,xsize=4,ysize=vsize,uname='year')

bmonth=widget_base(menu1,group_leader=root,/column,/frame)
lmonth=widget_label(bmonth,value='month')
month=widget_list(bmonth,value=['','',''],xsize=2,ysize=vsize,uname='month')

bday=widget_base(menu1,group_leader=root,/column,/frame)
lday=widget_label(bday,value='day')
day=widget_list(bday,value=['','',''],xsize=2,ysize=vsize,uname='day')

bhour=widget_base(menu1,group_leader=root,/column,/frame)
lhour=widget_label(bhour,value='hour')
hour=widget_list(bhour,value=['','',''],xsize=4,ysize=vsize,uname='hour')

bfiles=widget_base(menu1,group_leader=root,/column,/frame)
lfiles=widget_label(bfiles,value='files')
files=widget_list(bfiles,value=['','',''],xsize=32,ysize=vsize,uname='files')


bwave=widget_base(menu2,group_leader=root,/column,/frame)
lwave=widget_label(bwave,value='wavelength')
wavelength=[' 94','131','171','193','211','304','335','1600','1700','4500']
wavesel=cw_bgroup(bwave,wavelength,column=5,set_value=2,/exclusive,uname='wavesel')

infotext=widget_text(menu3,value=' ',uname='info',xsize=74)


;window size is deafult for big screens
;on smaller screens 512 is more appropriate
WindowSize=fcheck(WindowSize,1024)

;fine tuning of image ize is possible
;rectangular windows are possible (but will stretch square images)
ImageSizeX=(fcheck(ImageSizeX,WindowSize))[0]
ImageSizeY=(fcheck(ImageSizeY,WindowSize))[0]
ZoomImageSizeX=(fcheck(ZoomImageSizeX,WindowSize))[0];<ImageSizeX
ZoomImageSizeY=(fcheck(ZoomImageSizeY,WindowSize))[0];<ImageSizeY

;drawsurf1=widget_base(root,group_leader=root,/column)
drawsurf1a=widget_base(broot,group_leader=root,/row)
drawwin=widget_draw(drawsurf1a,xsize=ImageSizeX,ysize=ImageSizeY,uname='drawwin',/button_events)
drawwin2=widget_draw(drawsurf1a,xsize=ZoomImageSizeX,ysize=ZoomImageSizeY,uname='drawwin2');,/button_events)




widget_control,root,set_uvalue=WidgetData

;drawsurf1=widget_base(root,group_leader=root,/column)
;drawsurf1a=widget_base(drawsurf1,group_leader=root,/row)
;buttonm1=widget_base(menu1,group_leader=menu1,/row,/frame)

;create the widgets  
widget_control,base,/realize

;makes the widget respond to events
xmanager,'aia_imbrowser',root,/no_block


END 

