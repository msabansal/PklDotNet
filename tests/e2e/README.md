# Apple.Pkl.MSBuild End-to-End Tests

Comprehensive end-to-end test suite for the `Apple.Pkl.MSBuild` package using TypeScript and Vitest to validate MSBuild integration, compilation scenarios, and real-world usage patterns.

## Test Framework

- **Runtime**: Node.js with TypeScript
- **Test Framework**: [Vitest](https://vitest.dev/) - Fast unit test framework
- **Test Timeout**: 60 seconds (accommodates build operations)
- **Environment**: Node.js environment with cross-platform support
- **Dependencies**: Cross-spawn for reliable process execution across platforms


### Test Setup 

Global test setup handles:

- **Package Building**: Automatically builds MSBuild and CLI packages
- **Local NuGet Source**: Creates local package source for testing

**Environment Variables**:
- `RuntimeSuffix` - Target platform (e.g., `win-x64`, `linux-x64`)
- `PackageVersion` - Version to use for built packages (default: `1.0.0-test`)
- `BinaryVersion` - Pkl binary version to download (default: `0.29.1`)
- `BUILD_PACKAGES` - Whether to test and build cli and msbuild packages for tests (default: `false`)

