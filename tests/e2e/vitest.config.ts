import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    name: 'Apple.Pkl.MSBuild E2E Tests',
    testTimeout: 60000, // 60 seconds for build operations
    hookTimeout: 30000, // 30 seconds for setup/teardown
    globals: true,
    environment: 'node',
    setupFiles: './test-setup.ts',
    reporters: ['verbose']
  }
})