import React from 'react'
import { connectMenu } from 'react-instantsearch-dom'
import Select from '../Select/Select'

function Filters() {
  return (
    <>
      <span className="font-bold">Search Filters</span>
      <div className="space-y-4">
        <div>Appointment Status:</div>
        <AppointmentStatusMenu
          attribute="isDoctorAppointed"
          transformItems={(items) => {
            return items.map((item) => ({
              ...item,
              label: item.value === 'true' ? 'Appointed' : 'Not Appointed',
            }))
          }}
        />
      </div>
    </>
  )
}

const AppointmentStatusMenu = connectMenu(
  ({ items, currentRefinement, refine }) => {
    let finalOptions = [
      { label: 'Both', value: null },
      { label: 'Appointed', value: 'true' },
      { label: 'Not Appointed', value: 'false' },
    ]
    let currentOption = finalOptions.find((i) => i.value === currentRefinement)
    return (
      <Select
        value={currentRefinement}
        currentOption={currentOption}
        options={finalOptions}
        onChange={(data) => {
          refine(data.value)
        }}
      />
    )
  }
)

export default Filters
