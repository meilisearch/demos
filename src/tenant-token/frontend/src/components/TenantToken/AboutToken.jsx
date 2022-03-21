import Button from 'components/Button/Button'
import Select from 'components/Select/Select'
import { useUser } from 'context/UserContext'
import React from 'react'

function AboutToken(props) {
  const {user, setUser, usersList} = useUser()
  const { switchToCreateMode } = props

  return (
    <>
      <h6 className="font-bold">Tenant Token</h6>
      <div className="text-sm">
        <br />
        <p>
          Tenant Tokens are JWTs that hold rules to be applied at search time to
          ensure that your end-users can only search within documents that
          belong to them.
        </p>
        <br />
        <p>
          In this demo, you can experience the search as if you were an end-user
          by selecting a pre-generated tenant token.
        </p>
        <br />
      </div>

      <div>
        View the search results as:{' '}
        <Select
          options={usersList.map((u) => ({
            value: JSON.stringify(u),
            label: u.name,
          }))}
          currentOption={{ label: user.name }}
          onChange={(data) => {
            setUser(JSON.parse(data.value))
          }}
          style={{ width: 216 }}
        />
      </div>
      <Button className="mt-7" onClick={switchToCreateMode}>
        <span className="text-pink-500 text-2xl">+</span>
        <span className="ml-2 text-slate-800 relative bottom-0.5">
          Create a tenant token
        </span>
      </Button>
    </>
  )
}

export default AboutToken
