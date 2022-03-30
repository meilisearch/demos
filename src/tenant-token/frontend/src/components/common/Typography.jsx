import React from 'react'

const Typography = ({ children, ...props }) => {
  if (props.className) props.className += ' text-base font-medium'
  else props.className = 'text-base font-medium'
  return <span {...props}>{children}</span>
}

export default Typography
