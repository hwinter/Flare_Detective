;+
; NAME:
;     CLICKER_FLARE
; PURPOSE:
;     trace a line on a TV image and return the points
; CATEGORY:
; CALLING SEQUENCE:
;     clicker_flare, image, xx, yy, /archive, /noshow
; INPUTS:
;     an image
; OPTIONAL (KEYWORD) INPUT PARAMETERS:
;     archive, writes a .genx file with the output (index, data, xx, yy),
;       default filename = 'hh:mm:dd.genx' in the current directory,
;       otherwise enter a name for the .genx
;     noshow, disables the running display so as to avoid subjective
;       bias in marginal cases (and what that's interesting isn't marginal?)
; OUTPUTS:
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
; MODIFICATION HISTORY:
;     12-Aug-00, JIK, HSH
;-

pro clicker_flare, index_in, data_in, xx, yy, archive = archive, qdebug=qdebug,$
  noshow=noshow
;
print, 'Left button: data entry'
print, 'Middle button: remove last point'
print, 'Right button: quit'
index = index_in & data = data_in
wdef,0,image
n_img = n_elements(index)
for i = 0, n_img-1 do begin
  tvscl, rebin(data(*,*,i),512,512,/samp) 
  save = tvrd()
  x0 = -1
  y0 = -1
  repeat begin
         cursor, x, y, 3, /device
         if !err eq 1 then begin
            x0 = [x0, x]
            y0 = [y0, y]
;           print, x, y
            save = tvrd()
            if n_elements(noshow) eq 0 then begin
              save = tvrd()
              plots, x, y, psym=1, /device
            endif
         endif
         if !err eq 2 then begin
            print,'removing last point'
            x0 = x0(0:n_elements(x0)-2)
            y0 = y0(0:n_elements(y0)-2)
            tvscl,save
         endif
  endrep until !err gt 2
  xx = x0(1:*)
  yy = y0(1:*)
  tvscl,save
  plots, xx, yy, psym=1, /device
  if n_elements(archive) ne 0 then begin
    filename = strmid(fmt_tim(index(i)),11,8)
    if (size(archive))(1) eq 7 then filename = archive
    savegen,file=filename,index(i),data(*,*,i),xx,yy
  endif 
endfor
if n_elements(qdebug) ne 0 then stop
end

