;----------------------------------------------------------------------
;======================================================================
;			  ReposTV
;Continuously reposition an MPC Instance to upper section of any screen
;To ensure correct selection for my purposes it only supports formats:
;mp4, mkv, avi, flv,m4v, mpg as displayed in MPC's title
;Press [INS] at any time to switch (and save) screen selection
;----------------------------------------------------------------------
;======================================================================
#SingleInstance Force
;----------------------------------------------------------------------
;======================================================================
;			MAIN PROGRAM
;----------------------------------------------------------------------
Loop
 IfWinNotActive Launchy		;Ensure Launchy is closed
   break			;Usually not a problem
GoSub, GetWinIdAndTitle		;Find and get info on desired MPC instance
FileRead, i, i.txt		;Load previous screen selection
GoSub, CheckValidScreen		;Verify valid screen#
Loop
{
 GoSub, GetCoordsMove		;Get desired location/size and move MPC-HC window there
 sleep 1000			;Delay between repositions
GoSub, CheckStatus		;Check if instance of MPC is still open
}
ExitApp
Return
;-----------------------------------------------------------------------
;=======================================================================
;			SUB-ROUTINES
;----------------------------------------------------------------------
GetWinIdAndTitle:
 Loop
 {
  WinGetTitle, activeTitle, A
  ToolTip, Activate desired MPC Instance`n%activeTitle%
  if   (SubStr(activeTitle, -2) = "mp4") or (SubStr(activeTitle, -2) = "mkv")
    or (SubStr(activeTitle, -2) = "avi") or (SubStr(activeTitle, -2) = "flv")
    or (SubStr(activeTitle, -2) = "m4v") or (SubStr(activeTitle, -2) = "mpg")
         ;remove semi-colon and add additional formats here
   ;or (SubStr(activeTitle, -2) = "XXX") or (SubStr(activeTitle, -2) = "XXX")
   break
 }

WinGet, mpcID, ID, A
mpcID = ahk_id %mpcID%
WinGetTitle, mpcTitle, %mpcID%
ToolTip tracking ID: %mpcID%`n%mpcTitle%`nEnjoy! :)`nPress [INS] at any time to switch screen
Return
;-----------------------------------------------------------------------

CheckValidScreen:
 Loop
 {
  if (i > 10) or (i < 1)			;If it's NOT 1-10 inclusive
   i = 1					;reset to 1
  SysGet, mon%i%WorkArea, MonitorWorkArea, %i%	;Try to get coords for screen#
  if mon%i%WorkAreaLeft or mon%i%WorkAreaRight	;If coords are good
   break					;Continue vvv
  i++						; Otherwise try next screen#
 }
 GoSub, GetCoordsMove				;Make a move now
 FileAppend, %i%, i.txt				;Store the valid screen#
Return
;-----------------------------------------------------------------------

GetCoordsMove:
 SysGet, mon%i%WorkArea, MonitorWorkArea, %i%
 desWidth := mon%i%WorkAreaRight - mon%i%WorkAreaLeft
 WinMove,%mpcID%,,mon%i%WorkAreaLeft,mon%i%WorkAreaTop,desWidth,500
Return
;-----------------------------------------------------------------------

CheckStatus:
 if !WinExist(mpcID)			;MPC is no longer open
 {					;Quit
  ToolTip %mpcTitle% was closed.`nTracking ended.`nBYE!
  Sleep 1000
  ExitApp				
 }
 ;MPC is still open
 WinGetTitle, mpcTitle, %mpcID%	;Update current mpc title
 if (A_Index > 4)		
  ToolTip 			;Clear ToolTip after 4 loops/~seconds

Return
;-----------------------------------------------------------------------
;=======================================================================
;			HOTKEY
;----------------------------------------------------------------------
INS::	;Hotkey to hot switch between up to 10 monitors
 i++
 GoSub, CheckValidScreen
Return
;----------------------------------------------------------------------

ESC::
 Loop 200
 {
  ToolTip Quitting tracking on %mpcTitle%`nBYE!
  Sleep 10
 }
 ExitApp
Return