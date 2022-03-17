import React from 'react'
import { useSearch } from '../../context/MeiliSearchContext'
import Select from '../Select/Select'

function Filters() {
  const { isAppointed, setIsAppointed } = useSearch()

  return (
    <>
      <span className="font-bold">Search Filters</span>
      <div className="space-y-4">
        <div>Appointment Status:</div>
        <Select
          value={isAppointed}
          currentOption={{
            label:
              isAppointed == null
                ? 'Both'
                : isAppointed
                ? 'Appointed'
                : 'Not Appointed',
          }}
          options={[
            { label: 'Both', value: 'both' },
            { label: 'Appointed', value: true },
            { label: 'Not Appointed', value: false },
          ]}
          style={{ width: 216 }}
          onChange={(data) => {
            setIsAppointed(data.value === 'both' ? null : data.value)
          }}
        />
      </div>
    </>
  )
}

export default Filters
