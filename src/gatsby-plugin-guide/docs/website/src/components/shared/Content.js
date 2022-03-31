// React
import React from 'react'
import PropTypes from 'prop-types'
// Material UI
import { useTheme } from '@material-ui/core/styles'
import Button from '@material-ui/core/Button'
import EditIcon from '@material-ui/icons/EditOutlined'
import Toc from "./Toc"

require('prismjs/themes/prism.css')

const useStyles = theme => ({
  root: theme.mixins.gutters({
    paddingTop: theme.spacing(5),
    margin: theme.spacing(0, 'auto', 5),
    [theme.breakpoints.up(900 + theme.spacing(6))]: {
      maxWidth: 1000,
    },
  }),
  title: {
    ...theme.typography.root,
    ...theme.typography.h1,
    ...theme.typography.gutterBottom,
    fontWeight: 'normal',
  },
  editButton: {
    marginTop: theme.spacing(5),
    textTransform: 'inherit',
    color: '#777777 !important',
    '& svg': {
      marginRight: theme.spacing(1)
    }
  },
  container: {
    [theme.breakpoints.up('md')]: {
      display: 'flex',
      lignItems: 'flex-start',
    },
  },
  toc: {
    paddingTop: theme.spacing(2),
    paddingBottom: theme.spacing(2),
    [theme.breakpoints.up('md')]: {
      verticalAlign: 'top',
      display: 'inline-block',
      position: 'sticky',
      top: `calc(64px + ${theme.spacing(4)}px)`, // Compensate AppBar height + some marging
      maxHeight: `calc(100vh - 64px - ${theme.spacing(4)}px)`,
      paddingLeft: theme.spacing(6),
      order: 2,
      height: '100%',
      overflow: 'auto',
    },
  },
  content: {
    ...theme.typography.body1,
    // lineHeight: '1.6rem',
    '& h2': {
      ...theme.typography.root,
      ...theme.typography.h2,
      ...theme.typography.gutterBottom,
      fontWeight: 'normal',
      marginTop: theme.spacing(4),
    },
    '& h3': {
      ...theme.typography.root,
      ...theme.typography.h3,
      ...theme.typography.gutterBottom,
      fontWeight: 'normal',
      marginTop: theme.spacing(3),
    },
    '& blockquote': {
      borderLeft: '3px solid #777777',
      margin: 0,
      paddingLeft: theme.spacing(5),
    },
    '& blockquote p': {
      color: '#777777',
    },
    '& blockquote p > code[class*="language-"]': {
      color: '#646464',
    },
    '& ul': {
      paddingLeft: theme.spacing(2),
    },
    '& :not(pre) > code': {
      padding: '.1em .3em',
      background: theme.code.main,
      color: '#000',
    },
    '& a': {
      textDecoration: 'none',
      '&:link,&:visited,& > code': {
        color: theme.link.main,
      },
      '&:hover,&:hover > code': {
        textDecoration: 'none',
        color: theme.link.light,
      },
    },
    '& .gatsby-highlight pre': {
      background: theme.code.main,  // Apply a better background color for code snippets
      // Remove ugly colors for characters like "=;:"
      '& .token.operator, .token.entity, .token.url, .language-css .token.string, .style .token.string': {
        color: 'inherit',
        background: 'inherit',
      },
    },
    '& .gatsby-highlight-code-line': {
      background: 'rgba(255,255,255,.7)',
      display: 'block',
    },
  },
  content_with_toc: {
    [theme.breakpoints.up('md')]: {
      maxWidth: 'calc(100% - 250px)',
    },
  }
})

const Content = ({
  children,
  page
}) => {
  const styles = useStyles(useTheme())
  return (
    <main css={styles.root}>
      {page && !page.home && (
        <h1 id={page.tableOfContents
          && page.tableOfContents.items
          && page.tableOfContents.items[0]
          && page.tableOfContents.items[0].url
          && page.tableOfContents.items[0].url.replace('#', '')}
          css={styles.title}>
          {page.title}
          </h1>
      )}
      <div css={styles.container}>
        {page.tableOfContents
          && page.tableOfContents.items
          && (
          <div css={styles.toc}>
            <Toc isMobile={page.isMobile} items={page.tableOfContents.items}/>
          </div>
        )}
        <div css={[styles.content, page.tableOfContents && styles.content_with_toc]}>
          {children}
        </div>
      </div>
      {page.edit_url && (
        <Button href={page.edit_url} css={styles.editButton}>
          <EditIcon />
          Edit on GitHub
        </Button>
      )}
    </main>
  )
}

Content.propTypes = {
  children: PropTypes.node.isRequired,
}

export default Content
