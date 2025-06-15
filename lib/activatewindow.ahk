/************************************************************************
* ActivateWindow.ahk
* Description: AHK script to activate or run a program window.
* codes from keymap tool https://github.com/xianyukang/MyKeymap
 ***********************************************************************/



/**
 * 启动程序或切换到程序
 * @param {string} winTitle AHK中的WinTitle 
 * @param {string} target 程序的路径
 * @param {string} args 参数
 * @param {string} workingDir 工作文件夹
 * @param {bool} admin 是否为管理员启动
 * @param {bool} isHide 窗口是否为隐藏窗口
 * @returns {void} 
 * ActivateOrRun("ahk_exe eudic.exe", "d:\application\abspath.exe")
 */
ActivateOrRun(winTitle := "", target := "", args := "", workingDir := "", admin := false, isHide := false, runInBackground := false) {
  ; ; 如果是程序或参数中带有“选中的文件” 则通过该程序打开该连接
  ; if (InStr(target, "{selected}") || InStr(args, "{selected}")) {
  ;   ; 没有获取到文字直接返回
  ;   if not (ReplaceSelectedText(&target, &args))
  ;     return
  ; }

  ; 切换程序
  winTitle := Trim(winTitle)
  if (winTitle && activateWindow(winTitle, isHide))
    return

  ; 程序没有运行，运行程序
  if not target {
    return
  }
  workingDir := workingDir ? workingDir : A_WorkingDir
  RunPrograms(target, args, workingDir, admin, runInBackground)
}

/**
 * 轮换程序窗口
 * @param winTitle AHK中的WinTitle
 * @param hwnds 活动窗口的句柄数组
 * @returns {void|number} 
 */
LoopRelatedWindows(winTitle?, hwnds?) {
  ; 如果没有传句柄数组则获取当前窗口的
  if not (IsSet(hwnds)) {
    predicate := (hwnd) => WinGetTitle(hwnd) != ""
    if (GetProcessName() == "explorer.exe") {
      predicate := (hwnd) => WinGetClass(hwnd) = "CabinetWClass"
    }
    hwnds := FindWindows("ahk_exe " WinGetProcessName("A"), predicate)
  }

  ; 只有一个窗口显示出来就行
  if (hwnds.Length = 1) {
    WinActivate(hwnds.Get(1))
    return
  }

  ; 没有传winTitle时，则获取当前程序的名称
  if not (IsSet(winTitle)) {
    class := WinGetClass("A")
    if (class == "ApplicationFrameWindow") {
      winTitle := WinGetTitle("A") "  ahk_class ApplicationFrameWindow"
    } else {
      winTitle := "ahk_exe " GetProcessName()
    }
  }
  winTitle := Trim(winTitle)

  static winGroup, lastWinTitle := "", lastHwnd := "", gi := 0
  if (winTitle != lastWinTitle || lastHwnd != WinExist("A")) {
    lastWinTitle := winTitle
    winGroup := "AutoName" gi++
  }

  ; 将所有的hwnd都添加到组里
  for hwnd in hwnds {
    GroupAdd(winGroup, "ahk_id" hwnd)
  }

  ; 切换
  lastHwnd := GroupActivate(winGroup, "R")
  return lastHwnd
}



; =========================
/**
 *  将程序路径或参数中的{selected} 替换为选中的文字
 * @param target 程序路径的引用
 * @param args 参数的引用
 * @returns {void|number} 
 */
; ReplaceSelectedText(&target, &args) {
;   text := GetSelectedText()
;   if not (text) {
;     text := ""
;   }

;   ; 如果是划词搜索且选中了 http 链接那么跳转链接
;   if InStr(args, "https://") == 1 || InStr(target, "https://") == 1 {
;     if InStr(text, "https://") || InStr(text, "http://") {
;       args := InStr(args, "{selected}") ? Trim(text) : args
;       target := InStr(target, "{selected}") ? Trim(text) : target
;       return 1
;     }
;   }

;   if InStr(args, "://") || InStr(target, "://") {
;     text := URIEncode(text)
;   }
;   args := strReplace(args, "{selected}", text)
;   target := strReplace(target, "{selected}", text)

;   return 1
; }

/**
 * 激活窗口
 * @param winTitle AHK中的WinTitle
 * @param {number} isHide 窗口是否为隐藏窗口
 * @returns {number} 
 */
ActivateWindow(winTitle := "", isHide := false) {
  ; 如果匹配不到窗口且认为窗口为隐藏窗口时查找隐藏窗口
  hwnds := FindWindows(winTitle, (hwnd) => WinGetTitle(hwnd) != "")
  if ((!hwnds.Length) && isHide) {
    hwnds := FindHiddenWindows(winTitle)
    if hwnds.Length {
      WinShow(hwnds.Get(1))
      WinActivate(hwnds.Get(1))
      return true
    }
  }

  ; 如果匹配到则跳转，匹配不到返回0
  if (!hwnds.Length) {
    return 0
  }

  ; 只有一个窗口为最小化则切换否则最小化
  if (hwnds.Length = 1) {
    hwnd := hwnds.Get(1)
    ; 指定不为活动窗口或窗口被缩小则显示出来
    if (WinExist("A") != hwnd || WinGetMinMax(hwnd) = -1) {
      WinActivate(hwnd)
    ; } else {
    ;   WinMinimize(hwnd)
    }
  } else {
    ; 如果多个窗口则来回切换
    LoopRelatedWindows(winTitle, hwnds)
  }

  return 1
}

/**
 * 查找隐藏窗口返回窗口的Hwnd 
 * @param winTitle AHK中的WinTitle
 * @returns {array} 
 */
FindHiddenWindows(winTitle) {
  WS_MINIMIZEBOX := 0x00020000
  WS_MINIMIZE := 0x20000000

  ; 窗口过滤条件
  ; 标题不为空、包含最小化按钮
  Predicate(hwnd) {
    if (WinGetTitle(hwnd) = "")
      return false

    style := WinGetStyle(hwnd)
    return style & WS_MINIMIZEBOX
  }

  ; 开启可以查找到隐藏窗口
  DetectHiddenWindows true
  hwnds := FindWindows(winTitle, Predicate)
  DetectHiddenWindows false

  return hwnds
}

/**
 * 返回与指定条件匹配的所有窗口
 * @param winTitle AHK中的WinTitle
 * @param predicate 过滤窗口方法，传过Hwnd，返回bool
 * @returns {array} 
 */
FindWindows(winTitle, predicate?) {
  temps := WinGetList(winTitle)
  ; 不需要做任何匹配直接返回
  if not (IsSet(predicate)) {
    return temps
  }

  hwnds := []
  for i, hwnd in temps {
    ; 当有谓词条件且满足时添加这个hwnd
    if predicate(hwnd) {
      hwnds.Push(hwnd)
    }
  }
  return hwnds
}

/**
 * 运行程序或打开目录，用于解决打开的程序无法获取焦点的问题
 * @param target 程序路径
 * @param {string} args 参数
 * @param {string} workingDir 工作目录
 * @param {number} admin 是否为管理员启动
 * @returns {void} 
 */
RunPrograms(target, args := "", workingDir := "", admin := false, runInBackground := false) {
  ; 记录当前窗口的hwnd，当软件启动失败时还原焦点
  currentHwnd := WinExist("A")

  if !runInBackground {
    ActivateDesktop()
  }

  try {
    ; 补全程序路径
    programPath := CompleteProgramPath(target)

    ; 如果是文件夹直接打开
    if (InStr(FileExist(programPath), "D")) {
      Run(programPath)
      return
    }

    ; 避免在快捷方式无效，导致的程序卡住
    ShortcutTargetExist(programPath)

    ; if (admin) {
    ;   runAsAdmin(programPath, args, workingDir, runInBackground ? "Hide" : "")
    ; } else {
      ; 直接 run "https://example.com" 会让 chrome 以管理员启动
      ; ShellRun 也支持 ms-setting: 或 shell: 或 http: 之类的链接
      ShellRun(programPath, args, workingDir, , runInBackground ? 0 : unset)
    ; }

  } catch Error as e {
    Tip(e.Message)
    ; 还原窗口焦点
    try WinActivate(currentHwnd)
    return
  }
}

CompleteProgramPath(target) {
  ; 工作目录下的程序
  PathName := A_WorkingDir "\" target
  if FileExist(PathName)
    return PathName

  ; 本身便是绝对路径
  if FileExist(target)
    return target

  ; 从环境变量 PATH 中获取
  DosPath := EnvGet("PATH")
  loop parse DosPath, "`;" {
    if A_LoopField == ""
      continue

    if FileExist(A_LoopField "\" target)
      return A_LoopField "\" target
  }

  ; 从安装的程序中获取
  try {
    PathName := RegRead("HKLM", "SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\" target)
    if FileExist(PathName)
      return PathName
  }

  return target
}

ShellRun(target, arguments?, directory?, operation?, show?) {
  static VT_UI4 := 0x13, SWC_DESKTOP := ComValue(VT_UI4, 0x8)
  ComObject("Shell.Application").Windows.Item(SWC_DESKTOP).Document.Application
  .ShellExecute(target, arguments?, directory?, operation?, show?)
}

/**
 * 快捷方式指向目标是否存在，不存在抛出异常
 * @param LnkPath 快捷方式路径
 */
ShortcutTargetExist(LnkPath) {
  if SubStr(LnkPath, -4) == ".lnk" {
    FileGetShortcut(LnkPath, &OutTarget)

    ; 没有获取到目标路径可能是因为是uwp应用的快捷方式
    ; 也有可能是ms-setting: 或shell:之类的连接
    if !OutTarget || SubStr(outTarget, 2, 2) != ":\"
      return

    if !FileExist(OutTarget)
      throw Error("快捷方式指向的目标不存在`n快捷方式: " LnkPath "`n指向目标: " OutTarget)
  }
}

/**
 * 自动关闭的提示窗口 
 * @param message 要提示的文本
 * @param {number} time 超时后关闭
 */
Tip(message, time := -1500) {
  ToolTip(message)
  SetTimer(() => ToolTip(), time)
}


/**
 * 获取当前程序名称
 * 自带的WinGetProcessName无法获取到uwp应用的名称
 * 来源：https://www.autohotkey.com/boards/viewtopic.php?style=7&t=112906
 * @returns {string} 
 */
GetProcessName() {
  return GetActiveProcess("name")
}

GetActiveProcess(type) {
  fn := (winTitle) => (WinGetProcessName(winTitle) == 'ApplicationFrameHost.exe')

  winTitle := "A"
  if fn(winTitle) {
    for hCtrl in WinGetControlsHwnd(winTitle)
      bool := fn(hCtrl)
    until !bool && winTitle := hCtrl
  }

  if type == "name" {
    return WinGetProcessName(winTitle)
  }
  if type == "id" {
    return WinGetPID(winTitle)
  }
  if type == "path" {
    return WinGetProcessPath(winTitle)
  }
}

ActivateDesktop() {
  tmp := A_DetectHiddenWindows
  DetectHiddenWindows true
  if WinExist("ahk_class ForegroundStaging") {
    WinActivate
  }
  DetectHiddenWindows tmp
}



MyFunction(param1, param2) {
    MsgBox "Parameter 1: " param1 "`nParameter 2: " param2
}

; Check if command line arguments exist and call the function
if A_Args.Length > 0 {
    ; Pass the first argument to param1
    arg1 := A_Args[1]

    ; Pass the second argument to param2, if it exists
    arg2 := "" ; Default value if not provided
    if A_Args.Length > 1 {
        arg2 := A_Args[2]
    }

    ActivateOrRun(arg1, arg2)
    ; MyFunction(arg1, arg2)
} else {
    MsgBox ' this app use for activate the window of such app call from cmd .`nUseage AutoHotKey2 activatewindow.ahk ""akh_exe app.exe"" ""d:/app.exe"" .'
    ; Optionally, call the function with default values or handle as needed
    ; MyFunction("Default1", "Default2")
}

