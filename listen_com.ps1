$ports = @()
foreach ($name in 'COM5','COM6','COM7','COM8') {
    try {
        $p = New-Object System.IO.Ports.SerialPort $name,115200,'None',8,'One'
        $p.ReadTimeout = 200
        $p.Open()
        $ports += $p
        Write-Output "[open] $name"
    } catch {
        Write-Output "[fail] $name : $($_.Exception.Message)"
    }
}
$deadline = (Get-Date).AddSeconds(600)
while ((Get-Date) -lt $deadline) {
    foreach ($p in $ports) {
        if ($p.BytesToRead -gt 0) {
            $buf = New-Object byte[] $p.BytesToRead
            $n = $p.Read($buf, 0, $buf.Length)
            $txt = [System.Text.Encoding]::ASCII.GetString($buf, 0, $n)
            Write-Output ("[{0}] {1}" -f $p.PortName, $txt)
        }
    }
    Start-Sleep -Milliseconds 100
}
foreach ($p in $ports) { $p.Close() }
Write-Output "[done] listen window closed"
