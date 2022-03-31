import React from 'react'
import Layout from '../components/Layout'
import Intro from '../components/home/Intro'

import { useTheme } from '@material-ui/core/styles';
import Grid from '@material-ui/core/Grid'
// Material UI
import SvgIcon from '@material-ui/core/SvgIcon'
// Syntax
import SyntaxHighlighter from 'react-syntax-highlighter/dist/esm/prism-light'
import javascript from 'react-syntax-highlighter/dist/esm/languages/prism/javascript'
import { prism } from 'react-syntax-highlighter/dist/esm/styles/prism'

SyntaxHighlighter.registerLanguage('javascript', javascript)
const codeString = `
// Including Nikita
const nikita = require('nikita')
// User configuration
const config = {
  // url: 'http://download.redis.io/redis-stable.tar.gz',
  // conf: {
  //   bind: '127.0.0.1',
  //   port: 6379,
  //   ...
  // }
}
// Nikita instantiation
nikita
// Activate CLI reporting
.log.cli()
// Define and execute a custom Redis action
.call({$header: 'Redis'}, config, function({config}){
  // Default configuration
  if(!config.url){ config.url = 'http://download.redis.io/redis-stable.tar.gz' }
  if(!config.conf){ config.conf = {} }
  if(!config.conf['bind']){ config.conf['bind'] = '127.0.0.1' }
  if(!config.conf['protected-mode']){ config.conf['protected-mode'] = 'yes' }
  if(!config.conf['port']){ config.conf['port'] = 6379 }
  // Do the job
  this
  .file.download({
    $header: 'Download',
    source: config.url,
    target: 'cache/redis-stable.tar.gz'
  })
  .execute({
    $header: 'Compilation',
    $unless_exists: 'redis-stable/src/redis-server',
    command: \`
    tar xzf cache/redis-stable.tar.gz
    cd redis-stable
    make
    \`
  })
  .file.properties({
    $header: 'Configuration',
    target: 'conf/redis.conf',
    separator: ' ',
    content: config.conf
  })
  .execute({
    $header: 'Startup',
    code_skipped: 3,
    command: \`
    ./src/redis-cli ping && exit 3
    nohup ./redis-stable/src/redis-server conf/redis.conf &
    \`
  })
})
`.trim()

const useStyles = theme => ({
  root: {
    paddingTop: theme.spacing(10),
    flexGrow: 1,
    '& h2': {
      textAlign: 'center',
    },
    '& .MuiGrid-root': {
      marginTop: 0,
      marginBottom: 0,
    },
    
  },
  icon: {
    verticalAlign: 'middle',
    marginRight: theme.spacing(1),
    color: '#777777',
  },
  feature: {
    paddingBottom: '0 !important',
  },
  code: {
    // Apply a better background color and styles for code snippets
    background: theme.code.main,
    padding: '1em',
    margin: '.5em 0',
    overflow: 'auto',
    // Remove ugly colors for characters like "=;:"
    '& .token.operator, .token.entity, .token.url, .language-css .token.string, .style .token.string': {
      color: 'inherit',
      background: 'inherit',
    },
  }
})

const Index = () => {
  const styles = useStyles(useTheme())
  return (
    <Layout
      intro={<Intro/>}
      home={true}
      page={{
        title: 'Automation and deployment solution for Node.js',
        description: 'Automation and deployment solution of applications and infrastructures for Node.js.',
        keywords: 'node.js, automation, deployment, system, infrastructure, applications'
      }}
    >
      <div css={styles.root}>
        <h2>Main library features</h2>
        <Grid container spacing={2}>
          <Grid item xs={12} sm={6} css={styles.feature}>
            <h3>
              <SvgIcon css={styles.icon}>
                <path d=" M 20.625 10.125 C 19.589 10.125 18.75 10.964 18.75 12 L 18.375 12 L 18.375 10.5 C 18.375 9.464 17.536 8.625 16.5 8.625 C 15.464 8.625 14.625 9.464 14.625 10.5 L 14.625 12 L 14.25 12 L 14.25 2.25 C 14.25 1.007 13.243 0 12 0 C 10.757 0 9.75 1.007 9.75 2.25 L 9.75 12 L 9.114 12 L 5.845 3.677 C 5.39 2.521 4.084 1.951 2.928 2.406 C 1.771 2.86 1.202 4.166 1.656 5.323 L 5.161 14.245 L 3.704 15.411 C 2.983 15.988 2.789 17.004 3.247 17.805 L 6.247 23.055 C 6.581 23.639 7.202 24 7.875 24 L 19.125 24 C 19.995 24 20.751 23.401 20.95 22.554 L 22.45 16.179 C 22.483 16.039 22.5 15.895 22.5 15.75 L 22.5 12 C 22.5 10.964 21.661 10.125 20.625 10.125 Z " />
              </SvgIcon>
              {'Consistent Usage'}
            </h3>
            <p>
              {
                'All the functions share the same API, accepting configuration in a flexible manner validated by a schema. Once you learn the core usage, you only learn the configuration of the actions you wish to execute.'
              }
            </p>
          </Grid>
          <Grid item xs={12} sm={6} css={styles.feature}>
            <h3>
              <SvgIcon css={styles.icon}>
                <path d=" M 21 5.716 L 21 6 L 15 6 L 15 0 L 15.284 0 C 15.582 0 15.869 0.119 16.08 0.329 L 20.671 4.92 C 20.881 5.131 21 5.418 21 5.716 Z  M 14.625 7.5 C 14.006 7.5 13.5 6.994 13.5 6.375 L 13.5 0 L 4.125 0 C 3.504 0 3 0.504 3 1.125 L 3 22.875 C 3 23.496 3.504 24 4.125 24 L 19.875 24 C 20.496 24 21 23.496 21 22.875 L 21 7.5 L 14.625 7.5 Z  M 8.775 18.774 C 8.729 18.823 8.666 18.851 8.599 18.854 C 8.532 18.856 8.466 18.831 8.417 18.785 L 5.377 15.935 C 5.326 15.887 5.297 15.82 5.297 15.75 C 5.297 15.68 5.326 15.613 5.377 15.565 L 8.417 12.715 C 8.466 12.669 8.532 12.644 8.599 12.646 C 8.666 12.649 8.729 12.677 8.775 12.726 L 9.693 13.705 C 9.74 13.755 9.765 13.822 9.761 13.891 C 9.758 13.959 9.727 14.023 9.676 14.068 L 7.765 15.75 L 9.676 17.432 C 9.727 17.477 9.758 17.541 9.761 17.609 C 9.765 17.678 9.74 17.745 9.693 17.795 L 8.775 18.774 L 8.775 18.774 Z  M 11.18 21.14 L 9.893 20.766 C 9.759 20.727 9.681 20.587 9.72 20.453 L 12.6 10.533 C 12.639 10.398 12.78 10.321 12.914 10.36 L 14.201 10.734 C 14.265 10.752 14.32 10.796 14.352 10.855 C 14.384 10.914 14.392 10.983 14.373 11.047 L 11.493 20.967 C 11.475 21.032 11.431 21.086 11.372 21.119 C 11.313 21.151 11.244 21.159 11.18 21.14 L 11.18 21.14 Z  M 18.717 15.935 L 15.676 18.785 C 15.627 18.831 15.562 18.856 15.495 18.854 C 15.428 18.851 15.364 18.823 15.318 18.774 L 14.401 17.795 C 14.354 17.745 14.329 17.678 14.332 17.609 C 14.336 17.541 14.367 17.477 14.418 17.432 L 16.329 15.75 L 14.418 14.068 C 14.367 14.023 14.336 13.959 14.333 13.891 C 14.329 13.822 14.354 13.755 14.401 13.705 L 15.319 12.726 C 15.364 12.677 15.428 12.649 15.495 12.646 C 15.562 12.644 15.627 12.669 15.676 12.715 L 18.717 15.565 C 18.768 15.613 18.797 15.68 18.797 15.75 C 18.797 15.82 18.768 15.887 18.717 15.935 L 18.717 15.935 Z " />
              </SvgIcon>
              {'Everything is a file'}
            </h3>
            <p>
              {
                'No agent to install, no database to depends on. Your project is just another Node.js package easily versioned in Git and any SCM, easily integrated with your CI and CD DevOps tools.'
              }
            </p>
          </Grid>
          <Grid item xs={12} sm={6} css={styles.feature}>
            <h3>
              <SvgIcon css={styles.icon}>
                <path d="M12,5V1L7,6L12,11V7A6,6 0 0,1 18,13A6,6 0 0,1 12,19A6,6 0 0,1 6,13H4A8,8 0 0,0 12,21A8,8 0 0,0 20,13A8,8 0 0,0 12,5Z" />
              </SvgIcon>
              {'Idempotence'}
            </h3>
            <p>
              {
                'Call a function multiple times and expect the same result. You’ll be informed of any modifications and can retrieve detailed information.'
              }
            </p>
          </Grid>
          <Grid item xs={12} sm={6} css={styles.feature}>
            <h3>
              <SvgIcon css={styles.icon}>
                <path d=" M 18.479 11.375 L 18.667 14.667 Q 18.708 15.385 17.813 16 Q 16.917 16.615 15.365 16.974 Q 13.813 17.333 12 17.333 Q 10.188 17.333 8.635 16.974 Q 7.083 16.615 6.188 16 Q 5.292 15.385 5.333 14.667 L 5.521 11.375 L 11.5 13.26 Q 11.729 13.333 12 13.333 Q 12.271 13.333 12.5 13.26 L 18.479 11.375 Z  M 24 8 Q 24 8.24 23.771 8.323 L 12.104 11.99 Q 12.063 12 12 12 Q 11.938 12 11.896 11.99 L 5.104 9.844 Q 4.656 10.198 4.365 11.005 Q 4.073 11.813 4.01 12.865 Q 4.667 13.24 4.667 14 Q 4.667 14.719 4.063 15.115 L 4.667 19.625 Q 4.688 19.771 4.583 19.885 Q 4.49 20 4.333 20 L 2.333 20 Q 2.177 20 2.083 19.885 Q 1.979 19.771 2 19.625 L 2.604 15.115 Q 2 14.719 2 14 Q 2 13.24 2.677 12.844 Q 2.792 10.688 3.698 9.406 L 0.229 8.323 Q 0 8.24 0 8 Q 0 7.76 0.229 7.677 L 11.896 4.01 Q 11.938 4 12 4 Q 12.063 4 12.104 4.01 L 23.771 7.677 Q 24 7.76 24 8 Z " />
              </SvgIcon>
              {'Documentation'}
            </h3>
            <p>
              {
                'Learn fast. Source code is self-documented with the most common usages enriched by many examples. Don’t forget to look at the tests as well.'
              }
            </p>
          </Grid>
          <Grid item xs={12} sm={6} css={styles.feature}>
            <h3>
              <SvgIcon css={styles.icon}>
                <path d=" M 21.422 16.144 C 20.248 17.097 18.955 17.887 17.553 18.444 L 20.102 22.859 L 22.631 23.939 C 23.091 24.135 23.611 23.835 23.671 23.339 L 24 20.608 L 21.422 16.144 L 21.422 16.144 Z  M 23.414 11.712 C 23.642 11.352 23.503 10.869 23.131 10.662 L 21.815 9.933 C 21.464 9.738 21.036 9.864 20.818 10.201 C 18.891 13.179 15.574 15 12 15 C 10.879 15 9.786 14.801 8.747 14.459 L 11.904 8.99 C 11.937 8.991 11.967 9 12 9 C 12.033 9 12.063 8.991 12.095 8.99 L 14.49 13.138 C 15.954 12.718 17.282 11.931 18.362 10.845 L 15.935 6.64 C 16.284 6.001 16.5 5.279 16.5 4.5 C 16.5 2.015 14.486 0 12 0 C 9.515 0 7.5 2.015 7.5 4.5 C 7.5 5.279 7.716 6.001 8.065 6.64 L 4.864 12.186 C 4.275 11.642 3.741 11.033 3.285 10.358 C 3.06 10.025 2.63 9.907 2.283 10.108 L 0.982 10.861 C 0.614 11.074 0.484 11.56 0.718 11.915 C 1.447 13.023 2.344 13.987 3.342 14.822 L 0 20.609 L 0.329 23.339 C 0.389 23.836 0.909 24.136 1.369 23.939 L 3.898 22.859 L 7.216 17.111 C 8.725 17.685 10.342 18 12 18 C 16.643 18 20.948 15.609 23.414 11.712 Z  M 12 3 C 12.829 3 13.5 3.672 13.5 4.5 C 13.5 5.328 12.829 6 12 6 C 11.172 6 10.5 5.328 10.5 4.5 C 10.5 3.672 11.172 3 12 3 Z " />
              </SvgIcon>
              {'Flexibility'}
            </h3>
            <p>
              {
                'Deliberately sacrificing speed for a maximum of strength, ease of use, and flexibility. The simple API built on a plugin architecture allows us to constantly add new functionality without affecting the API.'
              }
            </p>
          </Grid>
          <Grid item xs={12} sm={6} css={styles.feature}>
            <h3>
              <SvgIcon css={styles.icon}>
                <path d=" M 19.206 9.59 L 18.898 10.127 C 18.786 10.325 18.546 10.408 18.332 10.329 C 17.889 10.164 17.484 9.928 17.128 9.632 C 16.956 9.489 16.91 9.238 17.023 9.043 L 17.331 8.507 C 17.072 8.207 16.869 7.858 16.734 7.479 L 16.115 7.479 C 15.89 7.479 15.695 7.318 15.658 7.093 C 15.583 6.643 15.579 6.17 15.658 5.701 C 15.695 5.476 15.89 5.311 16.115 5.311 L 16.734 5.311 C 16.869 4.933 17.072 4.584 17.331 4.284 L 17.023 3.747 C 16.91 3.552 16.952 3.301 17.128 3.159 C 17.484 2.862 17.893 2.626 18.332 2.461 C 18.546 2.382 18.786 2.465 18.898 2.664 L 19.206 3.2 C 19.599 3.129 20.001 3.129 20.395 3.2 L 20.702 2.664 C 20.815 2.465 21.055 2.382 21.268 2.461 C 21.711 2.626 22.116 2.862 22.472 3.159 C 22.645 3.301 22.69 3.552 22.577 3.747 L 22.27 4.284 C 22.528 4.584 22.731 4.933 22.866 5.311 L 23.485 5.311 C 23.71 5.311 23.905 5.473 23.942 5.698 C 24.017 6.148 24.021 6.62 23.942 7.089 C 23.905 7.314 23.71 7.479 23.485 7.479 L 22.866 7.479 C 22.731 7.858 22.528 8.207 22.27 8.507 L 22.577 9.043 C 22.69 9.238 22.648 9.489 22.472 9.632 C 22.116 9.928 21.707 10.164 21.268 10.329 C 21.055 10.408 20.815 10.325 20.702 10.127 L 20.395 9.59 C 20.005 9.662 19.599 9.662 19.206 9.59 L 19.206 9.59 Z  M 18.812 7.385 C 20.256 8.495 21.902 6.849 20.792 5.405 C 19.348 4.291 17.702 5.941 18.812 7.385 L 18.812 7.385 Z  M 14.488 13.157 L 15.752 13.787 C 16.13 14.005 16.295 14.466 16.145 14.878 C 15.812 15.786 15.155 16.619 14.548 17.346 C 14.27 17.68 13.79 17.762 13.411 17.545 L 12.32 16.915 C 11.72 17.429 11.023 17.837 10.261 18.104 L 10.261 19.364 C 10.261 19.799 9.95 20.174 9.522 20.249 C 8.6 20.406 7.632 20.414 6.676 20.249 C 6.245 20.174 5.926 19.803 5.926 19.364 L 5.926 18.104 C 5.165 17.834 4.467 17.429 3.867 16.915 L 2.776 17.541 C 2.401 17.759 1.917 17.676 1.639 17.342 C 1.032 16.615 0.39 15.782 0.057 14.878 C -0.093 14.47 0.072 14.008 0.45 13.787 L 1.699 13.157 C 1.553 12.373 1.553 11.567 1.699 10.779 L 0.45 10.145 C 0.072 9.928 -0.097 9.467 0.057 9.058 C 0.39 8.15 1.032 7.318 1.639 6.59 C 1.917 6.256 2.397 6.174 2.776 6.391 L 3.867 7.021 C 4.467 6.508 5.165 6.099 5.926 5.833 L 5.926 4.569 C 5.926 4.137 6.233 3.762 6.661 3.687 C 7.583 3.53 8.555 3.522 9.511 3.684 C 9.942 3.759 10.261 4.13 10.261 4.569 L 10.261 5.829 C 11.023 6.099 11.72 6.504 12.32 7.018 L 13.411 6.388 C 13.786 6.17 14.27 6.253 14.548 6.586 C 15.155 7.314 15.793 8.147 16.127 9.054 C 16.277 9.463 16.13 9.924 15.752 10.145 L 14.488 10.776 C 14.634 11.563 14.634 12.369 14.488 13.157 L 14.488 13.157 Z  M 10.077 13.948 C 12.298 11.061 9.001 7.764 6.113 9.984 C 3.893 12.872 7.19 16.168 10.077 13.948 Z  M 19.206 20.8 L 18.898 21.336 C 18.786 21.535 18.546 21.618 18.332 21.539 C 17.889 21.374 17.484 21.138 17.128 20.841 C 16.956 20.699 16.91 20.448 17.023 20.253 L 17.331 19.716 C 17.072 19.416 16.869 19.067 16.734 18.689 L 16.115 18.689 C 15.89 18.689 15.695 18.527 15.658 18.302 C 15.583 17.852 15.579 17.38 15.658 16.911 C 15.695 16.686 15.89 16.521 16.115 16.521 L 16.734 16.521 C 16.869 16.142 17.072 15.793 17.331 15.493 L 17.023 14.957 C 16.91 14.762 16.952 14.511 17.128 14.368 C 17.484 14.072 17.893 13.836 18.332 13.671 C 18.546 13.592 18.786 13.675 18.898 13.873 L 19.206 14.41 C 19.599 14.338 20.001 14.338 20.395 14.41 L 20.702 13.873 C 20.815 13.675 21.055 13.592 21.268 13.671 C 21.711 13.836 22.116 14.072 22.472 14.368 C 22.645 14.511 22.69 14.762 22.577 14.957 L 22.27 15.493 C 22.528 15.793 22.731 16.142 22.866 16.521 L 23.485 16.521 C 23.71 16.521 23.905 16.682 23.942 16.907 C 24.017 17.357 24.021 17.83 23.942 18.299 C 23.905 18.524 23.71 18.689 23.485 18.689 L 22.866 18.689 C 22.731 19.067 22.528 19.416 22.27 19.716 L 22.577 20.253 C 22.69 20.448 22.648 20.699 22.472 20.841 C 22.116 21.138 21.707 21.374 21.268 21.539 C 21.055 21.618 20.815 21.535 20.702 21.336 L 20.395 20.8 C 20.005 20.871 19.599 20.871 19.206 20.8 Z  M 18.812 18.591 C 20.256 19.701 21.902 18.055 20.792 16.611 C 19.348 15.501 17.702 17.147 18.812 18.591 L 18.812 18.591 Z " />
              </SvgIcon>
              {'Composition'}
            </h3>
            <p>
              {
                'Built from small and reusable actions imbricated into a complex system. It follows the Unix philosophy of building small single-building blocks with a clear API.'
              }
            </p>
          </Grid>
          <Grid item xs={12} sm={6} css={styles.feature}>
            <h3>
              <SvgIcon css={styles.icon}>
                <path d="M2.81,14.12L5.64,11.29L8.17,10.79C11.39,6.41 17.55,4.22 19.78,4.22C19.78,6.45 17.59,12.61 13.21,15.83L12.71,18.36L9.88,21.19L9.17,17.66C7.76,17.66 7.76,17.66 7.05,16.95C6.34,16.24 6.34,16.24 6.34,14.83L2.81,14.12M5.64,16.95L7.05,18.36L4.39,21.03H2.97V19.61L5.64,16.95M4.22,15.54L5.46,15.71L3,18.16V16.74L4.22,15.54M8.29,18.54L8.46,19.78L7.26,21H5.84L8.29,18.54M13,9.5A1.5,1.5 0 0,0 11.5,11A1.5,1.5 0 0,0 13,12.5A1.5,1.5 0 0,0 14.5,11A1.5,1.5 0 0,0 13,9.5Z" />
              </SvgIcon>
              {'SSH native support'}
            </h3>
            <p>
              All the functions run transparently over SSH with a possibility to
              execute as the root user via sudo. Look at the <a
              href="https://github.com/adaltas/node-nikita/tree/master/packages/core/test"
              alt="Nikita unit tests">tests</a>, they are all executed both
              locally and remotely.
            </p>
          </Grid>
          <Grid item xs={12} sm={6} css={styles.feature}>
            <h3>
              <SvgIcon css={styles.icon}>
                <path d="M12,16A3,3 0 0,1 9,13C9,11.88 9.61,10.9 10.5,10.39L20.21,4.77L14.68,14.35C14.18,15.33 13.17,16 12,16M12,3C13.81,3 15.5,3.5 16.97,4.32L14.87,5.53C14,5.19 13,5 12,5A8,8 0 0,0 4,13C4,15.21 4.89,17.21 6.34,18.65H6.35C6.74,19.04 6.74,19.67 6.35,20.06C5.96,20.45 5.32,20.45 4.93,20.07V20.07C3.12,18.26 2,15.76 2,13A10,10 0 0,1 12,3M22,13C22,15.76 20.88,18.26 19.07,20.07V20.07C18.68,20.45 18.05,20.45 17.66,20.06C17.27,19.67 17.27,19.04 17.66,18.65V18.65C19.11,17.2 20,15.21 20,13C20,12 19.81,11 19.46,10.1L20.67,8C21.5,9.5 22,11.18 22,13Z" />
              </SvgIcon>
              {'Reporting'}
            </h3>
            <p>
              {
                'Advanced reports can be obtained by providing a log function, listening to stdout and stderr streams, generating diffs and backups.'
              }
            </p>
          </Grid>
          <Grid item xs={12} sm={6} css={styles.feature}>
            <h3>
              <SvgIcon css={styles.icon}>
                <path d="M5,9V21H1V9H5M9,21A2,2 0 0,1 7,19V9C7,8.45 7.22,7.95 7.59,7.59L14.17,1L15.23,2.06C15.5,2.33 15.67,2.7 15.67,3.11L15.64,3.43L14.69,8H21C22.11,8 23,8.9 23,10V12C23,12.26 22.95,12.5 22.86,12.73L19.84,19.78C19.54,20.5 18.83,21 18,21H9M9,19H18.03L21,12V10H12.21L13.34,4.68L9,9.03V19Z" />
              </SvgIcon>
              {'Reliability'}
            </h3>
            <p>
              {
                'Feel confident. The modules are used in production for years and the code is enforced by an extensive test coverage.'
              }
            </p>
          </Grid>
          <Grid item xs={12} sm={6} css={styles.feature}>
            <h3>
              <SvgIcon css={styles.icon}>
                <path d=" M 6 10.8 L 6 13.2 L 18 13.2 L 18 10.8 C 18 9.476 19.076 8.4 20.4 8.4 L 21.6 8.4 C 21.6 6.412 19.988 4.8 18 4.8 L 6 4.8 C 4.013 4.8 2.4 6.412 2.4 8.4 L 3.6 8.4 C 4.924 8.4 6 9.476 6 10.8 Z  M 21.6 9.6 L 20.4 9.6 C 19.736 9.6 19.2 10.136 19.2 10.8 L 19.2 14.4 L 4.8 14.4 L 4.8 10.8 C 4.8 10.136 4.264 9.6 3.6 9.6 L 2.4 9.6 C 1.076 9.6 0 10.676 0 12 C 0 12.885 0.488 13.65 1.2 14.066 L 1.2 18.6 C 1.2 18.93 1.47 19.2 1.8 19.2 L 4.2 19.2 C 4.53 19.2 4.8 18.93 4.8 18.6 L 4.8 18 L 19.2 18 L 19.2 18.6 C 19.2 18.93 19.47 19.2 19.8 19.2 L 22.2 19.2 C 22.53 19.2 22.8 18.93 22.8 18.6 L 22.8 14.066 C 23.513 13.65 24 12.885 24 12 C 24 10.676 22.924 9.6 21.6 9.6 Z " />
              </SvgIcon>
              {'Suppport'}
            </h3>
            <p>
              The package is open-sourced with one of the least restrictive
              licenses. Get involved and contribute to open source
              development by sending pull requests and requesting commercial
              support from <a href="http://www.adaltas.com">Adaltas</a>.
            </p>
          </Grid>
        </Grid>
      </div>
      <div css={styles.root}>
        <h2>Redis installation example </h2>
        <SyntaxHighlighter
          language="javascript"
          style={prism}
          css={styles.code}
          useInlineStyles={false}>
          {codeString}
        </SyntaxHighlighter>
      </div>
    </Layout>
  )
}

export default Index
