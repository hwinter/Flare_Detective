;+
;ps -eo user,pid,ppid,pgid,sid,sgid,tty,tpgid,rss,size,vsize,start_time,utime,stime,etime,cmd --sort user
;;
;;EXAMPLE:
;;	data=psh_sys_usage()
;;	PRINT,psh_sys_usage()
;;
;;	data=psh_sys_usage(addcmd='|grep shilaire')
;;	data=psh_sys_usage(user='shilaire')
;;
;-

FUNCTION psh_sys_usage, addcmd=addcmd, user=user
	cmdlist=['user','pid','ppid','pgid','%mem','%cpu','rss','size','vsize','cmd']	;'cmd' MUST BE LAST!!!!

	cmdline='ps -eo '+cmdlist[0]
	FOR i=1,N_ELEMENTS(cmdlist)-1 DO cmdline=cmdline+','+cmdlist[i]	
	cmdline=cmdline+' --sort user'
	IF KEYWORD_SET(addcmd) THEN cmdline=cmdline+addcmd
	SPAWN,cmdline,res,err	
	res=res[1:*]

	data=STRARR(N_ELEMENTS(cmdlist),N_ELEMENTS(res))
	FOR j=0L,N_ELEMENTS(res)-1 DO BEGIN
		tmp=STRSPLIT(res[j],/EXTRACT)
		FOR i=0L,N_ELEMENTS(cmdlist)-1 DO BEGIN
			data[i,j]=tmp[i]
		ENDFOR
	ENDFOR

	;;remove processes which have same rss, and same cmdline argument (multi-threading)
	good_ss=-1
	FOR i=0L,N_ELEMENTS(data[0,*])-1 DO BEGIN
		ss=WHERE( (data[WHERE(cmdlist EQ 'rss'),*] EQ (data[WHERE(cmdlist EQ 'rss'),i])[0]) AND (data[WHERE(cmdlist EQ 'cmd'),*] EQ (data[WHERE(cmdlist EQ 'cmd'),i])[0]) AND (data[WHERE(cmdlist EQ 'pgid'),*] EQ (data[WHERE(cmdlist EQ 'pgid'),i])[0]) )   
		IF N_ELEMENTS(ss) LE 1 THEN BEGIN
			IF good_ss[0] EQ -1 THEN good_ss=i ELSE good_ss=[good_ss,i]
		ENDIF ELSE BEGIN
			;;keep only the one with the lowest pid...
			relevant_pid_ss=WHERE(data[(WHERE(cmdlist EQ 'pgid'))[0],ss] EQ (data[(WHERE(cmdlist EQ 'pgid'))[0],i])[0])
			pid_list=data[(WHERE(cmdlist EQ 'pid'))[0],ss[relevant_pid_ss]]
			pid_list=pid_list[SORT(pid_list)]
			IF (data[(WHERE(cmdlist EQ 'pid'))[0],i])[0] EQ pid_list[0] THEN BEGIN
				IF good_ss[0] EQ -1 THEN good_ss=i ELSE good_ss=[good_ss,i]
			ENDIF
		ENDELSE
	ENDFOR
	IF good_ss[0] NE -1 THEN data=data[*,good_ss] ELSE MESSAGE,'PROBLEMS!'
	
	IF KEYWORD_SET(user) THEN BEGIN
		good_ss=-1
		FOR i=0L,N_ELEMENTS(data[0,*])-1 DO BEGIN
			IF data[(WHERE(cmdlist EQ 'user'))[0],i] EQ user THEN BEGIN
				IF good_ss[0] EQ -1 THEN good_ss=i ELSE good_ss=[good_ss,i]
			ENDIF
		ENDFOR
		IF good_ss[0] NE -1 THEN data=data[*,good_ss] ELSE BEGIN
			PRINT,'No such user!'
			RETURN,-1
		ENDELSE
	ENDIF
	

	PRINT,'%MEM: '+strn(TOTAL(FLOAT(data[(WHERE(cmdlist EQ '%mem'))[0],*])))
	PRINT,'%CPU: '+strn(TOTAL(FLOAT(data[(WHERE(cmdlist EQ '%cpu'))[0],*]))/4)
	PRINT,'RSS: '+strn(TOTAL(LONG(data[(WHERE(cmdlist EQ 'rss'))[0],*]))/2d^10)+' MB'
	PRINT,'SIZE: '+strn(TOTAL(LONG(data[(WHERE(cmdlist EQ 'size'))[0],*]))/2d^10)+' MB'
	PRINT,'VSIZE: '+strn(TOTAL(LONG(data[(WHERE(cmdlist EQ 'vsize'))[0],*]))/2d^10)+' MB'

	RETURN,data
END

