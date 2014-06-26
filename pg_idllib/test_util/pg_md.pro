;
; from lajos foldi, idl newsgroup
; test mulitplication and divison speed on a system
; 
;


PRO pg_md 

a=sin(findgen(1000))*1e38
nrep=500000L

t=systime(1)
for j=1l,nrep do b=a/2.
t1=systime(1)-t
print, 'DIV: ',t1

t=systime(1)
for j=1l,nrep do b=a*0.5
t2=systime(1)-t
print, 'MUL: ', t2

print,'RATIO: ',t1/t2

end


