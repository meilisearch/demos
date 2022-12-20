
export const MEILISEARCH_CONFIG = {
  HOST: process.env.REACT_APP_MEILI_HOST || 'http://localhost:7700',
  SEARCH_API_KEY: process.env.REACT_APP_MEILI_SEARCH_API_KEY,
  INDEX: process.env.REACT_APP_MEILI_INDEX || 'tenant_token',
  API_HOST: process.env.REACT_APP_API_HOST || 'http://localhost:5000',
}
