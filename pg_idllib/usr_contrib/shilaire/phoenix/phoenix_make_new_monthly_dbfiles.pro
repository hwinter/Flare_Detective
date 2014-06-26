PRO phoenix_make_new_monthly_dbfiles
	start_ym=[2002,7]
	end_ym=[2002,7]	
	;start_ym=[1998,6]
	;end_ym=[2003,10]	

	cur_ym=start_ym
	goon=1
	WHILE goon DO BEGIN
		dirlist=find_all_dir('/ftp/pub/rag/phoenix-2/observations/'+int2str(cur_ym[0],4)+'/'+int2str(cur_ym[1],2)+'/')
		list=phoenix_filedb_newlist_get(dirlist)
		phoenix_filedb_update, list, '/global/hercules/data1/rapp_idl/TEMP/dbase/phoenix_filedb_i_'+int2str(cur_ym[0],4)+int2str(cur_ym[1],2)+'.fits',/NEW
		phoenix_filedb_update, list, '/global/hercules/data1/rapp_idl/TEMP/dbase/phoenix_filedb_p_'+int2str(cur_ym[0],4)+int2str(cur_ym[1],2)+'.fits',/NEW,/POL
			
		cur_ym[1]=cur_ym[1]+1
		IF cur_ym[1] GE 13 THEN cur_ym=[cur_ym[0]+1,1]
		IF anytim([0,0,0,0,1,cur_ym[1],cur_ym[0]]) GT anytim([0,0,0,0,1,end_ym[1],end_ym[0]])THEN goon=0
	ENDWHILE
END

