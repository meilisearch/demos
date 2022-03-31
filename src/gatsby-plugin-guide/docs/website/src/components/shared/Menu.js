// React
import React from 'react'
// Material UI
import { useTheme } from '@material-ui/core/styles'
import Typography from '@material-ui/core/Typography'
// Gatsby
import { Link, StaticQuery, graphql } from 'gatsby'
// Local
import Nav from './Nav'

const useStyles = theme => ({
  root: {
    height: '100%',
    backgroundColor: '#fff',
  },
  toolbar: {
    ...theme.mixins.toolbar,
    backgroundColor: '#f2f2f2',
    borderBottom: '1px solid #0000001f',
    paddingLeft: theme.spacing(2),
    display: 'flex',
    flexGrow: 1,
    flexDirection: 'column',
    alignItems: 'flex-start',
    justifyContent: 'center',
    color: theme.palette.grey[600],
    '& a': {
      ...theme.typography.body1,
      textDecoration: 'none',
      color: theme.palette.text.primary,
    },
  },
  body: {
    minHeight: 'calc(100% - 140px)',
  },
  footer: {
    backgroundColor: '#f2f2f2',
    padding: theme.spacing(2),
    borderTop: '1px solid #0000001f',
    color: theme.palette.grey[600],
    '& a': {
      textDecoration: 'none',
      color: theme.palette.text.primary,
    },
  },
})

const getMenuData = (node) => ({
  navtitle: node.navtitle || (node.frontmatter ? node.frontmatter.navtitle : ''),
  title: node.title || (node.frontmatter ? node.frontmatter.title : ''),
  slug: node.slug,
  sort: (node.frontmatter ? node.frontmatter.sort || 99 : '') || 99,
})

const createPageMenu = (menu, nodes, maxDepth = 3) => {
  nodes.forEach( node => {
    const slugs = node.slug.split('/').filter(part => part)
    if(node.version.alias) slugs.shift() // Don't count root version pages (eg. "/current/")
    let parentMenu = menu
    // Get menu hierarchy
    slugs.forEach((slug, i) => {
      if (i > maxDepth - 1) return
      if (i === maxDepth - 1)
        slug = slugs.slice(maxDepth - 1, slugs.length).join('/')
      if (!parentMenu.children[slug]){
        parentMenu.children[slug] = { data: {}, children: {} }
      }
      parentMenu = parentMenu.children[slug] 
    })
    parentMenu.data = getMenuData(node)
  })
}

const Menu = ({
  page,
  data
}) => {
  const styles = useStyles(useTheme())
  const menu = {
    children: {
      actions: {
        children: data.packages.nodes.map( (pckg) => ({
          children: pckg.actions.map( (action) => ({
            children: {},
            data: getMenuData(action)
          })),
          data: getMenuData(pckg)
        })),
        data: {
          title: 'Actions',
          slug: '/current/actions/',
          sort: 10,
        }
      }
    }
  }
  createPageMenu(menu, data.pages.nodes)
  return (
    <div css={styles.root}>
      <div css={styles.toolbar}>
        <Link to="/">
          Documentation
        </Link>
        <Typography variant="caption">{page.version ? `${page.version} version` : 'current version'}</Typography>
      </div>
      <div css={styles.body}>
        <Nav menu={menu} page={page}/>
      </div>
      <div css={styles.footer}>
        <Typography variant="caption">
          Help us
          {' '}
          <a
            href="https://github.com/adaltas/node-nikita/issues"
          >
            improve the docs
          </a>{' '}
          by fixing typos and proposing enhancements.
        </Typography>
      </div>
    </div>
  )
}

const WrappedMenu = props => (
  <StaticQuery
    query={graphql`
      query NavQuery {
        pages: allNikitaPage(
          filter: { frontmatter: { disabled: { eq: false } } }
          sort: { order: ASC, fields: [frontmatter___sort, slug] }
        ) {
          nodes {
            frontmatter {
              navtitle
              title
              sort
            }
            version {
              alias
            }
            slug
          }
        }
        packages: allNikitaPackage(sort: {fields: slug, order: ASC}) {
          nodes {
            slug
            title: name
            version {
              alias
            }
            actions {
              slug
              title: name
              version {
                alias
              }
            }
          }
        }
      }
    `}
    render={data => <Menu data={data} {...props} />}
  />
)

export default WrappedMenu
