import React from 'react'
import { connectSearchBox } from 'react-instantsearch-dom'
import SearchMedium from 'components/icons/SearchMedium'

const SearchBox = ({ currentRefinement, isSearchStalled, refine }) => {
  return (
    <div className="relative w-full">
      <SearchMedium className="absolute top-1/2 left-4 -translate-y-2/4 max-w-[20px] text-custom-gray-2" />
      <input
        value={currentRefinement}
        onChange={(event) => refine(event.currentTarget.value)}
        placeholder="Search something"
        className=" h-12 w-full pl-12 pr-2 border-custom-gray-6 border rounded-lg shadow-custom transition-colors outline-none text-custom-gray-1 font-medium text-base placeholder:text-custom-gray-4 hover:border-custom-gray-5 focus:border-custom-gray-3"
      />
    </div>
  )
}

export default connectSearchBox(SearchBox)
