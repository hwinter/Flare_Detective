;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This is eventinfo2.pro for the shs project. Original location:
; ~/work/shs/eventinfo/eventinfo2.pro
; It contains basic informations about the events (time intervals
; etc.).
; Meant to be called from IDL with evinfo=eventinfo2()
; --> replacement for batch file because of file reading problem
; on saturn...
; This comment written 10-MAR-2003
; $Id:$
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;resolve_routine,'work/shs/eventinfo/eventinfo2',/is_function
FUNCTION eventinfo2

;all event information!!!

;created 17-NOV-2003
;last modified 19-NOV-2003 --> changed SET to SEP in time intervals
;                          --> changed 2003 to 2002 in (13)

;template time_intv: orbit time
;         maxtime: reference time, max flux at high energy
;         position: as given by HEDC
;         time_bin: for specral accumulation, 0: means take 1/2 RHESSI
;         transmitter: 1 if transmitter on in the orbit
;         n_sources: number of sources in 25-50 keV HEDC images
;         (visual inspection at HEDC zoom level...)
;         part_bck: particle backgorund
;         comment: other stuff goes here

temp_str={ev_info,n:0,time_intv:['',''],maxtime:'',position:[0,0],time_bin:2.,transmitter:0,n_sources:1,part_bck:0,comment:''}


evinfo=replicate(temp_str,33)

;0
evinfo[0].n=0
evinfo[0].time_intv='20-FEB-2002 '+['09:32','10:26']
evinfo[0].maxtime='20-FEB-2002 09:58'
evinfo[0].position=[910,339]
evinfo[0].n_sources=1
evinfo[0].time_bin=0.
evinfo[0].transmitter=1
evinfo[0].part_bck=0
evinfo[0].comment=''

;1
evinfo[1].n=1
evinfo[1].time_intv='20-FEB-2002 '+['15:45','16:55']
evinfo[1].maxtime='20-FEB-2002 16:23'
evinfo[1].position=[170,162]
evinfo[1].n_sources=1
evinfo[1].time_bin=0.
evinfo[1].transmitter=1
evinfo[1].part_bck=1
evinfo[1].comment=''


;2
evinfo[2].n=2
evinfo[2].time_intv='20-FEB-2002 '+['20:25','21:35']
evinfo[2].maxtime='20-FEB-2002 21:07'
evinfo[2].position=[172,-193]
evinfo[2].n_sources=1
evinfo[2].time_bin=0.
evinfo[2].transmitter=1
evinfo[2].part_bck=0
evinfo[2].comment=''

;3
evinfo[3].n=3
evinfo[3].time_intv='25-FEB-2002 '+['02:00','03:10']
evinfo[3].maxtime='25-FEB-2002 02:57'
evinfo[3].position=[854,-270]
evinfo[3].n_sources=1
evinfo[3].time_bin=0.
evinfo[3].transmitter=0
evinfo[3].part_bck=0
evinfo[3].comment=''

;4
evinfo[4].n=4
evinfo[4].time_intv='26-FEB-2002 '+['10:10','11:00']
evinfo[4].maxtime='26-FEB-2002 10:27'
evinfo[4].position=[927,-225]
evinfo[4].n_sources=1
evinfo[4].time_bin=0.
evinfo[4].transmitter=1
evinfo[4].part_bck=0
evinfo[4].comment=''

;5
evinfo[5].n=5
evinfo[5].time_intv=['27-FEB-2002 23:10','28-FEB-2002 00:10']
evinfo[5].maxtime='27-FEB-2002 23:59'
evinfo[5].position=[926,-321]
evinfo[5].n_sources=1
evinfo[5].time_bin=0.
evinfo[5].transmitter=0
evinfo[5].part_bck=0
evinfo[5].comment=''


;6
evinfo[6].n=6
evinfo[6].time_intv='15-MAR-2002 '+['21:55','22:48']
evinfo[6].maxtime='15-MAR-2002 22:23'
evinfo[6].position=[0,0]
evinfo[6].n_sources=0
evinfo[6].time_bin=0.
evinfo[6].transmitter=0
evinfo[6].part_bck=0
evinfo[6].comment='bad images in HEDC'

;7
evinfo[7].n=7
evinfo[7].time_intv='04-APR-2002 '+['10:15','11:00']
evinfo[7].maxtime='04-APR-2002 10:44'
evinfo[7].position=[-901,-346]
evinfo[7].n_sources=1
evinfo[7].time_bin=0.
evinfo[7].transmitter=0
evinfo[7].part_bck=0
evinfo[7].comment=''


;8
evinfo[8].n=8
evinfo[8].time_intv='04-APR-2002 '+['15:08','15:44']
evinfo[8].maxtime='04-APR-2002 15:30'
evinfo[8].position=[-906,-331]
evinfo[8].n_sources=1
evinfo[8].time_bin=0.
evinfo[8].transmitter=0
evinfo[8].part_bck=0
evinfo[8].comment=''

;9
evinfo[9].n=9
evinfo[9].time_intv='09-APR-2002 '+['12:22','13:08']
evinfo[9].maxtime='09-APR-2002 13:00'
evinfo[9].position=[-569,405]
evinfo[9].n_sources=1
evinfo[9].time_bin=0.
evinfo[9].transmitter=0
evinfo[9].part_bck=0
evinfo[9].comment='attention at end --> atmospheric absorption'

;10
evinfo[10].n=10
evinfo[10].time_intv='10-APR-2002 '+['12:24','13:14']
evinfo[10].maxtime='10-APR-2002 12:28'
evinfo[10].position=[304,-336]
evinfo[10].n_sources=2
evinfo[10].time_bin=0.
evinfo[10].transmitter=0
evinfo[10].part_bck=0
evinfo[10].comment=''

;11
evinfo[11].n=11
evinfo[11].time_intv='10-APR-2002 '+['18:33','19:38']
evinfo[11].maxtime='10-APR-2002 19:03'
evinfo[11].position=[-352,352]
evinfo[11].n_sources=1
evinfo[11].time_bin=0.
evinfo[11].transmitter=1
evinfo[11].part_bck=1
evinfo[11].comment='No good images in HEDC'


;12
evinfo[12].n=12
evinfo[12].time_intv='14-APR-2002 '+['03:02','04:00']
evinfo[12].maxtime='14-APR-2002 03:24'
evinfo[12].position=[-702,27]
evinfo[12].n_sources=1
evinfo[12].time_bin=0.
evinfo[12].transmitter=0
evinfo[12].part_bck=0
evinfo[12].comment=''

;13
evinfo[13].n=13
evinfo[13].time_intv=['14-APR-2002 23:49','15-APR-2002 00:52']
evinfo[13].maxtime='15-APR-2002 00:11'
evinfo[13].position=[784,383]
evinfo[13].n_sources=1
evinfo[13].time_bin=0.
evinfo[13].transmitter=1
evinfo[13].part_bck=0
evinfo[13].comment='some data gaps after the flare --> check bad packets? - NxMpanel in HEDC broken'

;14
evinfo[14].n=14
evinfo[14].time_intv='17-APR-2002 '+['00:03','01:04']
evinfo[14].maxtime='17-APR-2002 00:39'
evinfo[14].position=[912,-256]
evinfo[14].n_sources=1
evinfo[14].time_bin=0.
evinfo[14].transmitter=1
evinfo[14].part_bck=0
evinfo[14].comment=''

;15
evinfo[15].n=15
evinfo[15].time_intv='24-APR-2002 '+['21:43','22:34']
evinfo[15].maxtime='24-APR-2002 21:55'
evinfo[15].position=[0,0]
evinfo[15].n_sources=1
evinfo[15].time_bin=0.
evinfo[15].transmitter=0
evinfo[15].part_bck=0
evinfo[15].comment='no HEDC data product --> try again later'

;16
evinfo[16].n=16
evinfo[16].time_intv='01-JUN-2002 '+['03:25','04:15']
evinfo[16].maxtime='01-JUN-2002 03:53'
evinfo[16].position=[-423,-303]
evinfo[16].n_sources=2
evinfo[16].time_bin=0.
evinfo[16].transmitter=1
evinfo[16].part_bck=0
evinfo[16].comment=''

;17
evinfo[17].n=17
evinfo[17].time_intv='06-JUN-2002 '+['03:17','03:45']
evinfo[17].maxtime='06-JUN-2002 03:33'
evinfo[17].position=[908,-281]
evinfo[17].n_sources=1
evinfo[17].time_bin=0.
evinfo[17].transmitter=0
evinfo[17].part_bck=1
evinfo[17].comment=''


;18
evinfo[18].n=18
evinfo[18].time_intv='11-JUN-2002 '+['14:12','14:45']
evinfo[18].maxtime='11-JUN-2002 14:18'
evinfo[18].position=[-791,281]
evinfo[18].n_sources=1
evinfo[18].time_bin=0.
evinfo[18].transmitter=0
evinfo[18].part_bck=0
evinfo[18].comment=''

;19
evinfo[19].n=19
evinfo[19].time_intv='16-AUG-2002 '+['21:30','22:30']
evinfo[19].maxtime='16-AUG-2002 22:12'
evinfo[19].position=[-346,-303]
evinfo[19].n_sources=1
evinfo[19].time_bin=0.
evinfo[19].transmitter=0
evinfo[19].part_bck=0
evinfo[19].comment=''

;20
evinfo[20].n=20
evinfo[20].time_intv='17-AUG-2002 '+['00:46','01:30']
evinfo[20].maxtime='17-AUG-2002 01:05'
evinfo[20].position=[0,0]
evinfo[20].n_sources=1
evinfo[20].time_bin=0.
evinfo[20].transmitter=0
evinfo[20].part_bck=0
evinfo[20].comment='NO HEDC event --> try again later'


;21
evinfo[21].n=21
evinfo[21].time_intv='22-AUG-2002 '+['01:15','02:25']
evinfo[21].maxtime='22-AUG-2002 01:52'
evinfo[21].position=[816,-272]
evinfo[21].n_sources=2
evinfo[21].time_bin=0.
evinfo[21].transmitter=0
evinfo[21].part_bck=0
evinfo[21].comment='REAR decimation during flare!'

;22
evinfo[22].n=22
evinfo[22].time_intv='23-AUG-2002 '+['11:45','12:15']
evinfo[22].maxtime='23-AUG-2002 11:59'
evinfo[22].position=[927,-168]
evinfo[22].n_sources=1
evinfo[22].time_bin=0.
evinfo[22].transmitter=0
evinfo[22].part_bck=0
evinfo[22].comment='REAR decimation + attenuator=3 at the very beginning --> maybe should force att=1 for srm file! Loop-like structure seen in lower energy.'


;23
evinfo[23].n=23
evinfo[23].time_intv='24-AUG-2002 '+['04:40','05:50']
evinfo[23].maxtime='24-AUG-2002 05:43'
evinfo[23].position=[-775,-141]
evinfo[23].n_sources=1
evinfo[23].time_bin=0.
evinfo[23].transmitter=0
evinfo[23].part_bck=1
evinfo[23].comment=''


;24
evinfo[24].n=-1
;event has SAA in the middle of flare --> rejected (bad choice by dbuser)

;25
evinfo[25].n=25
evinfo[25].time_intv='27-AUG-2002 '+['12:20','12:40']
evinfo[25].maxtime='27-AUG-2002 12:28'
evinfo[25].position=[849,-370]
evinfo[25].n_sources=1
evinfo[25].time_bin=0.
evinfo[25].transmitter=0
evinfo[25].part_bck=0
evinfo[25].comment=''


;26
evinfo[26].n=26
evinfo[26].time_intv='29-SEP-2002 '+['06:13','07:06']
evinfo[26].maxtime='29-SEP-2002 06:36'
evinfo[26].position=[-291,88]
evinfo[26].n_sources=1
evinfo[26].time_bin=0.
evinfo[26].transmitter=0
evinfo[26].part_bck=0
evinfo[26].comment=''

;27
evinfo[27].n=27
evinfo[27].time_intv='29-SEP-2002 '+['14:22','15:20']
evinfo[27].maxtime='29-SEP-2002 14:47'
evinfo[27].position=[-216,81]
evinfo[27].n_sources=1
evinfo[27].time_bin=0.
evinfo[27].transmitter=1
evinfo[27].part_bck=1
evinfo[27].comment='Rear decimation changes during flare.'


;28
evinfo[28].n=28
evinfo[28].time_intv='30-SEP-2002 '+['01:28','02:36']
evinfo[28].maxtime='30-SEP-2002 01:50'
evinfo[28].position=[-148,126]
evinfo[28].n_sources=1
evinfo[28].time_bin=0.
evinfo[28].transmitter=0
evinfo[28].part_bck=0
evinfo[28].comment=''


;29
evinfo[29].n=29
evinfo[29].time_intv='04-OCT-2002 '+['00:12','01:12']
evinfo[29].maxtime='04-OCT-2002 00:41'
evinfo[29].position=[88,-419]
evinfo[29].n_sources=1
evinfo[29].time_bin=0.
evinfo[29].transmitter=0
evinfo[29].part_bck=0
evinfo[29].comment='ghost images?'

;30
evinfo[30].n=30
evinfo[30].time_intv='09-NOV-2002 '+['12:23','13:36']
evinfo[30].maxtime='09-NOV-2002 13:17'
evinfo[30].position=[438,-263]
evinfo[30].n_sources=2
evinfo[30].time_bin=0.
evinfo[30].transmitter=0
evinfo[30].part_bck=1
evinfo[30].comment='Rear decimation'

;31
evinfo[31].n=31
evinfo[31].time_intv='10-NOV-2002 '+['03:02','03:42']
evinfo[31].maxtime='10-NOV-2002 03:12'
evinfo[31].position=[612,-239]
evinfo[31].n_sources=2
evinfo[31].time_bin=0.
evinfo[31].transmitter=0
evinfo[31].part_bck=0
evinfo[31].comment=''

;32
evinfo[32].n=32
evinfo[32].time_intv='14-NOV-2002 '+['22:20','22:55']
evinfo[32].maxtime='14-NOV-2002 22:25'
evinfo[32].position=[-840,-272]
evinfo[32].n_sources=2
evinfo[32].time_bin=0.
evinfo[32].transmitter=0
evinfo[32].part_bck=0
evinfo[32].comment='Rear decimation, changes during flare!'

return,evinfo
END
