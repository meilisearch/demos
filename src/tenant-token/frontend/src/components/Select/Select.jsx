import React from 'react'
import styled, { css } from 'styled-components'
import Color from 'color'
import { useMenuState, Menu, MenuItem, MenuButton } from 'reakit/Menu'

import Typography from 'components/common/Typography'
import ArrowDown from 'components/icons/ArrowDown'

const Arrow = styled(ArrowDown)`
  position: absolute;
  right: 0;
  top: calc(50% - 3px);
  transition: transform 300ms;
  width: 9px;
`

const SelectIndexesButton = styled(MenuButton)`
  position: relative;
  margin: 0px;
  padding: 12px 32px 12px 12px;
  height: 48px;
  background-color: white;
  display: flex;
  align-items: center;
  min-width: 218px;
  border-color: ${(p) => p.theme.colors.gray[10]};
  border-width: 1px;
  border-style: solid;
  border-radius: 8px;
  box-shadow: 0px 4px 6px ${Color('#000').alpha(0.04)};
  transition: border-color 300ms;
  outline: none;
  color: ${(p) => p.theme.colors.gray[0]};
  font-weight: 500;
  font-size: 16px;
  line-height: 22px;
  cursor: pointer;

  ${(p) =>
    p.visible &&
    css`
      ${Arrow} {
        transform: rotate(180deg);
      }
    `};

  &:hover,
  &:focus,
  &[aria-expanded='true'] {
    border-color: ${(p) => p.theme.colors.main.default};
  }

  svg {
    margin-right: 16px;
    color: ${(p) => p.theme.colors.main.default};
    flex-shrink: 0;
  }
`

const IndexesListContainer = styled(Menu)`
  min-width: 218px;
  display: flex;
  flex-direction: column;
  outline: none;
  border-width: 1px;
  border-style: solid;
  border-color: ${(p) => p.theme.colors.gray[10]};
  border-radius: 8px;
  box-shadow: 0px 4px 6px ${Color('#000').alpha(0.04)};
  overflow: hidden;
  max-height: 180px;
  overflow: auto;
  z-index: 1;
`

const IndexItem = styled(MenuItem)`
  background-color: white;
  height: 40px;
  border: 0;
  outline: none;
  transition: background-color 300ms;
  padding: 6px 18px;
  text-align: left;
  color: ${(p) => p.theme.colors.gray[2]};

  &:hover,
  &:focus {
    cursor: pointer;
    background-color: ${(p) => p.theme.colors.gray[10]};
  }

  ${(p) =>
    p.$selected &&
    css`
      span:first-child {
        font-weight: 600;
      }
      span:nth-child(2) {
        color: ${p.theme.colors.gray[5]};
      }
    `}
`

const IndexId = styled(Typography)`
  text-overflow: ellipsis;
  white-space: nowrap;
  overflow: hidden;
`

const TextToDisplay = ({ option, currentOption }) => (
  <>
    <IndexId variant="typo4" color={currentOption ? 'gray.0' : 'gray.2'} mr={2}>
      {option ? option.label : 'Select an index'}
    </IndexId>{' '}
  </>
)

const Select = ({
  options,
  icon,
  currentOption,
  onChange,
  noOptionComponent,
  ...props
}) => {
  const menu = useMenuState()
  return (
    <>
      <SelectIndexesButton {...menu} {...props}>
        {icon || null}
        <TextToDisplay option={currentOption} currentOption />
        <Arrow />
      </SelectIndexesButton>
      <IndexesListContainer {...menu} aria-label="Indexes" >
        {options?.length
          ? options.map((data, index) => (
              <IndexItem
                {...menu}
                key={index}
                id={data.label}
                type="button"
                onClick={() => {
                  onChange(data)
                  menu.hide()
                }}
                $selected={currentOption?.label === data.label}
              >
                <TextToDisplay option={data} />
              </IndexItem>
            ))
          : noOptionComponent}
      </IndexesListContainer>
    </>
  )
}

export default Select
