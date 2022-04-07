import React from 'react'
import { useMenuState, Menu, MenuItem, MenuButton } from 'reakit/Menu'
import Typography from 'components/common/Typography'
import ArrowDown from 'components/icons/ArrowDown'

const TextToDisplay = ({ option, currentOption }) => (
  <>
    <Typography
      className={`mr-2 ${
        currentOption ? 'text-custom-gray-1' : 'text-custom-gray-2'
      }`}
    >
      {option ? option.label : 'Choose'}
    </Typography>{' '}
  </>
)

const Select = ({ options, currentOption, onChange, ...props }) => {
  const menu = useMenuState()
  return (
    <>
      <MenuButton
        className="relative m-0 py-3 pr-8 pl-3 h-12 bg-white flex items-center min-w-[128px] border-custom-gray-6 border border-solid rounded-lg shadow-custom outline-none text-custom-gray-1 font-medium text-base cursor-pointer hover:border-primary focus:border-primary"
        style={{ width: 216 }}
        {...menu}
        {...props}
      >
        <TextToDisplay option={currentOption} currentOption />
        <ArrowDown
          className={`
          absolute right-0 w-2 top-1/2 mr-4 shrink-0 text-primary transition-transform duration-300${
            menu.visible ? ' rotate-180' : ''
          }`}
        />
      </MenuButton>
      <Menu
        className="flex flex-col min-w-[218px] outline-none border border-custom-gray-6 rounded-lg shadow-custom max-h-44 overflow-auto z-10"
        {...menu}
        aria-label="options"
      >
        {options?.length &&
          options.map((option, index) => (
            <MenuItem
              className={`bg-white h-10 bottom-0 outline-none transition-colors py-2 px-5 text-left text-custom-gray-2 hover:bg-custom-gray-6 focus:bg-custom-gray-6`}
              {...menu}
              key={index}
              id={option.label}
              type="button"
              onClick={() => {
                onChange(option)
                menu.hide()
              }}
            >
              <Typography
                className={`${
                  currentOption?.label === option.label ? 'font-semibold' : ''
                }`}
              >
                {option.label}
              </Typography>
            </MenuItem>
          ))}
      </Menu>
    </>
  )
}

export default Select