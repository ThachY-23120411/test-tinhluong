Add-Type @"
using System;
using System.Text;
using System.Collections.Generic;
using System.Runtime.InteropServices;

public class ChromeForegroundHelper {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern int GetClassName(IntPtr hWnd, StringBuilder lpClassName, int nMaxCount);

    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
    public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

    [DllImport("user32.dll")]
    public static extern bool IsWindowVisible(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, int dwExtraInfo);

    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);

    private static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);
    private static readonly IntPtr HWND_NOTOPMOST = new IntPtr(-2);
    private const uint SWP_NOSIZE = 0x0001;
    private const uint SWP_NOMOVE = 0x0002;
    private const uint SWP_SHOWWINDOW = 0x0040;

    public static List<IntPtr> FindChromeWindows() {
        var list = new List<IntPtr>();
        EnumWindows((hWnd, lParam) => {
            if (IsWindowVisible(hWnd)) {
                var sbClass = new StringBuilder(256);
                GetClassName(hWnd, sbClass, sbClass.Capacity);
                if (sbClass.ToString() == "Chrome_WidgetWin_1") {
                    var sbTitle = new StringBuilder(256);
                    GetWindowText(hWnd, sbTitle, sbTitle.Capacity);
                    string title = sbTitle.ToString();
                    if (!string.IsNullOrEmpty(title)) {
                        list.Add(hWnd);
                    }
                }
            }
            return true;
        }, IntPtr.Zero);
        return list;
    }

    public static void BringChromeToFront() {
        var handles = FindChromeWindows();
        foreach (var hWnd in handles) {
            keybd_event(0x12, 0, 0, 0);
            keybd_event(0x12, 0, 2, 0);
            ShowWindow(hWnd, 9); // SW_RESTORE
            ShowWindow(hWnd, 3); // SW_MAXIMIZE
            SetWindowPos(hWnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW);
            SetForegroundWindow(hWnd);
            SetWindowPos(hWnd, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW);
        }
    }
}
"@

for ($i = 0; $i -lt 16; $i++) {
    Start-Sleep -Milliseconds 500
    $wins = [ChromeForegroundHelper]::FindChromeWindows()
    if ($wins.Count -gt 0) {
        [ChromeForegroundHelper]::BringChromeToFront()
        Write-Output "Successfully brought $($wins.Count) Chrome window(s) to foreground!"
        break
    }
}
