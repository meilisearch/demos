import Image from "next/image";
import Link from "next/link";
import React from "react";
import { BiShoppingBag } from "react-icons/bi";
import { SearchBox } from "react-instantsearch-dom";
import MeilisearchLogo from "../../public/meilisearch-logo.svg";
import styles from "../../styles/nav-bar.module.css";

export const NavBar = () => {
  return (
    <div className={styles.container}>
      <Link href="/">
        <a style={{ width: "125px" }}>
          <Image src={MeilisearchLogo} width="75px" alt="logo" />
        </a>
      </Link>
      <SearchBox />
      <button className={styles.btn}>
        <BiShoppingBag /> <span>0</span>
      </button>
    </div>
  );
};

export default NavBar;
