import React from 'react'
import SearchInput from './SearchInput'
import { useSearchBox } from 'react-instantsearch-hooks-web';
import styles from '../../styles/SearchBar.module.css'

const SearchBar = (props) => {
  const { query, refine } = useSearchBox(props);
  const [value, setValue] = React.useState(query)
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
}

export default SearchBar
