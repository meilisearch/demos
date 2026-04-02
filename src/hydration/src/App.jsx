import { useState, useEffect } from 'react';
import Header from './components/Header';
import SearchBar from './components/SearchBar';
import ResultsList from './components/ResultsList';
import JsonInspector from './components/JsonInspector';
import { useSearch } from './hooks/useSearch';
import styles from './App.module.css';

export default function App() {
  const [hydrated, setHydrated] = useState(false);
  const [query, setQuery] = useState('');
  const [selectedMovie, setSelectedMovie] = useState(null);

  const { results, processingTimeMs, totalHits, loading, error } = useSearch(query, hydrated);

  // Auto-select first result on initial load
  useEffect(() => {
    if (results.length > 0 && !selectedMovie) {
      setSelectedMovie(results[0]);
    }
  }, [results]);

  // When toggling hydration, sync selected movie from fresh results
  useEffect(() => {
    if (results.length > 0 && selectedMovie) {
      const updated = results.find(m => m.id === selectedMovie.id);
      setSelectedMovie(updated ?? results[0]);
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [hydrated, results]);

  return (
    <div className={styles.app}>
      <Header hydrated={hydrated} onToggle={() => setHydrated(h => !h)} />

      <div className={styles.body}>
        <section className={styles.leftPanel}>
          <div className={styles.searchWrapper}>
            <SearchBar value={query} onChange={setQuery} />
            <p className={styles.stats}>
              {totalHits != null && (
                <>
                  <span className={styles.count}>{totalHits.toLocaleString()}</span>
                  {' '}result{totalHits !== 1 ? 's' : ''}
                  {processingTimeMs != null && (
                    <> · <span className={styles.time}>{processingTimeMs}ms</span></>
                  )}
                </>
              )}
            </p>
          </div>
          <ResultsList
            results={results}
            hydrated={hydrated}
            selectedId={selectedMovie?.id}
            onSelect={setSelectedMovie}
            loading={loading}
            error={error}
          />
        </section>

        <JsonInspector movie={selectedMovie} hydrated={hydrated} />
      </div>
    </div>
  );
}
