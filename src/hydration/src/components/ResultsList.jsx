import MovieCard from './MovieCard';
import styles from './ResultsList.module.css';

export default function ResultsList({ results, hydrated, selectedId, onSelect, loading, error }) {
  if (error) {
    return (
      <div className={styles.state}>
        <p className={styles.errorText}>Connection error</p>
        <p className={styles.errorDetail}>{error}</p>
        <p className={styles.hint}>Check your <code>VITE_MEILI_HOST</code> and <code>VITE_MEILI_API_KEY</code> in <code>.env</code></p>
      </div>
    );
  }

  if (!loading && results.length === 0) {
    return (
      <div className={styles.state}>
        <p className={styles.emptyText}>No results</p>
      </div>
    );
  }

  return (
    <div className={styles.list}>
      {loading && results.length === 0 && (
        <div className={styles.state}>
          <span className={styles.spinner} />
        </div>
      )}
      {results.map(movie => (
        <MovieCard
          key={movie.id}
          movie={movie}
          hydrated={hydrated}
          selected={movie.id === selectedId}
          onClick={() => onSelect(movie)}
        />
      ))}
    </div>
  );
}
