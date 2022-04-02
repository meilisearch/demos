import React from 'react'
import { Button as ReakitButton } from 'reakit/Button'
import Typography from 'components/common/Typography'

const Button = ({ children, ...props }) => {
  const baseClassNames = `py-0 px-6 min-w-[128px] bg-white border border-solid border-custom-gray-6  shadow-custom text-custom-gray-1 h-12 rounded-lg flex justify-center items-center outline-none 
  hover:border-primary active::border-primary focus::border-primary hover:shadow-none transition`

  if (props.className) props.className += ' ' + baseClassNames
  else props.className = baseClassNames

  return (
    <ReakitButton {...props}>
      <Typography>{children}</Typography>
    </ReakitButton>
  )
}

export default Button
