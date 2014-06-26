;+
; NAME:
;    pg_osp_setfitintv
;
; PURPOSE: 
;    set fitting intervals for a SPEX object, centered around the
;    maximum flux in a band around a certain time
;
; CALLING SEQUENCE:
;    pg_osp_stfitintv,obj,nintv=nintv,this_band=this_band
;   
;
; INPUTS:
;    nintv: number of intervals (integer>1) 
;    this_band: band to be checked for max 
;    tintv: time duration of each interval
;    input_intv: time interval to be scanned for maximum 
;  
; OUTPUTS:
;    none
;      
; KEYWORDS:
;
;
; HISTORY:
;    05-NOV-2003 written PG
;
; AUTHOR
;    Paolo Grigis, Institute for Astronomy, ETH, Zurich
;    pgrigis@astro.phys.ethz.ch
;
;-

PRO pg_osp_setfitintv,osp,nintv=nintv,this_band=this_band,tintv=tintv $
                    ,input_intv=input_intv

   IF NOT exist(osp) THEN BEGIN
      print,'Input a SPEX object'
      RETURN
   ENDIF

   this_band=fcheck(this_band,0)


   time_axis=osp->getaxis(/ut,/edges_2); ARRAY 2xN
   energy_axis=osp->getaxis(/ct,/edges_2); ARRAY 2xM
   energy_bands=osp->get(/spex_eband)

   input_intv=fcheck(input_intv,[min(time_axis),max(time_axis)])

   en_boundaries=energy_bands[*,this_band]
   ind=where(energy_axis[0,*] GE en_boundaries[0] AND $
             energy_axis[1,*] LE en_boundaries[1])
   
   data=osp->getdata(class='spex_data',spex_units='flux')
   
   banddata=total(data.data[ind,*],1)

   t_boundaries=input_intv
   time_ind=where(time_axis[0,*] GE t_boundaries[0] AND $
                  time_axis[1,*] LE t_boundaries[1])

   banddata2=banddata[time_ind]

   dummy=max(banddata2,maxind)

   maxtime=time_axis[*,time_ind[maxind]]
   avmaxtime=min(maxtime)+0.5*(max(maxtime)-min(maxtime))

   nintv=round(fcheck(nintv,3)>1)
   fittimes=dblarr(nintv,2)

   fittimes[*,0]=avmaxtime-0.5*tintv*nintv+findgen(nintv)*tintv
   fittimes[*,1]=fittimes[*,0]+tintv

   fittimes=transpose(fittimes)

   osp->set,spex_fit_time_interval=fittimes

END 











