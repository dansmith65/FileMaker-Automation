/**
 * CreateLayouts.ahk
 * Copyright (c) 2012, Daniel Smith http://scr.im/dansmith
 * License http://copyfree.org/licenses/mit/license.txt
 * 
 * PURPOSE:
 * 	Create a layout for every table in the file.
 * 
 * PARAMETERS:
 * 	-prefix=<prefix>		Value to add to beginning of each layout name.
 * 
 * VERSION 0.9.0.0
 * ============================================================================
 */

#Include <getopt>

 
/******************************************************************************
 * CONFIG
 */

; block user input while script runs
; values: "on" or "off"
BlockInputValue := "on"

sleepValue := 250

windowManageLayouts := "Manage Layouts"
windowNewLayout := "New Layout/Report"

; default delay is 10, setting this value higher allows more time for FileMaker
; to respond to simulated mouse clicks/key presses
SetKeyDelay, 75


/******************************************************************************
 * MAIN
 */

; build complete command line with all parameters
Loop %0%
{
	cmdline := cmdline %A_Index% " "
}
; parse command line
param := getopt(cmdline)

WaitForInitalWindow()
BlockInput, %BlockInputValue%

; get list of items to process
ClickNewLayout()
ControlGet, tableOccurrences, List,, ComboBox1, %windowNewLayout%
; remove last two values from list, which should be a separator and "Manage Database..."
StringGetPos, end, tableOccurrences, `n, R2
StringLeft, tableOccurrences, tableOccurrences, end


Loop, parse, tableOccurrences, `n, `r
{
	ClickNewLayout()
	
	; select the current table occurence from the "Show records from:" field
	Control, ChooseString, %A_LoopField%, ComboBox1, %windowNewLayout%
	
	; enter the table occurence as the Layout Name
	ControlFocus, Edit1, %windowNewLayout%
	tableName := % A_LoopField
	If param.prefix
	{
		tableName := param.prefix tableName
	}
	SendInput, % "^a" tableName
	
	; press the "Next" button three times
	Send, {Enter 3}
	
	; activate layout list so down key will select the newly created layout
	; (and cause the next layout to be placed below it)
	Send {Shift Down}{Tab}{Tab}{Shift Up}
	Send {Down}
}

; exit script
ExitApp



/******************************************************************************
 * FUNCTIONS
 */

WaitForInitalWindow()
{
	global windowManageLayouts
	
	IfWinNotActive, %windowManageLayouts%
	{
		WinWait, %windowManageLayouts%
		WinActivate
	}
}

ClickNewLayout()
{
	global BlockInputValue
	global sleepValue
	global windowManageLayouts
	global windowNewLayout
	
	; click "New" button
	; a loop is used because it does not always open on the first click
	Loop, 3
	{
		IfWinExist, %windowNewLayout%
		{
			WinActivate
			break
		}
		else
		{
			ControlClick, &New, %windowManageLayouts%,,,, NA
		}
		; give window time to open
		sleep, %sleepValue%
	}
	; just in case window did not open
	IfWinNotActive, %windowNewLayout%
	{
		BlockInput, off
		MsgBox, 262192, An Error Occured, "Please click 'New' button."
		WinWaitActive, %windowNewLayout%
		BlockInput, %BlockInputValue%
	}
}



/******************************************************************************
 * HOTKEYS
 */

; abort the script if Esc key is pressed
#UseHook
Escape::
	ExitApp
return