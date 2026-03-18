<template>
  <ais-instant-search index-name="artWorks" :search-client="searchClient">
    <ais-configure :hits-per-page.camel="21" />
    <div class="app">

      <!-- ── Navbar ─────────────────────────────────────── -->
      <header class="navbar">
        <div class="navbar__inner">
          <span class="navbar__title">MoMA Collection</span>
          <div class="navbar__center">
            <div class="navbar__search">
              <div class="search-bar">
                <img src="https://raw.githubusercontent.com/meilisearch/integration-guides/master/assets/logos/logo.svg" alt="Meilisearch" class="meili-logo" />
                <ais-search-box placeholder="Search artists, titles, mediums..." autofocus />
              </div>
            </div>
            <ais-sort-by
              :items="[
                { value: 'artWorks', label: 'Relevance' },
                { value: 'artWorks:DateToSortBy:asc', label: 'Oldest first' },
                { value: 'artWorks:DateToSortBy:desc', label: 'Newest first' }
              ]"
            />
          </div>
          <div class="navbar__right">
            <ais-stats />
          </div>
        </div>
      </header>

      <!-- ── Body ──────────────────────────────────────── -->
      <div class="body">

        <!-- Sidebar -->
        <aside class="sidebar">
          <div class="sidebar__head">
            <div class="sidebar__head-label">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="21" x2="14" y1="4" y2="4"/><line x1="10" x2="3" y1="4" y2="4"/><line x1="21" x2="12" y1="12" y2="12"/><line x1="8" x2="3" y1="12" y2="12"/><line x1="21" x2="16" y1="20" y2="20"/><line x1="12" x2="3" y1="20" y2="20"/><line x1="14" x2="14" y1="2" y2="6"/><line x1="8" x2="8" y1="10" y2="14"/><line x1="16" x2="16" y1="18" y2="22"/></svg>
              <span>Filters</span>
            </div>
            <ais-clear-refinements
              :class-names="{
                'ais-ClearRefinements-button': 'clear-btn',
                'ais-ClearRefinements-button--disabled': 'clear-btn--off'
              }"
            />
          </div>

          <!-- Active filter chips -->
          <div class="sidebar__chips">
            <ais-current-refinements />
          </div>

          <!-- Filter groups -->
          <div v-for="(filter, index) in filters" :key="index" class="fgroup">
            <h3 class="fgroup__label">{{ filter.name }}</h3>
            <ais-refinement-list
              :attribute="filter.name"
              :limit="20"
              :show-more="true"
              :show-more-limit="100"
              :transform-items="transformRefinementListItem"
              :class-names="{ 'ais-RefinementList-showMore': 'show-more-btn' }"
            />
          </div>
        </aside>

        <!-- Main -->
        <main class="main">
          <ais-infinite-hits :transform-items="transformHitItems">
            <template #item="{ item }">
              <article class="card">
                <div class="card__img-wrap">
                  <img
                    v-if="item.ThumbnailURL"
                    :src="item.ThumbnailURL"
                    :alt="item.Title"
                    class="card__img"
                    loading="lazy"
                  />
                  <div v-else class="card__no-img">
                    <span>{{ item.Title }}</span>
                  </div>
                  <!-- dept badge top-left -->
                  <span class="card__dept-badge">{{ item.Department }}</span>
                </div>
                <div class="card__body">
                  <h2 class="card__title">
                    <ais-highlight attribute="Title" :hit="item" />
                  </h2>
                  <p class="card__artist">
                    <ais-highlight attribute="Artist" :hit="item" /><span class="card__date">, <ais-highlight attribute="Date" :hit="item" /></span>
                  </p>
                  <p class="card__medium">
                    <ais-highlight attribute="Medium" :hit="item" />
                  </p>
                  <div class="card__footer">
                    <span class="card__dept">{{ item.Classification }}</span>
                    <a
                      v-if="item.URL"
                      :href="item.URL"
                      target="_blank"
                      rel="noopener noreferrer"
                      class="card__link"
                      aria-label="View on MoMA website"
                      @click.stop
                    >
                      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M15 3h6v6"/><path d="M10 14 21 3"/><path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"/></svg>
                    </a>
                  </div>
                </div>
              </article>
            </template>
            <template #loadMore="{ isLastPage, refineNext }">
              <div class="load-wrap">
                <button class="load-btn" :disabled="isLastPage" @click="refineNext">
                  Load more works
                </button>
              </div>
            </template>
          </ais-infinite-hits>
        </main>

      </div>
    </div>
  </ais-instant-search>
</template>

<script>
import 'instantsearch.css/themes/algolia-min.css'
import { instantMeiliSearch } from '@meilisearch/instant-meilisearch'

export default {
  data() {
    return {
      searchClient: instantMeiliSearch(
        "https://ms-69223ce62f2d-106.lon.meilisearch.io",
        "2969134b46109f7a8d0330f6d1655d9c65c84752ac130674859feeefdf216f25"
      ),
      filters: [
        { name: 'Classification' },
        { name: 'Nationality' },
        { name: 'Gender' }
      ]
    }
  },
  methods: {
    transformRefinementListItem(items) {
      return items.map(item => ({
        ...item,
        label: item.label === '' ? 'Unspecified' : item.label
      }))
    },
    transformHitItems(items) {
      return items.map(item => ({ ...item, _highlightResult: { ...item._highlightResult } }))
    },
    // kept for potential future use
    whichIcon() {}
  }
}
</script>

<style>
/* Fonts loaded via index.html */

/* ── Reset ───────────────────────────────────────────── */
*, *::before, *::after { box-sizing: border-box; }
body { margin: 0; font-family: 'Inter', -apple-system, sans-serif; background: #fff; color: #0f172a; }


/* ── Tokens ──────────────────────────────────────────── */
:root {
  --accent:  #e11d48;
  --border:  #e2e8f0;
  --muted:   #64748b;
  --muted-bg:#f1f5f9;
  --card-bg: #ffffff;
  --navbar-h: 57px;
  --sidebar-w: 260px;
}

/* ── App shell ───────────────────────────────────────── */
.app { min-height: 100vh; display: flex; flex-direction: column; }

/* ── Navbar ──────────────────────────────────────────── */
.navbar {
  height: var(--navbar-h);
  border-bottom: 1px solid var(--border);
  background: #fff;
  position: sticky;
  top: 0;
  z-index: 100;
}

.navbar__inner {
  max-width: 1536px;
  width: 100%;
  margin: 0 auto;
  height: 100%;
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 0 24px;
}

.navbar__title {
  font-size: 1.125rem; /* 18px */
  font-family: 'IBM Plex Serif', Georgia, serif;
  font-weight: 600;
  color: #0f172a;
  white-space: nowrap;
  flex-shrink: 0;
}

.navbar__center {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
}

.navbar__search { flex: 1; max-width: 460px; }

/* Search bar wrapper */
.search-bar {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 0 4px 0 12px;
  border: 1px solid var(--border);
  border-radius: 6px;
  background: #fff;
  transition: border-color 150ms ease, box-shadow 150ms ease;
}
.search-bar:focus-within {
  border-color: #94a3b8;
  box-shadow: 0 0 0 3px rgba(148,163,184,0.2);
}
.meili-logo {
  height: 14px; width: auto; flex-shrink: 0; display: block;
}

/* Search box — borderless inside wrapper */
.search-bar .ais-SearchBox { flex: 1; }
.search-bar .ais-SearchBox-form {
  display: flex; align-items: center;
  border: none; background: transparent; box-shadow: none;
}
.ais-SearchBox-input {
  flex: 1; border: none; outline: none; background: transparent;
  padding: 0 4px; height: 34px;
  font-family: 'Inter', sans-serif; font-size: 0.875rem; color: #0f172a;
}
.ais-SearchBox-input::placeholder { color: #94a3b8; }
.ais-SearchBox-submit { display: none !important; }
.ais-SearchBox-reset {
  display: flex; align-items: center; justify-content: center;
  width: 30px; height: 34px; flex-shrink: 0;
  background: none; border: none; cursor: pointer; color: #94a3b8;
  transition: color 150ms ease;
}
.ais-SearchBox-reset:hover { color: #0f172a; }
.ais-SearchBox-reset svg { width: 12px; height: 12px; }
.ais-SearchBox-resetIcon path { fill: currentColor; }

.navbar__right {
  display: flex; align-items: center; gap: 12px;
  flex-shrink: 0;
}

/* Sort by */
.ais-SortBy-select {
  height: 32px; padding: 0 28px 0 10px;
  border: 1px solid var(--border); border-radius: 6px;
  background: #fff url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='10' height='6'%3E%3Cpath d='M0 0l5 6 5-6z' fill='%2394a3b8'/%3E%3C/svg%3E") no-repeat right 8px center;
  font-family: 'Inter', sans-serif; font-size: 0.75rem; /* 12px */ color: #0f172a;
  appearance: none; cursor: pointer; outline: none;
  transition: border-color 150ms ease;
}
.ais-SortBy-select:focus { border-color: #94a3b8; }

/* Stats */
.ais-Stats { font-size: 0.75rem; /* 12px */ color: var(--muted); white-space: nowrap; }

/* ── Body ────────────────────────────────────────────── */
.body {
  display: flex;
  flex: 1;
  max-width: 1536px;
  width: 100%;
  margin: 0 auto;
}

/* ── Sidebar ─────────────────────────────────────────── */
.sidebar {
  width: var(--sidebar-w);
  flex-shrink: 0;
  border-right: 1px solid var(--border);
  padding: 16px;
  position: sticky;
  top: var(--navbar-h);
  height: calc(100vh - var(--navbar-h));
  overflow-y: auto;
}
.sidebar::-webkit-scrollbar { width: 3px; }
.sidebar::-webkit-scrollbar-thumb { background: #e2e8f0; border-radius: 2px; }

.sidebar__head {
  display: flex; align-items: center; justify-content: space-between;
  margin-bottom: 12px;
}
.sidebar__head-label {
  display: flex; align-items: center; gap: 6px;
  font-size: 0.65rem; font-weight: 600; letter-spacing: 0.08em;
  text-transform: uppercase; color: var(--muted);
}

/* Clear button */
.clear-btn {
  all: unset; cursor: pointer;
  display: flex; align-items: center; gap: 3px;
  font-size: 0.68rem; color: var(--accent);
  transition: opacity 150ms ease;
}
.clear-btn:hover { opacity: 0.75; }
.clear-btn--off { display: none !important; }

/* Active chips (current refinements) */
.sidebar__chips { margin-bottom: 16px; }
.ais-CurrentRefinements-list {
  list-style: none; margin: 0; padding: 0;
  display: flex; flex-wrap: wrap; gap: 6px;
}
.ais-CurrentRefinements-item { margin: 0; }
.ais-CurrentRefinements-label { display: none; }
.ais-CurrentRefinements-category {
  display: inline-flex; align-items: center; gap: 4px;
  padding: 2px 8px;
  background: rgba(225, 29, 72, 0.1);
  color: var(--accent);
  border-radius: 9999px;
  font-size: 0.6875rem; /* 11px */ font-weight: 500;
}
.ais-CurrentRefinements-delete {
  all: unset; cursor: pointer;
  display: inline-flex; align-items: center; justify-content: center;
  width: 12px; height: 12px; font-size: 0.5rem;
  transition: opacity 150ms ease;
}
.ais-CurrentRefinements-delete:hover { opacity: 0.65; }

/* Filter group */
.fgroup { margin-bottom: 20px; }

.fgroup__label {
  margin: 0 0 8px;
  font-size: 0.6875rem; /* 11px */ font-weight: 600;
  letter-spacing: 0.08em; text-transform: uppercase;
  color: rgba(100,116,139,0.7);
}

/* Refinement list */
.sidebar .ais-RefinementList-list { list-style: none; margin: 0; padding: 0; }
.sidebar .ais-RefinementList-item { margin: 0; }
.sidebar .ais-RefinementList-label {
  display: flex; align-items: center; gap: 8px;
  padding: 4px 0; cursor: pointer;
}
.sidebar .ais-RefinementList-label:hover .ais-RefinementList-labelText { color: #0f172a; }

.sidebar .ais-RefinementList-checkbox {
  width: 14px; height: 14px;
  border-radius: 3px;
  border: 1px solid #0f172a;
  background: #fff;
  appearance: none; -webkit-appearance: none;
  cursor: pointer; flex-shrink: 0; position: relative;
  transition: background 150ms ease, border-color 150ms ease;
}
.sidebar .ais-RefinementList-checkbox:checked {
  background: var(--accent); border-color: var(--accent);
}
.sidebar .ais-RefinementList-checkbox:checked::after {
  content: '';
  position: absolute; top: 1px; left: 3.5px;
  width: 4px; height: 7px;
  border: 1.5px solid #fff;
  border-top: none; border-left: none;
  transform: rotate(45deg);
}

.sidebar .ais-RefinementList-labelText {
  font-size: 0.75rem; /* 12px */ color: rgba(15,23,42,0.8);
  flex: 1; transition: color 150ms ease;
}
.sidebar .ais-RefinementList-count {
  font-size: 0.65rem; color: var(--muted);
  background: var(--muted-bg); border-radius: 9999px; padding: 1px 6px;
}

.show-more-btn,
.ais-RefinementList-showMore {
  all: unset; cursor: pointer;
  font-size: 0.6875rem; /* 11px */ color: var(--accent) !important;
  padding: 4px 0 !important; display: block !important;
  background: none !important;
  border-radius: 0 !important;
  border: none !important;
  box-shadow: none !important;
  text-align: left !important;
}
.show-more-btn:hover,
.ais-RefinementList-showMore:hover,
.ais-RefinementList-showMore:focus {
  background: none !important;
  text-decoration: underline;
  color: var(--accent) !important;
}

/* ── Main ────────────────────────────────────────────── */
.main { flex: 1; min-width: 0; padding: 16px; }

/* ── Highlight ───────────────────────────────────────── */
.ais-Highlight-highlighted {
  background: rgba(254,240,138,0.7);
  border-radius: 2px; padding: 0 1px; color: inherit;
}

/* ── Grid ────────────────────────────────────────────── */
.ais-InfiniteHits-list {
  display: grid !important;
  grid-template-columns: repeat(3, minmax(0, 1fr)) !important;
  gap: 16px !important;
  margin: 0 !important; padding: 0 !important; list-style: none !important;
}
.ais-InfiniteHits-item {
  width: auto !important; margin: 0 !important; padding: 0 !important;
  border: none !important; box-shadow: none !important;
  display: flex !important;
}

.ais-InfiniteHits-item .card { height: 100%; width: 100%; }

/* ── Card entry animation ────────────────────────────── */
@keyframes card-in {
  from { opacity: 0; transform: translateY(12px); }
  to   { opacity: 1; transform: translateY(0); }
}

/* ── Card ────────────────────────────────────────────── */
.card {
  background: var(--card-bg);
  border-radius: 8px;
  overflow: hidden;
  box-shadow: none;
  transition: box-shadow 300ms ease, transform 300ms ease;
  display: flex; flex-direction: column;
  animation: card-in 350ms ease both;
}
.card:hover {
  box-shadow: 0 20px 25px -5px rgba(0,0,0,0.12), 0 10px 10px -5px rgba(0,0,0,0.05);
  transform: translateY(-4px);
}

.card__img-wrap {
  aspect-ratio: 4/3;
  background: var(--muted-bg);
  overflow: hidden;
  position: relative;
}
.card__img {
  width: 100%; height: 100%;
  object-fit: cover; display: block;
  transition: transform 500ms ease;
}
.card:hover .card__img { transform: scale(1.05); }

/* No-image state: centered italic title */
.card__no-img {
  width: 100%; height: 100%;
  display: flex; align-items: center; justify-content: center;
  padding: 16px;
}
.card__no-img span {
  font-family: 'IBM Plex Serif', Georgia, serif;
  font-size: 0.875rem; /* 14px, matches card title */ font-style: italic;
  color: var(--muted); text-align: center; line-height: 1.4;
}

/* Dept badge overlaying image top-left */
.card__dept-badge { display: none; }

.card__body {
  padding: 12px; display: flex; flex-direction: column; gap: 6px; flex: 1;
}

.card__title {
  margin: 0;
  font-family: 'IBM Plex Serif', Georgia, serif;
  font-size: 0.875rem; /* 14px */ font-weight: 600; line-height: 1.35;
  color: #0f172a;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
}

.card__artist {
  margin: 0;
  font-size: 0.75rem; /* 12px */ color: var(--muted); line-height: 1.4;
  white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
}
.card__date { color: rgba(100,116,139,0.7); }

.card__medium {
  margin: 0;
  font-size: 0.75rem; /* 12px */ color: rgba(100,116,139,0.8); line-height: 1.4;
  display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden;
}

.card__footer {
  display: flex; align-items: center; justify-content: space-between;
  padding-top: 6px; margin-top: auto;
}
.card__dept {
  font-size: 0.75rem; font-weight: 500;
  letter-spacing: 0.08em; text-transform: uppercase;
  color: rgba(100,116,139,0.6);
}
.card__link {
  color: rgba(100,116,139,0.45);
  display: flex; align-items: center;
  transition: color 150ms ease; text-decoration: none;
}
.card__link:hover { color: var(--accent); }

/* ── Load more ───────────────────────────────────────── */
.load-wrap {
  grid-column: 1 / -1;
  display: flex; justify-content: center;
  padding: 32px 0 8px;
}
.load-btn {
  all: unset; cursor: pointer;
  padding: 10px 24px;
  background: #0f172a; color: #fff;
  border-radius: 6px;
  font-size: 0.8rem; font-weight: 500;
  transition: opacity 150ms ease;
}
.load-btn:hover { opacity: 0.85; }
.load-btn:disabled { opacity: 0.4; cursor: default; pointer-events: none; }

.ais-InfiniteHits-list {
  grid-template-columns: repeat(3, minmax(0, 1fr)) !important;
}
</style>
