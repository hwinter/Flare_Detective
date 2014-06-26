wave_ind=[0,1,2,4,5,6]


flare_programs=getenv('PROGRAMS')+'Flare_Detective/'
add_path,flare_programs,/expand,/append

for i=0, n_elements(wave_ind) -1ul do begin

   sdcfd_trig_runflaredetection,Wave_ind[i]

endfor 


end
