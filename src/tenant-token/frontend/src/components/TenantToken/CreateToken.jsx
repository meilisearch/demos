import React, { useState } from 'react'
import { useUser } from 'context/UserContext'
import Button from 'components/Button/Button'
import { getTenantToken } from 'config'

function CreateToken({ switchToAboutMode }) {
  const [filterValue, setFilterValue] = useState('')
  const { addUser, usersList, setUser } = useUser()

  const handleTokenCreate = async () => {
    if (!filterValue) {
      return alert('Please input a name')
    }
    let existingUser = usersList.find(
      (u) => u.name.toLowerCase() === filterValue.toLowerCase()
    )

    if (existingUser) {
      setUser(existingUser)
    } else {
      let userName = filterValue

      const tenantToken = await getTenantToken(userName)

      addUser({ key: tenantToken, name: userName })
    }
    switchToAboutMode()
  }

  return (
    <div>
      <div className="flex items-center justify-between">
        <h6 className="font-bold">Creating a Tenant token</h6>
        <button className="text-xl" type="button" onClick={switchToAboutMode}>
          &times;
        </button>
      </div>
      <br />
      <p className="text-justify text-sm">
        Tenant tokens contains specific searchRules to be applied before search
        request parameters.
        <br />
        <br />
        Try replacing "Enter name" with "Kevin" in the snippet below, and click
        on the button to create a dedicated tenant token for Kevin.
      </p>
      <div className="mt-8 border-2 border-slate-300 border-l-0	border-r-0 py-8 text-sm">
        <div>
          <code>
            <div>{'{'}</div>
            <div className="ml-4">{'“searchRules”: {'}</div>
            <div className="ml-8">
              “filter”: “user =
              <input
                type="text"
                className="ml-1 w-24 modal-filter-input create-token--input"
                value={filterValue}
                placeholder="Enter name"
                onChange={(e) => setFilterValue(e.target.value)}
              />
              ”
            </div>
            <div className="ml-4">{'}'}</div>
            <div>{'}'}</div>
          </code>
        </div>
      </div>
      <div className="text-center my-5">
        <Button className="mx-auto" onClick={handleTokenCreate}>
          Create token
        </Button>
      </div>
    </div>
  )
}

export default CreateToken
