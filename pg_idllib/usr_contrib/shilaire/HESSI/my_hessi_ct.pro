; by PSH , early 2001

; MODIFIED 29-apr-01 : added optional color outputs


; OPTIONAL OUTPUT : LIGHTBLUE to WHITE...
; ex:  	1) my_hessi_ct
;	2) MY_hessi_ct,colors

PRO my_hessi_ct,ct=ct,colors

if not exist(ct) then ct=41 else ct=42

N=!D.table_size

color_file = loc_file(path=hessi_data_paths(), 'colors_hessi.tbl')
loadct, file=color_file,41,ncolors=N-7
;one must use hessi software's object->plot methods in order for
; the zeros of images to correspond to black.

TVLCT,r,g,b,/GET
r(N-7)=160 & g(N-7)=160 & b(N-7)=160	; LIGHTGRAY
r(N-6)=80 & g(N-6)=80 & b(N-6)=80	; DARKGRAY
r(N-5)=255 & g(N-5)=226 & b(N-5)=180	; BEIGE
r(N-4)=0 & g(N-4)=255 & b(N-4)=0	; LIGHTGREEN
r(N-3)=43 & g(N-3)=132 & b(N-3)=49	; DARKGREEN
r(N-2)=0 & g(N-2)=255 & b(N-2)=255	; CYAN
r(N-1)=255 & g(N-1)=255 & b(N-1)=255	; WHITE

TVLCT,r,g,b


LIGHTBLUE = 	1
DARKBLUE = 	(N-8)/5.319
VIOLET =	(N-8)/3.125
BLACK = 	0
DARKRED = 	(N-8)/1.689
LIGHTRED =	(N-8)/1.421
ORANGE =	(N-8)/1.269
YELLOW =	(N-8)/1.147
WHITE = 	N-1
BEIGE =		N-5
LIGHTGREEN = 	N-4
DARKGREEN =	N-3
CYAN =		N-2
LIGHTGRAY =	N-7
DARKGRAY =	N-6

colors=[DARKRED,LIGHTRED,ORANGE,YELLOW,LIGHTGREEN,DARKGREEN,CYAN,  $
	LIGHTBLUE,DARKBLUE,VIOLET,BEIGE,LIGHTGRAY,DARKGRAY,BLACK,WHITE]
END
