PRO NULL_SETZEN
;The peak in x-direction is set to zero
;Run with " .r /global/helene/home/benz/soft/idl/null_setzen.pro " und dann nur noch
;" null_setzen "
 
filename='' 
read, prompt='Filename?', filename
common imagereal,zzz,xxx,yyy
dim=size(zzz)
dim1=dim(1)
dim2=dim(2)
tst=findgen(dim1)
openw, 42, filename
for i=0, dim(2)-1 do begin
 tst=zzz(*,i)
 a=max(tst,ind)
 print,a,yyy(i),xxx(ind)
 printf,42, a, xxx(ind), yyy(i)
 zzz(ind,i)=0.0
endfor

close, 42
;ragfitswrite,zzz,xxx,yyy
end