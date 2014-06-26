;flares with (EphTO - EphNTH+TH) > 4:
g1=	[1d-5,	2.4d-6,	2d-7,	2d-6,	1.5d-6,	7.4d-6,	1.6d-5,	1.5d-5	]
EphTO1=	[17.26,19.97,	17.5,	18.4,	15.67,	15.44,	16.37,	16.5	]

g2=	[7.3d-6,1.4d-5,	4.2d-6,	4.9d-6,	3.8d-6,	3d-7,	2.1d-6,	1d-6	]	
EphTO2=	[10.37,	16.03,	13.45,	12.14,	10.46,	10.11,	15.48,	10.91	]

g3=	[1.8d-5,3.1d-5,	3.2d-6,	1.4d-6,	2.7d-6,	1d-6,	2d-7,	3d-7,	2d-7,	7d-7,	6d-7,	7d-7,	8d-7,	5d-6	]		
EphTO3=	[15.06,	15.83,	16.12,	12.26,	11.83,	10.81,	8.96,	10.46,	9.5,	11.8,	9.53,	9.95,	9.5,	16.4	]

;only most reliable stuff (EphTO >4 keV to the right of Eph_th_nth)
PLOT,g1,EphTO1,psym=1,/XLOG
;adding stuff a bit less clear (>2 keV)
PLOT,[g1,g2],[EphTO1,EphTO2],psym=1,/XLOG
;adding some still less clearcut cases (but where I could still see a kink, hopefully not created by the model...)
PLOT,[g1,g2,g3],[EphTO1,EphTO2,EphTO3],psym=1,/XLOG
