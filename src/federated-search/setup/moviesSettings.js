const moviesSettings = {
  displayedAttributes: [
    'title',
    'overview',
    'popularity',
    'release_date',
    'runtime',
    'vote_average',
    'poster_path',
    'genres',
    'crew.job',
    'crew.name',
    'cast.character',
    'cast.name',
    'cast.profile_path',
  ],
  searchableAttributes: [
    'title',
    'crew.name',
    'cast.name',
    'cast.character',
    'overview',
  ],
  filterableAttributes: ['genre', 'vote_average'],
  sortableAttributes: ['release_date'],
  rankingRules: [
    'words',
    'typo',
    'proximity',
    'attribute',
    'sort',
    'exactness',
    'popularity:desc',
  ],
}

module.exports = moviesSettings
