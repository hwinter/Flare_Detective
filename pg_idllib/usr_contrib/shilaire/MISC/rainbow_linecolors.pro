;       0 - black
;	1 - red
;	2 - orange
;	3 - yellow
;	4 - green
;	5 - blue
;	6 - violet
;       7 - white

PRO rainbow_linecolors
	tvlct, r,g,b, /get
	r[0:7] = [0, 255, 255, 255,   0,   0, 255, 255] 
	g[0:7] = [0,   0, 128, 255, 255, 128,   0, 255]
	b[0:7] = [0,   0,   0,   0,   0, 255, 255, 255]
	tvlct, r,g,b
END
