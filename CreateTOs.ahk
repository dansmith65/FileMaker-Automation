/**
 * CreateTOs.ahk
 * Copyright (c) 2012, Daniel Smith http://scr.im/dansmith
 * License http://copyfree.org/licenses/mit/license.txt
 * 
 * PURPOSE:
 * 	Create a table occurrence for every table in the first external data source
 * 	in a FileMaker Pro database file.
 * 
 * PARAMETERS:
 * 	-dataSourceName=<name>	Name of external data source to use.
 *							Takes precedence over dataSourceNumber param.
 *
 * 	-dataSourceNumber=<#>	Number of external data source to use, based on
 *							order in list of data sources.
 *							1 = the first external data source
 * 
 * -prefix=<prefix>			Value to add to beginning of each table occurence
 *							name.
 * 
 *	If no parameters are provided, thecurrent database file is used.
 * 
 * VERSION 0.9.0.0
 * ============================================================================
 */

#Include <getopt>

; build complete command line with all parameters
Loop %0%
{
	cmdline := cmdline %A_Index% " "
}
; parse command line
param := getopt(cmdline)


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
		; wait for user to select Relationships tab
		Loop
		{
			ControlGet, onCorrectTab, Visible,, Add Table, Manage Database,,,, NA
			If onCorrectTab
			{
				break
			}
			Sleep, % sleepAfterAddATable
		}
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
				ControlClick, Add Table, Manage Database,,,, NA
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
		
		; select the data source
		If param.dataSourceName
		{
			temp := param.dataSourceName
			ControlGet, dataSourcePosition, FindString, %temp%, ComboBox1, Specify Table
			If ( dataSourcePosition > 1000 OR ErrorLevel )
			{
				BlockInput, off
				MsgBox, 262192, An Error Occured, Data source not found: [%temp%]
				Exit
			}
			; offset position by 2, because there are always two entries before the first external data source
			dataSourcePosition := dataSourcePosition - 2
			temp := "{Down " dataSourcePosition "}"
			SendInput, % temp
		}
		Else If param.dataSourceNumber
		{
			; validate dataSourceNumber parameter
			ControlGet, List, List,, ComboBox1, Specify Table
			count:=
			Loop, parse, List, `n, `r
			{
				count++
			}
			; remove count of standard items in data source list (current file, separators, add, manage)
			count := count - 6
			If ( param.dataSourceNumber > count )
			{
				BlockInput, off
				MsgBox, 262192, An Error Occured, Data source count exceeded.
				Exit
			}
			temp := "{Down " param.dataSourceNumber "}"
			SendInput, % temp
		}
		; else, select current file (which is selected by default)
		
		; move focus to list of tables
		SendInput, {Tab}
		; get count of Tables
		ControlGet, count, List, Count, SysListView321, Specify Table
		; if no tables exist, exit the loop
		if not count
		{
			break
		}
		
		; add first table to relationship graph
		
		AddPrefix( param.prefix )
		; add the table
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
		; activate the next table in the list
		SendInput {Tab}{Down}
		AddPrefix( param.prefix )
		; add the table
		SendInput {Enter}
	}
	
	; move up to reduce space needed on relationship graph
	SendInput {LCtrl Down}{Up 2}{Left 6}{LCtrl Up}
	
	
	; increment iteration
	i := i + 1
	
} Until i >= count


AddPrefix(prefix)
{
	If prefix
	{
		SendInput {Tab}{Home}%prefix%
	}
}