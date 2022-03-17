import React from 'react'
import LogoSvg from 'assets/logo.svg'
import MeilisearchSvg from 'assets/meilisearch.svg'

function Logo() {
  return (
    <div className="flex space-x-3">
      <img src={LogoSvg} alt="logo" />
      <img className="hidden sm:block" src={MeilisearchSvg} alt="meilisearch" />
    </div>
  )
}

export default Logo
