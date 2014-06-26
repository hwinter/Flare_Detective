; $Id: strsplit.pro,v 1.3 2000/01/21 00:29:34 scottm Exp $

; Copyright (c) 1999-2000, Research Systems, Inc.  All rights reserved.
;       Unauthorized reproduction prohibited.

;+
; NAME:
;       STRSPLIT
;
; PURPOSE:
;	Wrapper on the build in system routine STRTOK that implements exactly
;	the same interface as STRTOK, but with the STRSPLIT name.
;
;       The reason for doing this is so that if a user has their own
;	STRSPLIT in their local user library, their version will superceed
;	this one. RSI does not recommend this practice, but it is
;	allowed for backwards compatability reasons. See the
;       documentation for STRSPLIT in the IDL Reference manual
;	for details on arguments, keywords, and results.
; 
;
; MODIFICATION HISTORY:
;	14 October 1999, AB, RSI.
;-

function rsi_strsplit, string, pattern, _ref_extra=extra

if (n_params() eq 1) then return, strtok(string, _extra=extra) $
else return, strtok(string, pattern, _extra=extra)


end
