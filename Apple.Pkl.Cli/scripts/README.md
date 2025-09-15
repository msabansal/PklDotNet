# Pkl Binary Download Scripts

This directory contains scripts to download pkl binaries from the [Apple pkl repository](https://github.com/apple/pkl).

## Available Scripts

### 1. `download-pkl-binaries.sh` (Bash Script)
A comprehensive bash script that downloads **ALL** pkl binaries for a given version.

**Features:**
- Downloads all pkl binaries for a specified version
- Organizes files into logical directory structure
- Creates detailed README with usage instructions
- Colored output for better UX
- Error handling and progress reporting
- Makes binaries executable on Unix-like systems

**Usage:**
```bash
# Download latest version
./download-pkl-binaries.sh

# Download specific version
./download-pkl-binaries.sh 0.29.1

# Download to custom directory
./download-pkl-binaries.sh -o /custom/path 0.29.1

# Show help
./download-pkl-binaries.sh --help
```

### 2. `download-pkl-binaries.ps1` (PowerShell Script)
A native PowerShell script that downloads **ALL** pkl binaries for a given version.

**Features:**
- Same functionality as bash script
- Native Windows PowerShell experience
- Colored output using Write-Host
- PowerShell-style parameter handling

**Usage:**
```powershell
# Download latest version
.\download-pkl-binaries.ps1

# Download specific version
.\download-pkl-binaries.ps1 0.29.1

# Download to custom directory
.\download-pkl-binaries.ps1 -OutputDir "C:\custom\path" -Version 0.29.1

# Show help
.\download-pkl-binaries.ps1 -Help
```

### 3. `download-pkl-by-rid.sh` (Bash Script) - **NEW**
Downloads a **SPECIFIC** pkl binary for a given .NET Runtime Identifier (RID) and renames it to `pkl` or `pkl.exe`.

**Features:**
- Downloads only the binary needed for a specific .NET RID
- Automatic RID to pkl binary name mapping
- **Renames output to `pkl.exe` (Windows RIDs) or `pkl` (non-Windows RIDs)**
- Fallback support for unsupported architectures
- Makes binaries executable automatically
- Validates downloads and provides usage instructions

**Usage:**
```bash
# Download for Windows x64 -> creates win-x64/pkl.exe
./download-pkl-by-rid.sh "win-x64" "/path/to/output" "0.29.1"

# Download for Linux x64 -> creates linux-x64/pkl (latest version)
./download-pkl-by-rid.sh "linux-x64" "/tmp/pkl"

# Download for macOS Apple Silicon -> creates osx-arm64/pkl
./download-pkl-by-rid.sh "osx-arm64" "~/pkl" "0.29.1"

# Show help
./download-pkl-by-rid.sh --help
```

### 4. `download-pkl-by-rid.ps1` (PowerShell Script) - **NEW**
PowerShell version that downloads a **SPECIFIC** pkl binary for a given .NET Runtime Identifier (RID) and renames it to `pkl` or `pkl.exe`.

**Features:**
- Same functionality as bash version
- **Renames output to `pkl.exe` (Windows RIDs) or `pkl` (non-Windows RIDs)**
- Native PowerShell parameter handling
- Windows-friendly output and error handling
- Cross-platform PowerShell support

**Usage:**
```powershell
# Download for Windows x64 -> creates win-x64/pkl.exe
.\download-pkl-by-rid.ps1 -Rid "win-x64" -OutputFolder "C:\pkl" -Version "0.29.1"

# Download for Linux x64 -> creates linux-x64/pkl (latest version)
.\download-pkl-by-rid.ps1 -Rid "linux-x64" -OutputFolder "/tmp/pkl"

# Download for macOS Apple Silicon -> creates osx-arm64/pkl
.\download-pkl-by-rid.ps1 -Rid "osx-arm64" -OutputFolder "~/pkl" -Version "0.29.1"

# Show help
.\download-pkl-by-rid.ps1 -Help
```

## Supported .NET Runtime Identifiers (RIDs)

The RID-specific scripts support the following .NET Runtime Identifiers and output the final binary with a standardized name in RID-specific folders:

| .NET RID | Pkl Binary Source | Final Output Path | Notes |
|----------|-------------------|------------------|-------|
| `win-x64` | `pkl-windows-amd64.exe` | `{output}/win-x64/pkl.exe` | Windows 64-bit |
| `win-x86` | `pkl-windows-amd64.exe` | `{output}/win-x86/pkl.exe` | Windows 32-bit (fallback to 64-bit) |
| `win-arm64` | `pkl-windows-amd64.exe` | `{output}/win-arm64/pkl.exe` | Windows ARM64 (fallback to 64-bit) |
| `linux-x64` | `pkl-linux-amd64` | `{output}/linux-x64/pkl` | Linux 64-bit |
| `linux-arm64` | `pkl-linux-aarch64` | `{output}/linux-arm64/pkl` | Linux ARM64 |
| `linux-musl-x64` | `pkl-alpine-linux-amd64` | `{output}/linux-musl-x64/pkl` | Alpine Linux 64-bit |
| `linux-musl-arm64` | `pkl-alpine-linux-amd64` | `{output}/linux-musl-arm64/pkl` | Alpine Linux ARM64 (fallback to 64-bit) |
| `osx-x64` | `pkl-macos-amd64` | `{output}/osx-x64/pkl` | macOS Intel |
| `osx-arm64` | `pkl-macos-aarch64` | `{output}/osx-arm64/pkl` | macOS Apple Silicon |

## When to Use Which Script

### Use the "download all" scripts when:
- Setting up a development environment that needs to support multiple platforms
- Creating a comprehensive pkl binary cache
- You want all available tools (pkl, pkldoc, codegen, java tools)
- You're not sure which specific binary you need

### Use the "download by RID" scripts when:
- Building a .NET application that needs pkl for a specific target platform
- Creating minimal container images with only the required binary
- Automating builds where you know the exact target RID
- You only need the main pkl CLI tool (not pkldoc, codegen, etc.)

## What Gets Downloaded

### All-Binary Scripts (`download-pkl-binaries.*`)
- **Main pkl CLI Tool**: All platform variants (Windows, Linux, macOS, Alpine)
- **Documentation Tool (pkldoc)**: All platform variants
- **Code Generation Tools**: Java and Kotlin generators
- **Java Tools**: jpkl and jpkldoc

### RID-Specific Scripts (`download-pkl-by-rid.*`)
- **Main pkl CLI Tool Only**: Just the binary for the specified RID
- **Single File**: One executable per download
- **Platform Optimized**: Exact match for the target platform

## Directory Structure Examples

### All-Binary Scripts Output
```
pkl-binaries/
└── [version]/
    ├── pkl/           # Main pkl CLI binaries (6 files)
    ├── pkldoc/        # Documentation tool binaries (6 files)
    ├── codegen/       # Code generation tools (2 files)
    ├── java-tools/    # Java-based tools (2 files)
    └── README.md      # Usage instructions
```

### RID-Specific Scripts Output
```
[output-folder]/
├── [rid-1]/
│   └── pkl[.exe]  # Binary for RID 1
├── [rid-2]/
│   └── pkl[.exe]  # Binary for RID 2
└── ...

# Example:
/tmp/pkl/
├── win-x64/
│   └── pkl.exe
├── linux-x64/
│   └── pkl
└── osx-arm64/
    └── pkl
```

## Requirements

### Bash Scripts
- `bash` shell
- `curl` command
- Unix-like environment (Linux, macOS, WSL, Git Bash)

### PowerShell Scripts
- PowerShell 5.1+ (Windows) or PowerShell Core 6+ (cross-platform)
- Internet connection

## Platform Detection Examples

### Bash (for RID-specific downloads)
```bash
# Detect current platform RID
detect_current_rid() {
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')
    local arch=$(uname -m)
    
    case "$os" in
        linux*)
            case "$arch" in
                x86_64) echo "linux-x64" ;;
                aarch64|arm64) echo "linux-arm64" ;;
                *) echo "linux-x64" ;; # fallback
            esac
            ;;
        darwin*)
            case "$arch" in
                x86_64) echo "osx-x64" ;;
                arm64) echo "osx-arm64" ;;
                *) echo "osx-x64" ;; # fallback
            esac
            ;;
        mingw*|cygwin*|msys*)
            echo "win-x64"
            ;;
        *)
            echo "linux-x64" # fallback
            ;;
    esac
}

# Use detected RID
CURRENT_RID=$(detect_current_rid)
./download-pkl-by-rid.sh "$CURRENT_RID" "./pkl"
# This creates ./pkl/$CURRENT_RID/pkl (or pkl.exe for Windows)
```

### PowerShell (for RID-specific downloads)
```powershell
# Detect current platform RID
function Get-CurrentRid {
    if ($IsWindows -or ($PSVersionTable.PSVersion.Major -le 5)) {
        if ([Environment]::Is64BitOperatingSystem) {
            return "win-x64"
        } else {
            return "win-x86"
        }
    }
    elseif ($IsMacOS) {
        $arch = uname -m
        if ($arch -eq "arm64") {
            return "osx-arm64"
        } else {
            return "osx-x64"
        }
    }
    elseif ($IsLinux) {
        $arch = uname -m
        if ($arch -eq "aarch64" -or $arch -eq "arm64") {
            return "linux-arm64"
        } else {
            return "linux-x64"
        }
    }
    else {
        return "linux-x64"  # fallback
    }
}

# Use detected RID
$CurrentRid = Get-CurrentRid
.\download-pkl-by-rid.ps1 -Rid $CurrentRid -OutputFolder "./pkl"
```

## Error Handling

All scripts include comprehensive error handling:
- **Version validation**: Checks if version exists in the repository
- **RID validation**: Validates supported RIDs (RID-specific scripts only)
- **Network error handling**: Graceful handling of download failures
- **File system error handling**: Directory creation and file validation
- **Progress reporting**: Real-time status updates
- **Failed download tracking**: Reports which downloads failed

## Examples

### Download Latest for Current Platform
```bash
# Bash
RID=$(detect_current_rid)  # Use function above
./download-pkl-by-rid.sh "$RID" "./pkl"

# PowerShell
$Rid = Get-CurrentRid  # Use function above
.\download-pkl-by-rid.ps1 -Rid $Rid -OutputFolder "./pkl"
# This creates ./pkl/$Rid/pkl (or pkl.exe for Windows)
```

### Download All Binaries (Development Setup)
```bash
# Bash - All binaries for comprehensive setup
./download-pkl-binaries.sh 0.29.1

# PowerShell - All binaries for comprehensive setup
.\download-pkl-binaries.ps1 -Version 0.29.1
```

### Download for Specific Target Platform
```bash
# Bash - Linux container deployment -> creates ./bin/linux-x64/pkl
./download-pkl-by-rid.sh "linux-x64" "./bin" "0.29.1"

# PowerShell - Windows deployment -> creates .\bin\win-x64\pkl.exe
.\download-pkl-by-rid.ps1 -Rid "win-x64" -OutputFolder ".\bin" -Version "0.29.1"
```

## License

These scripts are provided as-is for downloading publicly available pkl binaries from the official Apple pkl repository.