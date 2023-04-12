import React from 'react'
import styles from '../../styles/Director.module.css'

const Director = ({ crew }) => {
  if (crew)
  return (
    <>
      {crew.map((people, index) =>
        people.job === 'Director' ? (
            <p key={index} className={styles.directorName}>{people.name}</p>
        ) : (
          ''
        )
      )}
    </>
  )
}

export default Director
