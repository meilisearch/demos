import React, { useContext } from "react";
import NavBar from "./NavBar";
import Blur from "./Blur";
import CartView from "../cart-view/CartView";
import { InstantSearch } from "react-instantsearch-dom";
import DisplayContext from "../../context/display-context";
import styles from "../../styles/layout.module.css";
import { instantMeiliSearch } from "@meilisearch/instant-meilisearch";

const searchClient = instantMeiliSearch(
  process.env.NEXT_MEILI_HOST_NAME,
  process.env.NEXT_MEILI_API_KEY
);

const Layout = ({ children }) => {
  const { cartView } = useContext(DisplayContext);

  return (
    <InstantSearch indexName="products" searchClient={searchClient}>
      <div className={cartView ? styles.noscroll : null}>
        <CartView />
        <Blur />
        <NavBar />
        <main>{children}</main>
      </div>
    </InstantSearch>
  );
};

export default Layout;
