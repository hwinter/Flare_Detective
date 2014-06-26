pro export_event, evstruct, outfil_voevent=outfil_voevent, outdir=outdir, suffix=suffix,$
  write_file=write_file,  display_xml=display_xml, buff=buff, $
  infil_params=infil_params, relax=relax, filenameout=filenameout

;+
;   Name:
;	export_event
;   Purpose:
;	Create a feature VOEvent XML file from a IDL strcuture provided by TAB2STRUC.PRO.
;   Input Parameters:
;	evstruct - IDL event structure
;	outfil_voevent - File name for generated XML VOEvent file
;			 (generated if not passed)
;	outdir - Output directory (default is current directory)
;       infil_params -  ASCII file of Heliphysics Knowledge Base event spec table
;			Default value is 'VOEvent_Spec.txt'
;       relax - By default, if required tags have their original
;               template values, then the procedure will print an
;               error and exit without outputing xml files. If the
;               relax keyword is set, then xml files will be written
;               accompanied by a warning message.
;   Keyword Parameters:
;	write_file - if set, write the XML file
;	display_xml - if set, print generated XML to terminal
;   Output:
;	VOEvent file written (if 'write_file' keyword set)
;	buff - optional output of string array of XML
;   Calling Sequence:
;       event = struct4event('AR')
;       export_event, event, /write_file, outdir="./VOEvents/", suffix='_some_uni_number'
;   Calling Examples:
;       export_event, evstruct, /write_file
;       export_event, evstruct, /write_file, outfil="something.xml"
;       export_event, evstruct, /display_xml
;   Procedure:
;	IVOA VOEvent 1.1 specification used as starting point:
;	http://www.ivoa.net/Documents/REC/VOE/VOEvent-20061101.html
;   History:
;	2007-02-27 Gregory Slater
;	2007-03-14 Mark Cheung - Generalized code so that in case new
;                                parameters are added to the
;                                VOEvent_Spec.txt table, this IDL
;                                routine would required minimal (or
;                                no) modification.
;       2007-03-23 Mark Cheung - Optional tags are not written
;                                to the XML file (or displayed)
;                                unless they have values
;                                that differ from the default
;                                (nonsensical) values for the variable type.
;       2007-04-16 Mark Cheung - Feature names and 2-letter codes no
;                                longer hardcoded.
;       2007-04-18 Mark Cheung - Corrected link to VOEvent schema
;       2007-05-16 Mark Cheung - Corrected format of bounding box
;                                coordinates
;       2007-08-16 Mark Cheung - Corrections to conform to VOEvent schema
;                                1. Removed <Name></Name> in <who> section      
;                                2. Bracketed <ObservationLocation></ObservationLocation>
;                                with <ObsDataLocation></ObsDataLocation>
;                                3. Replaced first link in
;                                xsi:schemaLocation by "stc"
;       2008-02-18 Mark Cheung - Changed XML file naming
;                                convention. Added suffix keyword to
;                                let user append characters to
;                                filename.
;       2008-02-25 Mark Cheung - error message for wrong
;                                Required.coord_sys value
;                                Also added time format check
;       2008-03-14 Mark Cheung - Added support for outputing
;                                event.reference_links and
;                                event.reference_names
;       2008-03-14 Mark Cheung - Added support for description
;       2008-08-11 Mark Cheung - Modified to create schema compliant
;                                VOEvent XML.
;       2009-03-13 Mark Cheung - Added output for optional attribute
;                                Event_expires in the <Why> tag
;       2009-08-05 Mark Cheung - Added check for IVORN. If default
;                                value, then automatically set values
;                                for IVORN. Otherwise, use provided
;                                optional.kb_archivid
;       2009-08-05 Mark Cheung - Added check for finiteness of
;                                event_probability. If not
;                                finite, don't include
;                                value. If outside range [0,1], give
;                                warning. 
;       2009-10-03 Mark Cheung - Added support for reporting of
;                                Citations (followup, supersedes and retraction)

;   Restrictions:                                                                     
;       Requires Solarsoft to operate
;-                                                                                    


if (N_ELEMENTS(infil_params) EQ 0) then infil_params = evstruct.SpecFile;'./VOEvent_Spec.txt'
if infil_params eq infil_params then infil_params = evstruct.SpecFile;'./VOEvent_Spec.txt'
; Read in Spec table
print, 'infil_params'
help, infil_params
lines = strarr(file_lines(infil_params))
print, 'infil_params'
help, infil_params
openr, lun,/get_lun, infil_params
readf, lun, lines
free_lun, lun 
lines = lines[2:*]
ncols = n_elements(strsplit(lines[0],',',/extract))
buff0 = strarr(ncols, n_elements(lines))
FOR I=0,N_ELEMENTS(lines)-1 DO buff0[*,I] = strsplit(lines[i],',',/extract)

buff1 = buff0[*,2:*]
feat_code_vec = strtrim(buff0[*,0],2)
feat_code_arr = feat_code_vec
feat_name_arr = strtrim(buff0[*,1],2)

col_labels = buff0[*,0]
param_names = buff1[0,*]
type_column = strtrim(buff1(where(strmatch(col_labels,'Type', /fold)),*),2)
vo_column   = strtrim(buff1(where(strmatch(col_labels,'VOParamType', /fold)),*),2)
ro_column   = strtrim(buff1(where(strmatch(col_labels,"R/O", /fold)),*),2)
source_column=strtrim(buff1(where(strmatch(col_labels,"Source", /fold)),*),2)
vo_translation=strtrim(buff1(where(strmatch(col_labels,'VOTranslation', /fold)),*),2)
dimensions_column = strtrim(buff1(where(strmatch(col_labels,'Dimensions', /fold)),*),2)
ss_code_match = where(feat_code_vec eq (strsplit(evstruct.required.event_type,':',/extract))[0],count_match)
if (N_ELEMENTS(outdir) EQ 0) then outdir = './'

type_vec = ['string' ,'byte','integer','long' ,'float'  ,'double' ,'undefined','strarr']
val_vec  = ['"blank"','0b'  ,'-9999'  ,'-999999l','!VALUES.F_Infinity','!VALUES.D_Infinity','"-"','' ]
idl_type_vec=[7,1,2,3,4,5,0,8]

; Check that all required tags have indeed been filled in (default
; values from template not acceptable.)
error_buff=['']
these_tags = tag_names(evstruct.required)
for I=0,n_elements(these_tags)-1 do begin
    temp_index = where( (size(evstruct.required.(I)))[1] EQ idl_type_vec) 
    var_type = type_vec[temp_index]
    ;    print, evstruct.required.(i), var_type
    case (size(evstruct.required.(I)))[1] of
        1: if evstruct.required.(i) EQ 0b then error_buff=[error_buff, string(these_tags[I])+ "=" +string(evstruct.required.(I))]
        2: if evstruct.required.(i) EQ -9999 then error_buff=[error_buff, string(these_tags[I])+ "=" +string(evstruct.required.(I))]
        3: if evstruct.required.(i) EQ -999999l then error_buff=[error_buff, string(these_tags[I])+ "=" +string(evstruct.required.(I))]
        4: if evstruct.required.(i) EQ !VALUES.F_Infinity then error_buff=[error_buff, string(these_tags[I])+ $
                                                                           "= " +string(evstruct.required.(I))]
        5: if evstruct.required.(i) EQ !VALUES.D_Infinity then error_buff=[error_buff, string(these_tags[I])+ $
                                                                           "= " +string(evstruct.required.(I))]
        7: if evstruct.required.(i) EQ "blank" then error_buff=[error_buff, string(these_tags[I])+ "=" +string(evstruct.required.(I))]
        else: begin
        endelse
    endcase
endfor

IF N_ELEMENTS(error_buff) GT 1 THEN BEGIN
    IF KEYWORD_SET(relax) EQ 0 THEN BEGIN
       print, "Error: The following required tags must be given proper values."
       print, "---------------------------------------------------------------------"
       FOR I=1,N_ELEMENTS(error_buff)-1 DO print, error_buff[I]
       print, "---------------------------------------------------------------------"
       print, "No xml files were produced."
       return
    ENDIF ELSE BEGIN
       print, "Warning: The following required tags must be given proper values."
       print, "---------------------------------------------------------------------"
       FOR I=1,N_ELEMENTS(error_buff)-1 DO print, error_buff[I]
       print, "---------------------------------------------------------------------"
       print, "Nevertheless, the XML code was displayed and/or written as requested."
    ENDELSE
ENDIF

; Time now
;this_moment = time2file(!stime,/sec)
get_utc, this_moment
this_moment = anytim(this_moment)

; Remove white spaces in suffix
IF N_ELEMENTS(suffix) NE 0 THEN BEGIN
    suffix = '_'+strjoin(strsplit(string(suffix),' ',/extract))
ENDIF ELSE BEGIN
    suffix = ''
ENDELSE

; AuthorIVORN
IF (evstruct.required.kb_archivid EQ 'Reserved for KB archivist: KB entry identifier') THEN BEGIN 
  evstruct.required.kb_archivid = 'ivo://helio-informatics.org/'+(strsplit(evstruct.required.event_type,':',/extract))[0] + '_' + $
                                  strjoin(strsplit(evstruct.required.frm_name,' ,;:/\{}[]`~=".',/extract)) + '_' + time2file(this_moment,/sec) + suffix
ENDIF

; KlugeStart:
if N_ELEMENTS(outfil_voevent) EQ 0 then $
  outfil_voevent = (strsplit(evstruct.required.event_type,':',/extract))[0] + '_' + $
  strjoin(strsplit(evstruct.required.frm_name,' ,;:/\{}[]`~=".',/extract)) + '_' + time2file(this_moment,/sec) + suffix +'.xml'

; KlugeEnd:
outfil_voevent_full = concat_dir(outdir,outfil_voevent)
if file_exist(outfil_voevent_full) then print, "Warning: pre-existing XML file may be overwritten."


buff = '<?xml version="1.0" encoding="UTF-8" ?>'
buff = [buff,	'<voe:VOEvent ivorn="'+evstruct.required.kb_archivid+'" role="observation" '+ $
                ;'<voe:VOEvent role="observation" ivorn="'+evstruct.required.kb_archivid+'" '+ $
		'version="1.1" xmlns:voe="http://www.ivoa.net/xml/VOEvent/v1.1" ' + $
                'xmlns:stc="http://www.ivoa.net/xml/STC/stc-v1.30.xsd" ' +$
                'xmlns:lmsal="http://www.lmsal.com/helio-informatics/lmsal-v1.0.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' + $
                'xsi:schemaLocation="http://www.ivoa.net/xml/VOEvent/v1.1 http://www.lmsal.com/helio-informatics/VOEvent-v1.1.xsd">']
		;'xmlns:lmsal="http://helio-informatics.org/" ' + $		
                ;'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" ' + $
		;'xsi:schemaLocation="stc ' + $
                ;'http://www.ivoa.net/xml/VOEvent/VOEvent-v1.1.xsd">']

buff = [buff, '']
buff = [buff, '']

; '<Who>' portion
buff = [buff, '    <Who>']
buff = [buff, '       <!-- Data pertaining to curation -->']
; First of all, conform to VO Events specifictions
;buff = [buff, '       <Name>' + evstruct.required.KB_ARCHIVIST + '</Name>']
buff = [buff, '        <AuthorIVORN>' + evstruct.required.kb_archivid + '</AuthorIVORN>']
buff = [buff, '        <Author>']
buff = [buff, '              <contactName>'+evstruct.required.FRM_Contact+'</contactName>']
buff = [buff, '        </Author>']
buff = [buff, '       <Date>' + strtrim(anytim(this_moment,/ccsds)) + '</Date>']

these_tags=tag_names(evstruct.required)
n_these_tags=n_elements(these_tags)
for i=0,n_these_tags-1 do begin
   row = where(strmatch(param_names, these_tags(i),/fold))
   if strmatch(ro_column(row),'r',/fold) and $
     strmatch(vo_column(row),'who',/fold) and strmatch(vo_translation(row), '-') then $
      buff = [buff, '       <lmsal:'+these_tags(i)+'>' + strtrim(string(evstruct.required.(i)),2)+'</lmsal:'+these_tags(i)+'>']
endfor

count = 0
for i=0,n_these_tags-1 do begin
   row = where(strmatch(param_names, these_tags(i),/fold))
   if strmatch(ro_column(row),'o',/fold) and $
     strmatch(vo_column(row),'who',/fold) and strmatch(vo_translation(row), '-') then begin
      count = count + 1
      IF count EQ 1 THEN buff = [buff, '       <Group name="' + strtrim((strsplit(evstruct.required.Event_type,':',/extract))[1],2) +'_required">']
      buff = [buff, '           <Param name="'+these_tags(i)+'" value="'+strtrim(string(evstruct.required.(i)),2)+'"/>']
   endif
endfor
if count GT 0 then buff = [buff, '       </Group>']

count = 0
these_tags=tag_names(evstruct.optional)
n_these_tags=n_elements(these_tags)
skip  = 0
for i=0,n_these_tags-1 do begin
    ;IF (strlowcase(these_tags[i]) NE 'references') THEN BEGIN
    row = where(strmatch(param_names, these_tags(i),/fold))
    idl_type_index = where( (size(evstruct.optional.(I)))[1] EQ idl_type_vec) 
    var_type = type_vec[idl_type_index]
    ;    print, evstruct.optional.(i), var_type
    case (size(evstruct.optional.(I)))[1] of
        1: if evstruct.optional.(i) EQ 0b then skip=1
        2: if evstruct.optional.(i) EQ -9999 then skip=1
        3: if evstruct.optional.(i) EQ -999999l then skip=1
        4: if evstruct.optional.(i) EQ !VALUES.F_Infinity then skip = 1
        5: if evstruct.optional.(i) EQ !VALUES.D_Infinity then skip = 1
        7: if evstruct.optional.(i) EQ "blank" then skip = 1
        else: begin
        endelse
    endcase
    if strmatch(vo_column(row),'who',/fold) and (NOT skip) then begin
      count = count + 1
      if count EQ 1 then buff = [buff, '       <Group name="' + strtrim((strsplit(evstruct.required.Event_type,':',/extract))[1],2) +'_optional">']
      buff = [buff, '           <Param name="'+these_tags(i)+'" value="'+strtrim(string(evstruct.optional.(i)),2)+'"/>']
  endif

endfor
if count GT 0 then buff = [buff, '       </Group>']
buff = [buff, '    </Who>']
buff = [buff, '']
buff = [buff, '']

; '<What>' portion:
buff = [buff, '    <What>']
buff = [buff, '       <!-- Data about what was measured/observed. -->']
these_tags=tag_names(evstruct.required)
n_these_tags=n_elements(these_tags)
for i=0,n_these_tags-1 do begin
   row = where(strmatch(param_names, these_tags(i),/fold))
   if strmatch(ro_column(row),'r',/fold) and $
     strmatch(vo_column(row),'what',/fold) and strmatch(vo_translation(row),'-') then $
      buff = [buff, '       <lmsal:'+these_tags(i)+'>' + strtrim(string(evstruct.required.(i)),2)+'</lmsal:'+these_tags(i)+'>']
endfor

count = 0
;buff = [buff, '       <Group name="' + strtrim((strsplit(evstruct.required.Event_type,':',/extract))[1],2) +'_required">']
for i=0,n_these_tags-1 do begin
   row = where(strmatch(param_names, these_tags(i),/fold))
   if strmatch(ro_column(row),'o',/fold) and $
     strmatch(vo_column(row),'what',/fold) and strmatch(vo_translation(row),'-') then begin
      count = count + 1
      if count EQ 1 then buff = [buff, '       <Group name="' + strtrim((strsplit(evstruct.required.Event_type,':',/extract))[1],2) +'_required">']
      buff = [buff, '           <Param name="'+these_tags(i)+'" value="'+strtrim(string(evstruct.required.(i)),2)+'"/>']
   endif
endfor
if count GT 0 then buff = [buff, '       </Group>']
; NEED this blank description node to validate, in case there are no
; params in the required group
buff = [buff, '              <Description></Description>']

count = 0
these_tags=tag_names(evstruct.optional)
n_these_tags=n_elements(these_tags)
for i=0,n_these_tags-1 do begin
    skip = 0
    row = where(strmatch(param_names, these_tags(i),/fold))
    idl_type_index = where( (size(evstruct.optional.(I)))[1] EQ idl_type_vec) 
    var_type = type_vec[idl_type_index]
    ;    print, evstruct.optional.(i), var_type
    case (size(evstruct.optional.(I)))[1] of
        1: if evstruct.optional.(i) EQ 0b then skip=1
        2: if evstruct.optional.(i) EQ -9999 then skip=1
        3: if evstruct.optional.(i) EQ -999999l then skip=1
        4: if evstruct.optional.(i) EQ !VALUES.F_Infinity then skip = 1
        5: if evstruct.optional.(i) EQ !VALUES.D_Infinity then skip = 1
        7: if evstruct.optional.(i) EQ "blank" then skip = 1
        else: begin
        endelse
    endcase
   if strmatch(vo_column(row),'what',/fold) and (skip EQ 0) then begin
      count = count + 1
      if count EQ 1 then buff = [buff, '       <Group name="' + strtrim((strsplit(evstruct.required.Event_type,':',/extract))[1],2) +'_optional">']
      buff = [buff, '           <Param name="'+these_tags(i)+'" value="'+strtrim(string(evstruct.optional.(i)),2)+'"/>']
   endif
endfor
if count GT 0 then buff = [buff, '       </Group>']
buff = [buff, '    </What>']
buff = [buff, '']
buff = [buff, '']


buff = [buff, '    <WhereWhen>']
buff = [buff, '        <!-- Data pertaining to when and where something occured -->']
buff = [buff, '        <ObsDataLocation xmlns="http://www.ivoa.net/xml/STC/stc-v1.30.xsd">']
;buff = [buff, '        <ObservationLocation id="'+ evstruct.required.OBS_Observatory + '">']

; Adopted coord_system_id="UTC-HPC-TOPO"  from VOEvent 1.1 specification:
; http://www.ivoa.net/Documents/REC/VOE/VOEvent-20061101.html

case strtrim(strlowcase(evstruct.required.event_coordsys),2) of
    'utc-hgs-topo': acceptable_coordsys = 1
    'utc-hgc-topo': acceptable_coordsys = 1
    'utc-hpc-topo': acceptable_coordsys = 1
    'utc-hpr-topo': acceptable_coordsys = 1
    'utc-hrc-topo': acceptable_coordsys = 1
    else: acceptable_coordsys = 0
endcase

IF (acceptable_coordsys EQ 0) THEN BEGIN
   print, '---------------------------Error--------------------------'
   print, 'Please use one of the following coordinate systems'
   print, 'for the required.coord_sys attribute.'
   print, 'Cartesian helio-projective:      "utc-hpc-topo"'
   print, 'Polar helio-projective:          "utc-hpr-topo"'
   print, 'Stonyhurst heliographic:         "utc-hgs-topo"'
   print, 'Carrington heliographic:         "utc-hgc-topo"'
   print, 'Pol. angle and radius (for CMEs):"utc-hcr-topo"'
   print, '----------------------------------------------------------'
   print, 'For details, go to:'
   print, 'http://www.ivoa.net/Documents/PR/VOE/VOEvent-20060629.html'
   print, '----------------------------------------------------------'
   return
ENDIF
buff = [buff, '             <ObservatoryLocation>']
buff = [buff, '                     <AstroCoordSystem></AstroCoordSystem>']
buff = [buff, '                     <AstroCoords id="'+ evstruct.required.event_coordsys+'" coord_system_id="'+evstruct.required.event_coordsys+'">']
buff = [buff, '                     </AstroCoords>']
buff = [buff, '             </ObservatoryLocation>']

; Check time formats
tcheck =  anytim(evstruct.required.event_starttime,error=error)
if (error EQ 1) then return
tcheck =  anytim(evstruct.required.event_endtime,error=error)
if (error EQ 1) then return
match = strmatch(strlowcase(tag_names(evstruct.optional)),'event_peaktime*')
index_match = where(match EQ 1)
IF index_match[0] NE -1 THEN BEGIN
   tcheck =  anytim(evstruct.required.event_starttime,error=error)
   if (error EQ 1) then return
ENDIF
match = strmatch(strlowcase(tag_names(evstruct.required)),'event_peaktime*')
index_match = where(match EQ 1)
IF index_match[0] NE -1 THEN BEGIN
   tcheck =  anytim(evstruct.required.event_starttime,error=error)
   if (error EQ 1) then return
ENDIF

buff = [buff, '         <ObservationLocation id="'+ evstruct.required.OBS_Observatory + '">']
buff = [buff, '            <AstroCoordSystem></AstroCoordSystem>']
buff = [buff, '            <AstroCoords coord_system_id="'+evstruct.required.event_coordsys+'">']
buff = [buff, '                <Time>']
buff = [buff, '                    <TimeInstant>']
buff = [buff, '                         <ISOTime>' +strtrim(anytim(evstruct.required.event_starttime,/ccsds),2)+ '</ISOTime>']
buff = [buff, '                    </TimeInstant>']
; buff = [buff, '                    <TimeInterval>'$
;            + strtrim(anytim(evstruct.required.event_starttime,/ccsds),2) $
;            +','+strtrim(anytim(evstruct.required.event_endtime,/ccsds),2)+'</TimeInterval>']
buff = [buff, '                </Time>']
buff = [buff, '']
buff = [buff, '                <Position2D unit="'+evstruct.required.event_coordunit+'"> ']
buff = [buff, '                       <Value2>']
buff = [buff, '                           <C1>'+strtrim(string(evstruct.required.event_coord1),2)+'</C1>']
buff = [buff, '                           <C2>'+strtrim(string(evstruct.required.event_coord2),2)+'</C2>']
buff = [buff, '                       </Value2>']
buff = [buff, '                       <Error2>']
buff = [buff, '                           <C1>'+strtrim(string(evstruct.required.event_c1error),2)+'</C1>']
buff = [buff, '                           <C2>'+strtrim(string(evstruct.required.event_c2error),2)+'</C2>']
buff = [buff, '                       </Error2>']
buff = [buff, '                </Position2D> ']
buff = [buff, '            </AstroCoords>']
; Start and end times
buff = [buff, '            <AstroCoordArea coord_system_id="'+evstruct.required.event_coordsys+'">']
buff = [buff, '                    <TimeInterval>']
buff = [buff, '                         <StartTime>']
buff = [buff, '                              <ISOTime>'+strtrim(anytim(evstruct.required.event_starttime,/ccsds),2)+'</ISOTime>']
buff = [buff, '                         </StartTime>']
buff = [buff, '                         <StopTime>']
buff = [buff, '                              <ISOTime>'+strtrim(anytim(evstruct.required.event_endtime,/ccsds),2)+'</ISOTime>']
buff = [buff, '                         </StopTime>']
buff = [buff, '                    </TimeInterval>']
; Now boundding box
buff = [buff, '                    <Box2>']
buff = [buff, '                        <Center>']
buff = [buff, '                           <C1>' +strtrim(string(0.5*(evstruct.required.BoundBox_C1LL+evstruct.required.BoundBox_C1UR)),2)+ '</C1>']
buff = [buff, '                           <C2>' +strtrim(string(0.5*(evstruct.required.BoundBox_C2LL+evstruct.required.BoundBox_C2UR)),2)+ '</C2>']
buff = [buff, '                        </Center>']
buff = [buff, '                        <Size>']
buff = [buff, '                           <C1>' +strtrim(string(abs(evstruct.required.BoundBox_C1UR-evstruct.required.BoundBox_C1LL)),2)+ '</C1>']
buff = [buff, '                           <C2>' +strtrim(string(abs(evstruct.required.BoundBox_C2UR-evstruct.required.BoundBox_C2LL)),2)+ '</C2>']
buff = [buff, '                        </Size>']
buff = [buff, '                    </Box2>']
buff = [buff, '            </AstroCoordArea>']
; if tag_exist(evstruct.required,'BoundBox_C1LL') AND tag_exist(evstruct.required,'BoundBox_C2LL') AND $
;    tag_exist(evstruct.required,'BoundBox_C1UR') AND tag_exist(evstruct.required,'BoundBox_C2UR') then begin
;    buff = [buff, '                <SpatialRegion>']
;    buff = [buff, '                    <Region>Box</Region>']
;    buff = [buff, '                    <!-- Coordinates of lower-left corner of bounding box -->']
;    buff = [buff, '                    <Value2>'] ;Lower-left corner of bounding box
;    buff = [buff, '                         <C1>'+strtrim(string(evstruct.required.BoundBox_C1LL),2)+'</C1>']
;    buff = [buff, '                         <C2>'+strtrim(string(evstruct.required.BoundBox_C2LL),2)+'</C2>']
;    buff = [buff, '                    </Value2>']
;    buff = [buff, '                    <!-- Coordinates of upper-right corner of bounding box -->']
;    buff = [buff, '                    <Value2>'] ;Upper-right corner of bounding box
;    buff = [buff, '                         <C1>'+strtrim(string(evstruct.required.BoundBox_C1UR),2)+'</C1>']
;    buff = [buff, '                         <C2>'+strtrim(string(evstruct.required.BoundBox_C2UR),2)+'</C2>']
;    buff = [buff, '                    </Value2>']
;    buff = [buff, '                </SpatialRegion>']
; endif
; buff = [buff, '            </AstroCoords>']
buff = [buff, '        </ObservationLocation>']
buff = [buff, '        </ObsDataLocation>']
buff = [buff, '']

these_tags=tag_names(evstruct.required)
n_these_tags=n_elements(these_tags)
for i=0,n_these_tags-1 do begin
   row = where(strmatch(param_names, these_tags(i),/fold))
   if strmatch(ro_column(row),'r',/fold) and $
     strmatch(vo_column(row),'wherewhen',/fold) and strmatch(vo_translation(row),'-') then $
      buff = [buff, '       <lmsal:'+these_tags(i)+'>' + strtrim(string(evstruct.required.(i)),2)+'</lmsal:'+these_tags(i)+'>']
endfor

count = 0
for i=0,n_these_tags-1 do begin
   row = where(strmatch(param_names, these_tags(i),/fold))
   if strmatch(ro_column(row),'o',/fold) and $
     strmatch(vo_column(row),'wherewhen',/fold) and strmatch(vo_translation(row),'-') then begin
      count = count + 1
      if count EQ 1 then buff = [buff, '       <Group name="' + strtrim((strsplit(evstruct.required.Event_type,':',/extract))[1],2) +'_required">']
      buff = [buff, '           <Param name="'+these_tags(i)+'" value="'+strtrim(string(evstruct.required.(i)),2)+'"/>']
   endif
endfor
if count GT 0 then buff = [buff, '       </Group>']

count = 0
these_tags=tag_names(evstruct.optional)
n_these_tags=n_elements(these_tags)
for i=0,n_these_tags-1 do begin
    skip = 0
    row = where(strmatch(param_names, these_tags(i),/fold))
    idl_type_index = where( (size(evstruct.optional.(I)))[1] EQ idl_type_vec) 
    var_type = type_vec[idl_type_index]
    ;    print, evstruct.optional.(i), var_type
    case (size(evstruct.optional.(I)))[1] of
        1: if evstruct.optional.(i) EQ 0b then skip=1
        2: if evstruct.optional.(i) EQ -9999 then skip=1
        3: if evstruct.optional.(i) EQ -999999l then skip=1
        4: if evstruct.optional.(i) EQ !VALUES.F_Infinity then skip = 1
        5: if evstruct.optional.(i) EQ !VALUES.D_Infinity then skip = 1
        7: if evstruct.optional.(i) EQ "blank" then skip = 1
        else: begin
        endelse
    endcase
   if strmatch(vo_column(row),'wherewhen',/fold) and (skip EQ 0) then begin
      count = count + 1
      if count EQ 1 then buff = [buff, '       <Group name="' + strtrim((strsplit(evstruct.required.Event_type,':',/extract))[1],2) +'_optional">']
      buff = [buff, '           <Param name="'+these_tags(i)+'" value="'+strtrim(string(evstruct.optional.(i)),2)+'"/>']
   endif
endfor
if count GT 0 then buff = [buff, '       </Group>']
buff = [buff, '    </WhereWhen>']
buff = [buff, '']
buff = [buff, '']


buff = [buff, '    <How>']
buff = [buff, '       <!-- Data pertaining to how the feature/event detection was performed -->']

; Need to make sure FRM_DateRun has the right time format
evstruct.required.frm_daterun = strtrim(anytim(evstruct.required.frm_daterun,/ccsds),2)

match = where(source_column EQ 'data' and ro_column EQ 'r')
if match[0] ne -1 then begin
   these_tags  = param_names(match)
   buff = [buff, '       <lmsal:data>']
   n_these_tags=n_elements(these_tags)
   for i=0,n_these_tags-1 do begin
      row = where(strmatch(param_names, these_tags(i),/fold))
      if strmatch(vo_column(row),'how',/fold) and strmatch(vo_translation(row),'-') then begin
        index = where(strmatch(tag_names(evstruct.required),these_tags[i],/fold_case))
        if index[0] NE -1 then buff = [buff, '           <lmsal:'+these_tags(i)+'>' + strtrim(string(evstruct.required.(index)),2)+'</lmsal:'+these_tags(i)+'>']
      endif
    endfor
  buff = [buff, '       </lmsal:data>']
endif

match = where(source_column EQ 'method' and ro_column EQ 'r')
if match[0] ne -1 then begin
   these_tags  =param_names(match)
   buff = [buff, '       <lmsal:method>']
   n_these_tags=n_elements(these_tags)
   for i=0,n_these_tags-1 do begin
      row = where(strmatch(param_names, these_tags(i),/fold))
      if strmatch(vo_column(row),'how',/fold) and strmatch(vo_translation(row),'-') then begin
        index = where(strmatch(tag_names(evstruct.required),these_tags[i],/fold_case))
        if index[0] ne -1 then buff = [buff, '           <lmsal:'+these_tags(i)+'>' + strtrim(string(evstruct.required.(index)),2)+'</lmsal:'+these_tags(i)+'>']
      endif
  endfor
  buff = [buff, '       </lmsal:method>']
endif

count = 0
these_tags=tag_names(evstruct.optional)
n_these_tags=n_elements(these_tags)
for i=0,n_these_tags-1 do begin
    skip = 0
    row = where(strmatch(param_names, these_tags(i),/fold))
    idl_type_index = where( (size(evstruct.optional.(I)))[1] EQ idl_type_vec) 
    var_type = type_vec[idl_type_index]
    ;    print, evstruct.optional.(i), var_type
    case (size(evstruct.optional.(I)))[1] of
        1: if evstruct.optional.(i) EQ 0b then skip=1
        2: if evstruct.optional.(i) EQ -9999 then skip=1
        3: if evstruct.optional.(i) EQ -999999l then skip=1
        4: if evstruct.optional.(i) EQ !VALUES.F_Infinity then skip = 1
        5: if evstruct.optional.(i) EQ !VALUES.D_Infinity then skip = 1
        7: if evstruct.optional.(i) EQ "blank" then skip = 1
        else: begin
        endelse
    endcase 
   if strmatch(vo_column(row),'how',/fold) and (skip EQ 0) then begin
      count = count + 1
      if count EQ 1 then buff = [buff, '       <Group name="' + strtrim((strsplit(evstruct.required.Event_type,':',/extract))[1],2) +'_optional">']
      buff = [buff, '           <Param name="'+these_tags(i)+'" value="'+strtrim(string(evstruct.optional.(i)),2)+'"/>']
   endif
endfor
if count GT 0 then buff = [buff, '       </Group>']
buff = [buff, '    </How>']
buff = [buff, '']
buff = [buff, '']

; Add expiry date attribute to Why tag if available
if (anytim(evstruct.optional.event_expires) NE anytim('1492-10-12 00:00:00')) then begin
   buff = [buff, '    <Why expires="'+strtrim(anytim(evstruct.optional.event_expires,/ccsds))+'">']
endif else begin
   buff = [buff, '    <Why>']
endelse
IF (FINITE(evstruct.optional.event_probability)) THEN BEGIN
   IF (abs(evstruct.optional.event_probability) GT 1.0) THEN BEGIN
      print, "Event probabilty outside of valid range of [0,1]"
   ENDIF
   buff = [buff, '       <Inference probability="' + strtrim(evstruct.optional.event_probability,2) + '"/>']
ENDIF
buff = [buff, '       <Concept>' + feat_name_arr(where(strmatch(feat_code_arr,(strsplit(evstruct.required.Event_Type,':',/extract))[0]))) $
	 + '</Concept>']
buff = [buff, '       <lmsal:EVENT_TYPE>' + strtrim(evstruct.required.Event_Type,2) + '</lmsal:EVENT_TYPE>']
these_tags=tag_names(evstruct.required)
n_these_tags=n_elements(these_tags)
for i=0,n_these_tags-1 do begin
   row = where(strmatch(param_names, these_tags(i),/fold))
   if strmatch(ro_column(row),'r',/fold) and $
     strmatch(vo_column(row),'why',/fold) and strmatch(vo_translation(row),'-') then $
      buff = [buff, '       <lmsal:'+these_tags(i)+'>' + strtrim(string(evstruct.required.(i)),2)+'</lmsal:'+these_tags(i)+'>']
endfor

count = 0
for i=0,n_these_tags-1 do begin
   row = where(strmatch(param_names, these_tags(i),/fold))
   if strmatch(ro_column(row),'o',/fold) and $
     strmatch(vo_column(row),'why',/fold) and strmatch(vo_translation(row),'-') then begin
      count = count + 1
      if count EQ 1 then buff = [buff, '       <Group name="' + strtrim((strsplit(evstruct.required.Event_type,':',/extract))[1],2) +'_required">']
      buff = [buff, '           <Param name="'+these_tags(i)+'" value="'+strtrim(string(evstruct.required.(i)),2)+'"/>']
   endif
endfor
if count GT 0 then buff = [buff, '       </Group>']

count = 0
these_tags=tag_names(evstruct.optional)
n_these_tags=n_elements(these_tags)
for i=0,n_these_tags-1 do begin
    skip = 0
    row = where(strmatch(param_names, these_tags(i),/fold))
    idl_type_index = where( (size(evstruct.optional.(I)))[1] EQ idl_type_vec) 
    var_type = type_vec[idl_type_index]
    ;    print, evstruct.optional.(i), var_type
    case (size(evstruct.optional.(I)))[1] of
        1: if evstruct.optional.(i) EQ 0b then skip=1
        2: if evstruct.optional.(i) EQ -9999 then skip=1
        3: if evstruct.optional.(i) EQ -999999l then skip=1
        4: if evstruct.optional.(i) EQ !VALUES.F_Infinity then skip = 1
        5: if evstruct.optional.(i) EQ !VALUES.D_Infinity then skip = 1
        7: begin
           if (evstruct.optional.(i) EQ "blank") then skip = 1
           if (strlowcase(these_tags(i)) EQ 'event_expires') then skip = 1
           if (evstruct.optional.(i) EQ '1492-10-12 00:00:00') then skip = 1
           end
        else: begin
        endelse
    endcase
   if strmatch(vo_column(row),'why',/fold) and (skip EQ 0) then begin
      count = count + 1
      if count EQ 1 then buff = [buff, '       <Group name="' + strtrim((strsplit(evstruct.required.Event_type,':',/extract))[1],2) +'_optional">']
      IF (strlowcase(these_tags(i)) NE 'event_probability') THEN BEGIN
         IF FINITE(evstruct.optional.(i)) THEN BEGIN
            IF (abs(evstruct.optional.(i))) THEN BEGIN
               print, "Warning: Event probabilty outside of valid range of [0,1]"
            ENDIF
            buff = [buff, '           <Param name="'+these_tags(i)+'" value="'+strtrim(string(evstruct.optional.(i)),2)+'"/>']
         ENDIF
      ENDIF ELSE BEGIN
         buff = [buff, '           <Param name="'+these_tags(i)+'" value="'+strtrim(string(evstruct.optional.(i)),2)+'"/>']
      ENDELSE
   endif
endfor
if count GT 0 then buff = [buff, '       </Group>']

if (evstruct.description NE '') then $
  buff = [buff, '       <Description>','          '+evstruct.description,'       </Description>']

buff = [buff, '    </Why>']
buff = [buff, '']

; Finally, add lines for VO Event reference uri's
these_tags=tag_names(evstruct.required)
n_these_tags=N_ELEMENTS(these_tags)
FOR I=0,n_these_tags-1 DO BEGIN
    row = where(strmatch(param_names, these_tags(i),/fold))
    if strmatch(vo_translation(row),'Reference uri', /fold_case) then $
      buff = [buff, '    <Reference name="'+strtrim(these_tags(i),2)+'" uri="' + strtrim(string(evstruct.required.(i)),2)+'"/>']
ENDFOR
these_tags=tag_names(evstruct.optional)
n_these_tags=N_ELEMENTS(these_tags)
FOR I=0,n_these_tags-1 DO BEGIN
    skip = 0
    row = where(strmatch(param_names, these_tags(i),/fold))
    idl_type_index = where( (size(evstruct.optional.(I)))[1] EQ idl_type_vec) 
    var_type = type_vec[idl_type_index]
    ;    print, evstruct.optional.(i), var_type
    case (size(evstruct.optional.(I)))[1] of
        1: if evstruct.optional.(i) EQ 0b then skip=1
        2: if evstruct.optional.(i) EQ -9999 then skip=1
        3: if evstruct.optional.(i) EQ -999999l then skip=1
        4: if evstruct.optional.(i) EQ !VALUES.F_Infinity then skip = 1
        5: if evstruct.optional.(i) EQ !VALUES.D_Infinity then skip = 1
        7: if evstruct.optional.(i) EQ "blank" then skip = 1
        else: begin
        endelse
    endcase
    if strmatch(vo_translation(row),'Reference uri', /fold_case) and (skip EQ 0) then $
      buff = [buff, '    <Reference name="'+strtrim(these_tags(i),2)+'" uri="' + strtrim(string(evstruct.optional.(i)),2)+'"/>']
ENDFOR

; Now output additional unnamed references
FOR i=0,n_elements(evstruct.reference_links)-1 DO BEGIN
    IF (strtrim(evstruct.reference_links[i],2) NE '') THEN BEGIN
      ref_name = ''
      ref_type = ''
      IF (strtrim(evstruct.reference_names[i],2) NE '') then $
        ref_name = 'name="'+strtrim(evstruct.reference_names[i],2)+ '"'
      IF (strtrim(evstruct.reference_types[i],2) NE '') then  $
        ref_type=  ' type="'+strtrim(evstruct.reference_types[i],2)+'"'
      buff = [buff,  '    <Reference '+ref_name+ ref_type+ ' uri="'+strtrim(evstruct.reference_links[i],2)+'"/>']
    ENDIF
ENDFOR

; Citations
cbuff = ['', '   <Citations>']
citation_added = 0
FOR I=0,n_elements(evstruct.citations)-1 DO BEGIN
   cite = (evstruct.citations)[I]
   cite.EventIVORN = strtrim(cite.EventIVORN,2)
   cite.Action = strtrim(cite.Action,2)
   IF (strlen(cite.EventIVORN) NE 0) THEN BEGIN
      IF ((cite.Action EQ 'followup') OR (cite.Action EQ 'supersedes') OR (cite.Action EQ 'retraction') ) THEN BEGIN
         cbuff = [cbuff, '      <EventIVORN action="'+cite.Action+'">'+cite.EventIVORN+'</EventIVORN>']
         IF (strlen(cite.Description) NE 0 ) THEN cbuff = [cbuff, '      <Description>'+cite.Description+'</Description>']
         citation_added = 1
      ENDIF ELSE BEGIN
         print, 'Error: Citation.Action must one one of the follow three values: followup, supersedes or retraction.'
         print, 'This VOEvent has a citation with the action = ' + cite.action
         IF (cite.action EQ 'supercedes') THEN print, 'Please change spellling to "supersedes"'
         print, 'export_event aborted'
         return
      ENDELSE
   ENDIF
ENDFOR
cbuff = [cbuff, '   </Citations>']
IF (citation_added EQ 1) THEN buff = [buff, cbuff]


buff = [buff, '']
buff = [buff, '</voe:VOEvent>']

if keyword_set(display_xml) then $
  prstr, buff

if keyword_set(write_file) then $
  file_append, outfil_voevent_full, buff, /newfile

filenameout = outfil_voevent_full
end
