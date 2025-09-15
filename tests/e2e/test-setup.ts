import { beforeAll, afterAll } from 'vitest'
import { execaSync } from 'execa'
import fs from 'fs-extra'
import path from 'path'
import { fileURLToPath } from 'url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

export const TEST_CONFIG = {
  packageVersion: process.env.PACKAGE_VERSION || '1.0.0-test',
  binaryVersion: process.env.BINARY_VERSION || '0.29.1',
  configuration: 'Debug',
  timeout: 60000,
  runtimeSuffix: process.env.RuntimeSuffix || 'win-x64',
  baseDir: __dirname,
  localPackagesDir: path.join(__dirname, 'local-packages'),
  nugetSource: 'PklDotNet-E2E-Local'
}

beforeAll(async () => {
  console.log('🔧 Setting up e2e test environment...')
  
  // Ensure local packages directory exists
  await fs.ensureDir(TEST_CONFIG.localPackagesDir)
  
  if (process.env.BUILD_PACKAGES === 'true') {
    // Build MSBuild package if not already built
    await buildAndCopyMSBuildPackage()
    await buildCliPackage()
  }
  
  console.log('✅ E2E test environment ready')
})

async function checkBuildPackageExists(packagePattern: string) {
  const packagePath = path.join(TEST_CONFIG.localPackagesDir, packagePattern)
  return fs.pathExists(packagePath)
}


async function buildAndCopyMSBuildPackage() {
  const packageName = `Apple.Pkl.MSBuild.${TEST_CONFIG.packageVersion}.nupkg`
  if (await checkBuildPackageExists(packageName)) {
    console.log('✅ MSBuild package already built, skipping build step')
    return
  }

  const buildRoot = path.join(TEST_CONFIG.baseDir, '..', '..', 'Apple.Pkl.MSBuild')
  const msbuildProject = path.join(buildRoot, 'Apple.Pkl.MSBuild.csproj')
  
  if (!(await fs.pathExists(msbuildProject))) {
    throw new Error(`MSBuild project not found: ${msbuildProject}`)
  }
  
  console.log('📦 Building Apple.Pkl.MSBuild package...')
  
  try {
    execaSync('dotnet', [
      'pack',
      msbuildProject,
      '--verbosity', 'minimal',
      '--configuration', TEST_CONFIG.configuration,
      '--output', TEST_CONFIG.localPackagesDir,
      `/p:Version=${TEST_CONFIG.packageVersion}`,
    ], { stdio: 'inherit' })
    
    console.log('✅ MSBuild package built successfully')
  } catch (error) {
    throw new Error(`Failed to build MSBuild package: ${error}`)
  }
}


async function buildCliPackage() {
  const packageName = `Apple.Pkl.Cli.${TEST_CONFIG.runtimeSuffix}.${TEST_CONFIG.packageVersion}.nupkg`
  if (await checkBuildPackageExists(packageName)) {
    console.log('✅ MSBuild package already built, skipping build step')
    return
  }

  
  const msbuildProject = path.join(TEST_CONFIG.baseDir, '..', '..', 'Apple.Pkl.Cli', 'Apple.Pkl.Cli.csproj')
  
  if (!(await fs.pathExists(msbuildProject))) {
    throw new Error(`MSBuild project not found: ${msbuildProject}`)
  }
  
  console.log('📦 Building Apple.Pkl.Cli package...')
  
  try {
    execaSync('dotnet', [
      'build',
      msbuildProject,
      '--verbosity', 'minimal',
      '--configuration', TEST_CONFIG.configuration,
      '--output', TEST_CONFIG.localPackagesDir,
      `/p:Version=${TEST_CONFIG.packageVersion}`,
      `/p:BinaryVersion=${TEST_CONFIG.binaryVersion}`,
      `/p:RuntimeSuffix=${TEST_CONFIG.runtimeSuffix}`,
    ], { stdio: 'inherit' })
    
    console.log('✅ MSBuild package built successfully')
  } catch (error) {
    throw new Error(`Failed to build MSBuild package: ${error}`)
  }
}

