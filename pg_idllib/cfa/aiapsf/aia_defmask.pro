;+
; NAME:
;
;    aia_defmask
;
; PURPOSE:
;
;    define useful masks to analyize diffraction spikes
;
; CATEGORY:
;
;    AIA PSF
;
; CALLING SEQUENCE:
;
;    aia_defmask,xmask=xmask,ymask=ymask,x2mask=xmask2,y2mask=ymask2 $
;               ,xedge=xmaskedge,yedge=ymaskedge,x2edge=xmaskedge2,y2edge=ymaskedge2
;
;
; INPUTS:
;
;    NONE
;
; OPTIONAL INPUTS:
;
;    NONE
;
; KEYWORD PARAMETERS:
;
;    NONE
;
; OUTPUTS:
;
;    various masks
;
; OPTIONAL OUTPUTS:
;
;    NONE
;
; COMMON BLOCKS:
;
;    NONE
;
; SIDE EFFECTS:
;
;    NONE
;
; RESTRICTIONS:
;  
;    NONE known
;
; PROCEDURE:
; 
;    
;
; EXAMPLE:
;
;
;
; MODIFICATION HISTORY:
;
;
;   written 2011/04/04 Paolo Grigis
;   pgrigis@cfa.harvard.edu
;-


PRO aia_defmask,xmask=xmask,ymask=ymask,x2mask=xmask2,y2mask=ymask2 $
               ,xedge=xmaskedge,yedge=ymaskedge,x2edge=xmaskedge2,y2edge=ymaskedge2


;mask
xmask=[              0, 1, 2, 3, 4, $
                 -1, 0, 1, 2, 3, 4, $
              -2,-1, 0, 1, 2, 3, 4, $
           -3,-2,-1, 0, 1, 2, 3, 4, $
        -4,-3,-2,-1, 0, 1, 2, 3, 4, $
        -4,-3,-2,-1, 0, 1, 2, 3,    $
        -4,-3,-2,-1, 0, 1, 2,       $
        -4,-3,-2,-1, 0, 1,          $
        -4,-3,-2,-1, 0              ]

ymask=[              4, 4, 4, 4, 4, $
                  3, 3, 3, 3, 3, 3, $
               2, 2, 2, 2, 2, 2, 2, $
            1, 1, 1, 1, 1, 1, 1, 1, $
         0, 0, 0, 0, 0, 0, 0, 0, 0, $
        -1,-1,-1,-1,-1,-1,-1,-1,    $
        -2,-2,-2,-2,-2,-2,-2,       $
        -3,-3,-3,-3,-3,-3,          $
        -4,-4,-4,-4,-4              ]



xmask2=[-4,-3,-2,-1, 0,             $
        -4,-3,-2,-1, 0, 1,          $
        -4,-3,-2,-1, 0, 1, 2,       $
        -4,-3,-2,-1, 0, 1, 2, 3,    $
        -4,-3,-2,-1, 0, 1, 2, 3, 4, $
           -3,-2,-1, 0, 1, 2, 3, 4, $
              -2,-1, 0, 1, 2, 3, 4, $
                 -1, 0, 1, 2, 3, 4, $
                     0, 1, 2, 3, 4  ]

ymask2=[ 4, 4, 4, 4, 4,             $
         3, 3, 3, 3, 3, 3,          $
         2, 2, 2, 2, 2, 2, 2,       $
         1, 1, 1, 1, 1, 1, 1, 1,    $
         0, 0, 0, 0, 0, 0, 0, 0, 0, $
           -1,-1,-1,-1,-1,-1,-1,-1, $
              -2,-2,-2,-2,-2,-2,-2, $
                 -3,-3,-3,-3,-3,-3, $
                    -4,-4,-4,-4,-4  ]



xmaskedge=[-4.5, 0.5, 0.5, 1.5, 1.5, 2.5, 2.5, 3.5, 3.5, 4.5,4.5,-0.5,-0.5,-1.5,-1.5,-2.5,-2.5,-3.5,-3.5,-4.5,-4.5]
ymaskedge=[-4.5,-4.5,-3.5,-3.5,-2.5,-2.5,-1.5,-1.5,-0.5,-0.5,4.5, 4.5, 3.5, 3.5, 2.5, 2.5, 1.5, 1.5, 0.5, 0.5,-4.5]

xmaskedge2=[-4.5,-3.5,-3.5,-2.5,-2.5,-1.5,-1.5,-0.5,-0.5, 4.5, 4.5, 3.5, 3.5, 2.5, 2.5, 1.5, 1.5, 0.5, 0.5,-4.5,-4.5]
ymaskedge2=[-0.5,-0.5,-1.5,-1.5,-2.5,-2.5,-3.5,-3.5,-4.5,-4.5, 0.5, 0.5, 1.5, 1.5, 2.5, 2.5, 3.5, 3.5, 4.5, 4.5,-0.5]


END 
