import React from 'react'
import { useMenuState, Menu, MenuItem, MenuButton } from 'reakit/Menu'
import Typography from 'components/common/Typography'
import ArrowDown from 'components/icons/ArrowDown'

const TextToDisplay = ({ option, currentOption }) => (
  <>
    <Typography
      className={`mr-2 ${currentOption ? 'text-[#39486E]' : 'text-[#606C8B]'}`}
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
        className="relative m-0 py-3 pr-8 pl-3 h-12 bg-white flex items-center min-w-[128px] border-[#edeef7] border border-solid rounded-lg shadow-custom outline-none text-[#39486e] font-medium text-base cursor-pointer hover:border-[#e41359] focus:border-[#e41359]"
        style={{ width: 216 }}
        {...menu}
        {...props}
      >
        <TextToDisplay option={currentOption} currentOption />
        <ArrowDown
          className={`
          absolute right-0 w-2 top-1/2 mr-4 shrink-0 text-[#e41359] transition-transform duration-300${
            menu.visible ? ' rotate-180' : ''
          }`}
        />
      </MenuButton>
      <Menu
        className="flex flex-col min-w-[218px] outline-none border border-[#edeef7] rounded-lg shadow-custom max-h-44 overflow-auto z-10"
        {...menu}
        aria-label="options"
      >
        {options?.length &&
          options.map((option, index) => (
            <MenuItem
              className={`bg-white h-10 bottom-0 outline-none transition-colors py-2 px-5 text-left text-[#606c8b] hover:bg-[#edeef7] focus:bg-[#edeef7]`}
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
