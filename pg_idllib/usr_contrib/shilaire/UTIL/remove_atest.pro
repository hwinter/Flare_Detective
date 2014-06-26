;PSH, 2001/05/23
; removes all atest subdirectories form !PATH variable

PRO remove_atest
str=RSI_STRSPLIT(!PATH,':',/EXTRACT)
for i=0, n_elements(str)-1 do if STRMATCH(str(i),'*atest*',/FOLD_CASE) then str(i)=''
!PATH=STRJOIN(str,':')
END
