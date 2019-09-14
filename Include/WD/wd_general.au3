#Region Description
   ; ==============================================================================
   ; UDF ...........: wd_general.au3
   ; Description ...: General functions for browser testing.
   ; Author(s) .....: Matze1985
   ; Url .......... : https://github.com/Matze1985/WebDriver/blob/master/Include/WD/wd_general.au3
   ; ==============================================================================
#EndRegion Description

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_WaitForSource
; Description ...: Waiting source with reload from page
; Syntax ........: _WD_WaitForSource($sSearch, $iWait, $bRefresh, $bVisibility)
; Parameters.....: $sFuncName 		- Function name for logging
;				   $i_sFrame		- Frame by int or string (xPath, number, Leave)
;				   $sSearch 		- Search with RegEx in string
;				   $iRound 			- Loop rounds (Int)
;				   $iWait			- Waiting in ms (Int)
;				   $bRefresh 		- True or False
;				   $bVisible		- Wait for visibility true/false
; Author ........: Matze1985
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: _WD_WaitForSource($sFuncName, 'class="btn"', 5, 1000, True, True)
; ===============================================================================================================================
Func _WD_WaitForSource($sFuncName, $i_sFrame, $sSearch, $iRound, $iWait, $bRefresh, $bVisible)
   Local $sSource, $i

   If $i_sFrame <> "" Then
      _WD_Frame($sFuncName, $i_sFrame)
   EndIf

   If $bVisible = True Then
      Do
         Sleep($iWait)
         $sSource = BinaryToString(_WD_GetSource($sSession), $SB_UTF8)
         If StringRegExp($sSource, $sSearch) Then
            $i = Int($iRound)
         Else
            _WD_HttpResult($sFuncName, "Source", $sSearch & " : is already not visible", 2)
            If $bRefresh == True Then
               _WD_BrowserAction($sFuncName, "refresh")
            EndIf
            $i = $i + 1
         EndIf
      Until $i = Int($iRound)
      If StringRegExp($sSource, $sSearch) Then
         _WD_HttpResult($sFuncName, "Source", $sSearch & " : passed", 2)
      Else
         _WD_HttpResult($sFuncName, "Source", $sSearch & " : not passed", 3)
      EndIf
   EndIf
   If $bVisible = False Then
      Do
         Sleep($iWait)
         $sSource = _WD_GetSource($sSession)
         If Not StringRegExp($sSource, $sSearch) Then
            $i = $iRound
         Else
            _WD_HttpResult($sFuncName, "Source", $sSearch & " : is already visible", 2)
            If $bRefresh == True Then
               _WD_BrowserAction($sFuncName, "refresh")
            EndIf
            $i = $i + 1
         EndIf
      Until $i = Int($iRound)
      If Not StringRegExp($sSource, $sSearch) Then
         _WD_HttpResult($sFuncName, "Source", $sSearch & " : passed", 2)
      Else
         _WD_HttpResult($sFuncName, "Source", $sSearch & " : not passed", 3)
      EndIf
   EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_ReturnBySource
; Description ...: Get return source code by text.
; Syntax ........: _WD_ReturnBySource($Session, $sFuncName, $sText, $iWait)
; Parameters ....: $sFuncName           - Func name for logging
;				   $sText				- Return text with True or False
;				   $iWait				- [optional] Wait for execute in ms
; Return values .: True or False
; Author ........: Matze1985
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Examples ......: _WD_ReturnBySource($sFuncName, "blue", 4000)
; ===============================================================================================================================
Func _WD_ReturnBySource($sFuncName, $sText, $iWait = 0)
   Sleep(Int($iWait))
   Local $sResult = BinaryToString(_WD_GetSource($sSession), $SB_UTF8)

   ; Return text
   If StringRegExp($sResult, $sText) Then
      _WD_HttpResult($sFuncName, "Source", "Actual => Return True => [" & $sText & "]", 2)
      Return True
   Else
      _WD_HttpResult($sFuncName, "Source", "Actual => Return False => [" & $sText & "]", 2)
      Return False
   EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_WaitForElementAndAction
; Description ...: Check if a element is empty
; Syntax ........: _WD_WaitForElementAndAction($sFuncName, $sId, $sAction, $sActionInput, Int($iDelay), Int($iTimeout), $sEnterFrame, $sLeaveFrame)
; Parameters.....: $sFuncName		- Func name for logging
;;				   $i_sFrame		- Frame by int or string (xPath, number, Leave)
;				   $sId  			- Id from locator
;				   $sAction     	- Action, value or click for example
;				   $sActionInput 	- [optional] Needs only for value and clear
;				   $iDelay			- [optional] Milliseconds to wait before checking status
;				   $iTimeout		- [optional] Period of time to wait before exiting function
; Author ........: Matze1985
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: _WD_WaitForElementAndAction($sFuncName, "", "//*[@class='button']", "click", "", 500, 1500)
; ===============================================================================================================================
Func _WD_WaitForElementAndAction($sFuncName, $i_sFrame, $sId, $sAction, $sActionInput = "", $iDelay = 0, $iTimeout = 0)
   Local $sActionWithInput = $sAction & " => " & $sActionInput

   If $i_sFrame <> "" Then
      _WD_Frame($sFuncName, $i_sFrame)
   EndIf

   If $sAction == "clear|value" Then
      _WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, $sId, $iDelay, $iTimeout)
      $sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, $sId)
      _WD_ElementAction($sSession, $sElement, 'clear')
      _WD_ElementAction($sSession, $sElement, 'value', $sActionInput)
      _WD_HttpResult($sFuncName, $sId, $sActionWithInput, 0)
   EndIf
   If $sAction == "value" Then
      _WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, $sId, $iDelay, $iTimeout)
      $sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, $sId)
      _WD_ElementAction($sSession, $sElement, $sAction, $sActionInput)
      _WD_HttpResult($sFuncName, $sId, $sActionWithInput, 0)
   EndIf
   If $sAction == "click" Then
      _WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, $sId, $iDelay, $iTimeout)
      $sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, $sId)
      _WD_ElementAction($sSession, $sElement, $sAction)
      _WD_HttpResult($sFuncName, $sId, $sAction, 0)
   EndIf
   If $sAction == "double-click" Then
      _WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, $sId, $iDelay, $iTimeout)
      $sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, $sId)
      _WD_ElementAction($sSession, $sElement, $sAction)
      _WD_ElementAction($sSession, $sElement, $sAction)
      _WD_HttpResult($sFuncName, $sId, $sAction, 0)
   EndIf
   If $sAction == "select" Then
      _WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, $sId, $iDelay, $iTimeout)
	  _WD_ElementOptionSelect($sSession, $_WD_LOCATOR_ByXPath, $sId)
      _WD_HttpResult($sFuncName, $sId, $sAction, 0)
   EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_TabHandle
; Description ...: Handle tabs
; Syntax ........: _WD_TabHandle()
; Parameters.....: $sFuncName	- Func name for logging
;				   $i_sTab		- Tab (Int) number of all tabs [1 = Current tab] or with string 'NewTab' open a new Tab
; Author ........: Matze1985
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: _WD_TabHandle(1), _WD_TabHandle("NewTab")
; ===============================================================================================================================
Func _WD_TabHandle($sFuncName, $i_sTab)
   Local $aHandles, $iTabCount, $sTabHandle

   If $i_sTab == 'new' Then
      _WD_NewTab($sSession)
      _WD_HttpResult($sFuncName, "Tab", "new", 0)
   EndIf

   If $i_sTab == 'close' Then
      _WD_Window($sSession, 'close')
      _WD_HttpResult($sFuncName, "Tab", "close", 0)
   EndIf

   If StringRegExp($i_sTab, '[0-9]{1,}') Then
      $aHandles = _WD_Window($sSession, 'handles')
      $iTabCount = UBound($aHandles)
      $sTabHandle = $aHandles[$iTabCount - Int($i_sTab)]
      _WD_Window($sSession, 'Switch', '{"handle":"' & $sTabHandle & '"}')
      _WD_HttpResult($sFuncName, "Tab", "Switch to " & $i_sTab & " (from right)", 0)
   EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_GetAndVerifyElementByValue
; Description ...: Get and verify a document element value.
; Syntax ........: WD_GetElementValue($sFuncName, $sMethod, $sId, $iNumber, $sProperty, $sVisibleValue, $bVisible, $iWait)
; Parameters ....: $sFuncName           - Func name for logging
; 				   $sMethod				- Id, TagName, ClassName
;				   $sId					- Method html name
;				   $iNumber				- Number for check
;  				   $sProperty			- innerHTML, attribute, style.property
;				   $sVisibleValue		- Verify: Value for check
;				   $bVisible			- Verify: True or False
;				   $iWait				- Wait for execute in ms
; Return values .: $sNoHtmlResult 		- Text without html
; Author ........: Matze1985
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........: https://www.w3schools.com/js/js_htmldom_document.asp
; Examples ......: => Check value for true/false:
;				   _WD_GetAndVerifyElementByValue($sFuncName, 'ClassName', 'page-header', '0', 'innerHTML', 'Football', True, 2000)
; 				   => Return value:
; 				   _WD_GetAndVerifyElementByValue($sFuncName, 'ClassName', 'page-header', '0', 'innerHTML', '', '', 2000)
; ===============================================================================================================================
Func _WD_GetAndVerifyElementByValue($sFuncName, $sMethod, $sId, $iNumber, $sProperty, $sVisibleValue, $bVisible, $iWait)
   Local $sPassed = "passed"
   Local $sNotPassed = "not passed"
   Sleep(Int($iWait))

   Local $sResponse = _WD_ExecuteScript($sSession, "return document.getElementsBy" & $sMethod & "('" & $sId & "')[" & Int($iNumber) & "]." & $sProperty & ";")
   Local $sJSON = Json_Decode($sResponse)
   Local $sResult = Json_Get($sJSON, "[value]")
   Local $sNoHtmlResult = BinaryToString(StringRegExpReplace($sResult, "<[^>]*>", ""), $SB_UTF8)

   ; Check element value
   If $bVisible == True Then
      _WD_HttpResult($sFuncName, "ID : " & $sId, "Actual => [" & $sNoHtmlResult & "] Expected (True) => [" & $sVisibleValue & "]", 0)
   EndIf
   If $bVisible == False And $bVisible <> "" Then
      _WD_HttpResult($sFuncName, "ID : " & $sId, "Actual => [" & $sNoHtmlResult & "] Expected (False) => [" & $sVisibleValue & "]", 0)
   EndIf
   If $bVisible == "" Then
      _WD_HttpResult($sFuncName, "ID : " & $sId, "Return => [" & $sNoHtmlResult & "]", 2)
      Return $sNoHtmlResult
   EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_GetAndVerifyElementByText
; Description ...: Get and verify a element by text with xPath.
; Syntax ........: _WD_GetAndVerifyElementByValue($Session, $sFuncName, $sId, $sVisibleValue, $bVisible, $iWait)
; Parameters ....: $sSession            - Session ID from _WDCreateSession
;				   $i_sFrame			- Frame by int or string (xPath, number, Leave)
;				   $sFuncName           - Func name for logging
;				   $sId					- Method xPath
;				   $sVisibleValue		- Verify: Value for check
;				   $bVisible			- Verify: True or False
;				   $iWait				- Wait for execute in ms
; Return values .: $sResult 			- Text
; Author ........: Matze1985
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Examples ......: => Check value for true/false:
;				   _WD_GetAndVerifyElementByText($sFuncName, "/html/frameset/frameset[2]/frame[2]", "//a[@class='bt']", "Hello", True, 2000)
; 				   => Return text:
;				   _WD_GetAndVerifyElementByText($sFuncName, "/html/frameset/frameset[2]/frame[2]", "//a[@class='bt']", "Hello", "", 2000)
; ===============================================================================================================================
Func _WD_GetAndVerifyElementByText($sFuncName, $i_sFrame, $sId, $sVisibleValue, $bVisible, $iWait)
   Local $sElement, $sOldClip
   Sleep(Int($iWait))

   If $i_sFrame <> '' Then
      _WD_Frame($sFuncName, $i_sFrame)
   EndIf

   $sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, $sId)
   Local $sResult = BinaryToString((_WD_ElementAction($sSession, $sElement, 'text')), $SB_UTF8)

   ; Check element value
   If $bVisible == True Then
      If StringRegExp($sResult, $sVisibleValue) Then
         _WD_HttpResult($sFuncName, "ID : " & $sId, "Actual => [" & $sResult & "] Expected (True) => [" & $sVisibleValue & "]", 0)
      EndIf
   EndIf

   If $bVisible == False Then
      If Not StringRegExp($sResult, $sVisibleValue) Then
         _WD_HttpResult($sFuncName, "ID : " & $sId, "Actual => [" & $sResult & "] Expected (False) => [" & $sVisibleValue & "]", 0)
      EndIf
   EndIf
   If $bVisible == "" Then
      _WD_HttpResult($sFuncName, "ID : " & $sId, "Return => [" & $sResult & "]", 2)
      Return $sResult
   EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_BrowserAction
; Description ...: Browser actions with logging
; Syntax ........: _WD_BrowserAction($sFuncName, $sAction)
; Parameters.....: $sFuncName	- Func name for logging
;				   $sAction		- forward, back, refresh, url, alert
; Author ........: Matze1985
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: _WD_BrowserAction($sFuncName, "refresh")
; ===============================================================================================================================
Func _WD_BrowserAction($sFuncName, $sAction)
   Local $sLogAction, $sReturn
   If StringInStr($sAction, "http") Then
      _WD_Navigate($sSession, $sAction)
      $sLogAction = "Open " & $sAction
   Else
      _WD_Action($sSession, $sAction)
      $sLogAction = $sAction
   EndIf
   If $sAction == "scrollHeight" Then
      _WD_ExecuteScript($sSession, 'window.scrollTo(0, document.body.scrollHeight)')
   EndIf
   If StringInStr($sAction, "alert:") Then
      _WD_Alert($sSession, StringReplace($sAction, "alert:", ""))
      $sLogAction = $sAction
   EndIf
   If StringInStr($sAction, "alert:sendtext:") Then
      _WD_Alert($sSession, "sendtext", StringReplace($sAction, "alert:sendtext:", ""))
      $sLogAction = $sAction
   EndIf
   _WD_HttpResult($sFuncName, "Browser", $sLogAction, 0)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_ReturnByText
; Description ...: Get return value by text with xPath.
; Syntax ........: _WD_ReturnByText($sFuncName, $sId, $sText, $sEnterFrame, $iWait)
; Parameters ....: $sFuncName           - Func name for logging
;				   $i_sFrame			- Frame by int or string (xPath, number, Leave)
;				   $sId					- Method xPath
;				   $sText				- Return text with True or False
;				   $iWait				- [optional] Wait for execute in ms
; Return values .: True or False
; Author ........: Matze1985
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Examples ......: _WD_ReturnByText($sFuncName, "/html/frameset/frameset[2]/frame[2]", "//*[@id='tkl']", "Huhu", 1000)
; ===============================================================================================================================
Func _WD_ReturnByText($sFuncName, $i_sFrame, $sId, $sText, $iWait = 0)
   Local $sElement
   Sleep(Int($iWait))
   If $i_sFrame <> "" Then
      _WD_Frame($sFuncName, $i_sFrame)
      _WD_HttpResult($sFuncName, "frame", $sId)
   EndIf

   Local $sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, $sId)
   Local $sResult = BinaryToString(_WD_ElementAction($sSession, $sElement, 'text'), $SB_UTF8)

   ; Return text
   If StringRegExp($sResult, $sText) Then
      _WD_HttpResult($sFuncName, "ID : " & $sId, "Actual => Return True => [" & $sText & "]", 2)
      Return True
   Else
      _WD_HttpResult($sFuncName, "ID : " & $sId, "Actual => Return False => [" & $sText & "]", 2)
      Return False
   EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_Frame
; Description ...: Get return value by text with xPath.
; Syntax ........: _WD_Frame($sSession, $sFuncName, $sId, $sText, $sEnterFrame, $iWait)
; Parameters ....: $sFuncName           - Func name for logging
;				   $i_sFrame			- Frame by int or string (xPath, number, Leave)
; Author ........: Matze1985
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Examples ......: _WD_Frame($Session, $i_sFrame)
; ===============================================================================================================================
Func _WD_Frame($sFuncName, $i_sFrame)
   Local $sElement, $sSession

   If $i_sFrame <> "" Then
      $sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, $i_sFrame)
      $sElement = _WD_FrameEnter($sSession, $sElement)
      _WD_HttpResult($sFuncName, "frame", $i_sFrame, 0)
   EndIf
   If $i_sFrame == "leave" Then
      _WD_FrameLeave($sSession)
      _WD_HttpResult($sFuncName, "frame", $i_sFrame, 0)
   EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_HttpResult
; Description ...: Log HTTP-Result
; Syntax ........: _WD_HttpResult($Session, $sFuncName, $sDescription, $sLogAction)
; Parameters ....: 	$sSession            	- Session ID from _WDCreateSession
;					$sFuncName           	- Func name for logging
;					$iMode					- 0=Error with exit, 1=Error with no exit, 2=Return, 3=StatusCode only by error
; Author ........: 	Matze1985
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Examples ......: _WD_HttpResult($Session, $sFuncName, $sDescription, $sLogAction)
; ===============================================================================================================================
Func _WD_HttpResult($sFuncName, $sDescription, $sLogAction, $iMode = 0)
   Local $sInfo = "--> [INFO] : "
   Local $sError = "--> [ERROR] : "

   ; Mode 0 for exit if error
   If $iMode == 0 Then
      If $_WD_HTTPRESULT <> 200 Then
         ConsoleWrite($sError & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & " : " & $sFuncName & " : " & $sDescription & " : " & $sLogAction & " : StatusCode=" & $_WD_HTTPRESULT & " : " & "not passed" & @CRLF)
         Exit
      Else
         ConsoleWrite($sInfo & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & " : " & $sFuncName & " : " & $sDescription & " : " & $sLogAction & " : StatusCode=" & $_WD_HTTPRESULT & " : " & "passed" & @CRLF)
      EndIf
   EndIf

   ; Mode 1 for no exit if error
   If $iMode == 1 Then
      If $_WD_HTTPRESULT <> 200 Then
         ConsoleWrite($sError & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & " : " & $sFuncName & " : " & $sDescription & " : " & $sLogAction & " : StatusCode=" & $_WD_HTTPRESULT & " : " & "not passed" & @CRLF)
      Else
         ConsoleWrite($sInfo & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & " : " & $sFuncName & " : " & $sDescription & " : " & $sLogAction & " : StatusCode=" & $_WD_HTTPRESULT & " : " & "passed" & @CRLF)
      EndIf
   EndIf

   ; Mode 2 Log info (without StatusCode)
   If $iMode == 2 Then
      ConsoleWrite($sInfo & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & " : " & $sFuncName & " : " & $sDescription & " : " & $sLogAction & @CRLF)
   EndIf

   ; Mode 3 Log error (without StatusCode)
   If $iMode == 3 Then
      ConsoleWrite($sError & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & " : " & $sFuncName & " : " & $sDescription & " : " & $sLogAction & @CRLF)
      Exit
   EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _GenerateTestData
; Description ...: Generate a string or a number
; Syntax ........: _GenerateTestData($iOption, $iLength)
; Parameters ....: 	$iLength            - Integer - Letter length begins with a large letter
;					$iOption            - Integer - Option: 0=Small, 1=Large, 2=First large, small letters, 3=Only numbers
; Author ........: 	Matze1985
; Modified ......:
; Remarks .......:
; Related .......:
; Examples ......: _GenerateTestData(8, 0)
; ===============================================================================================================================
Func _GenerateTestData($iLength = 5, $iOption = 0)
   Local $i_sName, $i
   Local $aLargeLetter = StringSplit("ABCDEFGHIJKLMNOPQRSTUVWXYZ", "")
   Local $aSmallLetter = StringSplit("abcdefghijklmnopqrstuvwxyz", "")
   Local $aNumber = StringSplit("0123456789", "")

   ; Small letters
   If $iOption == 0 Then
      For $i = 1 To $iLength
         $i_sName &= $aSmallLetter[Random(1, $aSmallLetter[0], 1)]
      Next
   EndIf

   ; Large Letters
   If $iOption == 1 Then
      For $i = 1 To $iLength
         $i_sName &= $aLargeLetter[Random(1, $aLargeLetter[0], 1)]
      Next
   EndIf

   ; First large letters and then small letters
   If $iOption == 2 Then
      $i_sName = $aLargeLetter[Random(1, $aLargeLetter[0], 1)]
      For $i = 2 To $iLength
         $i_sName &= $aSmallLetter[Random(1, $aSmallLetter[0], 1)]
      Next
   EndIf

   ; Generate numbers
   If $iOption == 3 Then
      For $i = 1 To $iLength
         $i_sName &= Int($aNumber[Random(1, $aNumber[0], 1)])
      Next
   EndIf

   Return $i_sName
EndFunc