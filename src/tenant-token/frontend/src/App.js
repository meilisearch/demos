import Header from 'components/Header/Header'
import Content from 'components/Content/Content'
import { InstantSearch } from 'react-instantsearch-dom'
import { instantMeiliSearch } from '@meilisearch/instant-meilisearch'
import { MEILISEARCH_CONFIG } from 'config'
import { useUser } from 'context/UserContext'

function App() {
  const { user } = useUser()
  return (
    <div className="min-h-screen bg-custom-gray-7">
      <InstantSearch
        indexName={MEILISEARCH_CONFIG.INDEX}
        searchClient={instantMeiliSearch(MEILISEARCH_CONFIG.HOST, user.key, { finitePagination : true } )}
      >
        <Header />
        <Content />
      </InstantSearch>
    </div>
  )
}

export default App
