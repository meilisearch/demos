import React from 'react'
// Material UI
import { useTheme } from '@material-ui/core/styles'
import Button from '@material-ui/core/Button'
import { css } from '@emotion/css'
import { css as cssReact, Global, keyframes } from '@emotion/react'
// Gatsby
import { Link } from 'gatsby'
// Local
import href from './anim.svg'
// import mw_high from './milky-way-high.jpg'

const dash = keyframes`
  to {
    stroke-dashoffset: 0;
  }
`
const opacity = keyframes`
  to {
    opacity: 1;
  }
`
const red = keyframes`
  40% {
    fill: #FF0000;
    opacity: 1;
  }
  50% {
    opacity: 0;
  }
  100% {
    fill: #FF0000;
    opacity: 1;
  }
`
const green = keyframes`
  40% {
    fill: #37E37C;
    opacity: 1;
  }
  50% {
    opacity: 0;
  }
  100% {
    fill: #37E37C;
    opacity: 1;
  }
`

const useStyles = theme => ({
  root: {
    backgroundColor: '#181824',
    // background: `no-repeat url(${mw_high})`,
    color: '#ffffff',
    textAlign: 'center',
    '> div': {
      margin: '0 auto',
      [theme.breakpoints.up(900 + theme.spacing(6))]: {
        maxWidth: 900,
      },
    },
  },
  svg: {
    paddingTop: theme.spacing(8),
  },
  info: {
    [theme.breakpoints.up('md')]: {
      display: 'flex',
      justifyContent: 'space-around',
    },
    padding: theme.spacing(4, 0),
  },
  buttons: {
    [theme.breakpoints.up('md')]: {
      display: 'flex',
      flexDirection: 'column',
    },
  },
  headlines: {
    [theme.breakpoints.down('sm')]: {
      fontSize: '1.2rem',
    },
    [theme.breakpoints.up('sm')]: {
      fontSize: '1.6rem',
    },
    [theme.breakpoints.up('md')]: {
      fontSize: '2rem',
    },
    '> p': {
      margin: 0,
    },
  },
  outlined: {
    margin: theme.spacing(2),
    borderColor: '#fff',
    color: '#fff',
    // backgroundColor: 'rgba(0, 0, 0, 0.2)',
    backgroundColor: 'rgba(255, 255, 255, 0.08)',
    '&:hover': {
      backgroundColor: 'rgba(255, 255, 255, 0.2)',
    },
  }
})

const Intro = () => {
  const styles = useStyles(useTheme())
  return (
    <div css={styles.root}>
      <div>
        <Global
          styles={cssReact`
            #bird_1 {
              stroke-dasharray: 1000 !important;
              animation: ${dash} 10s linear forwards !important;
              stroke-dashoffset: 1000;
            }
            #bird_2 {
              stroke-dasharray: 1000 !important;
              animation: ${dash} 10s linear forwards !important;
              animation-delay: .7s !important;
              stroke-dashoffset: 1000;
            }
            #bird_3 {
              stroke-dasharray: 1000 !important;
              animation: ${dash} 5s linear forwards !important;
              animation-delay: 2s !important;
              stroke-dashoffset: 1000;
            }
            #sun_1 {
              stroke-dasharray: 1000 !important;
              animation: ${dash} 30s linear forwards !important;
              animation-delay: 6s !important;
              stroke-dashoffset: 1000;
            }
            #sun_2 {
              stroke-dasharray: 1000 !important;
              animation: ${dash} 30s linear forwards !important;
              animation-delay: 6s !important;
              stroke-dashoffset: 1000;
            }
            #sun_3 {
              stroke-dasharray: 1000 !important;
              animation: ${dash} 30s linear forwards !important;
              animation-delay: 6s !important;
              stroke-dashoffset: 1000;
            }
            #sun_4 {
              stroke-dasharray: 1000 !important;
              animation: ${dash} 30s linear forwards !important;
              animation-delay: 6s !important;
              stroke-dashoffset: 1000;
            }
            #sun_5 {
              stroke-dasharray: 1000 !important;
              animation: ${dash} 30s linear forwards !important;
              animation-delay: 6s !important;
              stroke-dashoffset: 1000;
            }
            #sun_6 {
              stroke-dasharray: 1000 !important;
              animation: ${dash} 30s linear forwards !important;
              animation-delay: 6s !important;
              stroke-dashoffset: 1000;
            }
            #sun_7 {
              stroke-dasharray: 1000 !important;
              animation: ${dash} 30s linear forwards !important;
              animation-delay: 6s !important;
              stroke-dashoffset: 1000;
            }
            #sunshine {
              stroke-dasharray: 1000 !important;
              animation: ${dash} 20s linear forwards !important;
              animation-delay: 6s !important;
              stroke-dashoffset: 1000;
            }
            #cloud {
              stroke-dasharray: 5000 !important;
              animation: ${dash} 20s linear forwards !important;
              animation-delay: 3s !important;
              stroke-dashoffset: 5000;
            }
            #servers {
              stroke-dasharray: 5000 !important;
              animation: ${dash} 20s linear forwards !important;
              animation-delay: 0s !important;
              stroke-dashoffset: 5000;
            }
            #lights {
              animation: ${opacity} 10s ease-in forwards !important;
              animation-delay: 0s !important;
              opacity: 0;
            }
            #light_1 {
              animation: ${red} 1s ease-out forwards !important;
              animation-delay: 4s !important;
            }
            #light_2 {
              animation: ${green} 1s ease-out forwards !important;
              animation-delay: 4.5s !important;
            }
            #light_3 {
              animation: ${red} 1s ease-out forwards !important;
              animation-delay: 5s !important;
            }
            #light_4 {
              animation: ${green} 1s ease-out forwards !important;
              animation-delay: 5.5s !important;
            }
            #light_5 {
              animation: ${red} 1s ease-out forwards !important;
              animation-delay: 6s !important;
            }
            #light_6 {
              animation: ${green} 1s ease-out forwards !important;
              animation-delay: 6.5s !important;
            }
            #light_7 {
              animation: ${green} 1s ease-out forwards !important;
              animation-delay: 7s !important;
            }
            #light_8 {
              animation: ${green} 1s ease-out forwards !important;
              animation-delay: 7.5s !important;
            }
            #light_9 {
              animation: ${green} 1s ease-out forwards !important;
              animation-delay: 8s !important;
            }
          `}
        />
        <svg
          role="img"
          viewBox={`0 0 800 400`}
          css={styles.svg}
        >
          <title>Nikita</title>
          <use xlinkHref={`${href}#anim`} />
        </svg>
        <div css={styles.info}>
          <div css={styles.headlines}>
            <p>{'Automation and deployment solution'}</p>
            <p>{'Built for Node.js, MIT License'}</p>
            <p>{'Deploy apps and infrastructures'}</p>
          </div>
          <div css={styles.buttons}>
            <Button
              component={Link}
              to="/current/guide/tutorial/"
              size="large"
              variant="outlined"
              css={styles.button}
              classes={{ outlined: css(styles.outlined) }}
            >
              {'Get started'}
            </Button>
            <Button
              component={Link}
              to="/project/changelog/"
              size="large"
              variant="outlined"
              css={styles.button}
              classes={{ outlined: css(styles.outlined) }}
            >
              {'Changelog'}
            </Button>
          </div>
        </div>
      </div>
    </div>
  )
}

export default Intro
