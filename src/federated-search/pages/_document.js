import { Html, Head, Main, NextScript } from 'next/document'

export default function Document() {
  return (
    <Html lang="en">
      <Head>
        <link
          rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/instantsearch.css@7/themes/algolia-min.css"
        />
        <title>Meilisearch demo: federated search</title>
        <script src="https://thrilling-thirtyeight.meilisearch.com/script.js" data-site="QNBPJXIV" defer></script>
      </Head>
      <body>
        <Main />
        <NextScript />
      </body>
    </Html>
  )
}
