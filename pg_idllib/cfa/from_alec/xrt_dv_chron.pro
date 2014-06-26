;+
;
; PROJECT:
;       Solar-B / XRT
;
; NAME:
;
;       xrt_dv
;
; CATEGORY:
;
;       Hinode XRT data analysis.
;
; PURPOSE:
;
;       View data taken by XRT in a timely fashion with the option of
;       running the most recent spot correction code.  Make a
;       quicktime movie of all .gifs this code wrties out.  All different
;       filters and all images sizes (except 2048) are accounted for.   
;
; CALLING SEQUENCE:
;
;      XRT_DV,t0,t1,dir=dir,spot_cor,quicklook=quicklook,sep_size=sep_size
;
; INPUTS:
;
;       T0 and T1  - [Mandatory] string, 'dd-mm-yyyy hh:mm'  ;
;                          where the second mm stands for minutes
;
;       DIR        - [Mandatory] The path (folder) where the .gifs are
;                    to be written to.
;
; KEYWORDS:
;
;       spot_cor   - [Optional] If you would like to see the data with spot
;                      correction.  
;       quicklook  - [Optional]  Look at the unprocessed data.  This
;                    data is available more quickly than the level 0 data
;       sep_size   - [Optional]  creat sub directories under the user
;                    given directory for different naxis1 data sizes.
;                    eg. dir/384 and dir/512.  This way the images
;                    will flow more smoothly when you create the
;                    quicktime movie.  
;
;
; OUTPUTS:
;
;       The .gifs created get written out to the specified directory (dir)
;                      
; EXAMPLES:
;
;       Basic call to get quicklook data that is spot corrected
;        IDL> xrt_dv, t0, t1,/spot_cor,/quicklook
;
; COMMON BLOCKS:
;
;       None
;
; NOTES:
;   
;       Reports bugs and problems to xrt_manager@cfa.harvard.edu
;
;
; MODIFICATION HISTORY:
;
;      12-May-2009 -- A. Engell and P. Grigis
; ============================================================================
pro xrt_dv_inner,index,data,dir

	name = strmid(index.date_obs,0,16)
	nname = strmid(name,0,10)
	ename = strmid(name,11,19)
	tname = nname + ename
        sec = strmid(index.date_obs,17,2)
	ttname = strmid(tname,0,12)
	eename = strmid(tname,13,15)
	fname = ttname + eename
	yfname = strmid(fname,0,4)
	mfname = strmid(fname,5,2)
	tfname = strmid(fname,8,8)
        dfname = strmid(tfname,0,2)

        print, index.date_obs
        print, index.ec_fw2_
	print, index.exptime

        in = sort(data)
        n = n_elements(data)
        f = 0.999
        range = f*n
        data[in[range-1:*]] = data[in[range-1]]
        a=alog(data>40-35)

        img_min=0

   naxis1 = strn(index.naxis1)
   dirnew = dir+'/'+naxis1
   file_mkdir,dirnew

	IF index.naxis1 eq 1024 THEN BEGIN
           tv,bytscl(a)
        ENDIF
        IF index.naxis1 eq 768 THEN BEGIN
           tv,bytscl(a),150,150
	ENDIF
        IF index.naxis1 eq 512 THEN BEGIN
           tv,bytscl(a),256,256
	ENDIF
        IF index.naxis1 eq 384 THEN BEGIN
           tv,bytscl(a),350,350
        ENDIF
        IF index.naxis1 eq 256 THEN BEGIN
           tv,bytscl(a),430,430
        ENDIF



IF mfname eq 01 then xyouts,.38,.97,'January',/norm,size=3,font=1
IF mfname eq 02 then xyouts,.38,.97,'February',/norm,size=3,font=1
IF mfname eq 03 then xyouts,.39,.97,'March',/norm,size=3,font=1
IF mfname eq 04 then xyouts,.39,.97,'April',/norm,size=3,font=1
IF mfname eq 05 then xyouts,.40,.97,'May',/norm,size=3,font=1
IF mfname eq 06 then xyouts,.40,.97,'June',/norm,size=3,font=1
IF mfname eq 07 then xyouts,.40,.97,'July',/norm,size=3,font=1
IF mfname eq 08 then xyouts,.38,.97,'August',/norm,size=3,font=1
IF mfname eq 09 then xyouts,.37,.97,'September',/norm,size=3,font=1
IF mfname eq 10 then xyouts,.38,.97,'October',/norm,size=3,font=1
IF mfname eq 11 then xyouts,.38,.97,'November',/norm,size=3,font=1
IF mfname eq 12 then xyouts,.38,.97,'December',/norm,size=3,font=1

        xyouts,.50,.97,dfname+',',/norm,size=3,font=1
        xyouts,.55,.97,yfname,/norm,size=3,font=1
        xyouts,.43,.94,ename,/norm,size=3,font=1
        xyouts,.53,.94,'UT',/norm,size=3,font=1
	xyouts,.05,.97,index.ec_fw1_+'/'+index.ec_fw2_,/norm,size=2,font=1
	xyouts,.02,.94,index.exptime,/norm,size=2,font=1

	a2 = tvrd()
	filename = yfname + mfname + tfname + sec +'.gif'
	write_gif,dirnew+'/'+filename,a2,r,g,b
     end

;===================================================================================

Pro xrt_dv_chron;,t0,t1

t0 = anytim(anytim(!stime)-3*86400,/vms,/date_only) + ' 00:00'
t1 = anytim(anytim(!stime)-0*86400,/vms,/date_only) + ' 00:00'
print,t0,   t1

folder = time2file(anytim(ut_time())-3*86400) 
folder = strmid(folder,0,8) +'/'

dir = '/Users/Shared/xrt_' + folder
print,dir

file_mkdir,dir

   xrt_cat, t0, t1, cat,files,/quicklook,sirius=0
   
   ;replaces "QuickLook" string in filenames by "QLraw"
   qlindex=strpos(files[0],'QuickLook')
   thisString1=strmid(files,0,qlindex)
   thisString2=strmid(files,qlindex+9)
   f_file=thisString1+'QLraw'+thisString2

n = n_elements(f_file)
set_plot,'z'
wdef,0,1024,1094
loadct,3

img_min = -1

for i = 0, n-1, 1 Do begin
erase
wdef,0,1024,1094
print,i,f_file[i]
read_xrt,f_file[i],index,data

print, index.ec_fw2_
print, index.ec_fw1_

	name = strmid(index.date_obs,0,16)
	nname = strmid(name,0,10)
	ename = strmid(name,11,19)
	tname = nname + ename
        sec = strmid(index.date_obs,17,2)
	ttname = strmid(tname,0,12)
	eename = strmid(tname,13,15)
	fname = ttname + eename
	yfname = strmid(fname,0,4)
	mfname = strmid(fname,5,2)
	tfname = strmid(fname,8,8)
        dfname = strmid(tfname,0,2)

data = no_nyquist(data)

;   xrt_spotcor,index,data,data_out,numspots,spotmap,thresh=thresh
   xrt_dv_inner,index,data,dir

endfor

set_plot,'x'
return

end
