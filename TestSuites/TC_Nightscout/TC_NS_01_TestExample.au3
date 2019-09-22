#Region Description
   ; ==============================================================================
   ; UDF ...........: TC_NS_01_TestExample.au3
   ; Description ...: Add IC, ISF, Basal under profile by Nightscout
   ; Author(s) .....: Matze1985
   ; ==============================================================================
#EndRegion Description

#include "..\..\Include\Include.au3"

; Start scenario
_WD_SetupBrowser("Gecko", "LogTrace")
_NS_Login()
_NS_NavigateTo("Profile")
_NS_Profile("ic|isf|basal")
_WD_Shutdown()