; this procedure has for purpose to impose a 256-color private map,
; which will display a varying number of color tables, and a few
; constant colors (whose RGB vectors can be given by optional 
; input names (red, orange,...)
; BLACK and WHITE are always indices 0 and 255


pro myct3,ct=ct

if not exist(ct) then ct=[1,5] 	;default is BLUE/WHITE and STD-GAMMA II

;!!! impose use of 256 colors... -> !D.table_size=256

nb_ct=n_elements(ct)	; shouldn't be higher than 4-6
nb_ind=240/nb_ct	; number of color indices for each color table
for i=0,nb_ct-1 do loadct,ct(i),bottom=1+nb_ind*i,ncolors=nb_ind,/SILENT
tvlct,r,g,b,/get	; get the colors so far...

; now add the special colors...
; color indices between 242 and 244 (incl.) are (so far) unused		

r(245)=255 & g(245)=226 & b(245)=180 ; BEIGE
r(246)=9 & g(246)=158 & b(246)=255 ; LIGHTBLUE
r(247)=50 & g(247)=50 & b(247)=50 ; DARKGRAY
r(248)=175 & g(248)=175 & b(248)=175 ;LIGHTGRAY
r(249)=255 & g(249)=0 & b(249)=0 ; RED
r(250)=255 & g(250)=90 & b(250)=9 ; ORANGE
r(251)=255 & g(251)=255 & b(251)=0 ; YELLOW
r(252)=0 & g(252)=255 & b(252)=0 ; GREEN
r(253)=0 & g(253)=0 & b(253)=255 ; BLUE
r(254)=255 & g(254)=0 & b(254)=255 ; VIOLET
r(255)=255 & g(255)=255 & b(255)=255 ; WHITE

tvlct,r,g,b

print,".............. now using PSH's color table (myct3.pro) !!!"
end

;should later use tvscl,img,top=240 instead of plain ol' tv,img ...

