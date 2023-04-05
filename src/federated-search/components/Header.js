import React from 'react'
import Image from 'next/image'
import MeilisearchLogo from '../public/meili_logo.svg'
import MeilisearchLogoMark from '../public/meilisearch-logomark.svg'
import SearchBar from './SearchBar'
import styles from '../styles/Header.module.css'

const Header = () => {
    return (
        <div className={styles.header}>
            <div className={`${styles.headerContent} centralWidth`}>
                <a
                    href="https://www.meilisearch.com"
                    target="_blank"
                    className={styles.logoLink}
                    rel="noreferrer"
                >
                    <Image
                    className={styles.logo}
                    src={MeilisearchLogo}
                    alt="Meilisearch logo"
                    />
                    <Image
                    className={styles.logomark}
                    src={MeilisearchLogoMark}
                    alt="Meilisearch logomark"
                    />
                </a>
                <SearchBar />
            </div>
        </div>
    )
}

export default Header
