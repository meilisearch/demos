import React from 'react'
import { connectRange } from 'react-instantsearch-dom'
import Rheostat from 'rheostat'

import 'rheostat/initialize'
import 'rheostat/css/rheostat.css'

const RangeSlider = (props) => {
  let { min, max, currentRefinement, canRefine, refine } = props
  min = 0
  max = 4300
  const [stateMin, setStateMin] = React.useState(min)
  const [stateMax, setStateMax] = React.useState(max)

  React.useEffect(() => {
    setStateMin(0)
    setStateMax(4300)
    refine({ min: 0, max: 4300 })
  }, [])

  React.useEffect(() => {
    if (canRefine) {
      setStateMin(currentRefinement.min)
      setStateMax(currentRefinement.max)
    }
  }, [currentRefinement.min, currentRefinement.max])

  if (min === max) {
    return null
  }

  const onChange = ({ values: [min, max] }) => {
    if (currentRefinement?.min !== min || currentRefinement?.max !== max) {
      if (isNaN(min) || isNaN(max)) {
        refine({ min: 0, max: 4300 })
      } else {
        refine({ min, max })
      }
    }
  }

  const onValuesUpdated = ({ values: [min, max] }) => {
    setStateMin(min)
    setStateMax(max)
  }

  return (
    <Rheostat
      min={min}
      max={max}
      values={[currentRefinement?.min, currentRefinement?.max]}
      onChange={onChange}
      onValuesUpdated={onValuesUpdated}
    >
      <div className='rheostat-marker rheostat-marker--large' style={{ left: 0 }}>
        <div className='rheostat-value'>{stateMin}</div>
      </div>
      <div className='rheostat-marker rheostat-marker--large' style={{ right: 0 }}>
        <div className='rheostat-value'>{stateMax}</div>
      </div>
    </Rheostat>
  )
}

const CustomRangeSlider = connectRange(RangeSlider)

export default CustomRangeSlider
