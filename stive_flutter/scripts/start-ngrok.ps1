param(
  [int]$Port = 0,
  [string]$EnvFile = '.env',
  [string]$NgrokPath = '',
  [int]$TimeoutSeconds = 20,
  [switch]$NoStart,
  [switch]$CopyToClipboard
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-EnvFilePath {
  param([string]$PathFromArg)

  if ([System.IO.Path]::IsPathRooted($PathFromArg)) {
    return $PathFromArg
  }

  $projectRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
  return Join-Path $projectRoot $PathFromArg
}

function Resolve-BackendPort {
  param([int]$PortFromArg)

  if ($PortFromArg -gt 0) {
    return $PortFromArg
  }

  $projectRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
  $backendPropertiesPath = Join-Path (Join-Path $projectRoot '..') 'src/main/resources/application.properties'

  if (Test-Path $backendPropertiesPath) {
    $lines = Get-Content -Path $backendPropertiesPath
    foreach ($line in $lines) {
      if ($line -match '^\s*server\.port\s*=\s*(\d+)\s*$') {
        return [int]$Matches[1]
      }
    }
  }

  return 8080
}

function Get-NgrokPublicUrl {
  param([int]$WaitSeconds)

  $deadline = (Get-Date).AddSeconds($WaitSeconds)
  while ((Get-Date) -lt $deadline) {
    try {
      $resp = Invoke-RestMethod -Uri 'http://127.0.0.1:4040/api/tunnels' -Method Get
      $tunnels = @($resp.tunnels)

      $httpsTunnel = $tunnels | Where-Object { $_.public_url -like 'https://*' } | Select-Object -First 1
      if ($httpsTunnel) {
        return $httpsTunnel.public_url
      }

      $httpTunnel = $tunnels | Where-Object { $_.public_url -like 'http://*' } | Select-Object -First 1
      if ($httpTunnel) {
        return $httpTunnel.public_url
      }
    } catch {
      # ngrok API not ready yet
    }

    Start-Sleep -Milliseconds 500
  }

  throw "Impossible de recuperer l'URL ngrok depuis l'API locale (timeout ${WaitSeconds}s)."
}

function Update-EnvValue {
  param(
    [string]$FilePath,
    [string]$Key,
    [string]$Value
  )

  if (Test-Path $FilePath) {
    $content = Get-Content -Path $FilePath -Raw
  } else {
    $content = ''
  }

  $escapedValue = [System.Text.RegularExpressions.Regex]::Escape($Value)
  if ($content -match "(?m)^${Key}=.*$") {
    $updated = [System.Text.RegularExpressions.Regex]::Replace(
      $content,
      "(?m)^${Key}=.*$",
      "${Key}=$Value"
    )
  } else {
    $prefix = if ($content.Length -gt 0 -and -not $content.EndsWith("`n")) { "`n" } else { '' }
    $updated = "$content$prefix${Key}=$Value`n"
  }

  Set-Content -Path $FilePath -Value $updated -Encoding UTF8
}

$resolvedPort = Resolve-BackendPort -PortFromArg $Port

if (-not $NoStart) {
  $projectRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
  $defaultNgrokLocalPath = Join-Path $projectRoot 'ngrok.exe'

  $ngrokExecutable = $null

  if (-not [string]::IsNullOrWhiteSpace($NgrokPath)) {
    if ([System.IO.Path]::IsPathRooted($NgrokPath)) {
      $candidate = $NgrokPath
    } else {
      $candidate = Join-Path $projectRoot $NgrokPath
    }

    if (-not (Test-Path $candidate)) {
      throw "ngrok introuvable au chemin fourni: $candidate"
    }

    $ngrokExecutable = (Resolve-Path $candidate).Path
  } elseif (Test-Path $defaultNgrokLocalPath) {
    $ngrokExecutable = (Resolve-Path $defaultNgrokLocalPath).Path
  } else {
    $ngrokCommand = Get-Command 'ngrok.exe' -ErrorAction SilentlyContinue
    if (-not $ngrokCommand) {
      throw "ngrok introuvable. Place ngrok.exe dans le dossier stive_flutter ou passe -NgrokPath."
    }
    $ngrokExecutable = $ngrokCommand.Source
  }

  Start-Process -FilePath $ngrokExecutable -ArgumentList @('http', $resolvedPort.ToString()) -WindowStyle Hidden | Out-Null
  Start-Sleep -Seconds 1
}

$url = Get-NgrokPublicUrl -WaitSeconds $TimeoutSeconds
$envFilePath = Resolve-EnvFilePath -PathFromArg $EnvFile
Update-EnvValue -FilePath $envFilePath -Key 'URL_NGROK' -Value $url

if ($CopyToClipboard) {
  Set-Clipboard -Value $url
}

Write-Host "URL_NGROK mise a jour dans $envFilePath"
Write-Host "URL_NGROK=$url"
Write-Host "Port backend utilise: $resolvedPort"
if ($CopyToClipboard) {
  Write-Host 'URL copiee dans le presse-papiers.'
}
