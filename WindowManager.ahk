#Requires AutoHotkey v2.0
#SingleInstance Force

; --- Configuration ---
; Define the path to the DLL. A_ScriptDir ensures it looks in the same folder as this script.
dllPath := A_ScriptDir . "\VirtualDesktopAccessor.dll"

; --- Load the DLL ---
hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", dllPath, "Ptr")

; Check if DLL was loaded successfully
if (!hVirtualDesktopAccessor) {
    MsgBox("Error: Can not find VirtualDesktopAccessor.dll!`nMake sure it is located in: " . dllPath)
    ExitApp
}

; --- Get Functions from DLL ---
; 1. Function to MOVE windows
MoveWindowToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "MoveWindowToDesktopNumber", "Ptr")
; 2. Function to SWITCH desktops yourself
GoToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "GoToDesktopNumber", "Ptr")

if (!MoveWindowToDesktopNumberProc || !GoToDesktopNumberProc) {
    MsgBox("Error: Could not find necessary functions in the DLL.`nAre you using the correct DLL version for Windows 11?")
    ExitApp
}

; --- Custom Functions ---

; Move the active window (Win + Shift + Number)
MoveWindowToDesktop(number) {
    try {
        activeHwnd := WinGetID("A") ; Get ID of the currently active window
        ; The desktop index in Windows is 0-based (0 is Desktop 1), so we subtract 1
        DllCall(MoveWindowToDesktopNumberProc, "Ptr", activeHwnd, "Int", number - 1) 
    } catch as err {
        ; Prevent errors if no window is active
    }
}

; Switch to a specific desktop (Win + Number)
SwitchToDesktop(number) {
    try {
        DllCall(GoToDesktopNumberProc, "Int", number - 1)
    }
}

; --- Hotkeys ---

; Win + Shift + 1/2/3/4/5 -> Move Window
#+1::MoveWindowToDesktop(1)
#+2::MoveWindowToDesktop(2)
#+3::MoveWindowToDesktop(3)
#+4::MoveWindowToDesktop(4)
#+5::MoveWindowToDesktop(5)

; Win + 1/2/3/4/5 -> Switch Desktop (Overrides default Windows taskbar shortcuts!)
#1::SwitchToDesktop(1)
#2::SwitchToDesktop(2)
#3::SwitchToDesktop(3)
#4::SwitchToDesktop(4)
#5::SwitchToDesktop(5)
