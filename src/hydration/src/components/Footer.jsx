import styles from './Footer.module.css';

export default function Footer({ totalHits, processingTimeMs }) {
  return (
    <footer className={styles.footer}>
      <span className={styles.stats}>
        {totalHits != null && (
          <>
            <span className={styles.count}>{totalHits.toLocaleString()}</span>
            {' '}result{totalHits !== 1 ? 's' : ''}
            {processingTimeMs != null && (
              <> &mdash; <span className={styles.time}>{processingTimeMs}ms</span></>
            )}
          </>
        )}
      </span>
      <a
        className={styles.docsLink}
        href="https://www.meilisearch.com/docs/capabilities/indexing/how_to/document_relations"
        target="_blank"
        rel="noopener noreferrer"
      >
        Learn about foreignKeys →
      </a>
    </footer>
  );
}
