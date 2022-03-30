import React from 'react'
import { connectSearchBox } from 'react-instantsearch-dom'
import SearchMedium from 'components/icons/SearchMedium'

const SearchBox = ({ currentRefinement, isSearchStalled, refine }) => {
  return (
    <div className="relative w-full">
      <SearchMedium className="absolute top-1/2 left-4 -translate-y-2/4 max-w-[20px] text-[#606C8B]" />
      <input
        value={currentRefinement}
        onChange={(event) => refine(event.currentTarget.value)}
        placeholder="Search something"
        className=" h-12 w-full pl-12 pr-2 border-[#edeef7] border rounded-lg shadow-custom transition-colors outline-none text-[#39486E] font-medium text-base placeholder:text-[#BBC1CF] hover:border-[#CBCFDB] focus:border-[#A7AEC0]"
      />
    </div>
  )
}

export default connectSearchBox(SearchBox)
