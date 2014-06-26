;---------------------------------------------------------------------------
; Document name: show_image.pro
; Created by:    Andre Csillaghy, April, 1991
;
; Last Modified: Mon Dec 14 14:14:45 1998 (csillag@soleil)
;---------------------------------------------------------------------------
;
;+ 
;		----- This is the IDL version -----
; NAME:
;	Show Image
; PURPOSE: 
;	Displays or writes an image with axes and scale on
;	a window or on paper.
; CALLING SEQUENCE:
;	Show_Image, image [, xAxis, yAxis ]
; INPUTS:
;	image: a 2D array (usually real)
;	xAxis, yAxis: the axes corresponding to the image (real)
; KEYWORDS:
;	XPOS, YPOS: the position of the lower left corner of the
;		image, in device units (screen display) or
;		centimeters (PostScript).
;	/HMS: If present, the x axis is written in hours/minutes/
;		seconds style. The contents of xAxis is assumed
;               to be seconds after midnight.
;	XTITLE, YTITLE, ZTITLE, TITLE: Strings for
;		labeling axes and image, only for PostScript.
;		Default: the system-variables titles.
;	WINNR: The number of the window where the image will
;		be displayed. Default: the current window.
;	SCALEHEIGHT: the scale height in device units (screen)
;		or centimeters (PostScript).
;	WNAME: The name of the window. Default: empty string.
;	FILENAME: The filename of the PostScript file.
;		Default: "ragview.ps"
;	IMAGEOFFSET: If the image has non-homogeneous axes,
;		the distance (device units or centimeters)
;		between two homogeneous parts.
;	AXISOFFSET: The distance between the axes and the
;		 image, device units or centimeters.
;	/REVERSE: If present, the image intensity will be 
;		reversed.
;	/ENCAPSULATED: If present, the PostScript image will contain
;		no scaling and eject commands, to insert it into a TeX or
;		LaTeX Document.
;	/PORTRAIT: If present the image will be printed 
;		in portrait mode. Default: landscape mode.
; 	/PS: If present, the image is written in a PostScript file.
;	/LOGO: if present, the text "Institute of Astronomy,
;		ETH Zurich" is written in the lower right
;		corner of the paper (only in association 
;		with /PS).
;	/SXL: If present, the image is written in a SIXEL file
;	/REDUCEDFMT: with postscript, does not write the 
;		title of the image, the scale and the logo.
;	XMARKMODE, YMARKMODE: default: 'automatic'. Other value:
;		'range'. If set to the latter, the axes are always printed in
;		"range" mode, i.e. not pointing at the center of the pixels.
; SIDE EFFECTS:
; 	with /PS or /SXL, a file is written otherwise, a window is
;	opened.
; SEE ALSO:
;	enrad, axistime
; MODIFICATION HISTORY:
;	Created in April 1991 by A.Csillaghy
;		Institute of Astronomy, ETH Zurich
;	Rewritten in October 1991, A.Cs., merging
;		PostScript generation and Screen Display.
;	Sixel  added in Nov 92, A.Cs
;	Reduced annotations (REDUCEDFMT) and ticks length 
;		in postscript format added, respectively
;		modified in Jun 93, A.Cs
;	XMARKMODE, YMARKMODE in oct. 93, A.Csillaghy
;	titles display for PostScript changed, Nov, 93, A.Cs
; 	THIS IS THE IDL VERSION 5/96
;	Encapsulated problems in Sept 96 - ACs
;       Displaying image parts is better solved in Jan 98 - ACs
;       AxisTime routine call replaced by Set_UTAxis for 
;         compatibility with ssw.
;
;
;
;	HACKED by P. Saint-Hilaire on 2001/10/04 from "show_image.pro"
;	to be usable uner the Z-buffer. For this, 9 lines had to be 
;	commented out. Those lines all start with four semi-column (;;;;).
;
;	EXAMPLE USAGE:
;		old_device = !D.NAME
;		SET_PLOT, 'Z', /COPY
;		!ORDER=1
;		DEVICE, SET_RESOLUTION=[768,512]
;		ERASE
;		img=dist(100)
;		z_show_image,img,FINDGEN(100),FINDGEN(100),xpos=50,ypos=40,xsize=768,ysize=512
;		!ORDER=0
;		outimg=TVRD()
;		DEVICE, /CLOSE
;		SET_PLOT, old_device
;		window,xs=768,ys=512
;		tv,outimg
;
;-

  
PRO InitPs, fileName, encapsulated, landscape, xPos, yPos, $
	width, height, translationTable, blFont, CTNB = ctnb

;
; PURPOSE:
;	Opens the postscript file "filename" for writing 
;	the image, with the different options as parameters.
;

  COMMON Colors, red, green, blue, r, d2, d3
  
  Print, 'Creating Postscript file with name '+fileName+'.ps'

  Set_Plot,'PS'

  Plot, indgen(10)

  IF Keyword_Set( CTNB ) THEN BEGIN
   Loadct, ctnb
  ENDIF
  nElsRed = N_Elements(red)

  IF nElsRed NE 0 THEN BEGIN
    color = ( Max( red - green ) + Max( green - blue )  ) NE 0
    IF color EQ 1  THEN  BEGIN
      translationTable = IndGen(256)
      Device, /COLOR
    ENDIF ELSE translationTable = r ; B/W
  ENDIF ELSE translationTable = Indgen(!d.n_colors)


   IF landscape THEN BEGIN
     temporary = yPos & yPos = xPos+23 & xPos = temporary
   ENDIF
        
  IF encapsulated THEN BEGIN
    width = width + 7 & height = height + 7
  ENDIF

   Device,FILENAME=fileName+'.ps', BITS_PER_PIXEL=8,$
	    ENCAPSUL = encapsulated,  LANDSCAPE = landscape, $
	    XOFFSET= xPos, YOFFSET= yPos, $
	    XSIZE = width, YSIZE = height, $
	    /PALATINO, /BOLD

  IF blFont THEN $
    Tv, [[0,0],[0,0]], -100, -100, $
	XSIZE = width+1000, YSIZE = height+1000, $
	/CENTIMETERS
	
  !p.color = 255 * blFont 
  IF encapsulated THEN BEGIN
    Device, OUTPUT = '3500 1000 translate'
  ENDIF


END ; Init Ps
 
PRO DrawImage, image, xAxis, yAxis, xPos, yPos, widthP, heightP, $
	dist, dxBreaks, dyBreaks, ps

;
; PURPOSE:
;	Draws image on the device, with consideration of axes
;	breaks.
;

  IF ps THEN pixelPrinterLim = 1000

  nx = N_Elements( xAxis )
  ny = N_Elements( yAxis )
  nxBreaks = N_Elements( dxBreaks )
  nyBreaks = N_Elements( dyBreaks )

;------
; No need to split the image if dist is zero; therefore set the breaks
; to none; otherwise reduce the width and height of the display in
; order to insert a distance dist between two image parts.
;------
  IF dist EQ 0 THEN BEGIN
      nxBreaks = 2 & nyBreaks = 2
      dxBreaks = [0,nx-1] & dyBreaks = [0, ny-1]
      width = widthP
      height = heightP
  ENDIF ELSE BEGIN
      width =  widthP - dist*(N_Breaks( dxBreaks )-1)
      height = heightP - dist*(N_Breaks( dyBreaks )-1)
  ENDELSE

;------
; In some cases, the axes have so much breaks that the displayed images
; would consist only of empy space; in this case, reset the breaks.
;------
  IF width LT 0 THEN BEGIN
      Print,' Warning:  the X-axis has too much breaks, ' + $
	'they will not be handled '
      nxBreaks = 2
      dxBreaks = [0,nx-1]
      width =  widthP - dist*N_breaks(dxbreaks)
  ENDIF  
  IF height LT 0  THEN BEGIN
      Print,' Warning:  the Y-axis has too much breaks, ' + $
	'they will not be handled '
      nyBreaks = 2
      dyBreaks = [0,ny-1]
      height = heightP - dist*N_Breaks(dybreaks)
  ENDIF

;------
; Start of the iterations for displaying the image parts
;------
  y = ypos                      ; position of the image part
  yidx = 0                      ; current index of the break
  REPEAT BEGIN
      ymin = dybreaks(yidx)
      IF (yidx EQ nybreaks-1) THEN BEGIN
          ymax = ymin
          yidx = yidx+1
      ENDIF ELSE IF dybreaks(yidx+1) EQ dybreaks(yidx)+1 THEN BEGIN
          ymax = ymin
          yidx = yidx+1
      ENDIF ELSE BEGIN
          ymax = dybreaks(yidx+1)
          yidx = yidx+2
      ENDELSE                               
      partheight = (height*(ymax-ymin+1)/ny)>1 ; larger than 1 pixel
      x = xpos
      xidx = 0
      REPEAT BEGIN
          xmin = dxbreaks(xidx)
          IF (xidx EQ nxbreaks-1) THEN BEGIN
              xmax = xmin
              xidx = xidx+1
          ENDIF ELSE IF dxbreaks(xidx+1) EQ dxbreaks(xidx)+1 THEN BEGIN
              xmax = xmin
              xidx = xidx+1
          ENDIF ELSE BEGIN
              xmax = dxbreaks(xidx+1)
              xidx = xidx+2
          ENDELSE                               
          partwidth = (width*(xmax-xmin+1)/nx)>1 ; larger than 1 pixel
;------
; Draw the image part
;------
          IF ps THEN BEGIN
              xRange = xMax-xMin+1
              yRange = yMax-yMin+1
              IF yMin NE yMax THEN BEGIN
                  Tv, ConGrid( image( xMin:xMax, yMin: yMax ), $
                               xRange < pixelPrinterLim, $
                               yRange < pixelPrinterLim ),  $
                    x, y, XSIZE = partwidth, YSIZE = partheight
              ENDIF ELSE BEGIN
                  Tv, ConGrid( [[image( xMin:xMax, yMin )], $
                                [image( xMin:xMax, yMin )]], $
                               xRange < pixelPrinterLim, $
                               yRange < pixelPrinterLim > 2),  $
                    x, y, XSIZE = partwidth, YSIZE = partheight
              ENDELSE
          ENDIF ELSE IF yMin NE yMax THEN BEGIN
              Tv, ConGrid(image(xMin:xMax,yMin:yMax), $
                          partwidth, partheight), x, y 
          ENDIF ELSE BEGIN
              Tv, ConGrid( [ [image(xMin:xMax,yMin)], $
                             [image(xMin:xMax,yMin) ] ], $
                           partwidth, partheight), x, y 
          ENDELSE
;------
; Increment loop variables (indexes incremented at the top of the loop)
;------
          x = x + dist + partwidth         
          
      END UNTIL xidx GT (nxBreaks-1)
    
      y = y + dist + partheight

  END UNTIL yidx GT (nyBreaks-1)
    
END ; Draw Image


PRO DrawAxis, axis, xPos, yPos, lengthP, distP, breaks, fileWrite, markMode, $
	XDIR = xDir, YDIR = yDir, HMS = hms, $
	AXISTYPE = axisType, NOLABELS = noLabels, $
	TITLE = title

;------
; PURPOSE: 
;	Draws the axes around the image, with consideration 
;	of axes breaks
;------

  IF NOT Keyword_Set( YDIR ) THEN dir = 'X'  ELSE dir = 'Y'
  IF NOT Keyword_Set( AXISTYPE ) THEN axisType = 0
  IF NOT Keyword_Set( TITLE ) THEN title = ''
  IF Keyword_Set( NOLABELS ) THEN charSize = 0.01 $
  ELSE IF dir EQ 'X' THEN charSize = !x.charSize ELSE charSize = !y.charsize
  IF charSize EQ 0 THEN charSize = 1
  IF !p.charSize EQ 0 THEN !p.charSize = 1

  charSize = !p.charSize*charSize
  oldPos = !p.position
  !p.position = [ 0.0, 0.0, 1.0, 1.0 ]

  IF dir EQ 'X' THEN BEGIN
    siz = !d.x_size & pos = Double( xPos ) / siz
    xAxis = 1 & yAxis = 0
    oldWin = !x.window
    !x.window = [ pos, (pos + lengthP)/!d.x_size ]
    IF fileWrite AND NOT Keyword_Set( NOLABELS ) THEN BEGIN
      charHeight = !d.y_ch_size*charSize
      textLen = StrLen( title )*!d.x_ch_size*!x.charSize
      XYOuts, xPos + lengthP/2, ALIGNMENT = 0.5, $
	yPos- 2.5*charHeight, title,  /DEVICE, $
	CHARSIZE = charsize
    ENDIF
  ENDIF ELSE BEGIN
    siz = !d.y_size & pos = Double( yPos )  / siz
    yAxis = 1 & xAxis = 0
    oldWin = !y.window
    !y.window = [ pos, ( pos + lengthP ) / !d.y_size ]
    IF fileWrite AND NOT Keyword_Set( NOLABELS ) THEN BEGIN
      textLen = StrLen( title )*!d.x_ch_size*!y.charsize
      nbChars = Max( StrLen( StrTrim( Fix(axis), 2 ) ) ) + 1
      charLength = !d.x_ch_size*charSize
      XYOuts, xPos - nbChars*charLength - !d.y_ch_size, yPos + lengthP/2, $
	title, /DEVICE, ORIENTATION = 90, CHARSIZE = charsize, $
	ALIGNMENT = 0.5
    ENDIF
  ENDELSE
  
  n = N_Elements( axis ) 
  nBr = N_Elements( breaks )
  length = lengthP - distP*(N_Breaks(breaks)-1)
  index = 0 
  factor = Double(length)/n 
  dist = Double(distP) / siz
  dispLimit = 3.*(fileWrite EQ 0)+  150.*fileWrite

  WHILE index LT nBr DO BEGIN

    brMin = breaks(index)
    brMax = breaks((index+1) < (nBr-1))
    brMax = brMax*( brMax NE brMin+1 ) + $
	brMin*( brMax EQ brMin+1 )
    rangePix = (brMax - brMin) + 1
    rangeDev = Double(rangePix * factor) 
    range = rangeDev / siz

    axisRange = [axis(brMin), axis(brMax) ]

    IF (rangePix GT 1)  AND (axisRange(0) NE axisRange(1)) $
	THEN BEGIN

      charDev = !d.x_ch_size*15*(dir EQ 'X') + $
	!d.y_ch_size*(dir EQ 'Y') + 2*!p.charthick
      IF rangeDev LT charDev*4  THEN BEGIN
         ticks = Fix( rangeDev/charDev ) > 1
         IF rangeDev LT charDev THEN tickName = [' ',' ', ' '] $
         ELSE tickName = [' ', '', ' ','', ' ', '', ' '] 
      ENDIF ELSE BEGIN
          tickName = [''] 
          ticks = Fix( (rangePix-1)* $
	( factor GT (10 *(fileWrite EQ 0) + 300*fileWrite)) ) 
          WHILE ticks GT 15 DO ticks = ticks / 2 + $
	1*( rangePix MOD 2 EQ 0)
        
      ENDELSE
    
      style = 1 
      IF markMode EQ 'range' THEN BEGIN
        exactOffsetNorm = 0 
        ticks = 0
      ENDIF ELSE exactOffsetNorm = factor / (2*siz)
      axisWindow=[pos+exactOffsetNorm,  pos+range-exactOffsetNorm]

      IF dir EQ 'X' THEN BEGIN 
        !x.window  = axisWindow
        IF Keyword_Set( HMS ) THEN BEGIN
;	AxisTime, yPos, axisRange, fileWrite, $
;	  	AXISTYPE = axisType, $
;	  	NOLABELS = noLabels, CHARSIZE = charsize $
            SetUTBase, '79/01/01, 00:00:00'
            xAxis = Set_UTAxis( axisRange )
            !x = xAxis
            !x.window = axisWindow
            Axis,  xPos, yPos, /DEVICE, XRANGE = axisRange,  $
              CHARSIZE = charSize, XAXIS = axisType, $
              XTITLE = '', XSTYLE = style
        ENDIF ELSE BEGIN 
          IF Total( !x.tickname ne '' ) NE 0 THEN tickName = !x.tickName
          IF !x.ticks NE 0 THEN ticks = !x.ticks
          Axis,  xPos, yPos, /DEVICE, XRANGE = axisRange,  $
		CHARSIZE = charSize, XAXIS = axisType, $
		XTICKS = ticks, XTITLE = '', $
		XTICKNAME = tickName, XSTYLE = style
        ENDELSE
      ENDIF ELSE BEGIN
        !y.window = axisWindow
        IF Total( !y.tickname ne '' ) NE 0 THEN tickName = !y.tickName
        IF !y.ticks NE 0 THEN ticks = !y.ticks
        Axis, xPos, yPos, /DEVICE, YRANGE = axisRange, $
		YAXIS = axisType, CHARSIZE = charSize, $
		YTITLE = '', $
		YTICKS = ticks, YTICKNAME = tickName, $
		YSTYLE = style

      ENDELSE
     
    ENDIF

    index =index + 1 + 1*(brMin NE brMax) 
    pos = pos + dist + range

  ENDWHILE
  
  !p.position = oldPos
  IF dir EQ 'X' THEN !x.window = oldWin ELSE !y.window = oldWin
	 
END ; Draw Axis
  

PRO DrawScale, xPos, yPos, scaleLength, scaleHeight, ps, table, reverse


; PURPOSE
;	Draws the scale above the axis.

;  device, decompose=0, bypass=0
  scale = long((!d.table_size-2 > 0) *  findgen(256) / 256. )
;  scale = long((!d.n_colors-2 > 0) *  findgen(256) / 256. )
;  scale = BIndGen( (!d.n_colors-2)>0 )+1
  scale = [[scale],[ scale]]
  IF NOT ps THEN $
	Tv, ConGrid( scale, scaleLength, scaleHeight), xPos, yPos $
  ELSE  Tv, table( scale )*( reverse EQ 0 ) + $
	(NOT table(scale))*(reverse EQ 1), xPos, yPos,  $
      XSIZE = scaleLength, YSIZE = scaleHeight
 
END ; Draw Scale

;*******************************************************************************
;*******************************************************************************
;*******************************************************************************
;*******************************************************************************
;*******************************************************************************

PRO z_Show_Image, imageP, xAxis, yAxis, $
	XPOS = xPos, YPOS = yPos, HMS = hms, $
	XSIZE = xSize, YSIZE = ySize, $
	XTITLE = xTitle, YTITLE = yTitle,  $
	ZTITLE = zTitle, TITLE = title, $
	WINNR = winNr,  LOGO = logo, SXL = sxl,  $
	SIZES_ON = sizes_on, SCALEHEIGHT = scaleHeight, $
	WNAME = wName, PS = ps, FILENAME = fileName, $
	IMAGEOFFSET = imageOffset, $
	AXISOFFSET = axisOffset,  REVERSE = reverse, $
	ENCAPSULATED = encapsulated, $
	REDUCEDFMT = reducedFmt, PORTRAIT = portrait, $
	XMARKMODE = xMarkMode, YMARKMODE = yMarkMode, $
	NOMINMAX = noMinMax, BLFONT = blFont, $
    CTNB = ctnb

  On_Error, 0

;;;;  IF !d.name NE 'X' THEN BEGIN
;;;;    Error, 3, 'Show_Image'
;;;;    RETURN
;;;;  ENDIF

; Check parameters

  nbParams = N_Params()
  IF nbParams EQ 0 THEN BEGIN  Error, 1 & RETURN & ENDIF
  minIm = Double( Min( imageP ))
  maxIm = Double( Max( imageP ))
  image = BytScl( imageP, TOP = !d.n_colors-3 ) + 1B

  nx = N_Elements( image(*, 0) )
  ny = N_Elements( image(0,* ) )
  IF nx LT 1 OR ny LT 1 THEN RETURN

  IF nbParams EQ 1 THEN BEGIN
    xAxis = LIndGen( nx ) 
    yAxis = LIndGen( ny )
  ENDIF ELSE IF nbParams NE 3 THEN BEGIN
    Error, 4,'Show Image'
    RETURN
  ENDIF


; Variable init, keywords testing

  IF NOT Keyword_Set( HMS ) THEN hms = 0
  IF NOT KeyWord_Set( FILENAME ) THEN filename = 'ragview'

  ps =  Keyword_Set( PS ) 
  sxl = Keyword_Set( SXL )
  notPs = ps EQ 0
  notSxl = sxl EQ 0
  fileWrite = ps OR sxl
  notFileWrite = (ps EQ 0) AND (sxl EQ 0)

  IF Keyword_Set( SIZES_ON ) THEN BEGIN

    reducedFmt = 0
    GetMarksMode, xMarkMode, yMarkMode
    GetWinSize, xSize, ySize, PS = fileWrite
    hms = getHMS()
    GetImageSizes, xPos, yPos, width, height, scaleHeight, $
	PS = fileWrite
    GetOffsets, axisOffset, imageoffset, PS = fileWrite
    IF fileWrite THEN $
	GetMiscPs, encapsulated, landscape, reverse, blFont, $
		reducedFmt, noMinMax

  ENDIF ELSE BEGIN

     IF NOT Keyword_Set(XPOS) THEN $
	xPos = 45L*notFileWrite + 2.*fileWrite
     IF NOT Keyword_Set(YPOS) THEN $
	yPos = 36L*notFileWrite + 5.*fileWrite
     IF NOT Keyword_Set(XSIZE) THEN $
	xSize = 600L*notFileWrite + 15.*fileWrite
     IF NOT Keyword_Set(YSIZE) THEN $
	ySize = 600L*notFileWrite + 11.*fileWrite
     IF NOT Keyword_Set(SCALEHEIGHT) THEN $
	scaleHeight = 20L*notFileWrite + 0.5*fileWrite
     IF NOT Keyword_Set(AXISOFFSET) THEN $
	axisOffset = 15L*notFileWrite + 0.5*fileWrite ; in cm
     IF NOT Keyword_Set(REDUCEDFMT) THEN $
	reducedFmt = 0L
     IF NOT Keyword_Set(XMARKMODE) THEN $
	xMarkMode = 'automatic'
     IF NOT Keyword_Set(YMARKMODE) THEN $
	yMarkMode = 'automatic'
     IF NOT Keyword_Set(NOMINMAX) THEN $
	noMinMax = 1
     IF N_Elements( imageOffset ) EQ 0 THEN $
  	imageoffset = 5L*notFileWrite + 0.1*fileWrite ; in cm

     width = xSize - (2*xPos)*(notFileWrite) 
     height = ySize - (2*yPos)*(notFileWrite) - scaleHeight*2 

     Init_Display
     PutMarksMode, xMarkMode, yMarkMode
     PutWinSize, xSize, ySize, PS = ps
     PutImageSize, xPos, yPos, width, height, scaleHeight, PS = ps
     PutOffsets, axisOffset, imageOffset, PS = ps
     PutHMS, hms
     IF fileWrite THEN BEGIN
       IF NOT Keyword_Set( ENCAPSULATED ) THEN $
	encapsulated = 0 $
       ELSE encapsulated = 1
       IF Keyword_Set( PORTRAIT ) THEN landscape  = 0 $
	ELSE landscape = 1
       IF NOT Keyword_Set( REVERSE ) THEN reverse = 0
       IF NOT Keyword_Set( BLFONT ) THEN blFont = 0
   
       PutMiscPS, encapsulated, landscape, reverse, blFont, reducedFmt, noMinMax

    ENDIF

  ENDELSE

  oldP = !p & oldX = !x & oldY = !y
  IF !x.charsize EQ 0 THEN  !x.charsize=1.0
  IF !y.charsize EQ 0 THEN  !y.charsize=1.0
  IF !p.charsize EQ 0 THEN  !p.charsize=1.0

  scaleOffset = 20*notFileWrite + 100*ps + 7*sxl

  dxBreaks = FindBreaks( xAxis  )
  dyBreaks = FindBreaks( yAxis  )
 
  PutBreaks, dxBreaks, dyBreaks

  lastX = xPos + width + axisOffset
  lastY = yPos + height + axisOffset

  xAxisPos = xPos - axisOffset
  yAxisPos = yPos - axisOffset

; all the distances must be calculated here because sixel must know
; the total size
; all constants for ps or sxl are defined here

  IF fileWrite THEN BEGIN
    !x.thick = 5
    !y.thick = 5
    !p.thick = 5
    oldDevice = !d.name
    IF reverse THEN image = NOT( image )
    printFactor = 1000L ; 1/1000 cm is the unit
    tickBorderLen = 300
    titleOffset = 1500
    logoOffset = 1000
    IF reducedFmt THEN minTextOffset = 50 $
    ELSE minTextOffset = 750

    xPosCm = xPos & yPosCm = yPos 
    widthCm = width & heightCm = height
    lastXCm = lastX & lastYCm = lastY

    xPos = xPos*printFactor  & yPos = yPos*printFactor
    width = width*printFactor & height = height*printFactor
    scaleHeight =  scaleHeight*printFactor
    lastX = lastX*printFactor & lastY = lastY*printFactor
    xAxisPos = xAxisPos*printFactor & yAxisPos = yAxisPos*printFactor

    InitPs, fileName, encapsulated, landscape, $
	  xPosCm, yPosCm, $
	  widthCm, heightCm, translationTable, blFont, CTNB = ctnb 

    image = translationTable( image )

    IF NOT Keyword_Set(TITLE) THEN title= !p.title
    IF NOT Keyword_Set(XTITLE) THEN xTitle = !x.title 
    IF NOT Keyword_Set(YTITLE) THEN yTitle = !y.title
    IF NOT Keyword_Set(ZTITLE) THEN zTitle = !z.title
 
    XYOuts, xPos, lastY+  8*minTextOffset*(reducedFmt EQ 1) + $
	titleOffset*(reducedFmt EQ 0),  $
	title, /DEVICE, CHARSIZE = !p.charSize
    IF  noMinMax  EQ 0 THEN BEGIN
      XYOuts, xPos, lastY+minTextOffset, 'min = ' + StrTrim( minIm, 2 ), $
	/DEVICE,  SIZE = 0.8, CHARSIZE = !p.charSize
      XYOuts, xPos + width/3 + (width/3)*reducedFmt, $
	lastY + minTextOffset, ' max = ' + $
	StrTrim( maxIm, 2 ) , /DEVICE, SIZE = 0.8, CHARSIZE = !p.charSize
    ENDIF
    IF zTitle NE '' AND NOT reducedFmt THEN $
	XYOuts, xPos+width/1.5, lastY + minTextOffset, $
	'z scale: ' + zTitle, $
	/DEVICE, SIZE = 0.8, CHARSIZE = !p.charSize
    IF Keyword_Set( LOGO ) AND NOT reducedFmt THEN BEGIN
      IF ps THEN BEGIN
        IF logo EQ 1 THEN logo = 'Institute of Astronomy, ETH Zurich'
        Device, /HELVETICA, /OBLIQUE
      ENDIF ELSE BEGIN
         IF logo EQ 1 THEN $
	logo = '!18Institute of Astronomy, ETH Zurich'
       ENDELSE
       XYOuts, xPos+width/1.5, yAxisPos - logoOffset, $
	'Institute of Astronomy, ETH Zurich', $
	/DEVICE, SIZE = 0.8
       IF ps THEN Device, /TIMES
    ENDIF

  ENDIF ELSE BEGIN

    blFont = 0
    IF (N_Elements(winNr) EQ 0) AND ( !d.window EQ -1 ) $
	THEN BEGIN
      winNr = 0 
    ENDIF ELSE IF (N_Elements( winNr ) EQ 0 ) THEN $
      winNr= (!d.window)  
    IF NOT Keyword_Set(WNAME) THEN wName = ''
;;;;    IF winNr EQ -1 OR xSize NE !d.x_size OR ySize NE !d.y_size $
;;;;	OR winNr NE !d.window THEN $
;;;;      Window, winNr, TITLE = "Enrad 2D display", XSIZE = xSize, YSIZE = ySize, $
;;;;	COLORS = -1 $
;;;;    ELSE Erase
    xTitle ='' & yTitle = '' & zTitle = ''& title = ''
  ENDELSE
 
; Main Program

  DrawImage,  image, xAxis, yAxis,  xPos, yPos, width, height, $
	imageoffset, dxBreaks, dyBreaks, ps

  DrawAxis, xAxis, xPos, yAxisPos, width, imageoffset, $
	 dxBreaks, fileWrite, xMarkMode, /XDIR, $
	HMS = hms, TITLE = xTitle

  DrawAxis, yAxis, xAxisPos, yPos, height, imageoffset, $
	dyBreaks,  fileWrite , yMarkMode, $
	 /YDIR, TITLE = yTitle

  DrawAxis, xAxis, xPos,  lastY, width, $
	imageoffset, dxBreaks, fileWrite, xMarkMode, $
	 /XDIR, HMS = hms, $
	/NOLABELS, AXISTYPE = 1
  DrawAxis, yAxis, lastX, $
	yPos, height, imageoffset, dyBreaks, fileWrite, yMarkMode, /YDIR, $
	/NOLABELS, AXISTYPE = 1

  Plots, [ xAxisPos, lastX, lastX, xAxisPos, xAxisPos ], $
	[ yAxisPos, yAxisPos, lastY, lastY, yAxisPos ], /DEVICE

  IF NOT reducedFmt THEN $ 
    DrawScale,xPos + (width/4 )*notFileWrite, lastY+scaleOffset, $
	width/2,  scaleHeight, ps, translationTable, reverse

  IF fileWrite THEN BEGIN
    Device, /CLOSE
    Set_Plot,oldDevice
    IF encapsulated THEN BEGIN
      Spawn, 'sed /showpage/d ' + fileName + '.ps  >  /tmp/temp.ps'
      Spawn, 'mv /tmp/temp.ps ' + fileName + '.ps'
    ENDIF
  ENDIF

  !p = oldP & !x = oldX & !y = oldY
 
END ; Show Image


