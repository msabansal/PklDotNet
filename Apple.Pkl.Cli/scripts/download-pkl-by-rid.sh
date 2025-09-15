#!/bin/bash

# Download Pkl Binary by .NET RID Script
# Downloads specific pkl binary for a given .NET Runtime Identifier (RID)
# Usage: ./download-pkl-by-rid.sh <rid> <output_folder> [version]
# Example: ./download-pkl-by-rid.sh "linux-x64" "/tmp/pkl" "0.29.1"

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
REPO_OWNER="apple"
REPO_NAME="pkl"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 <rid> <output_folder> [version]"
    echo ""
    echo "Downloads the pkl binary for the specified .NET Runtime Identifier (RID)."
    echo ""
    echo "Arguments:"
    echo "  rid            The .NET Runtime Identifier (e.g., win-x64, linux-x64, osx-x64, osx-arm64)"
    echo "  output_folder  Output directory where the pkl binary will be saved"
    echo "  version        The pkl version to download (e.g., 0.29.1)"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo ""
    echo "Supported RIDs:"
    echo "  Windows:"
    echo "    win-x64            -> pkl-windows-amd64.exe"
    echo ""
    echo "  Linux:"
    echo "    linux-x64          -> pkl-linux-amd64"
    echo "    linux-arm64        -> pkl-linux-aarch64"
    echo "    linux-musl-x64     -> pkl-alpine-linux-amd64"
    echo ""
    echo "  macOS:"
    echo "    osx-x64            -> pkl-macos-amd64"
    echo "    osx-arm64          -> pkl-macos-aarch64"
    echo ""
    echo "Examples:"
    echo "  $0 \"win-x64\" \"C:\\pkl\" \"0.29.1\""
    echo "    -> Downloads to C:\\pkl\\win-x64\\pkl.exe"
    echo "  $0 \"linux-x64\" \"/tmp/pkl\""
    echo "    -> Downloads to /tmp/pkl/linux-x64/pkl"
    echo "  $0 \"osx-arm64\" \"~/pkl\" \"0.29.1\""
    echo "    -> Downloads to ~/pkl/osx-arm64/pkl"
}

# Function to check if version exists
check_version_exists() {
    local version=$1
    
    local status_code
    status_code=$(curl -s -o /dev/null -w "%{http_code}" \
                 "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/tags/${version}")
    
    if [[ "$status_code" != "200" ]]; then
        print_error "Version $version not found in the repository"
        exit 1
    fi
}

# Function to convert RID to pkl binary name
convert_rid_to_pkl_binary() {
    local rid=$1
    
    local binary_name=""
    
    case "$rid" in
        # Windows
        "win-x64")
            binary_name="pkl-windows-amd64.exe"
            ;;
        
        # Linux
        "linux-x64")
            binary_name="pkl-linux-amd64"
            ;;
        "linux-arm64")
            binary_name="pkl-linux-aarch64"
            ;;
        "linux-musl-x64")
            binary_name="pkl-alpine-linux-amd64"
            ;;
        
        # macOS
        "osx-x64")
            binary_name="pkl-macos-amd64"
            ;;
        "osx-arm64")
            binary_name="pkl-macos-aarch64"
            ;;
        
        *)
            print_error "Unsupported RID: '$rid'"
            echo "Supported RIDs: win-x64, win-x86, win-arm64, linux-x64, linux-arm64, linux-musl-x64, linux-musl-arm64, osx-x64, osx-arm64"
            exit 1
            ;;
    esac
    
    echo "$binary_name"
}

# Function to get download URL
get_download_url() {
    local version=$1
    local binary_name=$2
    
    local download_url
    download_url=$(curl -s "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/releases/tags/${version}" | \
                  grep "\"browser_download_url\":" | \
                  grep "$binary_name" | \
                  sed -E 's/.*"browser_download_url": "([^"]+)".*/\1/')
    
    echo "$download_url"
}

# Function to get output file name based on RID
get_output_filename() {
    local rid=$1
    
    if [[ "$rid" =~ ^win- ]]; then
        echo "pkl.exe"
    else
        echo "pkl"
    fi
}

# Function to download the pkl binary
download_pkl_binary() {
    local url=$1
    local output_path=$2
    local binary_name=$3
    
    print_status "Downloading '$binary_name' to '$output_path'..."
    
    # Create output directory if it doesn't exist
    local output_dir
    output_dir=$(dirname "$output_path")
    if [[ ! -d "$output_dir" ]]; then
        mkdir -p "$output_dir"
        print_status "Created output directory: $output_dir"
    fi
    
    echo curl --progress-bar --fail "$url" -o "$output_path" 

    if curl -L --fail -s "$url" -o "$output_path"; then
        print_status "Binary saved to: $output_path"
    else
        print_error "Failed to download '$binary_name'"
        return 1
    fi
}

# Function to test downloaded binary
test_downloaded_binary() {
    local binary_path=$1
    
    if [[ ! -f "$binary_path" ]]; then
        print_error "Downloaded binary not found at: $binary_path"
        return 1
    fi
    
    if [[ ! -s "$binary_path" ]]; then
        print_error "Downloaded binary is empty: $binary_path"
        return 1
    fi
    
    print_success "Binary validation successful"
    return 0
}

# Function to make binary executable (for non-Windows)
make_binary_executable() {
    local binary_path=$1
    local binary_name=$2
    
    # Make binary executable if it's not a Windows .exe file
    if [[ ! "$binary_name" =~ \.exe$ ]]; then
        chmod +x "$binary_path"
        print_status "Made '$binary_name' executable"
    fi
}


# Main function
main() {
    local rid=""
    local output_folder=""
    local version=""
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -*)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
            *)
                if [[ -z "$rid" ]]; then
                    rid="$1"
                elif [[ -z "$output_folder" ]]; then
                    output_folder="$1"
                elif [[ -z "$version" ]]; then
                    version="$1"
                else
                    print_error "Too many arguments"
                    show_usage
                    exit 1
                fi
                shift
                ;;
        esac
    done
    
    # Validate required parameters
    if [[ -z "$rid" ]]; then
        print_error "RID parameter is required"
        show_usage
        exit 1
    fi
    
    if [[ -z "$output_folder" ]]; then
        print_error "Output folder parameter is required"
        show_usage
        exit 1
    fi
    
    # Get version (use latest if not provided)
    if [[ -z "$version" ]]; then
        print_error "Version is required"
        show_usage
        exit 1
    fi
    
    # Validate inputs
    if ! command -v curl &> /dev/null; then
        print_error "curl is required but not installed"
        exit 1
    fi
    
    # Convert RID to pkl binary name
    local binary_name
    binary_name=$(convert_rid_to_pkl_binary "$rid")
    
    print_success "RID '$rid' maps to binary '$binary_name'"
    
    # Validate version exists
    check_version_exists "$version"
    
    # Get download URL
    local download_url
    download_url=$(get_download_url "$version" "$binary_name")

    print_status "Download URL for $binary_name: $download_url"
    
    # Get the final output file name based on RID
    local output_filename
    output_filename=$(get_output_filename "$rid")
    
    # Create RID-specific subdirectory and prepare output path
    local rid_folder="$output_folder/$rid"
    local output_path="$rid_folder/$output_filename"
    print_status "RID-specific folder: $rid_folder"
    print_status "Output path: $output_path"
    
    echo ""
    print_status "Starting download..."
    print_status "RID: $rid"
    print_status "Version: $version"
    print_status "RID folder: $rid_folder"
    print_status "Output: $output_path"
    echo ""
    
    # Download the binary
    if download_pkl_binary "$download_url" "$output_path" "$binary_name" ; then
        if test_downloaded_binary "$output_path"; then
            make_binary_executable "$output_path" "$output_filename"
        else
            print_error "Binary validation failed"
            exit 1
        fi
    else
        print_error "Download failed"
        exit 1
    fi
}

# Run main function with all arguments
main "$@"