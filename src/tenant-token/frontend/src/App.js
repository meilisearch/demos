import Header from 'components/Header/Header'
import Content from 'components/Content/Content'
import { MeiliSearchProvider } from 'context/MeiliSearchContext'
import { UserProvider } from 'context/UserContext'
import styled from 'styled-components'

const Wrapper = styled.div`
  background-color: ${(p) => p.theme.colors.gray[11]};
  min-height: 100vh;
`

function App() {
  return (
    <Wrapper>
      <MeiliSearchProvider>
        <UserProvider>
          <Header />
          <Content />
        </UserProvider>
      </MeiliSearchProvider>
    </Wrapper>
  )
}

export default App
