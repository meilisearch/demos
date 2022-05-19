import Head from "next/head";
import { StoreProvider } from "../context/store-context";
import { DisplayProvider } from "../context/display-context";
import "../styles/globals.css";
import "../styles/searchBoxAIS.css";
import Layout from "../components/layout/Layout";

function MyApp({ Component, pageProps }) {
  return (
    <StoreProvider>
      <DisplayProvider>
        <Head>
          <title>E-Commerce MeiliSearch with Medusa</title>
          <meta
            name="description"
            content="Integrating Meilisearch in Medusa"
          />
          <link rel="icon" href="/favicon.ico" />
        </Head>
        <Layout>
          <Component {...pageProps} />
        </Layout>
      </DisplayProvider>
    </StoreProvider>
  );
}

export default MyApp;
