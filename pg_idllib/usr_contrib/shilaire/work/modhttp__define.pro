;+
; Project     : HESSI
;
; Name        : HTTP__DEFINE
;
; Purpose     : Define a HTTP class
;
; Explanation : defines a HTTP class to open URL's and download (GET)
;               files. Example:
;
;               a=obj_new('http')                  ; create a HTTP object
;               a->open,'orpheus.nascom.nasa.gov'  ; open a URL socket 
;               a->head,'~zarro/dmz.html'          ; view file info
;               a->list,'~zarro/dmz.html'          ; list text file from server
;               a->copy,'~zarro/dmz.html'          ; copy file
;               a->close                           ; close socket
;
;               If using a proxy server, then first set environmental 
;               http_proxy, e.g.
;               IDL> setenv,'http_proxy=orpheus.nascom.nasa.gov:24'
;
; Category    : objects sockets 
;               
; Syntax      : IDL> a=obj_new('http')
;
; History     : Written 6 June 2001, D. Zarro (EITI/GSFC)
;
; Contact     : dzarro@solar.stanford.edu
;-

;-- init HTTP socket

function http::init,url,err=err

err=''

if not allow_sockets(err=err) then return,0b

self->hset,retry=2,buffsize=512l,timeout=1,protocol='HTTP/1.0',host=host,$
      user_agent='IDL '+!version.release+' on '+!version.os+'/'+!version.arch

if is_string(url) then self->open,url,err=err

return,fix(err eq '')

end
;--------------------------------------------------------------------------

pro http::cleanup

self->close

return & end

;---------------------------------------------------------------------------
;-- send request for specified type [def='text']

pro http::request,url,type=type,err=err,no_protocol=no_protocol,cgi_bin=cgi_bin,$
                      no_head=no_head

err=''

this_type='text/plain'

;-- don't send a HEAD request if a CGI_BIN or a filename is not specified in the
;   URL 

self->parse_url,url,server,file
ext=stregex(file,'\.',/bool)
get_type=(1b-keyword_set(cgi_bin)) and (1b-keyword_set(no_head)) and ext

if get_type then begin
 this_type=self->get_url_type(url,err=err,size=bsize,/quiet)
 if err eq '' then begin
  if bsize eq 0 then err='Requested file has zero bytes'
 endif
 if (err ne '') then begin
  message,err,/cont
  return
 endif
endif 

if is_blank(type) then type='text'

if type ne '*' then begin
 chk=stregex(this_type,type)
 if chk[0] eq -1 then begin
  err='Remote file is not of type = '+type
  message,err,/cont
  return
 endif
endif

self->open,url,file=file,err=err
if err ne '' then begin
 self->close & return
endif

;-- if sending a request to read a file, then don't include protocol 
;   information or the server will send back extra header information

if not keyword_set(no_protocol) then protocol=self->getprop(/protocol) else protocol=''

;-- send User-Agent keyword in request telling server that this is IDL calling

user_agent='User-Agent: '+self->getprop(/user_agent)

delim=stregex(file,'(\/|\\)$')
ext=stregex(file,'\.')
if (delim eq -1) and (ext eq -1) then file=file+'/'
chk=stregex(file,'^/',/bool)
if not chk then file='/'+file
arg=file
server=self->getprop(/server)
if self->use_proxy() then arg='http://'+server+file
request=['GET '+arg+' '+protocol+' ',user_agent,''] 
self->send,request,err=err

return & end

;---------------------------------------------------------------------------
;-- set method

pro http::hset,file=file,server=server,retry=retry,timeout=timeout,host=host,$
               buffsize=buffsize,protocol=protocol,user_agent=user_agent

if is_string(host) then self.host=' '+host+' '
if is_number(timeout) then self.timeout=timeout
if is_number(retry) then self.retry=abs(fix(retry))
if is_string(file) then self.file=file
if is_string(server) then begin
 self->parse_url,server,temp
 if is_string(temp) then self.server=temp
endif
if is_number(buffsize) then self.buffsize=abs(long(buffsize)) > 1l
if is_string(protocol) then self.protocol=' '+protocol+' '
if is_string(user_agent) then self.user_agent=' '+user_agent+' '

return & end

;---------------------------------------------------------------------------

pro http::help

message,'current server port - '+self->getprop(/server),/cont
if not self->is_socket_open() then begin
 message,'No socket open',/cont
 return
endif

;help,/st,fstat(self.unit)

if self->use_proxy() then begin
 message,'proxy server - '+self->getprop(/proxy_server),/cont
 message,'proxy port - '+trim(self->getprop(/proxy_port)),/cont
endif

return & end

;----------------------------------------------------------------------------
;-- check if proxy server being used

function http::use_proxy
 
http_proxy=chklog('http_proxy')
if is_blank(http_proxy) then begin
 self.proxy_server=''
 self.proxy_port=0
 return,0b
endif

self->parse_url,http_proxy,proxy_server,port=proxy_port
self.proxy_server=proxy_server
self.proxy_port=proxy_port
return,1b & end

;-----------------------------------------------------------------------
;-- list links

pro http::links,url,hrefs,err=err

self->list,url,page,err=err

if err ne '' then return

self->parse_href,page,hrefs

return & end

;-------------------------------------------------------------------------
;-- extract HREF links 

pro http::parse_href,input,hrefs,sizes

hrefs='' & sizes=0.

if is_blank(input) then return

regex='< *a *href *= *"?([^ "]+) *"? *>.+( +[0-9]+\.?[0-9]* *)[a-z]'

;regex='< *a *href *= *"?([^ "]+) *"? *>.+( *[0-9]+\.?[0-9]*[m|k] *)[a-z] ([0-9]|\.)'
match=stregex(input,regex,/subex,/extra,/fold)

chk=where(strtrim(match[1,*],2) ne '',count)
if count gt 0 then begin
 hrefs=reform(match[1,chk])
 sizes=reform(match[2,chk])
endif else hrefs=''

return & end

;--------------------------------------------------------------------------
;-- open URL via HTTP 

pro http::open,url,file=file,server=server,err=err

err=''
error=0

self->parse_url,url,server,file

;-- reopen last closed server if not entered

last_server=self->getprop(/server)
if is_blank(server) and is_string(last_server) then server=last_server

if not self->valid_server(server) then begin
 if is_blank(server) then err='Missing remote server name' else $
  err='Invalid server name - '+server
 message,err,/cont
 return
endif

;-- default to port 80 if not via proxy

port=80
tserver=server
tport=port
if self->use_proxy() then begin
 tserver=self->getprop(/proxy_server)
 tport=self->getprop(/proxy_port)
endif

count=0
again: count=count+1
self->close
error=1
dprint,'% HTTP::OPEN, server, port: ',tserver,tport
on_ioerror,done
call_procedure,'socket',lun,tserver,tport,/get_lun,error=error,connect=self.timeout
done:on_ioerror,null
if error eq 0 then begin
 self.unit=lun 
 self.server=server
endif else begin
 retry=self->getprop(/retry)
 if stregex(!error_state.msg,'Unable to connect|Unable to lookup',/bool,/fold) then retry=0
 if count ge retry then begin
  err='Could not open socket to server - '+tserver
;  err=!error_state.msg
  message,err,/cont
  self->close
 endif else begin
  message,'Retrying...',/cont
  goto,again
 endelse
endelse

if is_string(file) then self.file=file

return & end

;--------------------------------------------------------------------------
;-- parse URL input

pro http::parse_url,url,server,file,port=port

file='' & server='' & port=80
if is_blank(url) then return

temp=str_replace(url,'\','/')

s='(http[s]?://)?([^/:,]+)(/[^:]+)?(:[0-9]+)?'

chk=stregex(temp,s,/ext,/sub)

server=chk[2]
sfile=chk[3]
if is_string(sfile) then file=strmid(sfile,1,strlen(sfile))
sport=chk[4]
if is_string(sport) then port=fix(strmid(sport,1,strlen(sport)))

if not self->valid_server(server) then begin
 server='' & file=url
endif

return & end

;-------------------------------------------------------------------------
;-- check if server attached to this socket

function http::is_open,server

if is_blank(server) then return,0b

if not self->is_socket_open() then return,0b

stat=fstat(self.unit)
tserver=server
tport='80'
if self->use_proxy() then begin
 tserver=self->getprop(/proxy_server)
 tport=self->getprop(/proxy_port)
endif 
return,trim(stat.name) eq tserver+'.'+tport

end

;-------------------------------------------------------------------------
;-- check if socket is open

function http::is_socket_open

error=0
catch,error
if error ne 0 then begin
 catch,/cancel
 return,0b
endif

stat=fstat(self.unit)
return,stat.open

end

;-------------------------------------------------------------------------
;-- close socket

pro http::close

if self.unit gt 0 then free_lun,self.unit

return & end

;----------------------------------------------------------------------------
;-- validate server address 

function http::valid_server,server

if is_blank(server) then return,0b
patt='/,\,:,~'
if str_match(server,patt) then return,0b

pos=strpos(server,'.')
if pos eq -1 then return,0b

chk='([^\.\\/]+\.){1,3}[^\.\\/]+'
ok=stregex(trim(server),chk,/extra,/sub,/fold)

server_part=trim(ok[0])

return,server_part ne '' 

end

;---------------------------------------------------------------------------
;--- send a request to server

pro http::send,request,err=err

err=''
if is_blank(request) then return

if not self->is_socket_open() then self->open,err=err
if err ne '' then return

dprint,'% HTTP::SEND: ',request

for i=0,n_elements(request)-1 do printf,self.unit,request[i]

return & end

;--------------------------------------------------------------------------
;-- restore last URL

function http::last_url

file=self->getprop(/file)
server=self->getprop(/server)
if is_blank(file) or is_blank(server) then return,''

return,server+'/'+file

end

;---------------------------------------------------------------------------
;--- send HEAD request to determine server content

pro http::head,url,content,type=type,size=bsize,date=date,err=err

err='' & bsize=0l & date='' & type=''

;-- use last saved URL

if is_blank(url) then url=self->last_url()

if is_blank(url) then begin
 err='Invalid URL entered'
 message,err,/cont
 return
endif

self->open,url,file=file,err=err
if err ne '' then return

protocol=self->getprop(/protocol)
user_agent=self->getprop(/user_agent)
user_agent='User-Agent: '+user_agent
chk=stregex(file,'^/',/bool)
if not chk then file='/'+file

arg=file
server=self->getprop(/server)
if self->use_proxy() then arg='http://'+server+file
request=['HEAD '+arg+' '+protocol+' ',user_agent,'','']
self->send,request,err=err
if err eq '' then self->readf,content,err=err

self->close

if err ne '' then begin
 message,err,/cont
 return
endif

if is_string(content) and n_params() eq 1  then print,content

if is_blank(content) then return

content=strcompress(strlowcase(strtrim(content,2)))

if arg_present(type) or arg_present(bsize) or arg_present(date) then $
 self->file_content,content,type=type,size=bsize,date=date

return & end

;----------------------------------------------------------------------------
;-- compare local and remote file sizes

function http::same_size,url,file,err=err

err=''

if not self->file_found(url,content,err=err) then return,0b

self->file_content,content,size=bsize

if is_blank(file) then self->parse_url,url,server,lfile else lfile=file

fsize=file_size(lfile)


dprint,'% fsize, bsize: ',trim(fsize),' ',trim(bsize)
return, fsize eq bsize

end

;----------------------------------------------------------------------------
;-- get URL file type

function http::get_url_type,url,size=bsize,err=err,_extra=extra

bsize=0l
if not self->file_found(url,content,err=err,_extra=extra) then return,''

self->file_content,content,type=type,size=bsize

return,type
end

;---------------------------------------------------------------------------
;--- list text file from server

pro http::list,url,output,err=err,count=count,_extra=extra

err=''
count=0 & output=''
if is_blank(url) or (n_elements(url) ne 1) then url='/'

self->request,url,err=err,_extra=extra
if err eq '' then self->readf,output,err=err
self->close

if err ne '' then return

count=n_elements(output)
if is_string(output) and n_params() ne 2 then print,output

return & end

;---------------------------------------------------------------------------
;-- read the server output

pro http::readf,output,err=err

err=''
delvarx,output
output=rd_ascii_buff(self.unit,self.buffsize)

if is_blank(output) then begin
 err='No response from server'
 message,err,/cont
endif

return & end

;--------------------------------------------------------------------------
;-- check if file exists on server (look for 404 response)

function http::file_found,url,content,err=err,quiet=quiet

err='' 
verbose=1-keyword_set(quiet)
self->head,url,content,err=err
if err ne '' then return,0b
if is_blank(content) then return,0b

chk=where(strpos(content,'404 not found') gt -1,count)
if count gt 0 then begin
 err=url+'  not found'
 if verbose then message,err,/cont
 return,0b
endif

chk=where(strpos(content,'403 forbidden') gt -1,count)
if count gt 0 then begin
 err=url+'  access denied'
 if verbose then message,err,/cont
 return,0b
endif

return,1b
end

;--------------------------------------------------------------------------
;-- parse file content

pro http::file_content,content,type=type,size=bsize,date=date

type='' & date='' & bsize=0l

if is_blank(content) then return

;-- get type

cpos=strpos(content,'content-type:')
chk=where(cpos gt -1,count)
if count gt 0 then begin
 temp=content[chk[0]]
 pos=strpos(temp,':')
 if pos gt -1 then type=strmid(temp,pos+1,strlen(temp))
endif

;-- get last modified data

cpos=strpos(content,'last-modified')
chk=where(cpos gt -1,count)
if count gt 0 then begin
 temp=content[chk[0]]
 pos=strpos(temp,':')
 if pos gt -1 then begin
  time=strtrim(strmid(temp,pos+1,strlen(temp)),2)
  pie=str2arr(time,delim=' ')
  date=anytim2utc(pie[1]+'-'+pie[2]+'-'+pie[3]+' '+pie[4],/vms)
 endif
endif

;-- get size

cpos=strpos(content,'content-length')
chk=where(cpos gt -1,count)
if count gt 0 then begin
 temp=content[chk[0]]
 pos=strpos(temp,':')
 if pos gt -1 then bsize=long(strmid(temp,pos+1,strlen(temp)))
endif

return & end

;---------------------------------------------------------------------------
;-- GET binary data from server

pro http::copy,url,new_name,err=err,out_dir=out_dir,verbose=verbose,$
                    clobber=clobber,status=status,prompt=prompt,$
                   _ref_extra=extra

status=0b
err=''
verbose=keyword_set(verbose)

self->parse_url,url,server,file
last_server=self->getprop(/server)
if is_blank(server) and is_string(last_server) then server=last_server

if is_blank(server) or is_blank(file) then begin
 err='Blank URL filename entered'
 message,err,/cont
 return
endif

if is_string(out_dir) then tdir=local_name(out_dir) else begin
 tdir=curdir()
 out_dir=tdir
endelse

break_file,local_name(file),dsk,dir,name,ext
out_name=trim(name+ext)

if is_string(new_name) then begin
 break_file,local_name(new_name),dsk,dir,name,ext
 out_name=trim(name+ext)
 if is_string(dsk+dir) then tdir=trim(dsk+dir)
endif

out_file=concat_dir(tdir,out_name)

;-- check if clobbering existing file

no_clobber=1b-keyword_set(clobber)
if no_clobber then begin
 chk=loc_file(out_file,count=count)
 if count ne 0 then begin
  if verbose then begin
   message,'file '+out_file+ ' exists',/cont
  endif
  osize=file_content(out_file,/size)
;  status=1b-call_function('file_test',out_file,/zero_length)
;  if status then return
 endif
endif

;-- test for write access to destination directory

if not test_dir(tdir,err=err) then return

;-- check if valid source file input and get byte size

if not self->file_found(url,content,err=err) then return

;-- determine remote file size

self->file_content,content,size=bsize

if bsize eq 0. then begin
 err='Could not determine remote file size'
 message,err,/cont
 return
endif

;-- override no_clobber if local and remote file sizes have changed
 
if no_clobber then begin
 if exist(osize) then begin
  if osize eq bsize then return
  message,'Remote & local files differ in size: '+trim(bsize)+','+trim(osize),/cont
 endif
endif

;-- prompt before downloading

if keyword_set(prompt) then begin
 ans=xanswer(["Remote file: "+file+" is "+trim(str_format(bsize,'(i10)'))+" bytes.",$
              "Proceed with download?"])
 if not ans then return
endif

;-- send a GET request

self->open,url,file=file,err=err,server=server
if err ne '' then return

user_agent='User-Agent: '+self->getprop(/user_agent)
chk=stregex(file,'^/',/bool)
if not chk then file='/'+file
url=file
server=self->getprop(/server)
if self->use_proxy() then url='http://'+server+file
request=['GET '+file,user_agent,'']
self->send,request,err=err

;-- now read as bytes

cmess=['Please wait. Downloading...','File: '+file,$
        'Size: '+trim(str_format(bsize,"(i10)"))+' bytes',$
        'From: '+server,'To: '+tdir]

if verbose then begin
 for i=0,n_elements(cmess)-1 do message,cmess[i],/cont,noname=(i gt 0)
 t1=systime(/seconds)
endif

openw,lun,out_file,/get_lun
rdwrt_buff,self.unit,lun,bsize,err=err,counts=counts, $
           input_text=cmess,_extra=extra,verbose=verbose

close_lun,lun
self->close

if (counts ne bsize) or (err ne '') then begin
 file_delete,out_file,/quiet
 xack,err,/info
 return
endif

if verbose then begin
 t2=systime(/seconds)
 tdiff=t2-t1
 output1=trim(string(counts,'(i10)'))+' bytes of '
 output2=trim(string(bsize,'(i10)'))+' total bytes copied'
 output=output1+output2+' in '+str_format(tdiff,'(f8.2)')+' seconds'
 message,output,/cont
 message,'Wrote '+trim(string(counts,'(i10)'))+' bytes to file '+out_file,/cont
endif 
status=1b

return & end

;---------------------------------------------------------------------

pro http__define                 

struct={http,server:'',unit:0l,file:'',retry:0,timeout:0,buffsize:512l,$
         user_agent:'',protocol:'',proxy_server:'',proxy_port:0l,$
         host:'',inherits gen}

return & end


