import React from 'react'
import SearchInput from './SearchInput'
import { connectSearchBox } from 'react-instantsearch-dom'
import styles from '../styles/SearchBar.module.css'

const SearchBar = connectSearchBox(({ currentRefinement, refine }) => {
  const [value, setValue] = React.useState(currentRefinement)
  React.useEffect(() => {
    refine(value)
  }, [value])
  return (
    <div className={styles.searchForm}>
      <SearchInput
        type="search"
        value={value}
        onChange={e => setValue(e.target.value)}
        clear={() => setValue('')}
        placeholder="Search something"
      />
    </div>
  )
})

export default SearchBar
