;+
; NAME:
;
; pg_xrt_filterratio_display
;
; PURPOSE:
;
; Display interactively filterratios for XRT
;
; CATEGORY:
;
; XRT utils (useful for ob
;
; CALLING SEQUENCE:
;
;
;
; INPUTS:
;
;
;
; OPTIONAL INPUTS:
;
;
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
; MODIFICATION HISTORY:
;
;-


PRO pg_xrt_filterratio_display_draw,info

plot,info.temp,info.resp[*,info.self1]/info.resp[*,info.self2],/xlog,yrange=[0,2],psym=-6

END

;
;Widget event handler
;
PRO pg_xrt_filterratio_display_event,ev

widget_control,ev.handler,get_uvalue=info



CASE ev.ID OF 
    
   widget_info(ev.top,find_by_uname='filter1') : BEGIN
     
      print,'Filter 1:'+strtrim(info.filtername[ev.index],2)

      drawwidget=widget_info(ev.top,find_by_uname='drawim')
      widget_control,drawwidget,get_value=winmap
      wset,winmap

      info.self1=ev.index
      widget_control,ev.handler,set_uvalue=info

      pg_xrt_filterratio_display_draw,info
 

   END
   widget_info(ev.top,find_by_uname='filter2') : BEGIN
      print,'Filter 2:'+strtrim(info.filtername[ev.index],2)
 
      drawwidget=widget_info(ev.top,find_by_uname='drawim')
      widget_control,drawwidget,get_value=winmap
      wset,winmap


      info.self2=ev.index
      widget_control,ev.handler,set_uvalue=info

      pg_xrt_filterratio_display_draw,info
 
   END
ENDCASE
END

 

PRO pg_xrt_filterratio_display,resp=resp

;compute filter responses form XRT

IF n_elements(resp) EQ 0 THEN result = CALC_XRT_TEMP_RESP() ELSE result=resp

info={filtername:result.channel_name,self1:0,self2:0,temp:10^result[0].temp[0:result[0].length-1] $
     ,resp:result.temp_resp[0:result[0].length-1],yt:textoidl(result[0].temp_resp_units)}

;widget hierarchy creation
;

    base=widget_base(title='XRT filter ratio plotter',/row)
    root=widget_base(base,/row,uvalue=info,uname='root')
    
    menu1=widget_base(root,group_leader=root,/row,/frame)
 
    drawsurf1=widget_base(root,group_leader=root,/column)
    drawim =widget_draw(drawsurf1,xsize=1024,ysize=768,uname='drawim')
 

    sellab=widget_base(menu1,group_leader=menu1,/column)
    sellab2=widget_base(menu1,group_leader=menu1,/column)
    chn=info.filtername
    labelim=widget_label(sellab,value='Filter 1')
    selim=widget_list(sellab,value=chn,ysize=10,uname='filter1')
    labelim2=widget_label(sellab2,value='Filter 2')
    selim2=widget_list(sellab2,value=chn,ysize=10,uname='filter2')

;    buttonm1=widget_base(menu1,group_leader=menu1,/row,/frame)
;end widget hierarchy creation

    widget_control,base,/realize
    xmanager,'pg_xrt_filterratio_display',root,/no_block

   
END








