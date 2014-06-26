;+
; Pascal Saint-Hilaire, written 2001/06/19
;
;PURPOSE:
; Converts Civil Time to Sidereal Time.
;	see examples to get GMST or LST 
;	GMST is the time angle FROM the vernal point TO the Greenwitch meridian.
;
;INPUT:
;	a time in anytim format
;
;OPTIONAL INPUT KEYWORDS:
;	tz : enter time zone ahead of UT (ex: +1 for Paris in winter, +2 for Paris in summer) 
;	longitude : the longitude EAST of Greenwich, in degrees
;
;OUTPUT:
;	Sidereal Time in decimal hours (default)
;
;PLANNED improvements:
;	- include seconds in output !!!
;	- output keywords : decimal format/usual time format, etc...
;
;EXAMPLES:
;	to get the Greenwitch Mean Sidereal Time (GMST), enter a UT time
;		gmst=ct2st(UT_time)
;	to get Local Sidereal Time (LST) use either one of three ways:
;		a) lst=ct2st(local_civil_time)
;		b) lst=ct2st(UT_time,tz=tz)
;		c) lst=ct2st(UT_time,long=longitude)
;	methods a) and b) only give the Local Apparent Sidereal Time
;	method c) is the more precise one, of course, giving the REAL Local Sidereal Time
;-


FUNCTION ct2st,atime,long=long,tz=tz

if not keyword_set(long) then long=0
if not keyword_set(tz) then tz=0

t=anytim(atime,/EX)
ct2lst,lst,long,tz,ten(t(0),t(1)),t(4),t(5),t(6)
RETURN,lst
END
