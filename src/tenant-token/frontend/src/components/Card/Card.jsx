import React from 'react'

function Card({ data }) {
  const { isDoctorAppointed, patient, roomNumber, description } = data

  return (
    <div
      className="flex flex-col justify-between w-[250px] bg-white  p-5 m-2 xl:mr-10 rounded-[20px]"
      style={{
        boxShadow: '0px 0px 30px rgba(0, 0, 0, 0.05)',
      }}
    >
      <div>
        <div className="font-bold">{patient}</div>
        {isDoctorAppointed ? (
          <div className="text-green-500 font-medium">
            Doctor is appointed ✓
          </div>
        ) : (
          <div className="text-red-500 font-medium">
            Doctor is not appointed ×
          </div>
        )}
        <div className="text-slate-800 text-xs">{description}</div>
      </div>
      <div className="w-fit bg-violet-100 text-violet-800 rounded-md py-1 px-2 mt-2 text-center font-medium text-sm">
        Room {roomNumber}
      </div>
    </div>
  )
}

export default Card
