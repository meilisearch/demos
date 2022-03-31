// React
import React, {useState} from 'react'
import Helmet from 'react-helmet'
// Gatsby
import { StaticQuery, graphql } from 'gatsby'
// Local
import AppBar from './shared/AppBar'
import Content from './shared/Content'
import Footer from './shared/Footer'
import Menu from './shared/Menu'
// Material UI
import { useTheme, makeStyles } from '@material-ui/core/styles'
import Drawer from '@material-ui/core/Drawer'
import useMediaQuery from '@material-ui/core/useMediaQuery'

const drawerWidth = 250
const useClasses = makeStyles((theme) => ({
  drawerPaper: {
    width: drawerWidth,
  },
}))
const useStyles = theme => ({
  content: {
    width: '100%',
    backgroundColor: '#fff',
    transition: theme.transitions.create(['margin', 'width'], {
      easing: theme.transitions.easing.easeOut,
      duration: theme.transitions.duration.enteringScreen,
    })
  },
  shift: {
    width: `calc(100% - ${drawerWidth}px)`,
    marginLeft: drawerWidth,
    transition: theme.transitions.create(['margin', 'width'], {
      easing: theme.transitions.easing.easeOut,
      duration: theme.transitions.duration.enteringScreen,
    }),
  },
  contentNoIntro: {
    paddingTop: theme.spacing(8),
  },
})

const Layout = ({
  children,
  data,
  intro,
  home = false,
  page,
  path
}) => {
  // Styles
  const theme = useTheme()
  const classes = useClasses()
  const styles = useStyles(theme)
  // State
  var isMobile = useMediaQuery(theme.breakpoints.down('xs'), {noSsr: true})
  const [isOpen, setIsOpen] = useState(home || isMobile ? false : true)
  const onToggle = () => {
    setIsOpen(!isOpen)
  }
  if(page.slug == null) page.slug = '/'
  if(page.version === undefined) page.version = null
  return (
    <div>
      <Helmet
        title={'NIKITA - ' + page.title}
        meta={[
          { name: 'description', content: page.description },
          { name: 'keywords', content: page.keywords },
          { name: 'google-site-verification', content: 'ukvG8Ae6z6Ly-ABtoUMWzRAPMmn07QWlbRnot0AC5FA'}
        ]}
      >
        <html lang="en" />
      </Helmet>
      <Drawer
        variant={isMobile ? 'temporary' : 'persistent'}
        anchor='left'
        open={isOpen}
        onClose={onToggle}
        classes={{
          paper: classes.drawerPaper,
        }}
      >
        <Menu page={page} />
      </Drawer>
      <AppBar
        onMenuClick={onToggle}
        site={data.site.siteMetadata}
        shift={isOpen && !isMobile && styles.shift}
        opacity={home ? 0.3 : 1}
      />
      <div css={[styles.content, intro ? null : styles.contentNoIntro, isOpen && !isMobile && styles.shift]}>
        { intro }
        <Content page={{...page, ...{home: home, isMobile: isMobile}}}>{children}</Content>
        <Footer site={data.site.siteMetadata} />
      </div>
    </div>
  )
}

const WrappedLayout = props => (
  <StaticQuery
    query={graphql`
      query DocQuery {
        site: site {
          siteMetadata {
            title
            description
            github {
              url
              title
            }
            issues {
              url
              title
            }
            footer {
              title
              content
              links {
                label
                url
              }
              xs
              sm
            }
          }
        }
      }
    `}
    render={data => <Layout data={data} {...props} />}
  />
)

export default WrappedLayout
