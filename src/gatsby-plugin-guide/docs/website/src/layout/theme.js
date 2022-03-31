import { createTheme, responsiveFontSizes } from '@material-ui/core/styles';
import lightBlue from '@material-ui/core/colors/lightBlue';
import {styles} from '@material-ui/core/Typography/Typography';

// A custom theme for this app
const scrollMarginTop = 'calc(64px + 1.5rem)' // Compensate AppBar height + some margin
let theme = createTheme({
  props: {
    MuiButtonBase: {
      disableRipple: true, // No ripple on the whole application
    },
  },
  nprogress: {
    color: '#000',
  },
  link: {
    light: lightBlue[500],
    main: lightBlue[700]
  },
  code: {
    main: '#f0f0f5'
  },
  palette: {
    primary: {
      main: '#12182f',
    }
  },
  typography: {
    fontFamily: [
      '-apple-system',
      'BlinkMacSystemFont',
      '"Segoe UI"',
      'Roboto',
      '"Helvetica Neue"',
      'Arial',
      'sans-serif',
      '"Apple Color Emoji"',
      '"Segoe UI Emoji"',
      '"Segoe UI Symbol"',
    ].join(','),
    fontSize: 14,
    h1: {
      fontSize: '3rem',
      wordWrap: 'break-word',
      color: '#777777',
      scrollMarginTop: scrollMarginTop
    },
    h2: {
      fontSize: '2rem',
      color: '#777777',
      scrollMarginTop: scrollMarginTop
    },
    h3: {
      fontSize: '1.5rem',
      color: '#777777',
      scrollMarginTop: scrollMarginTop
    },
    body1: {
      lineHeight: '1.6rem',
    }
  },
});
theme = responsiveFontSizes(theme);
// Note, the current version of mui export `styles` function to enrich the 
// theme typography with additionnal properties like `root` and `gutterBottom`
// Things are changing in the future version of mui (branch `next`), there is
// `TypographyRoot` which we could use or the `typographyClasses` and the
// `getTypographyUtilityClass` properties.
// current: https://github.com/mui-org/material-ui/tree/ae27276980fd6f6950fc7d7ce7e19ab7215b03eb/packages/material-ui/src/Typography
// future: https://github.com/mui-org/material-ui/tree/next/packages/material-ui/src/Typography
// in the end, we dont need much, all the code below for:
// - typography.root: margin: 0
// - typography.gutterBottom: marginBottom: '0.35em'
theme.typography = {
  ...theme.typography,
  ...styles(theme),
}

export default theme;
