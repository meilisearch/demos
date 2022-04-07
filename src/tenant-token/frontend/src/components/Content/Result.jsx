import React from 'react'
import { useUser } from 'context/UserContext'
import Card from 'components/Card/Card'
import Pagination from 'components/Pagination/Pagination'
import Toast from 'components/Toast/Toast'
import { connectHits } from 'react-instantsearch-dom'

function Result() {
  const { user } = useUser()
  return (
    <>
      {user && user.name !== 'Admin' && <Toast user={user.name} />}
      <p className="my-3 text-gray-500 ml-2">Search Results:</p>
      <Hits />
    </>
  )
}

const Hits = connectHits(({ hits }) => {
  return (
    <>
      {hits.length > 0 ? (
        <div className="flex flex-wrap">
          {hits.map((i, index) => (
            <Card data={i} key={`data-${i.id}-${index}`} />
          ))}
          <Pagination />
        </div>
      ) : (
        <p className="text-gray-400 text-center">
          Data for the user does not exist
        </p>
      )}
    </>
  )
})

export default Result
