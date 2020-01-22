require 'meilisearch'

URL = ENV['MEILISEARCH_URL']
API_KEY = ENV['MEILISEARCH_API_KEY']

def feed_meilisearch_with(index_uid, schema, settings, documents)
  client = MeiliSearch::Client.new(URL, API_KEY)
  puts "Deleting old index #{index_uid}..."
  begin
    client.delete_index(index_uid)
    puts 'Done!'
  rescue MeiliSearch::HTTPError => e
    puts "No index #{index_uid} to delete."
  end
  puts "Creating a new index #{index_uid}..."
  index = client.create_index(
    name: index_uid.gsub('_', ' ').capitalize,
    uid: index_uid,
    schema: schema
  )
  puts 'Done!'
  puts 'Adding documents...'
  documents.each_slice(1800).with_index do |slice, i|
    # puts "Adding slice #{i}"
    index.add_documents(slice)
  end
  puts 'Done!'
  puts 'Adding settings...'
  index.add_settings(settings)
  puts 'Done!'
end

def load_data_into_meilisearch(documents)
  index_uid = 'gems'
  schema = {
    id:              ['identifier'],
    name:            ['indexed', 'displayed'],
    summary:         ['indexed', 'displayed'],
    description:     [           'displayed'],
    version:         ['indexed', 'displayed'],
    total_downloads: ['indexed', 'displayed', 'ranked'],
    fame:            ['indexed', 'displayed', 'ranked'],
  }
  settings = {
    rankingOrder: [
      '_sum_of_typos',
      '_number_of_words',
      'fame',
      '_word_proximity',
      '_sum_of_words_attribute',
      '_exact',
      'total_downloads',
    ],
    distinctField: nil,
    rankingRules: {
      total_downloads: 'dsc',
      fame: 'dsc',
    }
  }

  index_uid_with_desc = 'gems_with_desc'
  schema_with_desc = {
    id:              ['identifier'],
    name:            ['indexed', 'displayed'],
    summary:         ['indexed', 'displayed'],
    description:     ['indexed', 'displayed'],
    version:         ['indexed', 'displayed'],
    total_downloads: ['indexed', 'displayed', 'ranked'],
    fame:            ['indexed', 'displayed', 'ranked'],
  }
  settings_with_desc = {
    rankingOrder: [
      '_sum_of_typos',
      '_number_of_words',
      'fame',
      '_word_proximity',
      '_sum_of_words_attribute',
      '_exact',
      'total_downloads',
    ],
    distinctField: nil,
    rankingRules: {
      total_downloads: 'dsc',
      fame: 'dsc',
    }
  }

  feed_meilisearch_with(index_uid, schema, settings, documents)
  feed_meilisearch_with(index_uid_with_desc, schema_with_desc, settings_with_desc, documents)

end
