PRO hedc_dbmod_movies__go

	hedc_dbmod_movies3,IMSP=2,['2002/02/13','2002/07/01'],'/global/auriga/home/shilaire/TEMP',ELLIG=[10,10000,100],/NOCRASH
	hedc_dbmod_movies3,IMSP=2,['2002/07/01','2003/01/01'],'/global/auriga/home/shilaire/TEMP',ELLIG=[10,10000,100],/NOCRASH
	hedc_dbmod_movies3,IMSP=2,['2003/01/01','2003/07/01'],'/global/auriga/home/shilaire/TEMP',ELLIG=[10,10000,100],/NOCRASH
	hedc_dbmod_movies3,IMSP=2,['2003/07/01','2004/01/01'],'/global/auriga/home/shilaire/TEMP',ELLIG=[10,10000,100],/NOCRASH
	hedc_dbmod_movies3,IMSP=2,['2004/01/01','2004/07/01'],'/global/auriga/home/shilaire/TEMP',ELLIG=[10,10000,100],/NOCRASH
	hedc_dbmod_movies3,IMSP=2,['2004/07/01','2005/01/01'],'/global/auriga/home/shilaire/TEMP',ELLIG=[10,10000,100],/NOCRASH
	hedc_dbmod_movies3,IMSP=2,['2005/01/01','2005/03/09'],'/global/auriga/home/shilaire/TEMP',ELLIG=[10,10000,100],/NOCRASH


;	hedc_dbmod_movies3,IMSP=2,['2003/02/22','2003/06/12'],'/global/saturn/home/shilaire/TEMP',ELLIG=[10,10000,100],/NOCRASH
;	hedc_dbmod_movies3,IMSP=2,['2004/01/02','2004/07/01'],'/global/saturn/home/shilaire/TEMP',ELLIG=[10,10000,100],/NOCRASH
;	hedc_dbmod_movies3,IMSP=2,['2003/07/01','2003/10/22'],'/global/saturn/home/shilaire/TEMP',ELLIG=[10,10000,100],/NOCRASH
;	hedc_dbmod_movies3,IMSP=2,['2004/07/12','2004/07/22'],'/global/saturn/home/shilaire/TEMP',ELLIG=[10,10000,100],/NOCRASH
;	hedc_dbmod_movies3,IMSP=2,['2002/02/20','2002/03/15'],'/global/saturn/home/shilaire/TEMP',ELLIG=[10,10000,100],/NOCRASH
;
;	hedc_dbmod_movies2, '2005/01/01 '+['00:10','00:30'],/EIT,ELLIG=[1,1000,100],/NOCRASH,/REPLACE
;
;	hedc_dbmod_movies, ['2004/07/19','2005/01/01'],/EIT,ELLIG=[1,1000,100],/NOCRASH,/REPLACE
;	hedc_dbmod_movies, ['2004/07/19','2005/01/01'],ELLIG=[1,1000,100],/NOCRASH
;	
;	hedc_dbmod_movies, ['2004/04/08','2004/05/08'],/EIT,ELLIG=[1,1000,100],/NOCRASH,/REPLACE
;	hedc_dbmod_movies, ['2004/04/08','2004/05/08'],ELLIG=[1,1000,100],/NOCRASH
;	
;
;	eventcode='HYS311030955'	
;	hedc_dbmod_movies, eventcode,/EIT,ELLIG=1,/NOCRASH,/REPLACE
;	hedc_dbmod_movies, eventcode,ELLIG=1,/NOCRASH
;
;
;
;	gev=rapp_get_gev(['2003/10/19','2003/10/20'])
;	i=3
;	tmp=time2file(gev[i].PEAK_TIME)
;	eventcode='HYS'+STRMID(tmp,3,5)+STRMID(tmp,9,4)
;	hedc_dbmod_movies, eventcode,/EIT,ELLIG=1,/NOCRASH,/REPLACE
;	hedc_dbmod_movies, eventcode,ELLIG=1,/NOCRASH
;	
;	gev=rapp_get_gev(['2003/11/02','2003/11/03'])
;	i=4
;	tmp=time2file(gev[i].PEAK_TIME)
;	eventcode='HYS'+STRMID(tmp,3,5)+STRMID(tmp,9,4)
;	hedc_dbmod_movies, eventcode,/EIT,ELLIG=1,/NOCRASH,/REPLACE
;	hedc_dbmod_movies, eventcode,ELLIG=1,/NOCRASH
;
;	gev=rapp_get_gev(['2003/11/03','2003/11/04'])
;	i=5
;	tmp=time2file(gev[i].PEAK_TIME)
;	eventcode='HYS'+STRMID(tmp,3,5)+STRMID(tmp,9,4)
;	hedc_dbmod_movies, eventcode,/EIT,ELLIG=1,/NOCRASH,/REPLACE
;	hedc_dbmod_movies, eventcode,ELLIG=1,/NOCRASH
;
;	gev=rapp_get_gev(['2003/11/04','2003/11/05'])
;	i=6
;	tmp=time2file(gev[i].PEAK_TIME)
;	eventcode='HYS'+STRMID(tmp,3,5)+STRMID(tmp,9,4)
;	hedc_dbmod_movies, eventcode,/EIT,ELLIG=1,/NOCRASH,/REPLACE
;	hedc_dbmod_movies, eventcode,ELLIG=1,/NOCRASH
END

