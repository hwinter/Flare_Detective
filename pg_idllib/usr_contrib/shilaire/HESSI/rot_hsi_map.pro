	
	
FUNCTION rot_hsi_map,hsimap,alpha
	rhsimap=hsimap
	rhsimap=rot_map(hsimap,alpha,center=[0,0])
	rhsimap.roll_angle=0
	RETURN,rhsimap
END
