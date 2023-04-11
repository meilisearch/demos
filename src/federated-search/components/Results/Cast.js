import React from 'react'

const Cast = ({ cast }) => {
  return (
    <>
      {cast.map((people, index) => (
        <p key={index}>
          {people.name} - {people.character}
        </p>
      ))}
    </>
  )
}

export default Cast
