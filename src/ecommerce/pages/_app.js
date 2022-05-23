import Head from "next/head";
import Layout from "../components/layout/Layout";
import "../styles/globals.css";
import "../styles/searchBoxAIS.css";

function MyApp({ Component, pageProps }) {
  return (
    <>
      <Head>
        <title>MeiliSearch E-Commerce</title>
        <meta
          name="description"
          content="Meilisearch Ecommerce demo for scalability and extensibility"
        />
        <link rel="icon" href="/favicon.ico" />
      </Head>
      <Layout>
        <Component {...pageProps} />
      </Layout>
    </>
  );
}

export default MyApp;
