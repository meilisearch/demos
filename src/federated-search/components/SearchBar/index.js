import React from 'react'
import SearchInput from './SearchInput'
import styles from '../../styles/SearchBar.module.css'

const SearchBar = ({ value, onChange }) => {
  return (
    <div className={styles.searchForm}>
      <SearchInput
        type="search"
        value={value}
        onChange={e => onChange(e.target.value)}
        clear={() => onChange('')}
        placeholder="Search something"
      />
    </div>
  )
}

export default SearchBar
