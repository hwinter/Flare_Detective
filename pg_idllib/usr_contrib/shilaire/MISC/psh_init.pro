; PSH, 2001/06/11 
; pour initialiser correctement l'interface IDL graphique sur carme.
; et autres trucs...


PRO psh_init
device,pseudo_color=8
device,retain=2		; or use /pixmap ...
;!PATH='/usr/local/rsi/idl/lib:'+!PATH	;I don't want SLF's STRSPLIT ...

END
