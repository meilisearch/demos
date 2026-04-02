# CineSearch

A Vite + React demo showcasing **Meilisearch document hydration** (foreignKeys). Toggle between raw IDs and fully-resolved nested documents in real time.

---

## Local setup

```bash
git clone <repo>
cd cinesearch
npm install
cp .env.example .env   # fill in your values
npm run dev
```

### Environment variables

| Variable | Description |
|---|---|
| `VITE_MEILI_HOST` | Your Meilisearch instance URL (e.g. `https://xxx.meilisearch.io`) |
| `VITE_MEILI_API_KEY` | A search-only API key for that instance |

---

## Meilisearch index setup

You need **two indexes**:

### 1. `actors`

Upload actor documents (minimum fields: `id`, `name`, `profile_path`):

```json
[
  { "id": 504, "name": "Tim Robbins", "birthday": "1958-10-16", "place_of_birth": "Woodstock, Connecticut, USA", "profile_path": "/..." },
  { "id": 192, "name": "Morgan Freeman", "birthday": "1937-06-01", "place_of_birth": "Memphis, Tennessee, USA", "profile_path": "/..." }
]
```

### 2. `top_movies` (raw — no special settings)

Genres are stored as string arrays directly on the document. Actors are integer IDs:

```json
[
  {
    "id": 278,
    "title": "The Shawshank Redemption",
    "release_date": "1994-09-23",
    "vote_average": 8.7,
    "poster_path": "/q6y0Go1tsGEsmtFryDOJo3dEmqu.jpg",
    "genres": ["Drama", "Crime"],
    "actors": [504, 192]
  }
]
```

### 3. `top_movies_hydrated` (hydrated — configure foreignKeys)

Upload the **same documents** as `top_movies`, then apply this settings update:

```bash
curl -X PATCH 'https://<your-host>/indexes/top_movies_hydrated/settings' \
  -H 'Authorization: Bearer <your-master-key>' \
  -H 'Content-Type: application/json' \
  --data '{
    "foreignKeys": [
      { "fieldName": "actors", "foreignIndexUid": "actors" }
    ],
    "filterableAttributes": ["genres", "vote_average"]
  }'
```

Once the task completes, searches on `top_movies_hydrated` automatically resolve actor integer IDs into full nested actor documents.

---

## Vercel deployment

1. Push this repo to GitHub
2. Import the repo in [Vercel](https://vercel.com/new)
3. In **Project Settings → Environment Variables**, add:
   - `VITE_MEILI_HOST`
   - `VITE_MEILI_API_KEY`
4. Deploy — Vercel detects Vite automatically

The included `vercel.json` handles client-side routing.

---

## Feature reference

- [Meilisearch foreignKeys (document hydration) docs](https://www.meilisearch.com/docs/capabilities/indexing/how_to/document_relations)
