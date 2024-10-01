require 'meilisearch'

URL = ENV['MEILISEARCH_HOST_URL']
API_KEY = ENV['MEILISEARCH_API_KEY']

def feed_meilisearch_with(documents, index_uid, settings = nil)
  client = MeiliSearch::Client.new(URL, API_KEY)
  index = client.index(index_uid)
  LOGGER.info "Index #{index_uid} is ready."
  if settings
    index.update_settings(settings)
    LOGGER.info 'Settings updated.'
  end
  LOGGER.info 'Adding documents...'
  index.add_documents_in_batches(documents, 1800)
  LOGGER.info 'Done!'
end

def load_data_into_meilisearch(documents)
  index_uid = 'rubygems'
  settings = {
    ranking_rules: [
      'typo',
      'words',
      'fame:desc',
      'proximity',
      'attribute',
      'exactness',
      'total_downloads:desc',
    ],
    searchable_attributes: [
      'name',
      'summary'
    ],
    displayed_attributes: [
      'name',
      'summary',
      'description',
      'version',
      'total_downloads'
    ]
  }

  feed_meilisearch_with(documents, index_uid, settings)

end
