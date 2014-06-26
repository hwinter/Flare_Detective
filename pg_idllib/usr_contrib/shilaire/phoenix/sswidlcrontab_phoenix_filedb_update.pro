
today=systim2anytim()	; in anytim double units
;-----------------------------------------------------------------------
;yesterday...
day=anytim(today,/date)-86400D*2.
PRINT,'NOW PROCESSING: '+anytim(day,/ECS,/date)
timex=anytim(day,/EX)
ymd=[timex[6],timex[5],timex[4]]
dir=GETENV('PHOENIX_DATA_ARCHIVE')+'/'+int2str(ymd[0],4)+'/'+int2str(ymd[1],2)+'/'+int2str(ymd[2],2)
list=phoenix_filedb_newlist_get(dir)

idbfile=GETENV('PHOENIX_FILEDB_DIR')+'/phoenix_filedb_i_'+int2str(ymd[0],4)+int2str(ymd[1],2)+'.fits'
pdbfile=GETENV('PHOENIX_FILEDB_DIR')+'/phoenix_filedb_p_'+int2str(ymd[0],4)+int2str(ymd[1],2)+'.fits'
phoenix_filedb_update, list, idbfile, NEW=1-FILE_EXIST(idbfile)
phoenix_filedb_update, list, pdbfile ,/POL, NEW=1-FILE_EXIST(pdbfile)
;-----------------------------------------------------------------------
;one month ago... (in case of interruptions due to crashes, delayed data, and other problems...)
day=anytim(today,/date)-86400D*30.
PRINT,'NOW PROCESSING: '+anytim(day,/ECS,/date)
timex=anytim(day,/EX)
ymd=[timex[6],timex[5],timex[4]]
dir=GETENV('PHOENIX_DATA_ARCHIVE')+'/'+int2str(ymd[0],4)+'/'+int2str(ymd[1],2)+'/'+int2str(ymd[2],2)
list=phoenix_filedb_newlist_get(dir)

idbfile=GETENV('PHOENIX_FILEDB_DIR')+'/phoenix_filedb_i_'+int2str(ymd[0],4)+int2str(ymd[1],2)+'.fits'
pdbfile=GETENV('PHOENIX_FILEDB_DIR')+'/phoenix_filedb_p_'+int2str(ymd[0],4)+int2str(ymd[1],2)+'.fits'
phoenix_filedb_update, list, idbfile , NEW=1-FILE_EXIST(idbfile)
phoenix_filedb_update, list, pdbfile ,/POL, NEW=1-FILE_EXIST(pdbfile)
;-----------------------------------------------------------------------
PRINT,'sswidlcrontab_phoenix_filedb_update.pro-OK'
END
;=====================================================================================================================================================================================
