import React from 'react'
import Logo from 'components/common/Logo'
import SearchBox from 'components/SearchBox/SearchBox'

function Header() {
  return (
    <div
      className="flex align-middle items-center p-4 space-x-12 w-full bg-white sticky top-0 h-32 z-[3]"
      style={{ boxShadow: 'rgb(57 72 110 / 15%) 0px 0px 30px' }}
    >
      <div className="md:w-4/12 lg:w-3/12">
        <Logo />
      </div>
      <div className="md:w-6/12 lg:w-7/12">
        <SearchBox />
      </div>
    </div>
  )
}

export default Header
