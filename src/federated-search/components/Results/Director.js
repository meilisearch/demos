import React from 'react'
import styles from '../../styles/Director.module.css'

const Director = ({ crew }) => {
  return (
    <>
      {crew.map((people, index) =>
        people.job === 'Director' ? (
          <div key={index}>
            <p className={styles.directorName}>{people.name}</p>
          </div>
        ) : (
          ''
        )
      )}
    </>
  )
}

export default Director
