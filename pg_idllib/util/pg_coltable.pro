;+
; NAME:
;
; pg_coltable
;
; PURPOSE:
;
; loads a nice color table...
;
; CATEGORY:
;
; utilties (color)
;
; CALLING SEQUENCE:
;
; 
;
; INPUTS:
;
;
;
; OPTIONAL INPUTS:
;
;
;
; KEYWORD PARAMETERS:
;
;
;
; OUTPUTS:
;
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
; Paolo Grigis, Institute for Astronomy, ETH Zurich
; pgrigis@astro.phys.ethz.ch
;
; MODIFICATION HISTORY:
;
; 16-DEC-2004 written
;
;-

PRO pg_coltable,show=show,inverse=inverse,no_overwrite=no_overwrite,manycolors=manycolors


;color table
;    BLACK BLUE RED  GREENYELLW MAGENTA CYAN WHITE
red  =[0B, 0B  ,255B,   0B, 255B,255B,    0B,255B]
green=[0B, 0B  ,  0B, 255B, 255B,  0B,  255B,255B]
blue =[0B, 255B,  0B,   0B,   0B,255B,  255B,255B]


IF keyword_set(manycolors) THEN BEGIN 
   names =  ['White']
   rvalue = [ 255]
   gvalue = [ 255]
   bvalue = [ 255]
   names  = [ names,        'Snow',     'Ivory','Light Yellow',   'Cornsilk',      'Beige',   'Seashell' ]
   rvalue = [ rvalue,          255,          255,          255,          255,          245,          255 ]
   gvalue = [ gvalue,          250,          255,          255,          248,          245,          245 ]
   bvalue = [ bvalue,          250,          240,          224,          220,          220,          238 ]
   names  = [ names,       'Linen','Antique White',    'Papaya',     'Almond',     'Bisque',  'Moccasin' ]
   rvalue = [ rvalue,          250,          250,          255,          255,          255,          255 ]
   gvalue = [ gvalue,          240,          235,          239,          235,          228,          228 ]
   bvalue = [ bvalue,          230,          215,          213,          205,          196,          181 ]
   names  = [ names,       'Wheat',  'Burlywood',        'Tan', 'Light Gray',   'Lavender','Medium Gray' ]
   rvalue = [ rvalue,          245,          222,          210,          230,          230,          210 ]
   gvalue = [ gvalue,          222,          184,          180,          230,          230,          210 ]
   bvalue = [ bvalue,          179,          135,          140,          230,          250,          210 ]
   names  = [ names,        'Gray', 'Slate Gray',  'Dark Gray',   'Charcoal',      'Black', 'Light Cyan' ]
   rvalue = [ rvalue,          190,          112,          110,           70,            0,          224 ]
   gvalue = [ gvalue,          190,          128,          110,           70,            0,          255 ]
   bvalue = [ bvalue,          190,          144,          110,           70,            0,          255 ]
   names  = [ names, 'Powder Blue',   'Sky Blue', 'Steel Blue','Dodger Blue', 'Royal Blue',       'Blue' ]
   rvalue = [ rvalue,          176,          135,           70,           30,           65,            0 ]
   gvalue = [ gvalue,          224,          206,          130,          144,          105,            0 ]
   bvalue = [ bvalue,          230,          235,          180,          255,          225,          255 ]
   names  = [ names,        'Navy',   'Honeydew', 'Pale Green','Aquamarine','Spring Green',       'Cyan' ]
   rvalue = [ rvalue,            0,          240,          152,          127,            0,            0 ]
   gvalue = [ gvalue,            0,          255,          251,          255,          250,          255 ]
   bvalue = [ bvalue,          128,          240,          152,          212,          154,          255 ]
   names  = [ names,   'Turquoise', 'Sea Green','Forest Green','Green Yellow','Chartreuse', 'Lawn Green' ]
   rvalue = [ rvalue,           64,           46,           34,          173,          127,          124 ]
   gvalue = [ gvalue,          224,          139,          139,          255,          255,          252 ]
   bvalue = [ bvalue,          208,           87,           34,           47,            0,            0 ]
   names  = [ names,       'Green', 'Lime Green', 'Olive Drab',     'Olive','Dark Green','Pale Goldenrod']
   rvalue = [ rvalue,            0,           50,          107,           85,            0,          238 ]
   gvalue = [ gvalue,          255,          205,          142,          107,          100,          232 ]
   bvalue = [ bvalue,            0,           50,           35,           47,            0,          170 ]
   names  = [ names,       'Khaki', 'Dark Khaki',     'Yellow',       'Gold','Goldenrod','Dark Goldenrod']
   rvalue = [ rvalue,          240,          189,          255,          255,          218,          184 ]
   gvalue = [ gvalue,          230,          183,          255,          215,          165,          134 ]
   bvalue = [ bvalue,          140,          107,            0,            0,           32,           11 ]
   names  = [ names,'Saddle Brown',       'Rose',       'Pink', 'Rosy Brown','Sandy Brown',       'Peru' ]
   rvalue = [ rvalue,          139,          255,          255,          188,          244,          205 ]
   gvalue = [ gvalue,           69,          228,          192,          143,          164,          133 ]
   bvalue = [ bvalue,           19,          225,          203,          143,           96,           63 ]
   names  = [ names,  'Indian Red',  'Chocolate',     'Sienna','Dark Salmon',    'Salmon','Light Salmon' ]
   rvalue = [ rvalue,          205,          210,          160,          233,          250,          255 ]
   gvalue = [ gvalue,           92,          105,           82,          150,          128,          160 ]
   bvalue = [ bvalue,           92,           30,           45,          122,          114,          122 ]
   names  = [ names,      'Orange',      'Coral', 'Light Coral',  'Firebrick',      'Brown',  'Hot Pink' ]
   rvalue = [ rvalue,          255,          255,          240,          178,          165,          255 ]
   gvalue = [ gvalue,          165,          127,          128,           34,           42,          105 ]
   bvalue = [ bvalue,            0,           80,          128,           34,           42,          180 ]
   names  = [ names,   'Deep Pink',    'Magenta',     'Tomato', 'Orange Red',        'Red', 'Violet Red' ]
   rvalue = [ rvalue,          255,          255,          255,          255,          255,          208 ]
   gvalue = [ gvalue,           20,            0,           99,           69,            0,           32 ]
   bvalue = [ bvalue,          147,          255,           71,            0,            0,          144 ]
   names  = [ names,      'Maroon',    'Thistle',       'Plum',     'Violet',    'Orchid','Medium Orchid']
   rvalue = [ rvalue,          176,          216,          221,          238,          218,          186 ]
   gvalue = [ gvalue,           48,          191,          160,          130,          112,           85 ]
   bvalue = [ bvalue,           96,          216,          221,          238,          214,          211 ]
   names  = [ names, 'Dark Orchid','Blue Violet',     'Purple',    'Mybrown' ]
   rvalue = [ rvalue,          153,          138,          160,         154  ]
   gvalue = [ gvalue,           50,           43,           32,         118  ]
   bvalue = [ bvalue,          204,          226,          240,         14 ]

ENDIF



;normal color table
IF NOT keyword_set(no_overwrite) THEN BEGIN 
   loadct,0
ENDIF

tvlct,r,g,b,/get

IF keyword_set(inverse) THEN BEGIN 
   r=reverse(r)
   g=reverse(g)
   b=reverse(b)
ENDIF


r[1:8]=red
g[1:8]=green
b[1:8]=blue

IF keyword_set(manycolors) THEN BEGIN
   r=bytarr(256)
   g=bytarr(256)
   b=bytarr(256)

   r[0]=rvalue
   g[0]=gvalue
   b[0]=bvalue

ENDIF


tvlct,r,g,b


IF keyword_set(show) THEN BEGIN 

   wdef,1,512,512
   testim=congrid(bindgen(16,16),512,512)
   tv,testim

   r2=r
   g2=g
   b2=b
   r2[0]=0B
   g2[0]=0B
   b2[0]=0B
   r2[255]=255B
   g2[255]=255B
   b2[255]=255B
   tvlct,r2,g2,b2

   FOR i=0,16 DO FOR j=0,16 DO BEGIN
      xyouts,i*32-20,j*32+12,string(i+j*16),/device,color=0,charthick=5
      xyouts,i*32-20,j*32+12,string(i+j*16),/device,color=255,charthick=1
   ENDFOR

   tvlct,r,g,b;,/get

ENDIF


;inverse color table

; loadct,0
; tvlct,r,g,b,/get

; r[1:8]=red
; g[1:8]=green
; b[1:8]=blue
; tvlct,r,g,b

; wdef,2,512,512
; testim=congrid(bindgen(16,16),512,512)
; tv,testim

  
   
END
