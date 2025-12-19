A_ScriptDir := "."
dllPath := A_ScriptDir . "\VirtualDesktopAccessor.dll"

hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", dllPath, "Ptr")

if (!hVirtualDesktopAccessor) {
    MsgBox("Can not find VirtualDesktopAccessor.dll!`nMake sure it is in this folder: " . A_ScriptDir)
    ExitApp
}
; Load the DLL
hVirtualDesktopAccessor := DllCall("LoadLibrary", "Str", "VirtualDesktopAccessor.dll", "Ptr")
MoveWindowToDesktopNumberProc := DllCall("GetProcAddress", "Ptr", hVirtualDesktopAccessor, "AStr", "MoveWindowToDesktopNumber", "Ptr")

; Function to move the window
MoveWindowToDesktop(number) {
    activeHwnd := WinGetID("A")
    DllCall(MoveWindowToDesktopNumberProc, "Ptr", activeHwnd, "Int", number - 1) ; Desktop index begint bij 0
}

; Hotkeys (Win + Shift + 1 t/m 3)
#+1::MoveWindowToDesktop(1)
#+2::MoveWindowToDesktop(2)
#+3::MoveWindowToDesktop(3)