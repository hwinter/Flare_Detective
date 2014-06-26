; Pascal Saint-Hilaire Dec 2001
;	psainth@hotmail.com OR shilaire@astro.phys.ethz.ch


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
movie(256,256,*)=!D.table_size-5
end
;******************************************************************************************

;******************************************************************************************
pro dessine_rectangle,x1,x2,x3,x4,col=col,style=style

end
;******************************************************************************************

;******************************************************************************************
pro get_values,c,V=V,L=L,W=W,X0=X0,b=b,X1,X2,X3,X4,t0
; X1 is input, the other X2,X3,X4 output

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
t0=(c*t1 + A2)/c

;First set:
if set eq 1 then begin
t2=A1*(B1-sqrt(B2-B3))
t3=A1*(C1-sqrt(C2-C3))
t4=A1*(D1-sqrt(D2-D3))
end

;Second set:
if set eq 2 then begin
t2=A1*(B1-sqrt(B2-B3))
t3=A1*(C1-sqrt(C2-C3))
t4=A1*(D1+sqrt(D2-D3))
end

;Third set:
if set eq 3 then begin
t2=A1*(B1+sqrt(B2-B3))
t3=A1*(C1-sqrt(C2-C3))
t4=A1*(D1-sqrt(D2-D3))
end

;Fourth set:
if set eq 4 then begin
t2=A1*(B1+sqrt(B2-B3))
t3=A1*(C1-sqrt(C2-C3))
t4=A1*(D1+sqrt(D2-D3))
end

;Fifth set:
if set eq 5 then begin
t2=A1*(B1-sqrt(B2-B3))
t3=A1*(C1+sqrt(C2-C3))
t4=A1*(D1-sqrt(D2-D3))
end

;Sixth set:
if set eq 6 then begin
t2=A1*(B1-sqrt(B2-B3))
t3=A1*(C1+sqrt(C2-C3))
t4=A1*(D1+sqrt(D2-D3))
end

;Seventh set:
if set eq 7 then begin
t2=A1*(B1+sqrt(B2-B3))
t3=A1*(C1+sqrt(C2-C3))
t4=A1*(D1-sqrt(D2-D3))
end

;Eighth set:
if set eq 8 then begin
t2=A1*(B1+sqrt(B2-B3))
t3=A1*(C1+sqrt(C2-C3))
t4=A1*(D1+sqrt(D2-D3))
end

X2=X0-L+V*t2
X3=X0+V*t3
X4=X0-L+V*t4
end
;******************************************************************************************************

;******************************************************************************************************
pro rubberband_effect,movie,V=V,L=L,W=W,Xr=Xr,b=b,nbrframes=nbrframes,NOLORENTZ=NOLORENTZ,NOREAL=NOREAL

c=1.
if not exist(V) then V=0.7
gamma=1/sqrt(1-V^2/c^2)
if not exist(L) then L=1.5
L_over_gamma=L/gamma
if exist(NOLORENTZ) then L_over_gamma=L  ; If /NOLORENTZ, means LORENTZ ...
					 ; ... contraction is not to be considered.
if not exist(W) then W=1.0
if not exist(Xr) then Xr=[-10.0,10.0]
if not exist(b) then b=5.0
if not exist(nbrframes) then nbrframes=100

initialize_stuff,movie,nbrframes

devb=512*b/(Xr(1)-Xr(0)) + 256 			; device b
devbW=512*(b+W)/(Xr(1)-Xr(0)) + 256 		; device b+W
X1=Xr(0)
for i=0,nbrframes-1 do begin
get_values,c,V=V,L=L_over_gamma,W=W,X0=Xr(0),b=b,X1,X2,X3,X4,t0
devX1=(X1-Xr(0))*512/(Xr(1)-Xr(0))
devX2=(X2-Xr(0))*512/(Xr(1)-Xr(0))
devX3=(X3-Xr(0))*512/(Xr(1)-Xr(0))
devX4=(X4-Xr(0))*512/(Xr(1)-Xr(0))
tv,movie(*,*,i)
xyouts,237,240,/dev,charsi=1.0,'Observer',color=!D.table_size-6
str='Speed (in units of c): '+string(V)
xyouts,10,180,/dev,charsi=1.0,str,color=!D.table_size-3
str='Lorentz factor : '+string(gamma)
xyouts,10,170,/dev,charsi=1.0,str,color=!D.table_size-3
str='Elongation (nearest side)='+string((X1-X2)/L)
xyouts,280,175,/dev,charsi=1.0,str,color=!D.table_size-1

xyouts,10,120,/dev,charsi=1.0,'Original rectangle : ',color=!D.table_size-2
xyouts,280,120,/dev,charsi=1.0,'Same rectangle after Lorentz contraction : ',color=!D.table_size-2

img=tvrd()

dessine_un_symbole,img,type=5,256,256,size=10,value=!D.table_size-6
if devX1 ge 0 and devX1 lt 512 then dessine_un_symbole,img,devX1,devb,type=5,size=3,value=!D.table_size-3		;draw X1
if devX2 ge 0 and devX2 lt 512 then dessine_un_symbole,img,devX2,devb,type=5,size=3,value=!D.table_size-3
if devX3 ge 0 and devX3 lt 512 then dessine_un_symbole,img,devX3,devbW,type=5,size=3,value=!D.table_size-3
if devX4 ge 0 and devX4 lt 512 then dessine_un_symbole,img,devX4,devbW,type=5,size=3,value=!D.table_size-3

dessine_un_symbole,img,type=5,120-512*L/(Xr(1)-Xr(0)),30+512*W/(Xr(1)-Xr(0)),size=5,value=!D.table_size-2
dessine_un_symbole,img,type=5,120,30+512*W/(Xr(1)-Xr(0)),size=5,value=!D.table_size-2
dessine_un_symbole,img,type=5,120-512*L/(Xr(1)-Xr(0)),30,size=5,value=!D.table_size-2
dessine_un_symbole,img,type=5,120,30,size=5,value=!D.table_size-2

dessine_un_symbole,img,type=5,390-512*L_over_gamma/(Xr(1)-Xr(0)),30+512*W/(Xr(1)-Xr(0)),size=5,value=!D.table_size-2
dessine_un_symbole,img,type=5,390,30+512*W/(Xr(1)-Xr(0)),size=5,value=!D.table_size-2
dessine_un_symbole,img,type=5,390-512*L_over_gamma/(Xr(1)-Xr(0)),30,size=5,value=!D.table_size-2
dessine_un_symbole,img,type=5,390,30,size=5,value=!D.table_size-2


; if /NOREAL, then don't show the real position of object (at t0 each time) with purple crosses
;if not exist(NOREAL) then begin
;	devrealX1=Xr(0)+V*t0
;	devrealX2=Xr(0)-L_over_gamma+V*t0
;	devrealX3=devrealX1
;	devrealX4=devrealX2
;	if devrealX1 ge 0 and devrealX1 lt 512 then dessine_un_symbole,img,devrealX1,devb,type=5,size=3,value=!D.table_size-2
;	if devrealX2 ge 0 and devrealX2 lt 512 then dessine_un_symbole,img,devrealX2,devb,type=5,size=3,value=!D.table_size-2
;	if devrealX3 ge 0 and devrealX3 lt 512 then dessine_un_symbole,img,devrealX3,devbW,type=5,size=3,value=!D.table_size-2
;	if devrealX4 ge 0 and devrealX4 lt 512 then dessine_un_symbole,img,devrealX4,devbW,type=5,size=3,value=!D.table_size-2
;		          end
		
tv,img
movie(*,*,i)=img
X1=X1+(Xr(1)-Xr(0))/nbrframes
			end
end
;******************************************************************************************




