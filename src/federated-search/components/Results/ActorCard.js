import React from 'react'
import { Highlight } from 'react-instantsearch-hooks-web'
import Image from 'next/image'

export const ActorCard = ({ hit }) => {
  return (
    <div>
        {/* <Image src={hit.profile_path} /> */}
        <Highlight
          attribute="name"
          highlightedTagName="mark"
          hit={hit}

        />
    </div>
  )
}

export default ActorCard
