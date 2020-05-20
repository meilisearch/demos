require 'meilisearch'

URL = ENV['MEILISEARCH_URL']
API_KEY = ENV['MEILISEARCH_MASTER_KEY']

def get_or_create_index(index_uid, settings = nil)
  client = MeiliSearch::Client.new(URL, API_KEY)
  index = client.index(index_uid)
  begin
    index.show
    LOGGER.warn "Index #{index_uid} already exists."
  rescue MeiliSearch::HTTPError
    index = client.create_index(
      uid: index_uid,
    )
    LOGGER.info "New index #{index_uid} created."
    if settings
      index.update_settings(settings)
      LOGGER.info 'Settings added.'
    end
  end
  index
end

def feed_meilisearch_with(documents, index_uid, settings = nil)
  index = get_or_create_index(index_uid, settings)
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
      'name',
      'summary',
      'description',
      'version',
      'total_downloads',
      'fame'
    ]
  }

  feed_meilisearch_with(documents, index_uid, settings)

end
