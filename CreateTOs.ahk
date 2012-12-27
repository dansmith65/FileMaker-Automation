; CreateTOs.ahk
; Copyright (c) 2012, Daniel Smith http://scr.im/dansmith
; License http://copyfree.org/licenses/mit/license.txt
; 
; PURPOSE:
; 	Create a table occurrence for every table in the first external data source
; 	in a FileMaker Pro database file.
; 
; VERSION 0.9.0.0
; =============================================================================


; block user input while script runs
; values: "on" or "off"
BlockInputValue := "on"

; miliseconds to wait after clicking "Add a table" button
; if set too low the Specify Table window could open more than once before the script detects that it has been opened
sleepAfterAddATable := 250


Loop
{
	; wait until Manage Database window is active
	IfWinNotActive, Manage Database
	{
		WinWait, Manage Database
		WinActivate
		BlockInput, %BlockInputValue%
	}

	
	; add first TO to the graph
	if not count
	{
		i := 0
		; click "Add a table" button
		; a loop is used because it does not always open on the first click
		Loop, 3
		{
			IfWinExist, Specify Table
			{
				WinActivate
				break
			}
			else
			{
				ControlClick, Button1, Manage Database,,,, NA
			}
			; give window time to open
			sleep, %sleepAfterAddATable%
		}
		; just in case window did not open
		IfWinNotActive, Specify Table
		{
			BlockInput, off
			MsgBox, 262192, An Error Occured, "Please click 'Add a Table' button."
			WinWaitActive, Specify Table
			BlockInput, %BlockInputValue%
		}
		
		; select the data source then activate the list of tables
		SendInput, {Down}{Tab}
		; get count of Tables
		ControlGet, count, List, Count, SysListView321, Specify Table
		; if no tables exist, exit the loop
		if not count
		{
			break
		}
		
		; add first table to relationship graph
		; select the table
		SendInput {Enter}
		; minimize the table
		SendInput ^t
		
		; activate relationship graph area so ctrl+up key will move the TO
		SendInput {Shift Down}{Tab}{Shift Up}
	}
	else
	{
		; duplicate the table occurence
		SendInput ^d
		; modify it's source table
		SendInput ^o
		; select the next table in the list
		SendInput {Tab}{Down}{Enter}
	}
	
	; move up to reduce space needed on relationship graph
	SendInput {LCtrl Down}{Up 2}{Left 6}{LCtrl Up}
	
	
	; increment iteration
	i := i + 1
	
} Until i >= count
