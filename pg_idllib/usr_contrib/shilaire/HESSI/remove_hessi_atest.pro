;PSH, 2001/05/23
; removes all atest subdirectories of the HESSI tree form !PATH variable

PRO remove_hessi_atest
str=RSI_STRSPLIT(!PATH,':',/EXTRACT)
for i=0, n_elements(str)-1 do if STRMATCH(str(i),'*hessi*atest*',/FOLD_CASE) then str(i)=''
!PATH=STRJOIN(str,':')
END
