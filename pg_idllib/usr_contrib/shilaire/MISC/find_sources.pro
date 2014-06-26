; PSH, May 2001		shilaire@astro.phys.ethz.ch OR psainth@hotmail.com

; INPUT : an image
; OUTPUT : an array of sources
;	n_sources
;	pos
; this program finds sources in an image, an outputs the sources' location
;
; N_SIGMA : number of sigmas above (poissonian) background... default is 5 sigmas
; LOW (as in LOWER LIMIT) is the minimum pixel brightness, relative to strongest in image,
;	to still accept as source (ex: for HXT images, low>~0.1) (default is 0.1)
;this routine takes the stringiest of the two above conditions
; BACK_PIX is the proportion of background pixels to take (default is 0.1 or 10%)
;
; OPTIONAL KEYWORD INPUT:
;	SMOOTH: set to a value (typically 3 or 5) to smooth image first.
;
; EXAMPLES:
;	find_sources,img,nb_sources
;	find_sources,img,nb_sources,positions,n_sigma=3,back_pix=0.2,low=0.1,/quiet
;
; RESTRICTIONS :-don't use use saturated images or images which have 
;		constant-valued extended sources (this routine will ignore them !)
;		- eventual sources right at the edges of the image are not checked for
;
;
;	Modification: 2002/01/15 PSH added SMOOTH keyword
;


;*******************************************************************************
PRO get_backgnd_mu_sigma,img,back_pix,mu,sigma
;calculate mu and sigma of background pixels		
Ntot=n_elements(img)
tmp_img=img
mc=0.	; maxima counter
X=min(tmp_img,ss)	; array of values that'll be used for computing mu and sigma
tmp_img(ss)=max(tmp_img)
maxval=max(img)
WHILE mc le float(back_pix)*Ntot do begin
	X=[X,min(tmp_img,ss)]
	if min(tmp_img,ss) eq maxval then print,'............................Too many background points !!!'
	tmp_img(ss)=max(tmp_img)
	mc=mc+1.
ENDWHILE

mu=mean(X)
sigma=stddev(X)
END
;*******************************************************************************
;*******************************************************************************
FUNCTION find_local_maxima,img,limit

s=size(img)
out=-1

for i=1,S[1]-2 do begin
	for j=1,S[2]-2 do begin
				
				; check if current pixel is a valid local maximum
				curval=img(i,j)
	if curval ge limit then if img(i-1,j-1) lt curval then 		$
				if img(i-1,j) lt curval then 		$
				if img(i-1,j+1) lt curval then 		$
				if img(i,j-1) lt curval then 		$
				if img(i,j+1) lt curval then 		$
				if img(i+1,j-1) lt curval then 		$
				if img(i+1,j) lt curval then 		$
				if img(i+1,j+1) lt curval then 		$
				if datatype(out) eq 'STC' then out=merge_struct(out,{x:i,y:j}) ELSE out={x:i,y:j}	
	endfor
endfor
RETURN,out
END
;*******************************************************************************





;*******************************************************************************
PRO find_sources,inimg,n_sources,	pos,			$
				n_sigma=n_sigma,	$
				back_pix=back_pix,	$
				low=low,		$
				quiet=quiet,	$
				smoothe=smoothe
				
if not keyword_set(n_sigma) then n_sigma=5
if not keyword_set(back_pix) then back_pix=0.1
if not keyword_set(low) then low=0.1
if keyword_set(smoothe) then if smoothe EQ 1 then smoothe=3

if exist(smoothe) then img=SMOOTH(inimg,smoothe,/EDGE) else img=inimg

get_backgnd_mu_sigma,img,back_pix,mu,sigma
limit=(mu+float(n_sigma)*sigma) > (low*max(img))
pos=find_local_maxima(img,limit)

n_sources=n_elements(pos)

if not exist(quiet) then begin
	print,'Background mu = ',mu
	print,'Background sigma = ',sigma
	print,'Min value : ',min(img)
	print,'Max value : ',max(img)
	if keyword_set(smoothe) then print,'Smoothing... window size: '+STRN(smoothe)
	S=size(img)
	xf=512./S[1]
	yf=512./S[2]
	sf=xf<yf
	plot_image_v2,img
	if datatype(pos) eq 'STC' then begin
		for i=0,n_elements(pos)-1 do begin
			oplot,[pos(i).x],[pos(i).y],psym=7,color=255
			oplot,[pos(i).x],[pos(i).y],psym=4,color=128
			print,'Local maximum #',i,' has x=',pos(i).x,'	y=',pos(i).y,'	value=',img(pos(i).x,pos(i).y)
		endfor
	endif
endif
END
;*******************************************************************************
