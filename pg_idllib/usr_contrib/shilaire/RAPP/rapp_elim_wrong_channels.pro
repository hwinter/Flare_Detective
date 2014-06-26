;+
;	PSH 2004/09/17
;	From P. Messmer's qv_elimwrong.pro
;-

PRO rapp_elim_wrong_channels, image, xaxis, yaxis 
 print, "Eliminating wrong channels"
 image_old = image
 xaxis_old = xaxis
 yaxis_old = yaxis
 ElimWrongChannels, image, xaxis, yaxis
 if n_elements(image[0,*]) le 1 then begin 
    print, "Restoring original image"
    image = image_old
    xaxis = xaxis_old
    yaxis = yaxis_old
 endif
END
