#Region Description
   ; ==============================================================================
   ; UDF ...........: TC_WD_01_ClickTextByNumber.au3
   ; Description ...: Text click text by number
   ; Author(s) .....: Matze1985
   ; ==============================================================================
#EndRegion Description

#include "..\..\Include\Include.au3"

; Start scenario
_WD_SetupBrowser("Gecko", "LogTrace")
_WD_BrowserAction("eBay - Kleinanzeigen", "https://www.ebay-kleinanzeigen.de/")
_WD_Step("eBay - Kleinanzeigen", "", "[id]gdpr-banner-accept|[txt:3]Mehr ...|[txt:2]Mehr ...|[txt:1]Mehr ...")
_WD_Shutdown()
