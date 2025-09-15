# Download Pkl Binary by .NET RID PowerShell Script
# Downloads specific pkl binary for a given .NET Runtime Identifier (RID)
# Usage: .\download-pkl-by-rid.ps1 -Rid <rid> -OutputFolder <path> -Version <version>
# Example: .\download-pkl-by-rid.ps1 -Rid "win-x64" -OutputFolder "C:\pkl" -Version "0.29.1"

param(
    [Parameter(Mandatory = $true)]
    [string]$Rid,
    
    [Parameter(Mandatory = $true)]
    [string]$OutputFolder,
    
    [string]$Version = "",
    
    [switch]$Help
)

# Color functions for better output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Show-Usage {
    Write-Host @"
Usage: .\download-pkl-by-rid.ps1 -Rid <rid> -OutputFolder <path> [-Version <version>] [-Help]

Downloads the pkl binary for the specified .NET Runtime Identifier (RID).

Parameters:
  -Rid           The .NET Runtime Identifier (e.g., win-x64, linux-x64, osx-x64, osx-arm64)
  -OutputFolder  Output directory where the pkl binary will be saved
  -Version       The pkl version to download (e.g., 0.29.1)
                 If not provided, the latest version will be used
  -Help          Show this help message

Supported RIDs:
  Windows:
    win-x64            -> pkl-windows-amd64.exe
    win-x86            -> pkl-windows-amd64.exe (fallback)
    win-arm64          -> pkl-windows-amd64.exe (fallback)

  Linux:
    linux-x64          -> pkl-linux-amd64
    linux-arm64        -> pkl-linux-aarch64
    linux-musl-x64     -> pkl-alpine-linux-amd64
    linux-musl-arm64   -> pkl-alpine-linux-amd64 (fallback)

  macOS:
    osx-x64            -> pkl-macos-amd64
    osx-arm64          -> pkl-macos-aarch64

Examples:
  .\download-pkl-by-rid.ps1 -Rid "win-x64" -OutputFolder "C:\pkl" -Version "0.29.1"
    -> Downloads to C:\pkl\win-x64\pkl.exe
  .\download-pkl-by-rid.ps1 -Rid "linux-x64" -OutputFolder "/tmp/pkl"
    -> Downloads to /tmp/pkl/linux-x64/pkl
  .\download-pkl-by-rid.ps1 -Rid "osx-arm64" -OutputFolder "~/pkl" -Version "0.29.1"
    -> Downloads to ~/pkl/osx-arm64/pkl
"@
}

function Get-LatestVersion {
    Write-Status "Fetching latest pkl version..."
    
    try {
        $response = Invoke-RestMethod -Uri "https://api.github.com/repos/apple/pkl/releases/latest"
        $latestVersion = $response.tag_name
        
        if ([string]::IsNullOrEmpty($latestVersion)) {
            Write-Error "Failed to fetch latest version"
            exit 1
        }
        
        return $latestVersion
    }
    catch {
        Write-Error "Failed to fetch latest version: $($_.Exception.Message)"
        exit 1
    }
}

function Test-VersionExists {
    param([string]$Version)
    
    Write-Status "Checking if version $Version exists..."
    
    try {
        $null = Invoke-WebRequest -Uri "https://api.github.com/repos/apple/pkl/releases/tags/$Version" -Method Head
        Write-Success "Version $Version found"
        return $true
    }
    catch {
        Write-Error "Version $Version not found in the repository"
        exit 1
    }
}

function Convert-RidToPklBinary {
    param([string]$Rid)
    
    Write-Status "Converting RID '$Rid' to pkl binary name..."
    
    $ridToBinaryMap = @{
        # Windows
        "win-x64"          = "pkl-windows-amd64.exe"
        "win-x86"          = "pkl-windows-amd64.exe"  # Fallback to x64
        "win-arm64"        = "pkl-windows-amd64.exe"  # Fallback to x64
        
        # Linux
        "linux-x64"        = "pkl-linux-amd64"
        "linux-arm64"      = "pkl-linux-aarch64"
        "linux-musl-x64"   = "pkl-alpine-linux-amd64"
        "linux-musl-arm64" = "pkl-alpine-linux-amd64"  # Fallback to x64
        
        # macOS
        "osx-x64"          = "pkl-macos-amd64"
        "osx-arm64"        = "pkl-macos-aarch64"
    }
    
    if ($ridToBinaryMap.ContainsKey($Rid)) {
        $binaryName = $ridToBinaryMap[$Rid]
        Write-Success "RID '$Rid' maps to binary '$binaryName'"
        
        # Show fallback warning if applicable
        if (($Rid -eq "win-x86" -or $Rid -eq "win-arm64") -and $binaryName -eq "pkl-windows-amd64.exe") {
            Write-Warning "No native binary available for '$Rid', using 'pkl-windows-amd64.exe' as fallback"
        }
        elseif ($Rid -eq "linux-musl-arm64" -and $binaryName -eq "pkl-alpine-linux-amd64") {
            Write-Warning "No ARM64 Alpine binary available for '$Rid', using 'pkl-alpine-linux-amd64' as fallback"
        }
        
        return $binaryName
    }
    else {
        Write-Error "Unsupported RID: '$Rid'"
        Write-Host "Supported RIDs: $($ridToBinaryMap.Keys -join ', ')"
        exit 1
    }
}

function Get-DownloadUrl {
    param(
        [string]$Version,
        [string]$BinaryName
    )
    
    Write-Status "Getting download URL for '$BinaryName' version $Version..."
    
    try {
        $response = Invoke-RestMethod -Uri "https://api.github.com/repos/apple/pkl/releases/tags/$Version"
        $asset = $response.assets | Where-Object { $_.name -eq $BinaryName }
        
        if ($null -eq $asset) {
            Write-Error "Binary '$BinaryName' not found for version $Version"
            Write-Status "Available binaries for version ${Version}:"
            $response.assets | ForEach-Object { Write-Host "  - $($_.name)" }
            exit 1
        }
        
        $downloadUrl = $asset.browser_download_url
        Write-Success "Found download URL for '$BinaryName'"
        return $downloadUrl
    }
    catch {
        Write-Error "Failed to get download URL: $($_.Exception.Message)"
        exit 1
    }
}

function Get-PklBinary {
    param(
        [string]$Url,
        [string]$OutputPath,
        [string]$BinaryName,
        [string]$FinalName
    )
    
    Write-Status "Downloading '$BinaryName' to '$OutputPath'..."
    
    try {
        # Create output directory if it doesn't exist
        $outputDir = Split-Path $OutputPath -Parent
        if (-not (Test-Path $outputDir)) {
            New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
            Write-Status "Created output directory: $outputDir"
        }
        
        # Download the file with progress to a temporary path first
        $tempPath = "$OutputPath.tmp"
        $progressPreference = 'Continue'
        Invoke-WebRequest -Uri $Url -OutFile $tempPath -UseBasicParsing
        
        # Rename to final name
        Move-Item $tempPath $OutputPath -Force
        
        Write-Success "Downloaded '$BinaryName' and renamed to '$FinalName'"
        Write-Status "Binary saved to: $OutputPath"
        
        # Get file size for verification
        $fileInfo = Get-Item $OutputPath
        $fileSizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
        Write-Status "File size: $fileSizeMB MB"
        
        return $true
    }
    catch {
        Write-Error "Failed to download '$BinaryName': $($_.Exception.Message)"
        return $false
    }
}

function Test-DownloadedBinary {
    param([string]$BinaryPath)
    
    if (-not (Test-Path $BinaryPath)) {
        Write-Error "Downloaded binary not found at: $BinaryPath"
        return $false
    }
    
    $fileInfo = Get-Item $BinaryPath
    if ($fileInfo.Length -eq 0) {
        Write-Error "Downloaded binary is empty: $BinaryPath"
        return $false
    }
    
    Write-Success "Binary validation successful"
    return $true
}

function Get-OutputFileName {
    param([string]$Rid)
    
    if ($Rid.StartsWith("win-")) {
        return "pkl.exe"
    }
    else {
        return "pkl"
    }
}

function Show-Usage-Instructions {
    param(
        [string]$BinaryPath,
        [string]$Rid
    )
    
    $fileName = Split-Path $BinaryPath -Leaf
    
    Write-Host ""
    Write-Success "Pkl binary download completed!"
    Write-Host ""
    Write-Host "Binary Details:" -ForegroundColor Cyan
    Write-Host "  RID: $Rid"
    Write-Host "  Final name: $fileName"
    Write-Host "  Location: $BinaryPath"
    Write-Host ""
    Write-Host "Usage Instructions:" -ForegroundColor Cyan
    
    if ($Rid.StartsWith("win-")) {
        Write-Host "  # Run the binary directly:"
        Write-Host "  & `"$BinaryPath`""
        Write-Host ""
        Write-Host "  # Or add the RID directory to PATH and use:"
        Write-Host "  pkl --help"
    }
    else {
        Write-Host "  # Make the binary executable (if on Unix-like system):"
        Write-Host "  chmod +x `"$BinaryPath`""
        Write-Host ""
        Write-Host "  # Run the binary:"
        Write-Host "  `"$BinaryPath`" --help"
        Write-Host ""
        Write-Host "  # Or add the RID directory to PATH and use:"
        Write-Host "  pkl --help"
    }
    
    Write-Host ""
}

# Main execution
if ($Help) {
    Show-Usage
    exit 0
}

# Validate required parameters
if ([string]::IsNullOrEmpty($Rid)) {
    Write-Error "RID parameter is required"
    Show-Usage
    exit 1
}

if ([string]::IsNullOrEmpty($OutputFolder)) {
    Write-Error "OutputFolder parameter is required"
    Show-Usage
    exit 1
}

# Get version (use latest if not provided)
if ([string]::IsNullOrEmpty($Version)) {
    $Version = Get-LatestVersion
    Write-Status "Using latest version: $Version"
}

# Convert RID to pkl binary name
$binaryName = Convert-RidToPklBinary $Rid

# Validate version exists
Test-VersionExists $Version

# Get download URL
$downloadUrl = Get-DownloadUrl $Version $binaryName

# Get the final output file name based on RID
$outputFileName = Get-OutputFileName $Rid

# Create RID-specific subdirectory and prepare output path
$ridFolder = Join-Path $OutputFolder $Rid
$outputPath = Join-Path $ridFolder $outputFileName
Write-Status "RID-specific folder: $ridFolder"
Write-Status "Output path: $outputPath"

# Check if file already exists
if (Test-Path $outputPath) {
    Write-Warning "File already exists: $outputPath"
    $response = Read-Host "Do you want to overwrite the existing file? (y/N)"
    if ($response -notmatch '^[Yy]$') {
        Write-Status "Download cancelled"
        exit 0
    }
}

Write-Host ""
Write-Status "Starting download..."
Write-Status "RID: $Rid"
Write-Status "Binary: $binaryName -> $outputFileName"
Write-Status "Version: $Version"
Write-Status "RID folder: $ridFolder"
Write-Status "Output: $outputPath"
Write-Host ""

# Download the binary
if (Get-PklBinary $downloadUrl $outputPath $binaryName $outputFileName) {
    if (Test-DownloadedBinary $outputPath) {
        Show-Usage-Instructions $outputPath $Rid
    }
    else {
        Write-Error "Binary validation failed"
        exit 1
    }
}
else {
    Write-Error "Download failed"
    exit 1
}