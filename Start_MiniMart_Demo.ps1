# MiniMart local demo launcher. Run from its project folder.
# Does NOT change SQL, source files, policies, or save passwords to disk.
$ErrorActionPreference = 'Stop'
$project = Split-Path -Parent $MyInvocation.MyCommand.Path
$python = Join-Path $project '.venv\Scripts\python.exe'
$oldAdminList = $env:MM_PORTAL_ADMIN_LOGINS
$oldSecureCookie = $env:MM_COOKIE_SECURE

try {
    Set-Location -LiteralPath $project
    Write-Host '=== MiniMart: kiem tra truoc khi demo ===' -ForegroundColor Cyan

    if (!(Test-Path -LiteralPath $python -PathType Leaf)) {
        throw 'Khong tim thay .venv\Scripts\python.exe. Chua chay duoc web.'
    }
    if (!(Test-Path -LiteralPath (Join-Path $project 'mini_demo_preflight.py') -PathType Leaf)) {
        throw 'Khong tim thay mini_demo_preflight.py trong thu muc du an.'
    }

    # Protect against port conflicts; do not stop/kilI any existing process.
    $busy = @(Get-NetTCPConnection -LocalPort 5000 -State Listen -ErrorAction SilentlyContinue)
    if ($busy.Count -gt 0) {
        Write-Host 'Cong 5000 da duoc su dung. Kiem tra Flask cua so cu truoc.' -ForegroundColor Yellow
        Write-Host ('PID: ' + (($busy | Select-Object -ExpandProperty OwningProcess -Unique) -join ', '))
        throw 'Dung: cong 5000 dang ban.'
    }

    # Demo is local HTTP on 127.0.0.1 only; leave config.py unchanged.
    $env:MM_COOKIE_SECURE = '0'
    $admins = @($oldAdminList -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ })
    if ($admins -cnotcontains 'Portal_Admin') {
        $env:MM_PORTAL_ADMIN_LOGINS = (@($admins) + 'Portal_Admin') -join ','
    }

    Write-Host 'Nhap MAT KHAU SQL cua Portal_Service (khong phai Portal_Admin).' -ForegroundColor Cyan
    $secret = Read-Host 'Mat khau Portal_Service' -AsSecureString
    $ptr = [IntPtr]::Zero
    try {
        $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secret)
        $env:MM_SVC_PASSWORD = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    } finally {
        if ($ptr -ne [IntPtr]::Zero) {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
        }
        Remove-Variable secret -ErrorAction SilentlyContinue
    }

    Write-Host 'Dang kiem tra Python, giao dien, Portal_Service va SQL...' -ForegroundColor Cyan
    & $python (Join-Path $project 'mini_demo_preflight.py')
    if ($LASTEXITCODE -ne 0) {
        throw 'Preflight CHUA DAT. Khong khoi dong Flask de tranh loi khi demo.'
    }

    Write-Host 'SAN SANG - Mo http://127.0.0.1:5000/login tren CHINH MAY NAY.' -ForegroundColor Green
    Write-Host 'De nguyen cua so nay; Ctrl+C chi khi ket thuc demo.' -ForegroundColor Green
    & $python (Join-Path $project 'app.py')
} catch {
    Write-Host ('CHUA SAN SANG: ' + $_.Exception.Message) -ForegroundColor Red
    Write-Host 'Khong chay lai nhieu lan neu mat khau Portal_Service khong dung.' -ForegroundColor Yellow
} finally {
    # Discard secrets from this PowerShell process when Flask exits.
    Remove-Item Env:\MM_SVC_PASSWORD -ErrorAction SilentlyContinue
    $env:MM_PORTAL_ADMIN_LOGINS = $oldAdminList
    $env:MM_COOKIE_SECURE = $oldSecureCookie
}
