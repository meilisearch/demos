import React from 'react'
import { Highlight } from 'react-instantsearch-hooks-web'
import styles from '../../styles/MovieCard.module.css'
import Image from 'next/image'

export const MovieCard = ({ hit }) => {
  return (
    <div>
        <Highlight
          attribute="title"
          highlightedTagName="mark"
          hit={hit}
          className={styles.title}
        />
        <Highlight
          attribute="overview"
          highlightedTagName="mark"
          hit={hit}
          className={styles.name}
        />
        <Highlight
          attribute="crew.name"
          highlightedTagName="mark"
          hit={hit}
          className={styles.name}
        />
        <Highlight
          attribute="cast.name"
          highlightedTagName="mark"
          hit={hit}
          className={styles.name}
        />
        <Highlight
          attribute="cast.character"
          highlightedTagName="mark"
          hit={hit}
          className={styles.name}
        />
    </div>
  )
}

export default MovieCard
