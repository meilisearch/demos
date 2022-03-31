
import React, {Fragment, useEffect, useState} from 'react'
// Material UI
import { useTheme } from '@material-ui/core/styles';
import { Link } from 'gatsby'

const useStyles = theme => ({
  head: {
    color: '#777777',
    fontSize: theme.typography.fontSize,
    fontWeight: 500,
    textTransform: 'uppercase',
    marginBottom: theme.spacing(3),
  },
  activeHash: {
    color: `${theme.link.light} !important`,
  },
  list: {
    paddingLeft: 0,
    '& li': {
      listStyle: 'none',
      marginBottom: theme.spacing(1),
    },
    '& a': {
      textDecoration: 'none',
      '&:link,&:visited': {
        color: '#777777',
      },
      '&:hover': {
        color: theme.link.light,
      },
    },
  },
  childList: {
    marginTop: theme.spacing(1),
  }
})

const Toc = ({
  isMobile,
  items,
}) => {
  // Flatten TOC
  const flattenToc = items => items.map(item => {
    const arr = [{
      'url': item.url,
      'title': item.title
    }]
    if(item.items)
      return arr.concat(flattenToc(item.items))
    else
      return arr
  }).flat()
  const toc = flattenToc(items)
  // Highlight TOC on scroll
  const [activeHash, setActiveHash] = useState('')
  useEffect(() => {
    let observer = new IntersectionObserver(
      entries => {
        entries.forEach(entry => {
          if (entry.isIntersecting)
            setActiveHash(`#${entry.target.id}`)
        })
      },
      {
        rootMargin: '0% 0% -80% 0%', // Provides the best behavior
        threshold: 1.0
      }
    )
    toc.forEach((item) => {
      observer.observe(document.getElementById(item.url.replace('#', '')))
    })
    return () => toc.forEach((item) => {
      const el = document.getElementById(item.url.replace('#', ''))
      // Not stable without checking on development mode,
      // probably because of empty cache of a page.
      if(el) observer.unobserve(el)
    })
  })
  // Render TOC
  const styles = useStyles(useTheme())
  const renderToc = (items) => items.map((item) => (
    <Fragment key={item.url} >
      <li>
        <Link
          css={!isMobile && item.url === activeHash && styles.activeHash}
          to={item.url}>
          {item.title}
        </Link>
      </li>
      {item.items && renderToc(item.items)}
    </Fragment>
  ))
  return (
    <nav>
      <div css={styles.head}>Table of Contents</div>
      <ul css={styles.list}>
        {renderToc(items)}
      </ul>
    </nav>
  )
}

export default Toc
