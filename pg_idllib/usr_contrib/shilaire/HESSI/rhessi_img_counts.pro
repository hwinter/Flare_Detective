;EXAMPLE:
;	PRINT,rhessi_img_counts(imo)
;	PRINT,rhessi_img_counts(info,ctrl)

FUNCTION rhessi_img_counts, infoimo, ctrl
	IF datatype(infoimo) EQ 'OBJ' THEN BEGIN
		info=imo->get(/info) 
		ctrl=imo->get(/control)
	ENDIF ELSE info=infoimo
	n_event = info.binned_n_event
	text = hsi_coll_segment_list(ctrl.det_index_mask, REFORM(ctrl.a2d_index_mask, 9, 3), ctrl.front_segment, ctrl.rear_segment, colls_used=colls_used)
	RETURN,TOTAL(n_event[where(colls_used),0])
END
