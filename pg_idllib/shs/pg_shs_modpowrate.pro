;+
; NAME:
;
; pg_shs_modpowrate
;
; PURPOSE:
;
; computes model power injected in the elctrons in ergs s^-1 and model
; rate in electrons s^-1
; 
;
; CATEGORY:
;
; shs tool
;
; CALLING SEQUENCE:
;
; power=pg_shs_modpowrate(E,P2,deltamin,deltamax,model=model)
;
; INPUTS:
;
; E: threshold energy for model
; P2: second fit par for model
; deltamin: min delta for phase
; deltamax: max delta for phase
; model: modelname (one of 'pg_fixedn','pg_fixede','pg_brown')
;
; OPTIONAL INPUTS:
;
;
; KEYWORD PARAMETERS:
;
;
; OUTPUTS:
;
;
; OPTIONAL OUTPUTS:
;
;
;
; COMMON BLOCKS:
;
;
;
; SIDE EFFECTS:
;
;
;
; RESTRICTIONS:
;
;
;
; PROCEDURE:
;
;
;
; EXAMPLE:
;
;
;
; AUTHOR:
;
; Paolo Grigis, Institute of Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 21-SEP-2004 written PG
;
;-

FUNCTION pg_shs_modpowrate,E,P2,deltamin,deltamax,model=model


kappa=1.602d-9 ;conversion factor kev -->erg
dd=deltamax-deltamin
avd=0.5*(deltamax+deltamin)

CASE strupcase(model) OF 
   'PG_FIXEDN' : BEGIN 

      checkpower=kappa*P2*E*(avd-1)/(avd-2)
      power=kappa*P2*E*(1+alog((deltamax-2)/(deltamin-2))/dd)
      rate=P2
      checkrate=P2

   END
   'PG_FIXEDE' : BEGIN 

      checkpower=kappa*P2
      power=kappa*P2
      rate=P2/E*(1-alog((deltamax-1)/(deltamin-1))/dd)
      checkrate=P2/E*(avd-2)/(avd-1)

   END
   'PG_BROWN' : BEGIN 


      checkpower=kappa*P2*E*(avd-1)/((avd-2)*(avd+0.5)^2)
      power=kappa*P2*E* $
         (4d/25.*alog((deltamax-2)/(2*deltamax+1))-6./(5.*(2*deltamax+1))- $
          4d/25.*alog((deltamin-2)/(2*deltamin+1))+6./(5.*(2*deltamin+1)))/dd
      rate=P2*(1/((deltamax+0.5)*(deltamin+0.5)))
      checkrate=P2/(avd+0.5)^2

   END
   ELSE : BEGIN
      print,'Please input a valid model'
      return,-1
   ENDELSE 
ENDCASE 

return,{rate:rate,power:power,checkpower:checkpower,checkrate:checkrate}

END
