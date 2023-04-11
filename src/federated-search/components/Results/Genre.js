import React from 'react'
import styles from '../../styles/Genre.module.css'

const Genre = ({genres}) => {
    return (
      <>
      {genres.map((genre, index) => (
        <span key={index} className={styles.genreTag}>
          {genre}
        </span>
      ))}
      </>
    )
  }

export default Genre
