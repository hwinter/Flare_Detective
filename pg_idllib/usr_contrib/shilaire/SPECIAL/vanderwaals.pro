

;PRO vanderwaals

R=8.314D
a=.555D					; H2O
b=.0000305D				; H2O
n=1.D

window,0,xs=768,ys=512

V=(1D +DINDGEN(300))/200000.D
T=648.5D
p=n*R*T/(V-n*b) - a*(n/V)^2
plot,1000D*V,p/100000D,xtitle='V [l]',ytitle='p [bar]',xr=[0.,1.5],yr=[0,500]

T=288.D
p=n*R*T/(V-n*b) - a*(n/V)^2
oplot,1000D*V,p/100000D,linestyle=1


T=700.D
p=n*R*T/(V-n*b) - a*(n/V)^2
oplot,1000D*V,p/100000D,linestyle=2


T=388.D
p=n*R*T/(V-n*b) - a*(n/V)^2
oplot,1000D*V,p/100000D,linestyle=3


T=273.D
p=n*R*T/(V-n*b) - a*(n/V)^2
oplot,1000D*V,p/100000D,linestyle=4





window,1,xs=768,ys=512

V=(1D +DINDGEN(3000))/30000.D
T=288.D
p=n*R*T/(V-n*b) - a*(n/V)^2
plot,1000D*V,p/100000D,xtitle='V [l]',ytitle='p [bar]',xr=[0.,100],yr=[0,2]

END





