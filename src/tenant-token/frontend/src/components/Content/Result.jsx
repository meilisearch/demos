import React from 'react'
import { useSearch } from 'context/MeiliSearchContext'
import { useUser } from 'context/UserContext'
import Loader from 'components/common/Loader'
import Card from 'components/Card/Card'
import Pagination from 'components/Pagination/Pagination'
import Toast from 'components/Toast/Toast'

function Result() {
  const { data } = useSearch()
  const { user } = useUser()
  return (
    <>
      {user && user.name !== 'Admin' && <Toast user={user.name} />}
      <p className="my-3 text-gray-500 ml-2">Search Results:</p>
      {data ? (
        data.hits.length > 0 ? (
          <div>
            <div className="flex flex-wrap">
              {data.hits.map((i, index) => (
                <Card data={i} key={`data-${i.id}-${index}`} />
              ))}
              <Pagination />
            </div>
          </div>
        ) : (
          <p className="text-gray-400 text-center">
            Data for the user does not exist
          </p>
        )
      ) : (
        <Loader />
      )}
    </>
  )
}

export default Result
