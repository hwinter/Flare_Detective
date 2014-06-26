



  file_name=working_dir+'fits_list.txt'
  file_list=rd_tfile(file_name,1)
  fits_dir=
  ind=indgen(n_elements(file_list))
  aia_prep, file_list[ind], ind,fits_dir,/DO_WRITE_FITS
END



