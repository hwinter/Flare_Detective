; Pascal Saint-Hilaire 2001/07/20
; improved version of RUBBERBAND_EFFECT.pro 
;	psainth@hotmail.com OR shilaire@astro.phys.ethz.ch

; I'm strongly against using the /NOLORENTZ keyword...

;V=spacecraft speed, in units of c, the speed of light
;L=spacecraft length =1.0 (every lengths are normalized to this one)
;W=spacecraft width		(recommend 0.66*L, the default)
;Xr=xrange of screen	(recommend -10 to 10, the default)
;b=impact parameter   (must be > 0)

; /craft keyword : can be used only if /noreal is not set.
;	It'll center the story on the real spacecraft (instead of apparent one):
;	this is important for range Xr, and makes the spacecraft look like it's
;	going at constant speed.

;******************************************************************************************
;
;		------------> V
;
;
;		X4-----X3
;		  \ 	 \	W
;		   \	  \
;		    X2-----X1
;
;			L/gamma
;
;
;******************************************************************************************
pro initialize_stuff,movie,nbrframes
window,0,xsize=512,ysize=512	;/pixmap
movie=bytarr(512,512,nbrframes)
myct2
end
;******************************************************************************************

;******************************************************************************************
pro dessine_quadri,x1,x2,x3,x4,y1,y2,y3,y4,color=color,thick=thick
if not exist(color) then color=250
plots,[x1,x3],[y1,y3],color=color,thick=thick,/dev
plots,[x3,x4],[y3,y4],color=color,thick=thick,/dev
plots,[x4,x2],[y4,y2],color=color,thick=thick,/dev
plots,[x2,x1],[y2,y1],color=color,thick=thick,/dev
end
;******************************************************************************************

;******************************************************************************************
pro get_values,c,V=V,L=L,W=W,X0=X0,b=b,X1,X2,X3,X4
; X1 is input, the other X2,X3,X4 are outputs

set=1

t1=(X1-X0)/V

;Solutions for a certain t1:
A1=1/(2*(c^2-V^2))
A2=sqrt(b^2+(V*t1+X0)^2)

B1=-2*L*V + 2*c^2*t1 + 2*V*X0 + 2*c*A2
B2=(2*L*V - 2*c^2*t1 - 2*V*X0 - 2*c*A2)^2
B3=4*(c^2-V^2)*(-L^2 + c^2*t1^2 + V^2*t1^2 + 2*L*X0 + 2*V*t1*X0 + 2*c*t1*A2)

C1=2*c^2*t1 + 2*V*X0 + 2*c*A2
C2=(-2*c^2*t1 - 2*V*X0 - 2*c*A2)^2
C3=4*(c^2-V^2)*(-2*b*W - W^2 + c^2*t1^2 + V^2*t1^2 + 2*V*t1*X0 + 2*c*t1*A2)

D1=-2*L*V + 2*c^2*t1 + 2*V*X0 +2*c*A2
D2=(2*L*V -2*c^2*t1 - 2*V*X0 -2*c*A2 )^2
D3=4*(c^2-V^2)*(-L^2 -2*b*W - W^2 + c^2*t1^2 + V^2*t1^2 + 2*L*X0 +2*V*t1*X0 +2*c*t1*A2 )


;For all sets :
t0=(c*t1 + A2)/c	; t0 is the moment when all light rays are received at observer

;First set:
if set eq 1 then begin
t2=A1*(B1-sqrt(B2-B3))
t3=A1*(C1-sqrt(C2-C3))
t4=A1*(D1-sqrt(D2-D3))
end
; view first version of routine for other sets


;the others are easily derived:
X2=X0-L+V*t2
X3=X0+V*t3
X4=X0-L+V*t4
end
;******************************************************************************************************

;******************************************************************************************************
pro rubberband_effect2,movie,V=V,W=W,Xr=Xr,b=b, $
	nbrframes=nbrframes,NOLORENTZ=NOLORENTZ,NOREAL=NOREAL,$
	thick=thick, craft=craft

if exist(noreal) AND exist(craft) then begin
		print,'Cannot set simultaneoulsy /noreal and /craft keywords !!!'
		return
endif

c=1.
if not exist(V) then V=0.7
gamma=1/sqrt(1-V^2/c^2)
if not exist(L) then L=1.0	; the base length unit should be the spacecraft length in its rest frame
L_over_gamma=L/gamma
if exist(NOLORENTZ) then L_over_gamma=L  ; If /NOLORENTZ, means LORENTZ ...
					 ; ... contraction is not to be considered.
if not exist(W) then W=0.66*L
if not exist(Xr) then Xr=[-10.*L,10.*L]
if not exist(b) then b=5.*L
if not exist(nbrframes) then nbrframes=100

initialize_stuff,movie,nbrframes

devb=512*b/(Xr(1)-Xr(0)) + 256 			; device b
devbW=512*(b+W)/(Xr(1)-Xr(0)) + 256 		; device b+W
if not exist(craft) then X1=Xr(0) else begin
										Xcraft=Xr(0)
										X1=gamma^2 * ( Xcraft-(V/c)*SQRT(Xcraft^2 + (b/gamma)^2) )
									   endelse
for i=0,nbrframes-1 do begin
	get_values,c,V=V,L=L_over_gamma,W=W,X0=Xr(0),b=b,X1,X2,X3,X4
	devX1=(X1-Xr(0))*512/(Xr(1)-Xr(0))
	devX2=(X2-Xr(0))*512/(Xr(1)-Xr(0))
	devX3=(X3-Xr(0))*512/(Xr(1)-Xr(0))
	devX4=(X4-Xr(0))*512/(Xr(1)-Xr(0))
	
	tv,movie(*,*,i)	; clears the whole scenery!
	
	xyouts,237,240,/dev,charsi=1.0,'Observer',color=!D.table_size-1
	str='Speed (in units of c): '+string(V)
	xyouts,10,180,/dev,charsi=1.0,str,color=!D.table_size-3
	str='Lorentz factor : '+string(gamma)
	xyouts,10,170,/dev,charsi=1.0,str,color=!D.table_size-3
	str='Apparent elongation (nearest side)= '+STRN((X1-X2)/L)
	xyouts,260,175,/dev,charsi=1.0,str,color=!D.table_size-1

	plots,[0,511],[197,197],color=100,thick=6,/dev
	plots,[0,511],[160,160],color=100,thick=3,/dev

	xyouts,70,130,/dev,charsi=1.0,'Original rectangle, in its rest frame : ',color=!D.table_size-6
	xyouts,70,90,/dev,charsi=1.0,"In the Observer's frame (i.e. Lorentz contracted) :",color=!D.table_size-2
	xyouts,70,50,/dev,charsi=1.0,"As seen by the Observer :",color=!D.table_size-1
	
	;draw observer
	plots,[256],[256],psym=7,/dev,color=!D.table_size-1
	
	;draw apparent spacecraft in action
	dessine_quadri,devX1,devX2,devX3,devX4,devb,devb,devbW,devbW,color=255

	;draw S/C in its rest frame
	dessine_quadri,420,420-512*L/(Xr(1)-Xr(0)),420,420-512*L/(Xr(1)-Xr(0)),$
		120+512*W/(Xr(1)-Xr(0)),120+512*W/(Xr(1)-Xr(0)),120,120,color=!D.table_size-6
	
	;draw S/C in the observer's frame
	dessine_quadri,420,420-512*L_over_gamma/(Xr(1)-Xr(0)),420,420-512*L_over_gamma/(Xr(1)-Xr(0)), $
		80+512*W/(Xr(1)-Xr(0)),80+512*W/(Xr(1)-Xr(0)),80,80,color=254

	;draw S/C as seen by Observer
	dessine_quadri,420,420-(devX1-devX2),420-(devX1-devX3),420-(devX1-devX4), $
		40,40,40+(devbW-devb),40+(devbW-devb),color=255


; if /NOREAL, then don't show the real position of spacecraft with purple contours
	if not exist(NOREAL) then begin
		devrealX1=(X1+(V/c)*SQRT(X1^2+b^2)-Xr(0))*512/(Xr(1)-Xr(0))
		devrealX2=devrealX1 - L_over_gamma*512/(Xr(1)-Xr(0))
		devrealX3=devrealX1
		devrealX4=devrealX2
		dessine_quadri,devrealX1,devrealX2,devrealX3,devrealX4,$
			devb,devb,devbW,devbW, color=!D.table_size-2
	endif
		
	movie(*,*,i)=TVRD()
	if not exist(craft) then X1=X1+(Xr(1)-Xr(0))/nbrframes else begin
														Xcraft=Xcraft+(Xr(1)-Xr(0))/nbrframes
														X1=gamma^2 * ( Xcraft-(V/c)*SQRT(Xcraft^2 + (b/gamma)^2) )  															
															endelse
endfor
end
;******************************************************************************************




