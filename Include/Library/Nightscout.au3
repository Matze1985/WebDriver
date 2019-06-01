#Region Description
   ; ==============================================================================
   ; UDF ...........: Nightscout.au3
   ; Description ...: Steps for the Nightscout site.
   ; Author(s) .....: Mathias Noack
   ; AutoIt Version : v3.3.14.2
   ; ==============================================================================
#EndRegion Description

#include <FileConstants.au3>

; #FUNCTION# ====================================================================================================================
; Name ..........: _NS_Login
; Description ...: Login Nightscout
; Syntax ........: _SF_Login()
; Parameters.....: $sSession 	- Session ID from _WDCreateSession
; Author ........: Mathias Noack
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: _NS_Login($sSession)
; ===============================================================================================================================
Func _NS_Login($sSession)
   Local Const $sFuncName = "_NS_Login"
   _WD_BrowserAction($sFuncName, "https://matze1985.herokuapp.com/")
   _WD_LoadWait($sSession, 1000, 3000)
   _WD_WaitForElementAndAction($sFuncName, "", "//*[@id='lockedToggle']", "click", "", 1500, 1500)
   _WD_WaitForElementAndAction($sFuncName, "", "//*[@id='lockedToggle']", "click", "", 1500, 1500) ; => Two steps, better for Chrome
   _WD_WaitForElementAndAction($sFuncName, "", "//*[@id='apisecret']", "value", "000000000000", 500, 1500)
   _WD_WaitForElementAndAction($sFuncName, "", "//*[@id='storeapisecret']", "click", "", 500, 1500)
   _WD_WaitForElementAndAction($sFuncName, "", "//*[@class='ui-button ui-corner-all ui-widget']", "click", "", 500, 1500)
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _NS_NavigateTo
; Description ...: Navigate to Nightscout Pages
; Syntax ........: _NS_NavigateTo($sSession, $sTarget)
; Parameters.....: $sSession 	- Session ID from _WDCreateSession
;				   $sTarget		- Profile
; Author ........: Matze1985
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: _NS_Profile($sSession, "Profile")
; ===============================================================================================================================
Func _NS_NavigateTo($sSession, $sTarget)
   Local Const $sFuncName = "_NS_NavigateTo"

   _WD_LoadWait($sSession, 1000, 2000)
   If $sTarget = "Profile" Then
      _WD_WaitForElementAndAction($sFuncName, "", "//*[@id='drawerToggle']", "click", "", 500, 1500)
      _WD_WaitForElementAndAction($sFuncName, "", "//*[@id='editprofilelink']", "click", "", 500, 1500)
   EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _NS_Profile
; Description ...: Nightscout Profile Site
; Syntax ........: _NS_Profile($sSession, $sTarget)
; Parameters.....: $sSession 	- Session ID from _WDCreateSession
;				   $sTask		- ic|isf|basal (IC, ISF, Basal)
; Author ........: Matze1985
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: _NS_Profile($sSession, "SaveAllNewValues")
; ===============================================================================================================================
Func _NS_Profile($sSession, $sTask)
   Local Const $sFuncName = "_NS_Profile"
   Local $i_sFrame = 0
   Local $sElement, $sValue, $iIdNumber
   Dim $sFileRead = ""
   Local $hFileOpen = FileOpen(@ScriptDir & "\Files\Nightscout.txt", $FO_READ)

   _WD_LoadWait($sSession, 1000, 2000)
   _WD_TabHandle($sFuncName, 1)
   _WD_WaitForSource($sFuncName, '', 'Werte geladen.', 3, 2500, False, True)

   If $sTask = "ic|isf|basal" Then
      ; Insulin/Kohlenhydrate-Verhältnis (I:KH) [g]:
      $iIdNumber = 0
      For $iCounter = 2 To 25
         $sFileRead = FileReadLine($hFileOpen, $iCounter)
         $sValue = StringReplace($sFileRead, ",", ".")
         _WD_WaitForElementAndAction($sFuncName, $i_sFrame, "//*[@id='pe_ic_val_" & $iIdNumber & "']", "clear|value", $sValue, 100, 250)
         $i_sFrame = "" ; Enter frame 1x
         $sId = "//*[@id='pe_ic_val_" & $iIdNumber & "']"
         $iIdNumber = $iIdNumber + 1
      Next

      ; Insulinsensibilitätsfaktor (ISF) [mg/dL/U,mmol/L/U]:
      $iIdNumber = 0
      For $iCounter = 27 To 50
         $sFileRead = FileReadLine($hFileOpen, $iCounter)
         $sValue = StringReplace($sFileRead, ",", ".")
         _WD_WaitForElementAndAction($sFuncName, "", "//*[@id='pe_isf_val_" & $iIdNumber & "']", "clear|value", $sValue, 100, 250)
         $iIdNumber = $iIdNumber + 1
      Next

      ; Basalraten [Einheit/h]:
      $iIdNumber = 0
      For $iCounter = 52 To 75
         $sFileRead = FileReadLine($hFileOpen, $iCounter)
         $sValue = StringReplace($sFileRead, ",", ".")
         _WD_WaitForElementAndAction($sFuncName, "", "//*[@id='pe_basal_val_" & $iIdNumber & "']", "clear|value", $sValue, 100, 250)
         $iIdNumber = $iIdNumber + 1
      Next

      ; Click save
      _WD_WaitForElementAndAction($sFuncName, "", "//*[@id='pe_submit']", "click", "", 100, 500)
   EndIf

   ; Close the handle returned by FileOpen.
   FileClose($hFileOpen)
EndFunc
