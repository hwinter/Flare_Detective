PRO testbleien_doplot,imfile=imfile,bastitle=bastitle,logfile=logfile


IF NOT exist(imfile) THEN imfile='/global/saturn/data/www/staff/pgrigis/testbleien/test_connection.png'

IF NOT exist(logfile) THEN logfile='/global/pandora/home/pgrigis/testconnection/testlog.txt'


IF file_exist(logfile) THEN BEGIN 

    data=read_ascii(logfile)

    time=data.field1[0,*]
    ping=data.field1[1,*]

    ntime=n_elements(time)
    pastlen=289L
    IF ntime GT pastlen THEN BEGIN 
       time=time[ntime-pastlen : ntime-1]
       ping=ping[ntime-pastlen : ntime-1]
    ENDIF


    set_plot,'Z'
    loadct,0
    !p.color=0
    !p.background=255

    thistime=systime()
    IF NOT exist(bastitle) THEN $
      title='PING to pavo , created '+thistime $
    ELSE $
      title=bastitle+',created '+thistime

    utplot,time-time[0]+3600,ping,time[0],yrange=[-1,11] $
          ,psym=-6,/xstyle,/ystyle,title=title


    im=tvrd()
    write_png,imfile,im


ENDIF


end
