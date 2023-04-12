const actorsSettings = {
  displayedAttributes: [
    'name',
    'profile_path',
    'biography',
    'known_for',
  ],
  searchableAttributes: ['name', 'known_for', 'biography'],
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

module.exports = actorsSettings
