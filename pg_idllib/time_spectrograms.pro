;@ ~/work/spindex/time_spectrograms.pro

PRO time_spectrograms

time=strarr(26,2)

time[0,*]=['20-Feb-02 09:31:48.841','20-Feb-02 10:29:28.071']
time[1,*]=['20-Feb-02 15:43:24.489','20-Feb-02 16:54:06.165']
time[2,*]=['20-Feb-02 20:33:00.082','20-Feb-02 21:35:52.291']
time[3,*]=['25-Feb-02 02:07:58.566','25-Feb-02 03:07:16.632']
time[4,*]=['26-Feb-02 10:09:56.907','26-Feb-02 11:16:31.494']
time[5,*]=['27-Feb-02 23:18:10.330','28-Feb-02 00:16:22.505']
time[6,*]=['15-Mar-02 21:55:21.621','15-Mar-02 22:59:27.956']
time[7,*]=['04-Apr-02 09:57:18.330','04-Apr-02 10:57:01.104']
time[8,*]=['04-Apr-02 14:40:49.385','04-Apr-02 15:44:47.483']
time[9,*]=['09-Apr-02 12:10:53.621','09-Apr-02 13:06:54.016']
time[10,*]=['10-Apr-02 12:03:55.676','10-Apr-02 13:14:45.588']
time[11,*]=['10-Apr-02 18:18:40.000','10-Apr-02 19:41:01.758']
time[12,*]=['14-Apr-02 02:54:13.517','14-Apr-02 04:02:26.939']
time[13,*]=['14-Apr-02 23:40:32.808','15-Apr-02 00:58:31.005']
time[14,*]=['17-Apr-02 00:01:52.049','17-Apr-02 01:14:53.742']
time[15,*]=['24-Apr-02 21:18:34.412','24-Apr-02 22:41:29.115']
time[16,*]=['01-Jun-02 03:12:22.599','01-Jun-02 04:19:13.659']
time[17,*]=['06-Jul-02 03:11:38.984','06-Jul-02 04:20:00.643']
time[18,*]=['11-Jul-02 13:33:41.418','11-Jul-02 14:48:21.945']
time[19,*]=['16-Aug-02 21:35:24.538','16-Aug-02 22:44:43.852']
time[20,*]=['17-Aug-02 00:31:45.720','17-Aug-02 01:55:13.368']
time[21,*]=['22-Aug-02 01:16:07.121','22-Aug-02 02:28:35.868']
time[22,*]=['23-Aug-02 11:42:08.434','23-Aug-02 12:37:27.648']
time[23,*]=['23-Aug-02 11:41:31.203','23-Aug-02 12:46:51.665']
time[24,*]=['24-Aug-02 04:39:05.181','24-Aug-02 05:52:39.819']
time[25,*]=['24-Aug-02 11:04:50.055','24-Aug-02 12:14:42.313']


 FOR i=0,25 DO BEGIN
 time_intv=time[i,*]
 energy_band=findgen(498)+3
 time_bin=4.
 segment=bytarr(18)
 segment[[0,2,3,4,5,7,8]]=1
 filename='work/raw_data/spg/spg_'+anytim(time_intv[0],/ccsds)+'.fits'
 scfilename='work/raw_data/scspg/scspg_'+anytim(time_intv[0],/ccsds)+'.fits'

 print,'Now doing spectrogram '+string(i)
  
 hsi_spg_fitswrite,time_intv,time_bin=time_bin,energy_band=energy_band $
          ,segment=segment,filename=filename,scfilename=scfilename

 ENDFOR


end

