; docformat = 'rst'

;+
; Very simple Twitter client.
;-

pro mgfftwitterstatuses::startElement, uri, local, qname, attname, attvalue
  compile_opt strictarr
  
  case strlowcase(qname) of
    'text': begin
        self.insideText = 1B
        self.itemNumber++
      end
    else:
  endcase
end


pro mgfftwitterstatuses::endElement, uri, local, qname
  compile_opt strictarr

  case strlowcase(qname) of
    'text': self.insideText = 0B
    else:
  endcase  
end


pro mgfftwitterstatuses::characters, chars
  compile_opt strictarr

  if (self.insideText) then begin
    if (self.itemNumber gt 1L) then print, '--'
    print, chars
  endif
end


pro mgfftwitterstatuses__define
  compile_opt strictarr
  
  define = { MGffTwitterStatuses, inherits IDLffXMLSAX, $
             itemNumber: 0B, $
             insideText: 0B $
           }
end

pro mg_twitter, userid, count=count
  compile_opt strictarr
  
  _count = n_elements(count) gt 0L ? count : 5
  
  urlFormat = '(%"http://twitter.com/statuses/user_timeline/%s.xml?count=%d")'
  userUrl = string(userid, _count, format=urlFormat)

  url = obj_new('MGffTwitterStatuses')
  url->parseFile, userUrl, /url
  obj_destroy, url
end
