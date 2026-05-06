import React, { useState, useEffect } from 'react'
import { useInstantSearch } from 'react-instantsearch-hooks-web'
import FederatedHit from './FederatedHit'
import NoResults from './NoResults'
import styles from '../../styles/FederatedResults.module.css'

const FederatedResults = () => {
  const { indexUiState } = useInstantSearch()
  const query = indexUiState.query || ''
  const [hits, setHits] = useState([])
  const [ready, setReady] = useState(false)

  useEffect(() => {
    setReady(false)
    fetch(`${process.env.NEXT_PUBLIC_MEILISEARCH_HOST}/multi-search`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${process.env.NEXT_PUBLIC_MEILISEARCH_SEARCH_API_KEY}`,
      },
      body: JSON.stringify({
        queries: [
          {
            indexUid: 'moviesTmdb',
            q: query,
            attributesToHighlight: ['title', 'overview'],
            highlightPreTag: '<mark>',
            highlightPostTag: '</mark>',
          },
          {
            indexUid: 'actorsTmdb',
            q: query,
            attributesToHighlight: ['name', 'known_for'],
            attributesToCrop: ['biography:80'],
            highlightPreTag: '<mark>',
            highlightPostTag: '</mark>',
            cropMarker: '…',
          },
        ],
        federation: { limit: 20, offset: 0 },
      }),
    })
      .then(r => r.json())
      .then(data => {
        setHits(data.hits || [])
        setReady(true)
      })
      .catch(() => setReady(true))
  }, [query])

  if (!ready) return null
  if (hits.length === 0) return <NoResults />

  return (
    <ul className={styles.list}>
      {hits.map((hit, i) => (
        <li
          key={`${hit._federation.indexUid}-${hit.id ?? i}`}
          className={styles.item}
        >
          <FederatedHit hit={hit} />
        </li>
      ))}
    </ul>
  )
}

export default FederatedResults
