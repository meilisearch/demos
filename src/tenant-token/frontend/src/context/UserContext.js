import { MEILISEARCH_CONFIG } from 'config'
import axios from 'axios'
import React, { createContext, useContext, useEffect, useState } from 'react'
import { useSearch } from './MeiliSearchContext'

const DEFAULT_USERS = [
  {
    name: 'Admin',
    key: MEILISEARCH_CONFIG.MASTER_KEY,
  },
]

const UserContext = createContext()

export function useUser() {
  return useContext(UserContext)
}

export function UserProvider({ children }) {
  const [user, setUser] = useState(DEFAULT_USERS[0])
  const [usersList, setUsersList] = useState(DEFAULT_USERS)

  const { setApiKey, setSearchText } = useSearch()

  useEffect(() => {
    const fetchIntialTokens = async () => {
      const url = `${MEILISEARCH_CONFIG.API_HOST}/create-tenant-token`

      const { data: johnToken } = await axios.get(url + '?value=John')
      setUsersList((list) => [...list, { key: johnToken.token, name: 'John' }])

      const { data: ziaToken } = await axios.get(url + '?value=Zia')
      setUsersList((list) => [...list, { key: ziaToken.token, name: 'Zia' }])
    }

    fetchIntialTokens().finally(() => {
      setUsersList((list) => [
        ...list,
        ...JSON.parse(localStorage.getItem('users') || '[]'),
      ])
    })
  }, [])

  useEffect(() => {
    if (user) {
      setApiKey(user.key)
      setSearchText('')
    }

    // eslint-disable-next-line
  }, [user])

  function addUser(data) {
    setUsersList((list) => [...list, data])
    setUser(data)

    //saving in local storage for future ref
    let list = JSON.parse(localStorage.getItem('users')) || []
    localStorage.setItem('users', JSON.stringify([...list, data]))
  }

  return (
    <UserContext.Provider value={{ user, setUser, usersList, addUser }}>
      {children}
    </UserContext.Provider>
  )
}
