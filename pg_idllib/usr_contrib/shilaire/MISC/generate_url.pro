; PSH, 2001/04/23 : a small program to rapidly generate urls list for 
;  DMZ's JavaScript movie player

; ex: generate_url,'hedc_movie_20000831_163724_',nb=10

PRO generate_url,rootname,nb=nb

if not keyword_set(nb) then nb=20

print,'imax=',STRN(nb)
for i=0,nb-1 do BEGIN
	print,'urls['+STRN(i)+']=url_path+'+'"'+rootname+int2str(i,4)+'.png"'
		END
END

