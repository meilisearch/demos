import React from 'react'
import Input from 'components/Input/Input'
import styled from 'styled-components'
import { useSearch } from '../../context/MeiliSearchContext'
import SearchMedium from 'components/icons/SearchMedium'
import Logo from 'components/common/Logo'
import Color from 'color'

const SearchIcon = styled(SearchMedium)`
  max-width: 20px;
  color: ${(p) => p.theme.colors.gray[2]};
`

const HeaderWrapper = styled.div`
  background-color: white;
  position: sticky;
  top: 0;
  height: 120px;
  box-shadow: 0px 0px 30px ${(p) => Color(p.theme.colors.gray[0]).alpha(0.15)};
  z-index: 3;
`

function Header() {
  const { searchText = '', setSearchText } = useSearch()

  return (
    <HeaderWrapper className="flex align-middle items-center p-4 space-x-12 w-full">
      <div className="md:w-4/12 lg:w-3/12">
        <Logo />
      </div>
      <div className="md:w-6/12 lg:w-7/12">
        <Input
          value={searchText}
          onChange={(e) => {
            setSearchText(e.target.value)
          }}
          clear={() => false}
          placeholder="Search something"
          icon={<SearchIcon />}
        />
      </div>
    </HeaderWrapper>
  )
}

export default Header
