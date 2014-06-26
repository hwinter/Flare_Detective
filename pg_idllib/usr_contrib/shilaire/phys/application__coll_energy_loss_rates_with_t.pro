; .r coll_energy_loss_rates_with_t


set_plot,'ps'

tit='Collisional energy loss rate for fully-ionized target T=0, 2, 5, 10, 50MK'
ytit='Loss rate [keV/s] for 10!U10!N cm!U-3!N, fully ionized medium'
xtit='electron energy [keV]'

e=FINDGEN(100)+1.

T=0
lr=collisional_energy_loss_rate(e)
PLOT,e,lr,/XLOG,/YLOG,tit=tit,xtit=xtit,ytit=ytit
T=1.	;[keV]
lr=collisional_energy_loss_rate(e,T=T)
OPLOT,e,lr,linestyle=1

T=5.	;[keV]
lr=collisional_energy_loss_rate(e,T=T)
OPLOT,e,lr,linestyle=2

T=0.5	;[keV]
lr=collisional_energy_loss_rate(e,T=T)
OPLOT,e,lr,linestyle=3

T=0.2	;[keV]
lr=collisional_energy_loss_rate(e,T=T)
OPLOT,e,lr,linestyle=4


device,/close
set_plot,'X'
END
