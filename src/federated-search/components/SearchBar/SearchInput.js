import React, { useRef } from 'react'
import ResetButton from './ResetButton'
import styles from '../../styles/Input.module.css'

const Input = ({ type, value, clear, ...props }) => {
  const input = useRef(null)
  return (
    <>
      <input
        type={type}
        value={value}
        ref={input}
        className={`${styles.input} ${styles.searchInput}`}
        {...props}
      />
      <ResetButton
        aria-label="clear"
        onClick={() => {
          clear()
          input.current.focus()
        }}
        style={{ display: value ? 'block' : 'none' }}
      />
    </>
  )
}

export default Input
