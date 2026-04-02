import { useState, useEffect, useRef, useCallback } from 'react';
import MeiliSearch from 'meilisearch';

const client = new MeiliSearch({
  host: import.meta.env.VITE_MEILI_HOST,
  apiKey: import.meta.env.VITE_MEILI_API_KEY,
});

export function useSearch(query, hydrated) {
  const [results, setResults] = useState([]);
  const [processingTimeMs, setProcessingTimeMs] = useState(null);
  const [totalHits, setTotalHits] = useState(0);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const debounceRef = useRef(null);

  const search = useCallback(async (q, isHydrated) => {
    const indexName = isHydrated ? 'top_movies_hydrated' : 'top_movies';
    setLoading(true);
    setError(null);
    try {
      const res = await client.index(indexName).search(q, {
        limit: 20,
        attributesToRetrieve: ['id', 'title', 'release_date', 'vote_average', 'poster_path', 'genres', 'actors'],
        attributesToHighlight: ['title'],
        highlightPreTag: '<mark>',
        highlightPostTag: '</mark>',
      });
      setResults(res.hits);
      setProcessingTimeMs(res.processingTimeMs);
      setTotalHits(res.estimatedTotalHits ?? res.nbHits ?? res.hits.length);
    } catch (err) {
      setError(err.message ?? 'Search failed');
      setResults([]);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    clearTimeout(debounceRef.current);
    debounceRef.current = setTimeout(() => {
      search(query, hydrated);
    }, 150);
    return () => clearTimeout(debounceRef.current);
  }, [query, hydrated, search]);

  return { results, processingTimeMs, totalHits, loading, error };
}
