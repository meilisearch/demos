import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    environment: 'node',
    pool: 'forks',
    poolOptions: {
      forks: {
        singleFork: true
      }
    },
    testTimeout: 10000,
    coverage: {
      provider: 'v8',
      reportsDirectory: './coverage'
    }
  }
})
