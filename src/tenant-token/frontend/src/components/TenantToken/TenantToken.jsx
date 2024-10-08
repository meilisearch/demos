import React, { useState } from 'react'
import AboutToken from './AboutToken'
import CreateToken from './CreateToken'

function TenantToken() {
  const [show, setShow] = useState(true)
  return (
    <div className="mt-8 pt-6 border-t border-gray-200">
      {show ? (
        <AboutToken switchToCreateMode={() => setShow(false)} />
      ) : (
        <CreateToken switchToAboutMode={() => setShow(true)} />
      )}
    </div>
  )
}

export default TenantToken
