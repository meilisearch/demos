module.exports = {
  root: true,
  env: {
    browser: true,
    es2021: true
  },
  extends: 'standard',
  overrides: [
  ],
  parserOptions: {
    ecmaVersion: 'latest',
    sourceType: 'module'
  },
  globals: {
    instantsearch: 'readonly'
  },
  rules: {
  }
}
