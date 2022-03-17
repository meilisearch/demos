export const MEILISEARCH_CONFIG = {
  HOST: process.env.REACT_APP_MEILI_HOST || 'http://localhost:7700',
  MASTER_KEY: process.env.REACT_APP_MEILI_API_KEY || 'masterKey',
  INDEX: process.env.REACT_APP_MEILI_INDEX || 'tenant_token',
  API_HOST: process.env.REACT_APP_API_HOST || 'http://locahost:5000',
}
