// React
import React, { Fragment } from 'react'
// Gatsby
import { graphql, StaticQuery, Link } from 'gatsby'
// Material UI
import { useTheme, makeStyles } from '@material-ui/core/styles'
import Accordion from '@material-ui/core/Accordion';
import AccordionSummary from '@material-ui/core/AccordionSummary';
import AccordionDetails from '@material-ui/core/AccordionDetails';
import ExpandMoreIcon from '@material-ui/icons/ExpandMore';
import useMediaQuery from '@material-ui/core/useMediaQuery'
// Local
import Layout from '../../components/Layout'


const useClasses = makeStyles(() => ({
  accordionRoot: {
    boxShadow: 'none',
    backgroundColor: 'inherit',
    '&:not(:last-child)': {
      borderBottom: 0,
    },
    '&:before': {
      display: 'none',
    },
  },
  accordionExpanded: {
    marginTop: '0 !important',
  },
  accordionSummaryRoot: {
    padding: 0,
  },
  accordionDetailsRoot: {
    padding: 0,
    display: 'inherit'
  }
}))
const useStyles = theme => ({
  package: {
    marginTop: theme.spacing(2),
    paddingBottom: theme.spacing(2),
    '& > a': {
      fontSize: '1.2rem',
      // fontWeight: 'bold',
    },
    borderBottom: '1px solid #0000001f',
  },
  actions: {
    columnCount: 3,
    '& a': {
      display: 'block'
    },
    [theme.breakpoints.down('sm')]: {
      columnCount: 2,
    },
    [theme.breakpoints.down('xs')]: {
      columnCount: 1,
    },
  }
})

const Page = ({
  data,
  path
}) => {
  const theme = useTheme()
  const styles = useStyles(theme)
  const classes = useClasses()
  const isMobile = useMediaQuery(theme.breakpoints.down('xs'), {noSsr: true})
  const {packages} = data
  return (
    <Layout page={{
      keywords: 'node.js, nikita, packages',
      title: 'Browse all Nikita actions',
      description: 'Nikita actions are developed and distributed in several packages.',
      slug: path,
      version: 'current'
    }}>
      {packages.nodes && (
        <>
          <p>Actions are developed and distributed in several packages:</p>
          <ul>
            {packages.nodes
              .map( item => (
                <li key={item.slug} css={styles.package}>
                  <Link to={item.slug}>{item.name}</Link>
                  <br/>
                  {item.description}
                  <Accordion
                    square
                    defaultExpanded={isMobile ? false : true}
                    classes={{
                      root: classes.accordionRoot,
                      expanded: classes.accordionExpanded
                    }}>
                    <AccordionSummary
                      classes={{
                        root: classes.accordionSummaryRoot,
                      }}
                      expandIcon={<ExpandMoreIcon />}>
                      Actions
                    </AccordionSummary>
                    <AccordionDetails
                      classes={{
                        root: classes.accordionDetailsRoot,
                      }}>
                      <div css={styles.actions}>
                        {item.actions
                          .sort((p1, p2) => p1.slug > p2.slug)
                          .map( action => (
                            <Link key={action.slug} to={action.slug}>{action.name}</Link>
                          ))
                        }
                      </div>
                    </AccordionDetails>
                  </Accordion>
                </li>
              ))
            }
          </ul>
        </>
      )}
    </Layout>
  )
}

const WrappedPage = props => (
  <StaticQuery
    query={graphql`
      query ActionsQuery {
        packages: allNikitaPackage(
          sort: {fields: slug, order: ASC}
        ) {
          nodes {
            name
            slug
            description
            actions {
              name
              slug
            }
          }
        }
      }
    `}
    render={data => <Page data={data} {...props} />}
  />
)


export default WrappedPage
