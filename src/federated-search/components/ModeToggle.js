import React from 'react'
import styles from '../styles/ModeToggle.module.css'

const modes = [
  {
    id: 'multi',
    label: 'Multi-index',
    description:
      'Two independent searches run in parallel. Each index ranks its own results, displayed side by side.',
  },
  {
    id: 'federated',
    label: 'Federated',
    description:
      'A single search across both indexes. Meilisearch merges and re-ranks all results globally by relevance score.',
  },
]

const ModeToggle = ({ mode, onChange }) => {
  const current = modes.find(m => m.id === mode)
  return (
    <div className={styles.wrapper}>
      <div className={styles.toggle}>
        {modes.map(m => (
          <button
            key={m.id}
            className={`${styles.option} ${mode === m.id ? styles.active : ''}`}
            onClick={() => onChange(m.id)}
          >
            {m.label}
          </button>
        ))}
      </div>
      <p className={styles.description}>{current.description}</p>
    </div>
  )
}

export default ModeToggle
