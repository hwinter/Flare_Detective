
;+ ***********************************************************************
; NAME:
;       MODIFIED_READ_NRH
;
; PURPOSE:
;       This procedure read 2 dimensions images array from
;               NRH files, (result of VISIBILITY to IMAGE conversion NRH widget)
;                       or
;               VISIBILITY files from BASS2000 data base (http://mesola.obspm.fr)
;       and interface it with the D Zarro MAPPING SOFTWARE
;
; CATEGORY:
;       NRH Gen
;
; CALLING SEQUENCE:
;       READ_NRH, File, Index, Data 
;
; INPUTS:
;       FILE    NRH file name (NRH file or VISIBILITY file
;
; KEYWORD PARAMETERS:
;       HBEG    Time (hh:mm:ss:cc) of the first image to read,
;                       Default: begin of the file
;       HEND    Time of the last image to read
;                       Default same value than HBEG
;       STOKES  Stokes V parameter instead of I parameter
;
;       FREQ    Frequency number for VISIBILITY files [0 to 4]
;
;       DIR     Directory from where to read data
;
; OUTPUTS:
;       INDEX   Structure to map
;       DATA    Data array
;
; COMMON BLOCKS:
;       No
;

; EXAMPLE:
;       READ_NRH, File name, Index, Data
;               Read the first imade of the file
;       Idex2map, Index, Data, Map
;               Map the image
;       READ_NRH, File name, Index, Data, HBEG='10:00', HEND='10:10:30'
;               Read images cube
;
; MODIFICATION HISTORY:
;       Ecrit par: Jean Bonmartin (bonmartin@obspm.fr) 14/09/00
;               -ISHORT dans l'appel a FITS_INTERP pour avoir NAXISn en INT
;               plutot qu'en BYTE le 18/12/00 (JB)
;               le 04/04/01 Adapte pour les visibilites (JB)
;
;	PSH 2002/11/25: added keywords SIZE
;
;
;-*******************************************************************

PRO MODIFIED_READ_NRH, File, Index, Data, HBEG=Hbeg, HEND=Hend, STOKES=Stokes, $
                DIR= Dir, FREQ = Freq, SIZE=size

IF NOT KEYWORD_SET(DIR) THEN CD, CURRENT=Dir
        NRH_CTRLREP, Dir
IF NOT KEYWORD_SET(FREQ) THEN Freq = 0

IF STRMID(File, 0, 3) EQ 'nrh' THEN BEGIN       
        IF NOT KEYWORD_SET (HBEG) THEN Ideb = 0 $
                ELSE Ideb = TIME_IND_NRH( Dir+File, Hbeg)
        IF NOT KEYWORD_SET (HEND) THEN Iend = Ideb $
                ELSE Iend = TIME_IND_NRH( Dir+File, Hend)
        Donnee = MRDFITS( Dir+File, 1, Head, RANGE=[Ideb,Iend])
ENDIF ELSE IF STRMID(File,0,1) EQ '2' THEN BEGIN
        IF NOT KEYWORD_SET (HBEG) THEN Hbeg = 0
        IF NOT KEYWORD_SET (HEND) THEN Hend= Hbeg
        RH_RDIMCUBE, Dir+file, Donnee, Head0, Head, HDEB=Hbeg, Hfin= Hend, $
                /POLAR, FREQ = Freq, SIZE=size
ENDIF ELSE BEGIN
        PRINT,'ERROR: File:',file, 'Must be:'
        print,' NRH file result from Visibility to image conversion'
        print,' or Visibility file from data base BASS2000: "2Q*" or "2i*"'
        RETURN
ENDELSE

        FITS_INTERP, Head, STR, /ISHORT
        SZ =SIZE(Donnee[0].StokesI)
                Str.Naxis1 = Sz[1] & Str.naxis2 = Sz[2]
                Str.Bitpix=-32
        DATE = FXPAR(Head, 'DATE-OBS')
        RAYON = FXPAR(Head, 'SOLAR_R')
        PIX= NRH_PIXARCSEC(Date,Rayon)

        Nstr1 = ADD_TAG (Str, Pix, 'CDELT1',INDEX=5)
        Nstr2 = ADD_TAG (Nstr1, Pix, 'CDELT2',INDEX=6)
        Nstr3 = ADD_TAG (Nstr2, '', 'DATE_OBS',INDEX=9)

        IF NOT KEYWORD_SET (STOKES) THEN Data=Donnee.StokesI $
                ELSE Data=Donnee.StokesV
        NBIM = N_ELEMENTS(Donnee.Time)
        INDEX = REPLICATE(Nstr3, Nbim)

        FOR I = 0, Nbim-1 DO BEGIN
                HEURE = MSH(Donnee[i].Time, DELIM='.')
                INDEX[I].DATE_OBS= STR.DATE_D$OBS +'T'+ Heure +'Z'
        ENDFOR

END

