import React, { createContext, useContext, useEffect, useState } from 'react'
import { MeiliSearch } from 'meilisearch'
import { MEILISEARCH_CONFIG } from 'config'

const SearchContext = createContext()

export function useSearch() {
  return useContext(SearchContext)
}
const PAGE_LIMIT = 20

export function MeiliSearchProvider({ children }) {
  const [result, setResult] = useState()
  const [searchText, setSearchText] = useState()
  const [apiKey, setApiKey] = useState(MEILISEARCH_CONFIG.MASTER_KEY)
  const [pagination, setPagination] = useState({
    limit: PAGE_LIMIT,
    current: 1,
    total: 0,
  })

  //possible values: null,true,false
  const [isAppointed, setIsAppointed] = useState(null)

  useEffect(() => {
    setPagination({ ...pagination, current: 1 })
    search({ current: 1 })

    // eslint-disable-next-line
  }, [searchText, apiKey, isAppointed])

  useEffect(() => {
    if (result) {
      setPagination((currentPagination) => ({
        ...currentPagination,
        total: result.nbHits || 0,
      }))
    }
  }, [result])

  async function search({
    limit = pagination.limit,
    current = pagination.current,
  }) {
    setResult()
    const client = new MeiliSearch({
      host: MEILISEARCH_CONFIG.HOST,
      apiKey: apiKey,
    })

    const offset = (current - 1) * pagination.limit

    const index = client.index(MEILISEARCH_CONFIG.INDEX)
    let filter = []
    if (isAppointed != null) {
      filter.push(`isDoctorAppointed=${isAppointed}`)
    }
    return index
      .search(searchText, {
        limit,
        offset,
        filter,
      })
      .then((results) => {
        setResult(results)
      })
      .catch((err) => {
        console.log('err', err)
        setResult({ hits: [] })
        alert(err.message)
      })
  }

  function updateCurrent(current) {
    if (current === pagination.current) return

    setPagination((currentPagination) => ({
      ...currentPagination,
      current,
    }))

    search({
      current,
    })
  }

  return (
    <SearchContext.Provider
      value={{
        data: result,
        search,
        searchText,
        setSearchText,
        setApiKey,
        pagination,
        updateCurrent,
        isAppointed,
        setIsAppointed,
      }}
    >
      {children}
    </SearchContext.Provider>
  )
}
