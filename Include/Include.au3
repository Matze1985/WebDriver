#Region Description
   ; ==============================================================================
   ; UDF ...........: IncludeAll.au3
   ; Description ...: Include all
   ; Author(s) .....: Mathias Noack
   ; AutoIt Version : v3.3.14.2
   ; ==============================================================================
#EndRegion Description

; Folder WD
#include "WD\wd_core.au3"
#include "WD\wd_helper.au3"
#include "WD\wd_browser.au3"
#include "WD\wd_general.au3"
#include "WD\WinHttp.au3"
#include "WD\WinHttpConstants.au3"
#include "WD\Json.au3"

; Folder Library
#include "Library\Nightscout.au3"

; Folder Other

; AutoIt Include
#include <Debug.au3>
#include <FileConstants.au3>

; Globals
Global $_WD_DEBUG = False