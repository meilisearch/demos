import Exclamation from 'components/icons/Exclamation'
import React from 'react'
export default function Toast({ user }) {
  return (
    <div
      className="bg-pink-50 border border-pink-300 rounded text-pink-500  px-4 py-2 ml-6 w-5/6"
      role="alert"
    >
      <Exclamation />
      <span></span>
      <strong className="font-semibold">{user} </strong>
      <span>
        will see those search results by using its dedicated tenant token
      </span>
    </div>
  )
}
