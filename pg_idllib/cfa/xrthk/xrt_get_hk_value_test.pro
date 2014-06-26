PRO test

dir='/archive/hinode/cmn/XRT_STS/2007_03/'
file=dir+'XRT_STS-20070331060000.fits.gz'

d=mrdfits(file,1,h)

; .comp xrt_get_hk_value
t=['21-MAR-2007 03:10','02-APR-2007 09:12']
a=xrt_get_hk_value('MDP_XRT_AEC_ULT',t[0],t[1],/loud)

utplot,a.time-a.time[0],a.value,a.time[0]

t=['01-JAN-2009 00:00','01-MAR-2009 00:00']
a=xrt_get_hk_value('MDP_XRT_FLD_FLG',t[0],t[1],/loud)


t=['02-FEB-2009 18:00','02-FEB-2009 20:00' ]
a=xrt_get_hk_value('MDP_XRT_FLD_FLG',t[0],t[1],/loud)
utplot,a.time-a.time[0],a.value,a.time[0]

t=['02-FEB-2009 18:00','02-FEB-2009 20:00' ]
a=xrt_get_hk_value('MDP_XRT_FLD_C2_HADR',t[0],t[1],/loud)
utplot,a.time-a.time[0],a.value,a.time[0]

t=['02-FEB-2009 18:00','02-FEB-2009 20:00' ]
a=xrt_get_hk_value('MDP_XRT_FLD_HADR',t[0],t[1],/loud)
outplot,a.time-a.time[0],a.value,a.time[0]

t=['02-FEB-2009 18:00','02-FEB-2009 20:00' ]
a=xrt_get_hk_value('MDP_XRT_FLD_VADR',t[0],t[1],/loud)
utplot,a.time-a.time[0],a.value,a.time[0]


t=['01-FEB-2009 18:00','10-FEB-2009 20:00' ]
a=xrt_get_hk_value('MDP_IMG_XRT_FLD_CNT',t[0],t[1],/loud)
utplot,a.time-a.time[0],a.value,a.time[0]

t=['01-FEB-2009 18:00','02-FEB-2009 00:00' ]
a=xrt_get_hk_value(['MDP_IMG_XRT_FLD_CNT','MDP_XRT_FLD_VADR'],t[0],t[1],/loud)
utplot,a.time-a.time[0],a.value,a.time[0]

; .comp xrt_get_hk_value
t=['01-FEB-2009 18:00','02-FEB-2009 00:00' ]
a=xrt_get_hk_value(['MDP_XRT_AEC_LLT','MDP_XRT_AEC_ULT'],t[0],t[1],/loud)
b=xrt_get_hk_value('MDP_XRT_AEC_LLT',t[0],t[1],/loud)
c=xrt_get_hk_value('MDP_XRT_AEC_ULT',t[0],t[1],/loud)

;utplot,a.time-a.time[0],a.value,a.time[0]

t=['01-FEB-2009 18:00','02-FEB-2009 00:00' ]
a=xrt_get_hk_value(['MDP_XRT_AEC_LLT','MDP_XRT_AEC_ULT'],t[0],t[1],/loud)

a=xrt_get_hk_value(g,t[0],t[1],/loud)



t=['01-FEB-2009 18:00','05-FEB-2009 22:00' ]
hkinfo=xrt_get_hk_value(['XRTE_CCD_TEMP'],t[0],t[1],hkfileprefix='XRTE_STS',/loud)
utplot,hkinfo.time-hkinfo.time[0],hkinfo.value,hkinfo.time[0],title=hkinfo.name


t=['17-JAN-2008 00:00','20-JAN-2008 00:00' ]
hkinfo=xrt_get_hk_value('XRTD_P_M15BV',t[0],t[1],hkfileprefix='XRTD_STS',/loud)
utplot,hkinfo.time-hkinfo.time[0],hkinfo.value,hkinfo.time[0],title=hkinfo.name


END



