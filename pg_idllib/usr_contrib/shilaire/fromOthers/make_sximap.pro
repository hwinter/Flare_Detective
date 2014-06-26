PRO make_sximap,fff,map,wl=wl,$
         map_o=map_o,map_p0=map_p0,map_p1=map_p1,map_p2=map_p2,$
         map_b0=map_b0,map_b1=map_b1,map_b2=map_b2

; make_sximap,'20030124_03',map,wl=wl
; map_b_thn_a=select_sxi_wl(map,wl,'B_THN_A')
; map_o=select_sxi_wl(map,wl,'OPEN')
; map_r=select_sxi_wl(map,wl,'RDSH')
; map_pm=select_sxi_wl(map,wl,'P_MED_A')
; make_sximap,'20030124_03',map,wl=wl,map_o=map_o,map_p0=map_p0,map_p1=map_p1,map_p2=map_p2,map_b0=map_b0,map_b1=map_b1,map_b2=map_b2
; make_sximap,'20030125_13',map,wl=wl,map_o=map_o,map_p0=map_p0,map_p1=map_p1,map_p2=map_p2,map_b0=map_b0,map_b1=map_b1,map_b2=map_b2
; make_sximap,'20030423_0',map,wl=wl,map_o=map_o,map_p0=map_p0,map_p1=map_p1,map_p2=map_p2,map_b0=map_b0,map_b1=map_b1,map_b2=map_b2


dd='/disks/sundrop/home/krucker/sxi_data/'
f=findfile(dd+'SXI*'+fff+'*.FTS')
fdim=n_elements(f)
wl=strarr(fdim)

if f(0) ne '' then begin 

for i=0,fdim-1 do begin 
  fits2map,f(i),hmap,header=header
  wl(i)=strtrim(strmid(header(40),10,10),2)
  if i eq 0 then begin 
    map=hmap
  endif else begin 
    map=[map,hmap]
  endelse
endfor

map=rotate_sxi(map)

;open
map_o=select_sxi_wl(map,wl,'OPEN',/show)
;poly
map_p0=select_sxi_wl(map,wl,'P_THN_A',/show)
map_p1=select_sxi_wl(map,wl,'P_MED_A',/show)
map_p2=select_sxi_wl(map,wl,'P_THK',/show)
;be
map_b0=select_sxi_wl(map,wl,'B_THN_A',/show)
map_b1=select_sxi_wl(map,wl,'B_MED',/show)
map_b2=select_sxi_wl(map,wl,'B_THK',/show)

endif else begin
  print,'no files found'
endelse



END