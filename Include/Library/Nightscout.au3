#Region Description
   ; ==============================================================================
   ; UDF ...........: Nightscout.au3
   ; Description ...: Steps for the Nightscout site.
   ; Author(s) .....: Matze1985
   ; ==============================================================================
#EndRegion Description

; #FUNCTION# ====================================================================================================================
; Name ..........: _NS_Login
; Description ...: Login Nightscout
; Syntax ........: _SF_Login()
; Parameters.....:
; Author ........: Matze1985
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: _NS_Login($sSession)
; ===============================================================================================================================
Func _NS_Login()
   Local Const $sLogName = "_NS_Login"
   ; Accountdata
   Local $sFileFullPath = "..\..\Files\UserAccounts.ini"
   Local $sUrl = IniRead($sFileFullPath, "Nightscout", "Url", "https://account.herokuapp.com")
   Local $sApiSecretKey = IniRead($sFileFullPath, "Nightscout", "API-Secret-Key", "000000000000")

   _WD_BrowserAction($sLogName, $sUrl)
   _WD_LoadWait($sSession, 1000, 3000)
   _WD_WaitForElementAndAction($sLogName, "", "//*[@id='lockedToggle']", "click", "", 1500, 1500)
   _WD_WaitForElementAndAction($sLogName, "", "//*[@id='lockedToggle']", "double-click", "", 1500, 1500)
   _WD_WaitForElementAndAction($sLogName, "", "//*[@id='apisecret']", "value", $sApiSecretKey, 500, 1500)
   _WD_WaitForElementAndAction($sLogName, "", "//*[@id='storeapisecret']", "click", "", 500, 1500)
   _WD_WaitForElementAndAction($sLogName, "", "//*[@class='ui-button ui-corner-all ui-widget']", "click", "", 500, 1500)
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
Func _NS_NavigateTo($sTarget)
   Local Const $sLogName = "_NS_NavigateTo"

   _WD_LoadWait($sSession, 1000, 2000)
   If $sTarget = "Profile" Then
      _WD_WaitForElementAndAction($sLogName, "", "//*[@id='drawerToggle']", "click", "", 500, 1500)
      _WD_WaitForElementAndAction($sLogName, "", "//*[@id='editprofilelink']", "click", "", 500, 1500)
   EndIf
EndFunc

; #FUNCTION# ====================================================================================================================
; Name ..........: _NS_Profile
; Description ...: Nightscout Profile Site
; Syntax ........: _NS_Profile($sSession, $sTarget)
; Parameters.....: $sTask		- ic|isf|basal (IC, ISF, Basal)
; Author ........: Matze1985
; Modified ......:
; Remarks .......:
; Related .......:
; Link ..........:
; Example .......: _NS_Profile($sSession, "SaveAllNewValues")
; ===============================================================================================================================
Func _NS_Profile($sTask)
   Local Const $sLogName = "_NS_Profile"
   Local $i_sFrame = 0
   Local $sElement, $iIdNumber
   Dim $sFileRead = ""
   Local $hFileOpen = FileOpen(@ScriptDir & "\Files\Nightscout.txt", $FO_READ)

   _WD_LoadWait($sSession, 1000, 2000)
   _WD_TabHandle($sLogName, 1)
   _WD_WaitForSource($sLogName, '', 'Werte geladen.', 3, 2500, False, True)

   If $sTask = "ic|isf|basal" Then
      ; Insulin/Kohlenhydrate-Verhältnis (I:KH) [g]:
      $iIdNumber = 0
      For $iCounter = 2 To 25
         $sFileRead = FileReadLine($hFileOpen, $iCounter)
         $sValue = StringReplace($sFileRead, ",", ".")
         _WD_WaitForElementAndAction($sLogName, $i_sFrame, "//*[@id='pe_ic_val_" & $iIdNumber & "']", "clear|value", $sValue, 100, 250)
         $i_sFrame = "" ; Enter frame 1x
         $sId = "//*[@id='pe_ic_val_" & $iIdNumber & "']"
         $iIdNumber = $iIdNumber + 1
      Next

      ; Insulinsensibilitätsfaktor (ISF) [mg/dL/U,mmol/L/U]:
      $iIdNumber = 0
      For $iCounter = 27 To 50
         $sFileRead = FileReadLine($hFileOpen, $iCounter)
         $sValue = StringReplace($sFileRead, ",", ".")
         _WD_WaitForElementAndAction($sLogName, "", "//*[@id='pe_isf_val_" & $iIdNumber & "']", "clear|value", $sValue, 100, 250)
         $iIdNumber = $iIdNumber + 1
      Next

      ; Basalraten [Einheit/h]:
      $iIdNumber = 0
      For $iCounter = 52 To 75
         $sFileRead = FileReadLine($hFileOpen, $iCounter)
         $sValue = StringReplace($sFileRead, ",", ".")
         _WD_WaitForElementAndAction($sLogName, "", "//*[@id='pe_basal_val_" & $iIdNumber & "']", "clear|value", $sValue, 100, 250)
         $iIdNumber = $iIdNumber + 1
      Next

      ; Click save
      _WD_WaitForElementAndAction($sLogName, "", "//*[@id='pe_submit']", "click", "", 100, 500)
   EndIf

   ; Close the handle returned by FileOpen.
   FileClose($hFileOpen)
EndFunc