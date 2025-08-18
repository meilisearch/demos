// @ts-check
import js from '@eslint/js'
import vue from 'eslint-plugin-vue'

/** @type {import('eslint').Linter.FlatConfig[]} */
export default [
  {
    ignores: ['dist', 'coverage', 'node_modules', 'setup/**']
  },
  js.configs.recommended,
  ...vue.configs['flat/recommended'],
  {
    files: ['src/**/*.js', 'src/**/*.vue'],
    languageOptions: {
      ecmaVersion: 2023,
      sourceType: 'module'
    },
    rules: {
      // Relax some Vue formatting rules for existing code
      'vue/max-attributes-per-line': 'off',
      'vue/html-indent': 'off',
      'vue/singleline-html-element-content-newline': 'off',
      'vue/multiline-html-element-content-newline': 'off',
      'vue/html-closing-bracket-spacing': 'off',
      'vue/mustache-interpolation-spacing': 'off',
      'vue/html-closing-bracket-newline': 'off',
      'vue/first-attribute-linebreak': 'off',
      'vue/html-quotes': 'off',
      'vue/attributes-order': 'off',
      'vue/no-multi-spaces': 'off',
      'vue/this-in-template': 'off',
      'vue/v-bind-style': 'off',
      'vue/html-self-closing': 'off',
      'vue/no-useless-template-attributes': 'off'
    }
  },
  {
    files: ['*.config.js', 'vite.config.js', 'vitest.config.js'],
    languageOptions: {
      ecmaVersion: 2023,
      sourceType: 'module'
    }
  }
]
