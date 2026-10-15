Add-Type @"
using System;
using System.Runtime.InteropServices;

public class DesktopLauncher {
    [StructLayout(LayoutKind.Sequential)]
    public struct STARTUPINFO {
        public int cb;
        public string lpReserved;
        public string lpDesktop;
        public string lpTitle;
        public int dwX;
        public int dwY;
        public int dwXSize;
        public int dwYSize;
        public int dwXCountChars;
        public int dwYCountChars;
        public int dwFillAttribute;
        public int dwFlags;
        public short wShowWindow;
        public short cbReserved2;
        public IntPtr lpReserved2;
        public IntPtr hStdInput;
        public IntPtr hStdOutput;
        public IntPtr hStdError;
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct PROCESS_INFORMATION {
        public IntPtr hProcess;
        public IntPtr hThread;
        public int dwProcessId;
        public int dwThreadId;
    }

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool CreateProcess(
        string lpApplicationName,
        string lpCommandLine,
        IntPtr lpProcessAttributes,
        IntPtr lpThreadAttributes,
        bool bInheritHandles,
        uint dwCreationFlags,
        IntPtr lpEnvironment,
        string lpCurrentDirectory,
        ref STARTUPINFO lpStartupInfo,
        out PROCESS_INFORMATION lpProcessInformation
    );

    public static int Launch(string cmdLine, string workDir) {
        STARTUPINFO si = new STARTUPINFO();
        si.cb = Marshal.SizeOf(si);
        si.lpDesktop = @"WinSta0\Default";
        PROCESS_INFORMATION pi = new PROCESS_INFORMATION();
        // 0x10 = CREATE_NEW_CONSOLE
        bool res = CreateProcess(null, cmdLine, IntPtr.Zero, IntPtr.Zero, false, 0x00000010, IntPtr.Zero, workDir, ref si, out pi);
        if (!res) {
            return Marshal.GetLastWin32Error();
        }
        return 0;
    }
}
"@

$workDir = "c:\Users\Y.Thach\Desktop\paradiseHR"
$cmdLine = "cmd.exe /k c:\Users\Y.Thach\Desktop\paradiseHR\run_live.bat"

$err = [DesktopLauncher]::Launch($cmdLine, $workDir)
if ($err -eq 0) {
    Write-Output "SUCCESS: Launched run_live.bat on WinSta0\Default"
} else {
    Write-Output "FAILED: Error code $err"
}
