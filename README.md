# PklDotNet

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

### Apple.Pkl.MSBuild

The main MSBuild integration package that provides:
- **Apple Pkl MSBuild Task** - Compiles Pkl files during build
- **Build Targets** - Automatic compilation and output management
- **Multi-format Support** - Generate multiple output formats from the same Pkl source

### Apple.Pkl.Cli

Platform-specific packages that provide the Apple Pkl CLI binary:
- `Apple.Pkl.Cli.win-x64` - Windows x64
- `Apple.Pkl.Cli.linux-x64` - Linux x64  
- `Apple.Pkl.Cli.linux-arm64` - Linux ARM64
- `Apple.Pkl.Cli.osx-x64` - macOS Intel
- `Apple.Pkl.Cli.osx-arm64` - macOS Apple Silicon
- `Apple.Pkl.Cli.linux-musl-x64` - Alpine Linux x64rce.org/licenses/MIT)

A .NET integration for [Apple's Pkl configuration language](https://pkl-lang.org/), providing MSBuild tasks and NuGet packages to seamlessly use Pkl in .NET projects.

## What is Pkl?

Pkl (pronounced "pickle") is Apple's configuration language designed to be safe, expressive, and composable. It combines the benefits of static configuration files with the power of a programming language, enabling:

- **Type safety** - Catch configuration errors at compile time
- **Composability** - Reuse and extend configurations
- **Validation** - Built-in constraints and validation rules
- **Multiple output formats** - Generate JSON, YAML, XML, properties files, and more

## Features

- 🚀 **MSBuild Integration** - Compile Pkl files as part of your .NET build process
- 📦 **NuGet Packages** - Platform-specific Pkl CLI tools distributed via NuGet
- 🔧 **Automatic Tool Management** - Downloads and manages Pkl binaries automatically
- 🎯 **Multi-Target Support** - Works with all .NET project types and target frameworks
- 🌐 **Cross-Platform** - Supports Windows, Linux, and macOS
- 📄 **Multiple Output Formats** - JSON, YAML, XML, Properties, and more

## Quick Start

### 1. Install the NuGet Package

Add the Pkl MSBuild package to your project:

```xml
<PackageReference Include="Apple.Pkl.MSBuild" Version="0.3.1" />
```

### 2. Add a Pkl Configuration File

Create a file called `config.pkl`:

```pkl
// config.pkl
appName = "MyApp"
version = "1.0.0"
database {
  host = "localhost"
  port = 5432
  name = "myapp_db"
}
features {
  enableLogging = true
  maxConnections = 100
}
```

### 3. Configure MSBuild to Compile Pkl Files

Add this to your `.csproj` file:

```xml
<ItemGroup>
  <Pkl Include="config.pkl" Format="json" />
</ItemGroup>
```

### 4. Build Your Project

When you build your project, `config.pkl` will be compiled to `config.json`:

```json
{
  "appName": "MyApp",
  "version": "1.0.0",
  "database": {
    "host": "localhost",
    "port": 5432,
    "name": "myapp_db"
  },
  "features": {
    "enableLogging": true,
    "maxConnections": 100
  }
}
```

## Packages

### Pkl.MSBuild

The main MSBuild integration package that provides:
- **Pkl MSBuild Task** - Compiles Pkl files during build
- **Build Targets** - Automatic compilation and output management
- **Multi-format Support** - Generate multiple output formats from the same Pkl source

### PklCli

Platform-specific packages that provide the Pkl CLI binary:
- `PklCli.win-x64` - Windows x64
- `PklCli.linux-x64` - Linux x64  
- `PklCli.linux-arm64` - Linux ARM64
- `PklCli.osx-x64` - macOS Intel
- `PklCli.osx-arm64` - macOS Apple Silicon
- `PklCli.linux-musl-x64` - Alpine Linux x64

These packages automatically set the `PklPath` MSBuild property to point to the correct binary.

## Configuration

### MSBuild Properties

| Property | Description | Default |
|----------|-------------|---------|
| `PklPath` | Path to the Pkl executable | Auto-detected from NuGet packages |
| `PklOutputPath` | Directory for compiled output files | `$(OutputPath)` |
| `PklOutputStyle` | Output organization: `Flat` or `Recursive` | `Flat` |
| `PklCompileAfterTargets` | When to run Pkl compilation | `CoreCompile` |

### Output Styles

#### Flat Output (`PklOutputStyle=Flat`)
All compiled files are placed directly in the output directory:
```
bin/
├── config.json
├── database.yaml
└── features.properties
```

#### Recursive Output (`PklOutputStyle=Recursive`)  
Maintains the source directory structure:
```
bin/
├── configs/
│   ├── app.json
│   └── database.yaml
└── templates/
    └── features.properties
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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Related Projects

- **[Apple Pkl](https://github.com/apple/pkl)** - The official Pkl language implementation
- **[Pkl Language Website](https://pkl-lang.org/)** - Official documentation and tutorials



