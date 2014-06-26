
sp1=forward_spectrum_thick(/EARTH,Eph=Eph,/LOUD,el={delta:4.,Eco:20})
sp2=forward_spectrum_thick(/EARTH,Eph=Eph,/LOUD,el={delta:4.,Eco:20},/HAUG,/BETHEBLOCH)

!P.MULTI=[0,1,2]
PLOT,Eph,sp1,/XLOG,/YLOG,xr=[1,100],tit='!7d!3=4, Eco=20'
label_plot,0.03,2,/LINE,'NR BH, NR Coulomb losses'
label_plot,0.03,1,/LINE,'Haug, Bethe-Bloch',style=2
OPLOT,Eph,sp2,linestyle=2
PLOT,Eph,sp2/sp1,/XLOG,xr=[1,100]
label_plot,0.03,1,'ratio Rel/NR'

sp1=forward_spectrum_thick(/EARTH,Eph=Eph,/LOUD,el={delta:4.,Eco:0.5})
sp2=forward_spectrum_thick(/EARTH,Eph=Eph,/LOUD,el={delta:4.,Eco:0.5},/HAUG,/BETHEBLOCH)

!P.MULTI=[0,1,2]
PLOT,Eph,sp1,/XLOG,/YLOG,xr=[1,100],tit='!7d!3=4, Eco=0.5'
label_plot,0.03,2,/LINE,'NR BH, NR Coulomb losses'
label_plot,0.03,1,/LINE,'Haug, Bethe-Bloch',style=2
OPLOT,Eph,sp2,linestyle=2
PLOT,Eph,sp2/sp1,/XLOG,xr=[1,100]
label_plot,0.03,1,'ratio Rel/NR'

sp1=forward_spectrum_thick(/EARTH,Eph=Eph,/LOUD,el={delta:4.,Eto:20})
sp2=forward_spectrum_thick(/EARTH,Eph=Eph,/LOUD,el={delta:4.,Eto:20},/HAUG,/BETHEBLOCH)

!P.MULTI=[0,1,2]
PLOT,Eph,sp1,/XLOG,/YLOG,xr=[1,100],tit='!7d!3=4, Eto=20'
label_plot,0.03,2,/LINE,'NR BH, NR Coulomb losses'
label_plot,0.03,1,/LINE,'Haug, Bethe-Bloch',style=2
OPLOT,Eph,sp2,linestyle=2
PLOT,Eph,sp2/sp1,/XLOG,xr=[1,100]
label_plot,0.03,1,'ratio Rel/NR'
