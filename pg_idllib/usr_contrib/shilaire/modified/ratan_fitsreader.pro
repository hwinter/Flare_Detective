; taken from their website - PSH 2001/07/20
; out is an array xaxis is time and y-axis are frequencies ~1-17GHz
; use bla=headfits('ratanfitsfile',ext=0) [or ext=1) and hprint,bla for more info


pro ratan_fitsreader,out
                                                                   
common ws_comm,namobj,solar_r,bunit,angle,xscale,centr_x, $                                                        
 nfield,dtype,tdim,xmas,ddata,status,wscan,base,draw, $                                                        
 list,fl_load,fl_iv,nfile,twoscn,exbeg,exend                                                       
                                
;pro loadfits                                                                    
wscan=-1 & fl_load=0                                                                  
nfile=pickfile(TITLE='Select Binary FITS file')                                                        
if nfile eq '' then return                                                                   
fxbopen, fid, nfile,1                                                                  
fhdr=fxbheader(fid)                                                                  
ndate=fxpar(fhdr,'DATE_OBS')                                                                 
nobj=fxpar(fhdr,'OBJECT')                                                                 
solar_r=fxpar(fhdr,'SOLAR_R')                                                                 
bunit=fxpar(fhdr,'BUNIT')                                                                 
angle=fxpar(fhdr,'ANGLE')                                                         
xscale=fxpar(fhdr,'XSCALE')                                                                 
centr_x=fxpar(fhdr,'CENTRE_X')                                                                 
nfield=fxpar(fhdr,'TFIELDS')                                                                 
dtype=strmid(fxpar(fhdr,'TTYPE*'),12,50)                                                                
tdim=fix(fxpar(fhdr,'TFORM1'))                                                         
xmas=(findgen(tdim)-centr_x)/solar_r;*xscale                                                                
ddata=make_array(nfield,tdim,/double)                                                                
for i=0,nfield-1 do begin                                                                
fxbread,fid,xdata,i+1                                                                
ddata(i,*)=xdata                                                                
out=transpose(ddata)	; PSH
end                                                        
