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

; Get the address of the specific function inside the DLL
MoveWindowToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "MoveWindowToDesktopNumber", "Ptr")

if (!MoveWindowToDesktopNumberProc) {
    MsgBox("Error: Could not find the function 'MoveWindowToDesktopNumber'.`nAre you using the correct DLL version for Windows 11?")
    ExitApp
}

; --- Function Definition ---
MoveWindowToDesktop(number) {
    try {
        activeHwnd := WinGetID("A") ; Get ID of the currently active window
        ; The desktop index in Windows is 0-based (0 is Desktop 1), so we subtract 1
        DllCall(MoveWindowToDesktopNumberProc, "Ptr", activeHwnd, "Int", number - 1) 
    } catch as err {
        ; Prevent errors if no window is active
    }
}

; --- Hotkeys ---
; Win + Shift + Number
#+1::MoveWindowToDesktop(1)
#+2::MoveWindowToDesktop(2)
#+3::MoveWindowToDesktop(3)
#+4::MoveWindowToDesktop(4)
#+5::MoveWindowToDesktop(5)
