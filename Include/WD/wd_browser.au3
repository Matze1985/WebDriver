#Region Description
   ; ==============================================================================
   ; UDF ...........: wd_browser.au3
   ; Description ...: Setups for browsers.
   ; Author(s) .....: Mathias Noack
   ; AutoIt Version : v3.3.14.2
   ; ==============================================================================
#EndRegion Description

#include <FileConstants.au3>

#Region Locals
   Local $sInfo = "--> [INFO] : "
   Local $sError = "--> [ERROR] : "
#EndRegion Locals

; Path
Local $sBrowserPath = "Browser\"

; Capabilities for browsers
Local $sDesiredCapabilitiesChrome = '{"capabilities": {"alwaysMatch": {"goog:chromeOptions": {"w3c": true, "args":["start-maximized", "disable-infobars"] }}}}'
Local $sDesiredCapabilitiesChromeProfile = '{"capabilities": {"alwaysMatch": {"goog:chromeOptions": {"w3c": true, "args":["start-maximized", "disable-infobars", "--user-data-dir=Browser/Profile/ChromeProfile"] }}}}'
Local $sDesiredCapabilitiesGecko = '{"desiredCapabilities":{"javascriptEnabled":true,"nativeEvents":true,"acceptInsecureCerts":true}}'
Local $sDesiredCapabilitiesEdge = '{"capabilities":{}}'


; Exe for browsers
Local $sExeChrome = 'chromedriver.exe'
Local $sExeGecko = 'geckodriver.exe'
Local $sExeEdge = 'MicrosoftWebDriver.exe'

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_SetupBrowser
; Description ...: Setup of Browser
; Syntax ........: SetupBrowser($sBrowser, $sDriverParams)
; Parameters.....: $sSession 		- Session ID from _WDCreateSession
;				   $sBrowser		- Chrome, Gecko, Edge
;				   $sDriverParams	- LogTrace, LogPath, Verbose, Debug
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: _WD_SetupBrowser("Gecko", "LogTrace") or _WD_SetupBrowser("Gecko", "Debug")
; ===============================================================================================================================
Func _WD_SetupBrowser($sBrowser, $sDriverParams)
   Local Const $sFuncName = "_WD_SetupBrowser"
   Local Const $sFilePath = $sBrowserPath & "_WD_SetupBrowser.txt"
   Local $hFileOpen
   Global $sSession

   ; BrowserConfig
   If $sBrowser = "Chrome" Then
      _WD_Option('Driver', $sBrowserPath & $sExeChrome)
      _WD_Option('Port', 9515)
      $sDesiredCapabilities = $sDesiredCapabilitiesChrome
   EndIf
   If $sBrowser = "Gecko" Then
      _WD_Option('Driver', $sBrowserPath & $sExeGecko)
      _WD_Option('Port', 4444)
      $sDesiredCapabilities = $sDesiredCapabilitiesGecko
   EndIf
   If $sBrowser = "Edge" Then
      _WD_Option('Driver', $sBrowserPath & $sExeEdge)
      _WD_Option('Port', 17556)
      $sDesiredCapabilities = $sDesiredCapabilitiesEdge
   EndIf

   ; DriverParams
   If $sDriverParams = "LogPath" Then
      _WD_Option('DriverParams', '--log-path=' & @ScriptDir & '\' & $sBrowser & '.log')
   EndIf
   If $sDriverParams = "LogTrace" Then
      _WD_Option('DriverParams', '--log trace')
   EndIf
   If $sDriverParams = "Verbose" Then
      _WD_Option('DriverParams', '--verbose')
   EndIf
   If $sDriverParams = "Debug" Then
      _WD_Option('DriverParams', '--log trace --connect-existing')
   Else
      ; Wait for browser and new session
      Sleep(2000)
   EndIf

   ; Write session and read session from temp file
   If $sDriverParams = "Debug" Then
      $sSession = FileReadLine($sFilePath, 1)
	  If StringRegExp($sSession, '[0-9]|[a-z]') Then
		 ConsoleWrite($sInfo & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & " : " & $sFuncName & " : Read session : " & $sSession & " : Path : " & $sFilePath & @CRLF)
      Else
		ConsoleWrite($sError & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & " : " & $sFuncName & " : Read no session : " & $sSession & " : Path : " & $sFilePath & @CRLF)
		Exit
	  EndIf
      _WD_GetSource($sSession)
   Else
	  FileDelete($sFilePath)
      $hFileOpen = FileOpen($sFilePath, $FO_READ + $FO_OVERWRITE)
      If $hFileOpen = -1 Then
         ConsoleWrite($sError & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & " : " & $sFuncName & " : An error occurred whilst writing the temporary file" & @CRLF)
	  EndIf
	  _WD_Startup()
      $sSession = _WD_CreateSession($sDesiredCapabilities)
      FileWrite($hFileOpen, $sSession)
      ConsoleWrite($sInfo & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & " : " & $sFuncName & " : Start : " & $_WD_DRIVER & " : Session : " & $sSession & " : Path : " & $sFilePath  & @CRLF)
   EndIf

   ; Close file
   FileClose($hFileOpen)
EndFunc