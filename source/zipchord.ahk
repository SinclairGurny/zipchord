﻿#NoEnv
SetWorkingDir %A_ScriptDir%

; ZipChord by Pavel Soukenik
; Licensed under GPL-3.0
; See https://github.com/psoukie/zipchord/

; Recognize these keys
global keys := "',-./0123456789;=[\]abcdefghijklmnopqrstuvwxyz"
; Chord file
global chfile := ""
; List of chords
global chords := {}
; Threshold to recognize chords
global chdelay := 0
; Delay before outputting
global outdelay := 0
; Temporary variables
global newdelay := 0
global newoutdelay := 0
; Filename of chord file
global UIdict := "none"
; Number of chords
global UIentries := "0"
; Is zipchord enabled?
global UIon := 1
; ...
global start := 0
chord := ""

; Start Program
Initialize()
Return

; Holding C-c triggers menu
~^+c::
  Sleep 300
  if GetKeyState("c","P")
    ShowMenu()
  Return

Initialize() {
  ; Basic setup
  Gui, Font, s10, Segoe UI
  Gui, Margin, 15, 15
  ; Dictionary Setup
  Gui, Add, GroupBox, w320 h130 Section, Dictionary
  Gui, Add, Text, xp+20 yp+30 w280 vUIdict Left, [file name]
  Gui, Add, Text, xp+10 Y+10 w280 vUIentries Left, (999 chords)
  Gui, Add, Button, gSelectDict Y+10 w80, &Open
  Gui, Add, Button, gEditDict xp+100 yp+0 w80, &Edit
  Gui, Add, Button, gReloadDict xp+100 yp+0 w80, &Reload
  ; Sensitivity
  Gui, Add, GroupBox, xs ys+150 w320 h100 Section, Sensitivity
  Gui, Add, Text, xp+20 yp+30, I&nput delay (ms):
  Gui, Add, Edit, vnewdelay Right xp+150 yp+0 w40, 99
  Gui, Add, Text, xp-150 Y+10, O&utput delay (ms):
  Gui, Add, Edit, vnewoutdelay Right xp+150 yp+0 w40, 99
  ; Disable zipchord
  Gui, Add, Checkbox, gUIControlStatus vUIon xs Y+40 Checked%UIon%, Re&cognition enabled
  Gui, Add, Button, Default w80 xs+220, OK
  Gui, Font, Underline cBlue
  Gui, Add, Text, xs Y+10 gWebsiteLink, v1.6.0 (updates)
  ; Adjust menu options from taskbar
  Menu, Tray, Add, Open Settings, ShowMenu
  Menu, Tray, Default, Open Settings
  Menu, Tray, Tip, ZipChord
  Menu, Tray, Click, 1
  ; Read registry values
  RegRead chdelay, HKEY_CURRENT_USER\Software\ZipChord, ChordDelay
  if ErrorLevel
    SetDelay(90)
  RegRead outdelay, HKEY_CURRENT_USER\Software\ZipChord, OutDelay
  if ErrorLevel
    SetOutDelay(0)
  RegRead chfile, HKEY_CURRENT_USER\Software\ZipChord, ChordFile
  if (ErrorLevel || !FileExist(chfile)) {
    errmsg := ErrorLevel ? "" : Format("The last used dictionary {} could not be found.`n`n", chfile)
    chfile := "chords*.txt"
    if FileExist(chfile) {
      Loop, Files, %chfile%
        flist .= SubStr(A_LoopFileName, 1, StrLen(A_LoopFileName)-4) "`n"
      Sort flist
      chfile := SubStr(flist, 1, InStr(flist, "`n")-1) ".txt"
      errmsg .= Format("ZipChord detected the dictionary '{}' and is going to open it.", chfile)
    }
    else {
      errmsg .= "ZipChord is going to create a new 'chords.txt' dictionary in its own folder."
      chfile := "chords.txt"
      FileAppend % "This is a dictionary for ZipChord. Define chords and corresponding words in a tab-separated list (one entry per line).`nSee https://github.com/psoukie/zipchord for details.`n`ndm`tdemo", %chfile%, UTF-8
    }
    chfile := A_ScriptDir "\" chfile
    MsgBox ,, ZipChord, %errmsg%
  }
  LoadChords(chfile)

  Loop Parse, keys
  {
    Hotkey, % "~" A_LoopField, KeyDown
    Hotkey, % "~" A_LoopField " Up", KeyUp
    Hotkey, % "~+" A_LoopField, ShiftKeys
  }
  Hotkey, % "~Space", KeyDown
  Hotkey, % "~Space Up", KeyUp
  ShowMenu()
}

WebsiteLink:
Run https://github.com/psoukie/zipchord/releases
return

ShowMenu() {
  GuiControl Text, newdelay, %chdelay%
  GuiControl Text, newoutdelay, %outdelay%
  GuiControl , , UIon, % (start==-1) ? 0 : 1
  Gui, Show,, ZipChord
  UIControlStatus()
}

UIControlStatus() {
  GuiControlGet, checked,, UIon
  GuiControl, Enable%checked%, newdelay
  GuiControl, Enable%checked%, newoutdelay
}

ButtonOK:
  Gui, Submit, NoHide
  if SetDelay(newdelay) {
    start := UIon ? 0 : -1
    CloseMenu()
  }
  if SetOutDelay(newoutdelay) {
    start := UIon ? 0 : -1
    CloseMenu()
  }
  Return

GuiClose:
GuiEscape:
  CloseMenu()
  Return

CloseMenu() {
  Gui, Submit
  static intro := true
  if intro {
    MsgBox ,, ZipChord, % "Press and hold Ctrl-C to define a new chord for the selected text.`n`nPress and hold Ctrl-Shift-C to open the ZipChord menu again."
    intro := false
  }
}

KeyDown:
  key := SubStr(StrReplace(A_ThisHotkey, "Space", " "), 2, 1)
  chord .= key
  if (start==-1)
    Return
  if (StrLen(chord)==2)
    start:= A_TickCount
  Return

KeyUp:
  key := SubStr(StrReplace(A_ThisHotkey, "Space", " "), 2, 1)
  ch := chord
  chord := StrReplace(chord, key)
  st := start
  if (start==-1)
    Return
  start := 0
  if (st && StrLen(ch)>1 && A_TickCount - st > chdelay) {
    chord := ""
    sorted := Arrange(ch)
    Sleep outdelay
    if (chords.HasKey(sorted)) {
      Loop % StrLen(sorted)
        SendInput {Backspace}
      exp := chords[sorted]
      if (SubStr(exp, StrLen(exp), 1) == "~") {
        exp := SubStr(exp, 1, StrLen(exp)-1)
        pref := true
      }
      else
        pref := false
        SendInput % exp
    }
    else {
      if (delnonchords) {
        Loop % StrLen(sorted)
          SendInput {Backspace}
      }
    }
  }
  Return

ShiftKeys:
  key := SubStr(A_ThisHotkey, 3, 1)
  if (start==-1)
    Return
  Return

~^c::
  Sleep 300
  if GetKeyState("c","P") {
    newword := Trim(Clipboard)
    if (!StrLen(newword)) {
      MsgBox ,, ZipChord, % "First, select a word you would like to define a chord for, and then press and hold Ctrl+C again."
      Return
    }
    For ch, wd in chords
      if (wd==newword) {
        MsgBox  ,, ZipChord, % Format("The text '{}' already has the chord {:U} associated with it.", wd, ch)
        Return
      }
    Loop {
      InputBox, newch, ZipChord, % Format("Type the individual keys that will make up the chord for '{}'.`n(Only lowercase letters, numbers, space, and other alphanumerical keys without pressing Shift or function keys.)", newword)
      if ErrorLevel
        Return
    } Until RegisterChord(newch, newword, true)
    UpdateUI()
  }
  Return

SelectDict() {
  FileSelectFile dict, , %A_ScriptDir%, Open Dictionary, Text files (*.txt)
  if (dict != "")
    LoadChords(dict)
  Return
}

EditDict() {
  Run notepad.exe %chfile%
}

RegisterChord(newch, newword, w := false) {
  newch := Arrange(newch)
  if chords.HasKey(newch) {
    MsgBox ,, ZipChord, % "The chord '" newch "' is already in use for '" chords[newch] "'.`nPlease use a different chord for '" newword "'."
    Return false
  }
  if (StrLen(newch)<2) {
    MsgBox ,, ZipChord, The chord needs to be at least two characters.
    Return false
  }
  if (w)
    FileAppend % "`r`n" newch "`t" newword, %chfile%, UTF-8
  newword := StrReplace(newword, "~", "{Backspace}")
  if (SubStr(newword, -10)=="{Backspace}")
    newword := SubStr(newword, 1, StrLen(newword)-11) "~"
  chords.Insert(newch, newword)
  chords.Insert(" " newch, newword " ")
  return true
}

SetDelay(newdelay) {
  newdelay := Round(newdelay + 0)
  if (newdelay<1) {
    MsgBox ,, ZipChord, % "The chord sensitivity needs to be entered as only numbers."
    Return false
  }
  RegWrite REG_SZ, HKEY_CURRENT_USER\Software\ZipChord, ChordDelay, %newdelay%
  chdelay := newdelay
  Return true
}

SetOutDelay(newoutdelay) {
  newoutdelay := Round(newoutdelay + 0)
  if (newoutdelay<0) {
    MsgBox ,, ZipChord, % "The output delay must be greater than 0"
    Return false
  }
  RegWrite REG_SZ, HKEY_CURRENT_USER\Software\ZipChord, OutDelay, %newoutdelay%
  outdelay := newoutdelay
  Return true
}

Arrange(raw) {
  raw := RegExReplace(raw, "(.)", "$1`n")
  Sort raw
  Return StrReplace(raw, "`n")
}

ReloadDict() {
  LoadChords(chfile)
}

LoadChords(fname) {
  chfile := fname
  RegWrite REG_SZ, HKEY_CURRENT_USER\Software\ZipChord, ChordFile, %chfile%
  chords := {}
  Loop, Read, %chfile%
  {
    pos := InStr(A_LoopReadLine, A_Tab)
    if (pos)
      RegisterChord(Arrange(SubStr(A_LoopReadLine, 1, pos-1)), SubStr(A_LoopReadLine, pos+1))
  }
  UpdateUI()
}

UpdateUI() {
  if StrLen(chfile) > 35
    filestr := "..." SubStr(chfile, -34)
  else
    filestr := chfile
  GuiControl Text, newdelay, %chdelay%
  GuiControl Text, newoutdelay, %outdelay%
  GuiControl Text, UIdict, %filestr%
  entriesstr := "(" chords.Count()
  entriesstr .= (chords.Count()==1) ? " chord)" : " chords)"
  GuiControl Text, UIentries, %entriesstr%
}
