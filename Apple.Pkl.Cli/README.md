# Apple.Pkl.Cli

[![NuGet](https://img.shields.io/nuget/v/Apple.Pkl.Cli)](https://www.nuget.org/packages/Apple.Pkl.Cli/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Platform-specific NuGet packages that provide the [Apple Pkl CLI](https://pkl-lang.org/) binary for use in .NET projects and MSBuild tasks.

## Overview

The `Apple.Pkl.Cli` packages automatically download and manage platform-specific Pkl binaries, eliminating the need to manually install Pkl on build machines or developer workstations. These packages integrate seamlessly with the `Apple.Pkl.MSBuild` package to provide a complete Pkl compilation solution for .NET projects.

## Features

- 🚀 **Automatic Binary Management** - Downloads the correct Pkl binary for your target platform
- 📦 **Platform-Specific Packages** - Separate packages for each supported runtime identifier (RID)
- 🔧 **MSBuild Integration** - Automatically sets the `PklPath` property for use with MSBuild tasks
- 🌐 **Cross-Platform Support** - Supports Windows, Linux, macOS, and Alpine Linux
- ⚡ **No Manual Installation** - No need to manually install Pkl CLI tools
- 🛡️ **Version Consistency** - Ensures consistent Pkl version across all environments

## Available Packages

| Package | Runtime Identifier | Platform | Architecture |
|---------|-------------------|----------|-------------|
| `Apple.Pkl.Cli.win-x64` | `win-x64` | Windows | x64 |
| `Apple.Pkl.Cli.linux-x64` | `linux-x64` | Linux | x64 |
| `Apple.Pkl.Cli.linux-arm64` | `linux-arm64` | Linux | ARM64 |
| `Apple.Pkl.Cli.osx-x64` | `osx-x64` | macOS | Intel x64 |
| `Apple.Pkl.Cli.osx-arm64` | `osx-arm64` | macOS | Apple Silicon |
| `Apple.Pkl.Cli.linux-musl-x64` | `linux-musl-x64` | Alpine Linux | x64 |

## Installation


Add the main package reference and let MSBuild automatically select the correct platform package:

```xml
<PackageReference Include="Apple.Pkl.MSBuild" Version="0.29.1" />
```


## How It Works

1. **Download Phase**: During package restore, the appropriate Pkl binary is downloaded from the [official Apple Pkl releases](https://github.com/apple/pkl/releases)
2. **Extraction Phase**: The binary is extracted and placed in the package's tools directory
3. **MSBuild Integration**: The `PklPath` MSBuild property is automatically set to point to the correct binary
4. **Build Integration**: MSBuild tasks can use the `PklPath` property to execute Pkl commands

## MSBuild Properties

When a `Apple.Pkl.Cli.*` package is installed, it automatically sets the following MSBuild properties:

| Property | Description | Example Value |
|----------|-------------|---------------|
| `PklPath` | Full path to the Pkl executable | `$(UserProfile)\.nuget\packages\apple.pkl.cli.win-x64\0.29.1\tools\pkl.exe` |
| `PklToolsPath` | Directory containing the Pkl binary | `$(UserProfile)\.nuget\packages\apple.pkl.cli.win-x64\0.29.1\tools\` |

## Binary Sources and Versions

The packages download official Pkl binaries from the [Apple Pkl GitHub releases](https://github.com/apple/pkl/releases). The mapping between package RIDs and binary files is:

| Package RID | Source Binary | Final Name |
|-------------|---------------|------------|
| `win-x64` | `pkl-windows-amd64.exe` | `pkl.exe` |
| `linux-x64` | `pkl-linux-amd64` | `pkl` |
| `linux-arm64` | `pkl-linux-aarch64` | `pkl` |
| `osx-x64` | `pkl-macos-amd64` | `pkl` |
| `osx-arm64` | `pkl-macos-aarch64` | `pkl` |
| `linux-musl-x64` | `pkl-alpine-linux-amd64` | `pkl` |
