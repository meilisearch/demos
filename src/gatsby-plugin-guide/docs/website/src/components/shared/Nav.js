// React
import React, { Fragment, useState } from 'react'
// Material UI
import { useTheme, makeStyles } from '@material-ui/core/styles'
import ListItemText from '@material-ui/core/ListItemText'
import IconButton from '@material-ui/core/IconButton'
import ListItemSecondaryAction from '@material-ui/core/ListItemSecondaryAction'
import MenuItem from '@material-ui/core/MenuItem'
import List from '@material-ui/core/List'
import Collapse from '@material-ui/core/Collapse'
import ExpandLess from '@material-ui/icons/ExpandLess'
import ExpandMore from '@material-ui/icons/ExpandMore'
// Gatsby
import { Link } from 'gatsby'

const useStyles = (theme) => ({
  nested: {
    '& a': {
      paddingLeft: theme.spacing(3),
    },
    '& ul a': {
      paddingLeft: theme.spacing(4),
    },
  },
  child: {
    '& div': {
      margin: 0,
      '& span': {
        fontSize: '.9rem',
        color: '#777777',
      },
    },
  },
})

const useClasses = makeStyles((theme) => ({
  active: {
    '& span': {
      color: `${theme.link.main} !important`,
    },
  },
}))

const CollapsedNav = ({ page, styles, classes, activePage, depth }) => {
  const activeSlug = activePage.slug.replace('/packages', '/actions') // Support packages pages
  const pageSlug = page.data.slug.replace('/packages', '/actions') // Support packages pages
  const [open, setOpen] = useState(activeSlug.indexOf(pageSlug) === 0)
  const onToggle = () => setOpen(!open)
  return (
    <Fragment>
      <MenuItem
        component={Link}
        to={page.data.slug}
        css={depth > 0 ? styles.child : ''}
        activeClassName={classes.active}
      >
        <ListItemText primary={page.data.navtitle || page.data.title} />
        <ListItemSecondaryAction>
          <IconButton size={depth > 0 ? 'small' : 'medium'} onClick={onToggle}>
            {open ? <ExpandLess /> : <ExpandMore />}
          </IconButton>
        </ListItemSecondaryAction>
      </MenuItem>
      <Collapse in={open} timeout="auto" unmountOnExit>
        <List css={styles.nested}>
          <BuildNav
            styles={styles}
            depth={++depth}
            classes={classes}
            menu={page.children}
            activePage={activePage}
          />
        </List>
      </Collapse>
    </Fragment>
  )
}

const BuildNav = ({ menu, styles, classes, activePage, depth }) => {
  return Object.values(menu)
    .sort((p1, p2) => p1.data.title.localeCompare(p2.data.title)) // First, sort by name, it is useful for actions
    .sort((p1, p2) => p1.data.sort - p2.data.sort)
    .map((page, index) => {
      if (Object.keys(page.children).length === 0)
        return (
          <MenuItem
            key={`link-${index}`}
            component={Link}
            activeClassName={classes.active}
            to={page.data.slug}
            css={depth > 0 ? styles.child : ''}
          >
            <ListItemText primary={page.data.navtitle || page.data.title} />
          </MenuItem>
        )
      return (
        <CollapsedNav
          key={`list-${index}`}
          depth={depth}
          page={page}
          styles={styles}
          classes={classes}
          activePage={activePage}
        />
      )
    })
}

const Nav = ({ menu, page }) => {
  const theme = useTheme()
  const classes = useClasses(theme)
  const styles = useStyles(theme)
  return (
    <List component="nav">
      <BuildNav
        styles={styles}
        classes={classes}
        menu={menu.children}
        depth={0}
        activePage={page}
      />
    </List>
  )
}

export default Nav
