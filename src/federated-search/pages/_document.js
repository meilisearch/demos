import { Html, Head, Main, NextScript } from 'next/document'
import Script from 'next/script'

export default function Document() {
  return (
    <Html lang="en">
      <Head>
        {/* GTag Consent Default */}
        <Script
          id="gtag-consent"
          strategy="beforeInteractive"
          dangerouslySetInnerHTML={{
            __html: `
                  window.dataLayer = window.dataLayer || [];
                  function gtag(){dataLayer.push(arguments);}
                  gtag('consent', 'default', {
                    'ad_storage': 'denied',
                    'ad_user_data': 'denied',
                    'ad_personalization': 'denied',
                    'analytics_storage': 'denied'
                  });
                `,
          }}
        />
        {/* End GTag Consent Default */}
        {/* Google Tag Manager */}
        {/* eslint-disable-next-line @next/next/next-script-for-ga */}
        <script
          dangerouslySetInnerHTML={{
            __html: `(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start':
            new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0],
            j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src=
            'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f);
            })(window,document,'script','dataLayer','GTM-TNSCGVBH');`,
          }}
        />
        {/* End Google Tag Manager */}
        {/* CookieYes */}
        <Script
          id="cookieyes"
          src="https://cdn-cookieyes.com/client_data/0ec5a8e516eccaa724a461f6/script.js"
          strategy="afterInteractive"
        />
        {/* End CookieYes */}
        <link
          rel="stylesheet"
          href="https://cdn.jsdelivr.net/npm/instantsearch.css@7/themes/algolia-min.css"
        />
        <script
          src="https://thrilling-thirtyeight.meilisearch.com/script.js"
          data-site="QNBPJXIV"
          defer
        />
      </Head>
      <body>
        {/* Google Tag Manager (noscript) */}
        <noscript
          dangerouslySetInnerHTML={{
            __html: `<iframe src="https://www.googletagmanager.com/ns.html?id=GTM-TNSCGVBH"
            height="0" width="0" style="display:none;visibility:hidden"></iframe>`,
          }}
        />
        {/* End Google Tag Manager (noscript) */}
        <Main />
        <NextScript />
      </body>
    </Html>
  )
}
