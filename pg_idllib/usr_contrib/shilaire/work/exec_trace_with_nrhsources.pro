pro exec_trace_with_nrhsources,map,movieAll	;	movie164,movie2366,movie327,movie4105,movie432,movieAll

; stats for sept 8th,1999 event
xrange=[-1000,-500]
yrange=[-120,380]
sourcefiles=['mylepus/nrh2_1640_s70_19990908_121459c33_c.fts','mylepus/nrh2_2366_s70_19990908_121459c83_c.fts', $
'mylepus/nrh2_3270_s70_19990908_121459c84_c.fts','mylepus/nrh2_4105_s70_19990908_121459c72_c.fts', $
'mylepus/nrh2_4320_s70_19990908_121459c85_c.fts']
nbrsources=[1,1,2,2,2]

;plot_nrh_sources_on_images,map,sourcefiles(0),nbrsources(0),xrange,yrange,movie164
;plot_nrh_sources_on_images,map,sourcefiles(1),nbrsources(1),xrange,yrange,movie2366
;plot_nrh_sources_on_images,map,sourcefiles(2),nbrsources(2),xrange,yrange,movie327
;plot_nrh_sources_on_images,map,sourcefiles(3),nbrsources(3),xrange,yrange,movie4105
;plot_nrh_sources_on_images,map,sourcefiles(4),nbrsources(4),xrange,yrange,movie432

plot_nrh_sources_on_images,map,sourcefiles,nbrsources,xrange,yrange,movieAll
end
