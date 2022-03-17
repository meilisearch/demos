import React, { useState } from 'react'
import AboutToken from './AboutToken'
import CreateToken from './CreateToken'
import styled from "styled-components";

const Wrapper = styled.div`
margin-top:2rem;
padding-top:1.5rem;
border-top:1px solid #E9E5ED
`

function TenantToken() {
  const [show, setShow] = useState(true)

  return (
    <Wrapper>
      {show ? (
        <AboutToken switchToCreateMode={() => setShow(false)} />
      ) : (
        <CreateToken switchToAboutMode={() => setShow(true)} />
      )}
    </Wrapper>
  )
}

export default TenantToken
