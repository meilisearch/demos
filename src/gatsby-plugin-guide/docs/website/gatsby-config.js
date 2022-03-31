const contentPath = `${__dirname}/../content`
const packagesPath = `${__dirname}/../../packages`
const removeMd = require('remove-markdown');

module.exports = {
  // Seems it is not used, leave commented until published
  // pathPrefix: `/node-nikita`,
  siteMetadata: {
    title: 'Nikita',
    siteUrl: `https://nikita.js.org`,
    description:
      'Nikita - Automation of system deployments for applications and infrastructures.',
    keywords:
      'automation, deployment, node.js, devops, systems, applications, infrastructures',
    github: {
      url: 'https://github.com/adaltas/node-nikita',
      title: 'Nikita GitHub Repository',
    },
    issues: {
      url: 'https://github.com/adaltas/node-nikita/issues',
      title: 'Report an issue',
    },
    footer: [
      {
        title: 'Navigate',
        links: [
          {
            label: 'Project',
            url: '/project/',
          },
          {
            label: 'API',
            url: '/current/api/',
          },
          {
            label: 'Guide',
            url: '/current/guide/',
          },
          {
            label: 'Actions',
            url: '/current/actions/',
          },
        ],
        xs: 6,
        sm: 3,
      },
      {
        title: 'Contribute',
        links: [
          {
            label: 'GitHub',
            url: 'https://github.com/adaltas/node-nikita',
          },
          {
            label: 'Issue Tracker',
            url: 'https://github.com/adaltas/node-nikita/issues',
          },
          {
            label: 'License',
            url: '/project/license/',
          },
        ],
        xs: 6,
        sm: 3,
      },
      {
        title: 'About',
        content:
          'Nikita is an open source project hosted on <a href="https://github.com/adaltas/node-nikita/" target="_blank" rel="noopener">GitHub</a> and developed by <a href="http://www.adaltas.com" target="_blank" rel="noopener">Adaltas</a>.',
        xs: 12,
        sm: 6,
      },
    ],
  },
  plugins: [
    {
      resolve: 'nikita-pages',
      options: {
        include: contentPath,
        doNotVersion: ['./project'],
      },
    },
    {
      resolve: 'nikita-packages',
      options: {
        include: packagesPath,
        ignore: [`./nikita`],
      },
    },
    {
      resolve: 'nikita-actions',
      options: {
        include: packagesPath,
      },
    },
    {
      resolve: `gatsby-plugin-material-ui`,
      options: {
        stylesProvider: {
          injectFirst: true,
        },
        disableAutoprefixing: true, // fixes issue https://github.com/hupe1980/gatsby-plugin-material-ui/issues/65, even after updating "gatsby-plugin-material-ui": "^3.0.0"
      },
    },
    `gatsby-plugin-react-helmet`,
    {
      resolve: `gatsby-plugin-emotion`,
    },
    {
      resolve: `gatsby-source-filesystem`,
      options: {
        path: contentPath,
        name: 'pages',
      },
    },
    {
      resolve: `gatsby-source-filesystem`,
      options: {
        path: packagesPath,
        name: 'actions',
        ignore: ['**/assets', '**/env', '**/lib', '**/test'],
      },
    },
    {
      resolve: 'gatsby-plugin-mdx',
      options: {
        extensions: [`.mdx`, `.md`],
        gatsbyRemarkPlugins: [
          {
            resolve: 'gatsby-remark-title-to-frontmatter',
          },
          {
            resolve: 'gatsby-remark-autolink-headers',
            // Option `offsetY` doesn't work with gatsby-plugin-mdx,
            // see https://github.com/gatsbyjs/gatsby/issues/19859#issuecomment-634061592
            // options: {
            //   offsetY: '64', // <600: 48; >600:64
            // },
          },
          {
            resolve: `gatsby-remark-prismjs`,
            options: {
              classPrefix: 'language-',
              inlineCodeMarker: null,
              aliases: {},
              showLineNumbers: false,
              inlineCodeMarker: '±',
              prompt: {
                user: 'whoami',
                host: 'localhost',
                global: false,
              },
            },
          },
        ],
        // Fixes CSS of anchor icon
        // see https://github.com/gatsbyjs/gatsby/issues/20441
        plugins: ['gatsby-remark-autolink-headers'],
      },
    },
    {
      resolve: 'gatsby-plugin-meilisearch',
      options: {
        host: 'http://localhost:7700',
        apiKey: 'masterKey',
        skipIndexing: false,
        indexes: [
          {
            indexUid: 'nikita-api-docs',
            settings: {
              searchableAttributes: ['lvl0', 'lvl1', 'lvl2', 'content'],
            },
            transformer: (data) =>
              data.allMdx.edges
                .filter(
                  ({ node }) =>
                    node.slug.search('guide') !== -1 ||
                    node.slug.search('project') !== -1 ||
                    node.slug.search('api') !== -1
                )
                .map(({ node }) => {
                  // Have to update for versioning
                  const currentVersion =
                    node.slug.substring(0, 8).search('project') === -1
                      ? '/current'
                      : ''

                  return {
                    id: node.id,
                    lvl0:
                      node.frontmatter.navtitle || node.frontmatter.title || '',
                    lvl1:
                      node.frontmatter.title || node.frontmatter.navtitle || '',
                    lvl2: node.frontmatter.description || '',
                    content: removeMd(node.rawBody),
                    url: `${currentVersion}/${node.slug}`,
                  }
                }),
            query: `query MyQuery {
              allMdx {
                edges {
                  node {
                    frontmatter {
                      title
                      navtitle
                      description
                    }
                    slug
                    rawBody
                    id
                  }
                }
              }
            }`,
          },
        ],
      },
    },
    {
      resolve: `gatsby-plugin-catch-links`,
    },
    {
      resolve: `gatsby-plugin-google-analytics`,
      options: {
        trackingId: 'UA-1322093-4',
      },
    },
    {
      resolve: `gatsby-plugin-manifest`,
      options: {
        name: 'Nikita',
        short_name: 'Nikita',
        start_url: '/',
        background_color: '#ffffff',
        theme_color: '#105859',
        display: 'minimal-ui',
        icon: 'src/images/logo.png', // This path is relative to the root of the site.
      },
    },
    {
      resolve: `gatsby-plugin-offline`,
    },
    {
      resolve: `gatsby-plugin-sitemap`,
    },
    {
      resolve: 'gatsby-plugin-robots-txt',
      options: {
        host: 'https://nikita.js.org',
        sitemap: 'https://nikita.js.org/sitemap.xml',
        policy: [{ userAgent: '*', allow: '/' }],
      },
    },
  ],
}
