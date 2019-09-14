#Region Description
   ; ==============================================================================
   ; UDF ...........: NS_TestExample.au3
   ; Description ...: Add IC, ISF, Basal under profile by Nightscout
   ; Author(s) .....: Matze1985
   ; ==============================================================================
#EndRegion Description

#include "Include\Include.au3"

; Debug mode
$_WD_DEBUG = False

; Start scenario
_WD_SetupBrowser("Gecko", "LogTrace")
_NS_Login($sSession)
_NS_NavigateTo($sSession, "Profile")
_NS_Profile($sSession, "ic|isf|basal")
_WD_Shutdown()