import styles from './Header.module.css';

export default function Header({ hydrated, onToggle }) {
  const indexName = hydrated ? 'top_movies_hydrated' : 'top_movies';

  return (
    <header className={styles.header}>
      <div className={styles.titleRow}>
        <h1 className={styles.title}>CineSearch</h1>
        <a
          className={styles.subtitle}
          href="https://www.meilisearch.com"
          target="_blank"
          rel="noopener noreferrer"
        >
          powered by Meilisearch
        </a>
      </div>

      <div className={styles.explanationRow}>
        <p className={styles.explanation}>
          Meilisearch's new{' '}
          <a
            className={styles.featureLink}
            href="https://www.meilisearch.com/docs/capabilities/indexing/how_to/document_relations"
            target="_blank"
            rel="noopener noreferrer"
          >
            hydration feature
          </a>
          {' '}resolves foreign key IDs into full documents at search time — no extra queries, no backend logic. Toggle to see the difference.
        </p>

        <button
          className={styles.segmented}
          onClick={onToggle}
          aria-pressed={hydrated}
          aria-label="Toggle between raw IDs and hydrated documents"
        >
          <span className={`${styles.segment} ${!hydrated ? styles.segmentActive : ''}`}>
            <span className={styles.segmentIcon}>⚙</span>
            Raw IDs
          </span>
          <span className={`${styles.segment} ${hydrated ? styles.segmentActive : ''}`}>
            <span className={styles.segmentIcon}>✦</span>
            Hydrated
          </span>
        </button>
      </div>
    </header>
  );
}
