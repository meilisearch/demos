import React from 'react'
import { connectPagination } from 'react-instantsearch-dom'

function Pagination({ currentRefinement, nbPages, refine }) {
  return (
    <div className="flex justify-center w-full mt-3">
      <nav aria-label="footer pagination">
        <ul className="flex list-style-none">
          {new Array(nbPages).fill(null).map((_, index) => {
            const page = index + 1
            return (
              <li className={'page-item'} key={page}>
                <button
                  className={
                    'page-link relative block py-1.5 px-3 border-0 outline-none transition-all duration-300 rounded focus:shadow-none' +
                    (currentRefinement === page
                      ? ' bg-pink-500 text-white hover:text-white hover:bg-pink-500'
                      : 'bg-transparent text-gray-800 hover:text-gray-800 hover:bg-gray-200')
                  }
                  onClick={() => {
                    refine(page)
                  }}
                >
                  {page}
                </button>
              </li>
            )
          })}
        </ul>
      </nav>
    </div>
  )
}

export default connectPagination(Pagination)
