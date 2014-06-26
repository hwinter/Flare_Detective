
PRO psh_test,imo,coll=coll

IF NOT EXIST(coll) THEN coll=7	;i.e. 8
IF NOT KEYWORD_SET(LOUD) THEN LOUD=0

;detres=[2.3,3.9,6.9,11.9,20.7,35.9,62.1,107.,186.]
detres=[2.26,3.92,6.79,11.76,20.36,35.27,61.08,105.8,183.2]

imo->set,image_alg='back projection'
imo->set_no_screen_output

imo->set,image_dim=128,pixel_size=1.
det_index=BYTARR(9)
det_index[coll]=1B
imo->set,det_index=det_index,sim_det_index=det_index

res_incr=detres[coll]/4.
n_incr=FIX(1410./res_incr)
PRINT,'N_increments: '+strn(n_incr)+' of '+strn(res_incr)+'"'
A=FLTARR(n_incr)

FOR i=0,n_incr-1 DO BEGIN
;choose FOV:
	xyoffset=[410.-i*res_incr,10.]
	imo->set,sim_xyoffset=xyoffset, xyoffset=xyoffset
;get peakvalue
	imo->plot
	tmp=imo->getdata()
	peakvalue=MAX(tmp)
;get counts
	tmp=imo->get(/binned_n_event)
	counts=tmp[coll,0]
;get gridtran
	cbe=imo->GetData( CLASS_NAME = 'HSI_Calib_eventlist' )
	;P_m=MEAN((*cbe[coll,0]).GRIDTRAN)
	P_m=mean( (*cbe[coll,0]).gridtran*(1.+(*cbe[coll,0]).modamp*cos((*cbe[coll,0]).phase_map_ctr)))
	PRINT,'Gridtran: '+strn(P_m)+' +/- '+strn(STDDEV((*cbe[coll,0]).GRIDTRAN))
;determine A
	A[i]=peakvalue*P_m/counts
ENDFOR ;i

text='Subcollimator '+strn(coll+1)
PLOT,410-FINDGEN(n_incr)*res_incr,A,xtit='Map center, X coordinate (arcsecs)',ytit='Relative amplitude A',tit=text;,psym=-7

END


