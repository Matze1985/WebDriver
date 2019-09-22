#Region Description
   ; ==============================================================================
   ; UDF ...........: wd_general.au3
   ; Description ...: General functions for browser testing.
   ; Author(s) .....: Matze1985
   ; Url .......... : https://github.com/Matze1985/WebDriver/blob/master/Include/WD/wd_general.au3
   ; ==============================================================================
#EndRegion Description

#Region Copyright
   #cs
      * wd_general.au3
      *
      * MIT License
      *
      * Copyright (c) 2019 Mathias Noack
      *
      * Permission is hereby granted, free of charge, to any person obtaining a copy
      * of this software and associated documentation files (the "Software"), to deal
      * in the Software without restriction, including without limitation the rights
      * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
      * copies of the Software, and to permit persons to whom the Software is
      * furnished to do so, subject to the following conditions:
      *
      * The above copyright notice and this permission notice shall be included in all
      * copies or substantial portions of the Software.
      *
      * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
      * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
      * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
      * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
      * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
      * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
      * SOFTWARE.
   #ce
#EndRegion Copyright

#Region ThankYou
   #cs
      - Dan Pollak - WebDriver UDF - https://www.autoitscript.com/forum/topic/191990-webdriver-udf-w3c-compliant-version-9102019/
      - Ward - JSON UDF - https://www.autoitscript.com/forum/topic/148114-a-non-strict-json-udf-jsmn
      - Ward - BinaryCall UDF - https://www.autoitscript.com/forum/topic/162366-binarycall-udf-write-subroutines-in-c-call-in-autoit/
      - trancexx - WinHTTP UDF - https://www.autoitscript.com/forum/topic/84133-winhttp-functions/
   #ce
#EndRegion ThankYou

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_WaitForSource
; Description ...: Waiting source with reload from page
; Syntax ........: _WD_WaitForSource($sSearch, $iWait, $bRefresh, $bVisibility)
; Parameters.....: $sLogName 		- Name for logging
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
; Example .......: _WD_WaitForSource($sLogName, 'class="btn"', 5, 1000, True, True)
; ===============================================================================================================================
Func _WD_WaitForSource($sLogName, $i_sFrame, $sSearch, $iRound, $iWait, $bRefresh, $bVisible)
   Local $sSource, $i

   ; Enter a frame
   If $i_sFrame <> "" Then
      _WD_Frame($sLogName, $i_sFrame)
   EndIf

   If $bVisible = True Then
      Do
         Sleep($iWait)
         $sSource = BinaryToString(_WD_GetSource($sSession), $SB_UTF8)
         If StringRegExp($sSource, $sSearch) Then
            $i = Int($iRound)
         Else
            _WD_HttpResult($sLogName, "Source", $sSearch & " : is already not visible", 2)
            If $bRefresh == True Then
               _WD_BrowserAction($sLogName, "refresh")
            EndIf
            $i = $i + 1
         EndIf
      Until $i = Int($iRound)
      If StringRegExp($sSource, $sSearch) Then
         _WD_HttpResult($sLogName, "Source", $sSearch & " : passed", 2)
      Else
         _WD_HttpResult($sLogName, "Source", $sSearch & " : not passed", 3)
      EndIf
   EndIf
   If $bVisible = False Then
      Do
         Sleep($iWait)
         $sSource = _WD_GetSource($sSession)
         If Not StringRegExp($sSource, $sSearch) Then
            $i = $iRound
         Else
            _WD_HttpResult($sLogName, "Source", $sSearch & " : is already visible", 2)
            If $bRefresh == True Then
               _WD_BrowserAction($sLogName, "refresh")
            EndIf
            $i = $i + 1
         EndIf
      Until $i = Int($iRound)
      If Not StringRegExp($sSource, $sSearch) Then
         _WD_HttpResult($sLogName, "Source", $sSearch & " : passed", 2)
      Else
         _WD_HttpResult($sLogName, "Source", $sSearch & " : not passed", 3)
      EndIf
   EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_WaitForElementAndAction
; Description ...: Check if a element is empty
; Syntax ........: _WD_WaitForElementAndAction($sLogName, $sId, $sAction, $sActionInput, Int($iDelay), Int($iTimeout), $sEnterFrame, $sLeaveFrame)
; Parameters.....: $sLogName 		- Name for logging
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
; Example .......: _WD_WaitForElementAndAction($sLogName, "", "//*[@class='button']", "click", "", 500, 1500)
; ===============================================================================================================================
Func _WD_WaitForElementAndAction($sLogName, $i_sFrame, $sId, $sAction, $sActionInput = "", $iDelay = 0, $iTimeout = 0)
   Local $sActionWithInput = $sAction & " => " & $sActionInput

   Local $sIdDesc = "ID : "

   If $i_sFrame <> "" Then
      _WD_Frame($sLogName, $i_sFrame)
   EndIf

   _WD_WaitElement($sSession, $_WD_LOCATOR_ByXPath, $sId, $iDelay, $iTimeout)
   Local $sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, $sId)
;~    _WD_ExecuteScript($sSession, "arguments[0].scrollIntoView({block:'end',behavior:'smooth'});", '{"' & $_WD_ELEMENT_ID & '":"' & $sElement & '"}')

   If $sAction == "clear|value" Then
      _WD_ElementAction($sSession, $sElement, 'clear')
      _WD_ElementAction($sSession, $sElement, 'value', $sActionInput)
      _WD_HttpResult($sLogName, $sIdDesc & $sId, $sActionWithInput, 0)
   EndIf
   If $sAction == "value" Then
      _WD_ElementAction($sSession, $sElement, $sAction, $sActionInput)
      _WD_HttpResult($sLogName, $sIdDesc & $sId, $sActionWithInput, 0)
   EndIf
   If $sAction == "click" Then
      _WD_ElementAction($sSession, $sElement, $sAction)
      _WD_HttpResult($sLogName, $sIdDesc & $sId, $sAction, 0)
   EndIf
   If $sAction == "double-click" Then
      _WD_ElementAction($sSession, $sElement, $sAction)
      _WD_ElementAction($sSession, $sElement, $sAction)
      _WD_HttpResult($sLogName, $sIdDesc & $sId, $sAction, 0)
   EndIf
   If $sAction == "select" Then
      _WD_ElementOptionSelect($sSession, $_WD_LOCATOR_ByXPath, $sId)
      _WD_HttpResult($sLogName, $sIdDesc & $sId, $sAction, 0)
   EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_TabHandle
; Description ...: Handle tabs
; Syntax ........: _WD_TabHandle()
; Parameters.....: $sLogName 	- Name for logging
;				   $i_sTab		- Tab (Int) number of all tabs [1 = Current tab] or with string 'NewTab' open a new Tab
; Author ........: Matze1985
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: _WD_TabHandle(1), _WD_TabHandle("NewTab")
; ===============================================================================================================================
Func _WD_TabHandle($sLogName, $i_sTab)
   Local $aHandles, $iTabCount, $sTabHandle

   If $i_sTab == 'new' Then
      _WD_NewTab($sSession)
      _WD_HttpResult($sLogName, "Tab", "new", 0)
   EndIf

   If $i_sTab == 'close' Then
      _WD_Window($sSession, 'close')
      _WD_HttpResult($sLogName, "Tab", "close", 0)
   EndIf

   If StringRegExp($i_sTab, '[0-9]{1,}') Then
      $aHandles = _WD_Window($sSession, 'handles')
      $iTabCount = UBound($aHandles)
      $sTabHandle = $aHandles[$iTabCount - Int($i_sTab)]
      _WD_Window($sSession, 'Switch', '{"handle":"' & $sTabHandle & '"}')
      _WD_HttpResult($sLogName, "Tab", "Switch to " & $i_sTab & " (from right)", 0)
   EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_GetText
; Description ...: Get text from element.
; Syntax ........: _WD_GetText($sLogName, $sId, $iWait)
; Parameters ....: $i_sFrame			- Frame by int or string (xPath, number, Leave)
;				   $sLogName            - Name for logging
;				   $sId					- Method xPath
;				   $iWait				- [optional] Wait for execute in ms
; Return values .: $sResult 			- Text
; Author ........: Matze1985
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Examples ......: _WD_GetText("Test", 1, "/html/frameset/frameset[2]/frame[2]" , 2000)
; ===============================================================================================================================
Func _WD_GetText($sLogName, $i_sFrame, $sId, $iWait = 0)
   Sleep(Int($iWait))

   If $i_sFrame <> '' Then
      _WD_Frame($sLogName, $i_sFrame)
   EndIf

   Local $sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, $sId)
   _WD_HttpResult($sLogName, "ID : " & $sId, "Element", 0)

   Local $sResult = BinaryToString((_WD_ElementAction($sSession, $sElement, 'text')), $SB_UTF8)
   _WD_HttpResult($sLogName, "ID : " & $sId, "Return => [" & $sResult & "]", 2)
   Return $sResult
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_BrowserAction
; Description ...: Browser actions with logging
; Syntax ........: _WD_BrowserAction($sLogName, $sAction)
; Parameters.....: $sLogName 	- Name for logging
;				   $sAction		- forward, back, refresh, url, alert
; Author ........: Matze1985
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: _WD_BrowserAction($sLogName, "refresh")
; ===============================================================================================================================
Func _WD_BrowserAction($sLogName, $sAction)
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
   _WD_HttpResult($sLogName, "Browser", $sLogAction, 0)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_ReturnBySource
; Description ...: Get return source code by text.
; Syntax ........: _WD_ReturnBySource($Session, $sLogName, $sText, $iWait)
; Parameters ....: $sLogName            - Name for logging
;				   $sText				- Return text with True or False
;				   $iWait				- [optional] Wait for execute in ms
; Return values .: True or False
; Author ........: Matze1985
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Examples ......: _WD_ReturnBySource($sLogName, "blue", 4000)
; ===============================================================================================================================
Func _WD_ReturnBySource($sLogName, $sText, $iWait = 0)
   Sleep(Int($iWait))
   Local $sResult = BinaryToString(_WD_GetSource($sSession), $SB_UTF8)

   ; Return text
   If StringRegExp($sResult, $sText) Then
      _WD_HttpResult($sLogName, "Source", "Actual => Return True => [" & $sText & "]", 2)
      Return True
   Else
      _WD_HttpResult($sLogName, "Source", "Actual => Return False => [" & $sText & "]", 2)
      Return False
   EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_ReturnByText
; Description ...: Get return value by text with xPath.
; Syntax ........: _WD_ReturnByText($sLogName, $sId, $sText, $sEnterFrame, $iWait)
; Parameters ....: $sLogName            - Name for logging
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
; Examples ......: _WD_ReturnByText($sLogName, "/html/frameset/frameset[2]/frame[2]", "//*[@id='tkl']", "Huhu", 1000)
; ===============================================================================================================================
Func _WD_ReturnByText($sLogName, $i_sFrame, $sId, $sText, $iWait = 0)
   Local $sElement
   Sleep(Int($iWait))
   If $i_sFrame <> "" Then
      _WD_Frame($sLogName, $i_sFrame)
      _WD_HttpResult($sLogName, "frame", $sId)
   EndIf

   Local $sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, $sId)
   _WD_HttpResult($sLogName, "ID : " & $sId, "Element", 0)
   Local $sResult = BinaryToString(_WD_ElementAction($sSession, $sElement, 'text'), $SB_UTF8)

   ; Return text
   If StringRegExp($sResult, $sText) Then
      _WD_HttpResult($sLogName, "ID : " & $sId, "Actual => Return True => [" & $sText & "]", 2)
      Return True
   Else
      _WD_HttpResult($sLogName, "ID : " & $sId, "Actual => Return False => [" & $sText & "]", 2)
      Return False
   EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_Frame
; Description ...: Get return value by text with xPath.
; Syntax ........: _WD_Frame($sSession, $sLogName, $sId, $sText, $sEnterFrame, $iWait)
; Parameters ....: $sLogName            - Name for logging
;				   $i_sFrame			- Frame by int or string (xPath, number, Leave)
; Author ........: Matze1985
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Examples ......: _WD_Frame($Session, $i_sFrame)
; ===============================================================================================================================
Func _WD_Frame($sLogName, $i_sFrame)
   Local $sElement, $sSession

   If $i_sFrame <> "" Then
      $sElement = _WD_FindElement($sSession, $_WD_LOCATOR_ByXPath, $i_sFrame)
      $sElement = _WD_FrameEnter($sSession, $sElement)
      _WD_HttpResult($sLogName, "frame", $i_sFrame, 0)
   EndIf
   If $i_sFrame == "leave" Then
      _WD_FrameLeave($sSession)
      _WD_HttpResult($sLogName, "frame", $i_sFrame, 0)
   EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_HttpResult
; Description ...: Log HTTP-Result
; Syntax ........: _WD_HttpResult($Session, $sLogName, $sDescription, $sLogAction)
; Parameters ....:  $sLogName           	- Name for logging
;					$sId					- Log id
;					$sLogAction				- Log action
;					$iMode					- 0=Error with exit, 1=Error with no exit, 2=Return, 3=StatusCode only by error
; Author ........: 	Matze1985
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Examples ......: _WD_HttpResult($Session, $sLogName, $sId, $sLogAction)
; ===============================================================================================================================
Func _WD_HttpResult($sLogName, $sId, $sLogAction, $iMode = 0)

   Local $sTitle = StringRegExpReplace(@ScriptName, ".au3|.exe", "")
   If Not @Compiled Then
      _DebugSetup($sTitle, False, 2, "")
   Else
      _DebugSetup($sTitle, False)
   EndIf

   If StringLen($sLogAction) >= 95 Then
      $sLogAction = StringMid(StringRegExpReplace($sLogAction, '[\r\n]', " "), 1, 100) & ' ...]' ; Log the first 100 character without line breaks
   Else
      $sLogAction = StringRegExpReplace($sLogAction, '[\r\n]', " ")
   EndIf

   Local $sInfo = "--> [INFO] : "
   Local $sError = "--> [ERROR] : "

   ; Mode 0 for exit if error
   If $iMode == 0 Then
      If $_WD_HTTPRESULT <> 200 Then
         _DebugOut($sError & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & " : " & $sLogName & " : " & $sId & " : " & $sLogAction & " : StatusCode=" & $_WD_HTTPRESULT & " : " & "not passed")
         Exit
      Else
         _DebugOut($sInfo & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & " : " & $sLogName & " : " & $sId & " : " & $sLogAction & " : StatusCode=" & $_WD_HTTPRESULT & " : " & "passed")
      EndIf
   EndIf

   ; Mode 1 for no exit if error
   If $iMode == 1 Then
      If $_WD_HTTPRESULT <> 200 Then
         ConsoleWrite($sError & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & " : " & $sLogName & " : " & $sId & " : " & $sLogAction & " : StatusCode=" & $_WD_HTTPRESULT & " : " & "not passed")
      Else
         _DebugOut($sInfo & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & " : " & $sLogName & " : " & $sId & " : " & $sLogAction & " : StatusCode=" & $_WD_HTTPRESULT & " : " & "passed")
      EndIf
   EndIf

   ; Mode 2 Log info (without StatusCode)
   If $iMode == 2 Then
      _DebugOut($sInfo & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & " : " & $sLogName & " : " & $sId & " : " & $sLogAction)
   EndIf

   ; Mode 3 Log error (without StatusCode)
   If $iMode == 3 Then
      _DebugOut($sError & @YEAR & "-" & @MON & "-" & @MDAY & " " & @HOUR & ":" & @MIN & ":" & @SEC & " : " & $sLogName & " : " & $sId & " : " & $sLogAction)
      Exit
   EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _WD_Step
; Description ...: Step for automation (Handle input, text, select)
; Syntax ........: _WD_Step($sLogName, $i_sFrame, $sCommand)
; Parameters ....: 	$sLogName           	- Name for logging
;					$i_sFrame				- Select a frame of source
;					$sCommand				- Command for execution
;					$iRounds				- Rounds of waiting source every 1000 ms
; Author ........: 	Matze1985
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Examples ......: _WD_Step("Mask of website", "", "[id]first_name->test|[txt]Password->xdfc|[txt:2]Home", 60)
;				   _WD_Step("Mask of website", "", "[cls]types->hello|[txt:3]Einloggen", 60) => Working on it (Click the third Einloggen button)
; ===============================================================================================================================
Func _WD_Step($sLogName, $i_sFrame, $sCommand, $iRounds = 30)
   Local $sText, $sSelect, $sInput
   Local $aCommand = StringSplit($sCommand, "|")
   Local $iCountData = 1

   ; Enter a frame
   If $i_sFrame <> '' Then
      _WD_Frame($sLogName, $i_sFrame)
   EndIf

   ; General wait
   _WD_LoadWait($sSession, 500, 2000)

   ; Select
   Local $iCountText = UBound($aCommand)
   For $i = 2 To $iCountText

      ; Text
      If Not StringInStr($aCommand[$iCountData], "=>") And Not StringInStr($aCommand[$iCountData], "->") And $aCommand[$iCountData] <> "" Then
         $sText = StringRegExpReplace($aCommand[$iCountData], "^(.*?)\[[a-z:0-9]{1,}\]", "")
         _WD_WaitForSource($sLogName, "", StringRegExpReplace($sText, "^(.*?)\[[a-z:0-9]{1,}\]", ""), $iRounds, 1000, False, True)
         If StringRegExp($aCommand[$iCountData], "[txt:[0-9]{1,}\]") Then
            If StringRegExp($aCommand[$iCountData], '[a-z]{1,3}:[0-9]{1,}') Then
               _WD_WaitForElementAndAction($sLogName, "", "(//*[text()='" & $sText & "'])[" & Int(StringRegExpReplace($aCommand[$iCountData], "^[^=0-9{1,}]*|\[[a-z]{1,}]|\].*$", "")) & "]", "click", "", 0, 0)
            Else
               _WD_WaitForElementAndAction($sLogName, "", "//*[text()='" & $sText & "']", "click", "", 0, 0)
            EndIf
         EndIf
         If StringInStr($aCommand[$iCountData], "[id]") Then
            _WD_WaitForElementAndAction($sLogName, "", "//*[@id='" & $sText & "']", "click", "", 0, 0)
         EndIf
         If StringInStr($aCommand[$iCountData], "[cls]") Then
            _WD_WaitForElementAndAction($sLogName, "", "//*[@class='" & $sText & "']", "click", "", 0, 0)
         EndIf
         _WD_LoadWait($sSession, 500, 2000)
      EndIf

      ; Select
      If StringInStr($aCommand[$iCountData], "=>") And Not StringInStr($aCommand[$iCountData], "->") And $aCommand[$iCountData] <> "" Then
         $sText = StringRegExpReplace($aCommand[$iCountData], "\[[a-z]{1,}\]|\=>.*$", "")
         _WD_WaitForSource($sLogName, "", StringRegExpReplace($sText, "\[[a-z]{1,}\]|\=>.*$", ""), $iRounds, 1000, False, True)
         $sSelect = StringRegExpReplace($aCommand[$iCountData], "^(.*?)=>", "")
         If StringInStr($aCommand[$iCountData], "[txt]") Then
            _WD_WaitForElementAndAction($sLogName, "", "//*[contains(.,'" & $sText & "')]/following::select/option[text()='" & $sSelect & "']", "select", "", 0, 0)
         EndIf
         If StringInStr($aCommand[$iCountData], "[id]") Then
            _WD_WaitForElementAndAction($sLogName, "", "//*[contains(id,'" & $sText & "')]/option[text()='" & $sSelect & "']", "select", "", 0, 0)
         EndIf
         If StringInStr($aCommand[$iCountData], "[cls]") Then
            _WD_WaitForElementAndAction($sLogName, "", "//*[contains(class,'" & $sText & "')]/option[text()='" & $sSelect & "']", "select", "", 0, 0)
         EndIf
         _WD_LoadWait($sSession, 500, 2000)
      EndIf

      ; Input
      If StringInStr($aCommand[$iCountData], "->") And Not StringInStr($aCommand[$iCountData], "=>") And $aCommand[$iCountData] <> "" Then
         $sText = StringRegExpReplace($aCommand[$iCountData], "\[[a-z]{1,}\]|\->.*$", "")
         _WD_WaitForSource($sLogName, "", StringRegExpReplace($sText, "\[[a-z]{1,}\]|\->.*$", ""), $iRounds, 1000, False, True)
         $sInput = StringRegExpReplace($aCommand[$iCountData], "^(.*?)->", "")
         If StringInStr($aCommand[$iCountData], "[txt]") Then
            _WD_WaitForElementAndAction($sLogName, "", "//*[contains(.,'" & $sText & "')]/following::input[1]", "clear|value", $sInput, 0, 0)
         EndIf
         If StringInStr($aCommand[$iCountData], "[id]") Then
            _WD_WaitForElementAndAction($sLogName, "", "//input[@id='" & $sText & "']", "clear|value", $sInput, 0, 0)
         EndIf
         If StringInStr($aCommand[$iCountData], "[cls]") Then
            _WD_WaitForElementAndAction($sLogName, "", "//input[@class='" & $sText & "']", "clear|value", $sInput, 0, 0)
         EndIf
         _WD_LoadWait($sSession, 500, 2000)
      EndIf

      $iCountData = $iCountData + 1
   Next
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