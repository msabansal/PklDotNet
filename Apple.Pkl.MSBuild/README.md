# Apple.Pkl.MSBuild

[![NuGet](https://img.shields.io/nuget/v/Apple.Pkl.MSBuild)](https://www.nuget.org/packages/Apple.Pkl.MSBuild/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

MSBuild integration package for [Apple's Pkl configuration language](https://pkl-lang.org/), providing seamless compilation of Pkl files as part of your .NET build process.

## Overview

`Apple.Pkl.MSBuild` enables you to compile Pkl configuration files directly within your .NET projects using MSBuild. It automatically handles downloading platform-specific Pkl binaries, compiling Pkl files to various output formats, and integrating the compiled configurations into your build and publish workflows.

## Features

- 🚀 **Automatic Compilation** - Compile Pkl files during MSBuild execution
- 📦 **Multiple Output Formats** - Support for JSON, YAML, XML, Properties, and more
- 🔧 **MSBuild Integration** - Native MSBuild tasks and targets
- 🌐 **Cross-Platform** - Works on Windows, Linux, and macOS
- 📁 **Flexible Output** - Flat or recursive directory structures
- 🛠️ **Tool Management** - Automatic Pkl CLI binary management
- 📤 **Publish Integration** - Compiled files included in publish output
- ⚡ **Incremental Builds** - Only recompiles when source files change

## Installation

Add the package to your project:

```xml
<PackageReference Include="Apple.Pkl.MSBuild" Version="0.29.1" />
```

Optionally either set the PklPath variable to the Pkl binary path or reference the platform specific Apple.Pkl.Cli.*

```xml
<PackageReference Include="Apple.Pkl.Cli.win-x64" Version="0.29.1" />
```



## Quick Start

### 1. Add Pkl Files to Your Project

Create a Pkl configuration file (e.g., `config.pkl`):

```pkl
// config.pkl
appName = "MyApplication" 
version = "1.0.0"
database {
  host = "localhost"
  port = 5432
  connectionString = "Host=\(host);Port=\(port);Database=myapp"
}
features {
  enableLogging = true
  maxRetries = 3
}
```

### 2. Configure Compilation

Add the Pkl file to your project file:

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
  </PropertyGroup>
  
  <ItemGroup>
    <PackageReference Include="Apple.Pkl.MSBuild.win-x64" Version="0.29.1" />
    <PackageReference Include="Apple.Pkl.MSBuild" Version="0.29.1" />
  </ItemGroup>
  
  <ItemGroup>
    <Pkl Include="config.pkl" Format="json" />
  </ItemGroup>
</Project>
```

### 3. Build Your Project

When you build your project, `config.pkl` will be compiled to `config.json` in your output directory:

```bash
dotnet build
```

Output (`bin/Debug/net8.0/config.json`):
```json
{
  "appName": "MyApplication",
  "version": "1.0.0",
  "database": {
    "host": "localhost",
    "port": 5432,
    "connectionString": "Host=localhost;Port=5432;Database=myapp"
  },
  "features": {
    "enableLogging": true,
    "maxRetries": 3
  }
}
```

## Pkl Item Configuration

### Basic Syntax

```xml
<ItemGroup>
  <Pkl Include="path/to/file.pkl" Format="json" />
</ItemGroup>
```

### Item Metadata

| Metadata | Description | Default | Example |
|----------|-------------|---------|---------|
| `Format` | Output format | `json` | `json`, `yaml`, `xml`, `properties` |
| `OutputFile` | Custom output path | Auto-generated | `custom-config.json` |

### Multiple Files Example

```xml
<ItemGroup>
  <Pkl Include="configs/app.pkl" Format="json" />
  <Pkl Include="configs/database.pkl" Format="yaml" />
  <Pkl Include="configs/logging.pkl" Format="xml" />
  <Pkl Include="settings/*.pkl" Format="properties" />
</ItemGroup>
```

## Supported Output Formats

| Format | Extension | Description |
|--------|-----------|-------------|
| `json` | `.json` | JavaScript Object Notation |
| `yaml` | `.yaml` | YAML Ain't Markup Language |
| `xml` | `.xml` | Extensible Markup Language |
| `properties` | `.properties` | Java-style properties file |
| `jsonnet` | `.jsonnet` | Jsonnet configuration language |
| `pcf` | `.pcf` | Pkl Configuration Format (native) |
| `plist` | `.plist` | Apple Property List |
| `textproto` | `.textproto` | Protocol Buffers text format |

## MSBuild Properties

### Core Properties

| Property | Description | Default |
|----------|-------------|---------|
| `PklPath` | Path to Pkl executable | Auto-detected |
| `PklOutputPath` | Output directory | `$(OutputPath)` |
| `PklOutputStyle` | Output organization | `Flat` |
| `PklCompileAfterTargets` | When to run compilation | `CoreCompile` |

### Output Styles

#### Flat Output (`PklOutputStyle=Flat`)

All compiled files are placed directly in the output directory:

```xml
<PropertyGroup>
  <PklOutputStyle>Flat</PklOutputStyle>
</PropertyGroup>
```

Directory structure:
```
bin/Debug/net8.0/
├── MyApp.exe
├── config.json
├── database.yaml
└── logging.xml
```

#### Recursive Output (`PklOutputStyle=Recursive`)

Maintains the source directory structure in the output:

```xml
<PropertyGroup>
  <PklOutputStyle>Recursive</PklOutputStyle>
</PropertyGroup>
```

Directory structure:
```
bin/Debug/net8.0/
├── MyApp.exe
└── configs/
    ├── app.json
    ├── database.yaml
    └── sub/
        └── logging.xml
```

### Custom Output Directory

```xml
<PropertyGroup>
  <PklOutputPath>$(OutputPath)configurations\</PklOutputPath>
</PropertyGroup>
```

### Custom Build Timing

```xml
<PropertyGroup>
  <!-- Run before the main compile -->
  <PklCompileAfterTargets>BeforeBuild</PklCompileAfterTargets>
  
  <!-- Run after publish prepare -->
  <PklCompileAfterTargets>PrepareForPublish</PklCompileAfterTargets>
</PropertyGroup>
```

## Publish Integration

Compiled Pkl files are automatically included in publish operations:

```bash
dotnet publish
```

The published output will include all compiled configuration files according to your `PklOutputStyle` setting.
