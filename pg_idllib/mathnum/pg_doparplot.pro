;+
; NAME:
;      pg_doparplot
;
; PROJECT:
;      diffusion & acceleration (plasma physics)
;
; PURPOSE: 
;      plot parameters etc.
;
;
; CALLING SEQUENCE:
;      
;
; INPUTS:
;      
;   
; OUTPUTS:
;      
;      
; KEYWORDS: 
;
;      
;      
;
; HISTORY:
;       16-JAN-2005 written PG
;      
;
; AUTHOR
;       Paolo Grigis, Institute for Astronomy, ETH, Zurich
;       pgrigis@astro.phys.ethz.ch
;
;-


PRO pg_doparplot,unpar=unpar,pivdata=pivdata

;choice for plotting
par='YTHERM';x value to plot
;linepar='DENSITY';different lines on same plot
;plotpar='THRESHOLD_ESCAPE_KEV';different plots
linepar='THRESHOLD_ESCAPE_KEV';different lines on same plot
plotpar='DENSITY';different plots

parind=(where(unpar.parnames EQ par))[0]
lineparind=(where(unpar.parnames EQ linepar))[0]
plotparind=(where(unpar.parnames EQ plotpar))[0]

parval=*unpar.uniqval[parind]
lineparval=*unpar.uniqval[lineparind]
plotparval=*unpar.uniqval[plotparind]

n=3
datavalues=fltarr(n,n_elements(pivdata))
FOR i=0,n_elements(pivdata)-1 DO datavalues[*,i]=(*pivdata[i]).parvalues


epiv=dblarr(n_elements(pivdata))
fpiv=dblarr(n_elements(pivdata))

FOR i=0,n_elements(pivdata)-1 DO BEGIN &$
   epiv[i]=(*pivdata[i]).epiv &$ 
   fpiv[i]=(*pivdata[i]).fpiv &$
ENDFOR


x=parval
x2=kev2kel((10^parval)*511.)*1d-6


;!p.multi=[0,2,3]
!p.charsize=1.5

psymlist=['CIRCLE','STAR','SQUARE','TRIANGLE','DIAMOND']
psize=[1,1.5,1,1,1.2]

;pg_set_ps,filename='~/saturn/diff/parplot2.ps',xoffset=1,yoffset=1,xsize=18,ysize=28
!p.multi=[0,2,3]


FOR i=0,n_elements(plotparval)-1 DO BEGIN                                                  
                                                                                          
   title=plotpar+': '+strtrim(string(plotparval[i]),2)                                    
   xtitle='Temperature (MK)'                                                              
                                                                                          
                                                                                          
   FOR j=0,n_elements(lineparval)-1 DO BEGIN                                              
      ind=where((abs(datavalues[plotparind,*]-plotparval[i]) LT 1d6) AND $    
                (abs(datavalues[lineparind,*] -lineparval[j]) LT 1d-2),count)             
                                                                                          
      y=epiv[ind]                                                                         
                                                                                          
      pg_setplotsymbol,psymlist[j],size=psize[j]                                          
                                                                                          
      IF j EQ 0 THEN BEGIN                                                                
         plot,x2,y,/xlog,xrange=[0.75,75],/xstyle,title=title,xtitle=xtitle $ 
              ,psym=-8,yrange=[0,25],/ystyle                                              
      ENDIF $                                                                             
      ELSE BEGIN                                                                          
         oplot,x2,y,psym=-8                                                               
      ENDELSE                                                                             
                                                                                          
      ENDFOR  
ENDFOR


      ;oplot,[1,2,4],15+j*3*[1,1,1],psym=-8                                              
      ;xyouts,6,15+j*3,linepar+': '+strtrim(string(lineparval[j],format='(e8.1)'),2),charsize=0.7


!p.multi=[0,2,3]


FOR i=0,n_elements(plotparval)-1 DO BEGIN                                                 
                                                                                          
   title=plotpar+': '+strtrim(string(plotparval[i]),2)                                    
   xtitle='Temperature (MK)'                                                              
                                                                                          
   FOR j=0,n_elements(lineparval)-1 DO BEGIN                                              
        ind=where((abs(datavalues[plotparind,*]-plotparval[i]) LT 1d6) AND $        
                (abs(datavalues[lineparind,*] -lineparval[j]) LT 1d-2),count)             
                                                                                          
      y=epiv[ind]                                                                         
      pg_setplotsymbol,psymlist[j],size=psize[j]                                          
                                                                                          
      IF j EQ 0 THEN BEGIN                                                                
         plot,x2,y,/xlog,xrange=[0.75,75],/xstyle,title=title,xtitle=xtitle $   
             ,psym=-8,yrange=[1d-1,50],/ylog,/ystyle                                      
      ENDIF $                                                                             
      ELSE BEGIN                                                                          
        oplot,x2,y,psym=-8                                                                
      ENDELSE                                                                             
                                                                                          
                                                                                          
   ENDFOR                                                                                 
                                                                                          
ENDFOR                                                                                  


;device,/close
;set_plot,'X'








par='YTHERM';x value to plot
linepar='DENSITY';different lines on same plot
plotpar='THRESHOLD_ESCAPE_KEV';different plots
;linepar='THRESHOLD_ESCAPE_KEV';different lines on same plot
;plotpar='DENSITY';different plots

parind=(where(unpar.parnames EQ par))[0]
lineparind=(where(unpar.parnames EQ linepar))[0]
plotparind=(where(unpar.parnames EQ plotpar))[0]

parval=*unpar.uniqval[parind]
lineparval=*unpar.uniqval[lineparind]
plotparval=*unpar.uniqval[plotparind]

n=3
datavalues=fltarr(n,n_elements(pivdata))
FOR i=0,n_elements(pivdata)-1 DO datavalues[*,i]=(*pivdata[i]).parvalues


epiv=dblarr(n_elements(pivdata))
fpiv=dblarr(n_elements(pivdata))

FOR i=0,n_elements(pivdata)-1 DO BEGIN   
   epiv[i]=(*pivdata[i]).epiv            
   fpiv[i]=(*pivdata[i]).fpiv            
ENDFOR                                  

x=parval
x2=kev2kel((10^parval)*511.)*1d-6


!p.multi=[0,2,3]
!p.charsize=1.5


psymlist=['CIRCLE','STAR','SQUARE','TRIANGLE','DIAMOND']
psize=[1,1.5,1,1,1.2]

;pg_set_ps,filename='~/saturn/diff/parplot.ps',xoffset=1,yoffset=1,xsize=18,ysize=28
;!p.multi=[0,2,3]


FOR i=0,n_elements(plotparval)-1 DO BEGIN                                                    
                                                                                             
   title=plotpar+': '+strtrim(string(plotparval[i]),2)                                       
   xtitle='Temperature (MK)'                                                                 
                                                                                             
                                                                                             
   FOR j=0,n_elements(lineparval)-1 DO BEGIN                                                 
      ind=where(    (datavalues[plotparind,*] EQ plotparval[i]) AND $               
                (abs(datavalues[lineparind,*] -lineparval[j]) LT 1d6),count)                 
                                                                                             
      y=epiv[ind]                                                                            
                                                                                             
      pg_setplotsymbol,psymlist[j],size=psize[j]                                             
                                                                                             
      IF j EQ 0 THEN BEGIN                                                                   
         plot,x2,y,/xlog,xrange=[0.75,75],/xstyle,title=title,xtitle=xtitle $       
              ,psym=-8,yrange=[0,25],/ystyle                                                 
      ENDIF $                                                                                
      ELSE BEGIN                                                                             
         oplot,x2,y,psym=-8                                                                  
      ENDELSE                                                                                
                                                                                             
      oplot,[1,2,4],15+j*3*[1,1,1],psym=-8                                                   
      xyouts,6,15+j*3,linepar+': '+strtrim(string(lineparval[j],format='(e8.1)'),2),charsize=0.7  
                           
   ENDFOR    
ENDFOR



!p.multi=[0,2,3]


FOR i=0,n_elements(plotparval)-1 DO BEGIN                                            
                                                                                     
   title=plotpar+': '+strtrim(string(plotparval[i]),2)                               
   xtitle='Temperature (MK)'                                                         
                                                                                     
   FOR j=0,n_elements(lineparval)-1 DO BEGIN                                         
      ind=where(    (datavalues[plotparind,*] EQ plotparval[i]) AND $               
                (abs(datavalues[lineparind,*] -lineparval[j]) LT 1d6),count)         
                                                                                     
      y=epiv[ind]                                                                    
      pg_setplotsymbol,psymlist[j],size=psize[j]                                     
                                                                                     
      IF j EQ 0 THEN BEGIN                                                           
         plot,x2,y,/xlog,xrange=[0.75,75],/xstyle,title=title,xtitle=xtitle $       
             ,psym=-8,yrange=[1d-1,50],/ylog,/ystyle                                 
      ENDIF $                                                                        
      ELSE BEGIN                                                                     
        oplot,x2,y,psym=-8                                                           
      ENDELSE                                                                        
   ENDFOR                                                                            
ENDFOR                                                                               



;device,/close
;set_plot,'X'


END



