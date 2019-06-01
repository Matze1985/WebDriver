#Region Description
   ; ==============================================================================
   ; UDF ...........: NS_TestCase.au3
   ; Description ...: Scenario
   ; Author(s) .....: Mathias Noack
   ; AutoIt Version : v3.3.14.2
   ; ==============================================================================
#EndRegion Description

#include "Include\WD\wd_core.au3"
#include "Include\WD\wd_helper.au3"
#include "Include\WD\wd_browser.au3"
#include "Include\WD\wd_general.au3"
#include "Include\Library\Nightscout.au3"

; Debug mode
$_WD_DEBUG = False

; Start scenario
_WD_SetupBrowser("Gecko", "LogTrace")
_NS_Login($sSession)
_NS_NavigateTo($sSession, "Profile")
_NS_Profile($sSession, "ic|isf|basal")
_WD_Shutdown()
