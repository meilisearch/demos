require 'meilisearch'

URL = ENV['MEILISEARCH_HOST_URL']
API_KEY = ENV['MEILISEARCH_API_KEY']

def feed_meilisearch_with(documents, index_uid, settings = nil)
  client = MeiliSearch::Client.new(URL, API_KEY)
  index = client.get_or_create_index(index_uid)
  LOGGER.info "Index #{index_uid} is ready."
  if settings
    index.update_settings(settings)
    LOGGER.info 'Settings updated.'
  end
  LOGGER.info 'Adding documents...'
  documents.each_slice(1800).with_index do |slice, i|
    # puts "Adding slice #{i}"
    index.add_documents(slice)
  end
  LOGGER.info 'Done!'
end

def load_data_into_meilisearch(documents)
  index_uid = 'rubygems'
  settings = {
    rankingRules: [
      'typo',
      'words',
      'desc(fame)',
      'proximity',
      'attribute',
      'exactness',
      'desc(total_downloads)',
    ],
    searchableAttributes: [
      'name',
      'summary'
    ],
    displayedAttributes: [
      'id',
      'name',
      'summary',
      'description',
      'version',
      'total_downloads'
    ]
  }

  feed_meilisearch_with(documents, index_uid, settings)

end
