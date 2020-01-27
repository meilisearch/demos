require 'meilisearch'

URL = ENV['MEILISEARCH_URL']
API_KEY = ENV['MEILISEARCH_API_KEY']

def get_or_create_index(index_uid, schema, settings)
  client = MeiliSearch::Client.new(URL, API_KEY)
  index = client.index(index_uid)
  begin
    index.name
    puts "Index #{index_uid} already exists."
  rescue
    puts "Creating a new index #{index_uid}..."
    index = client.create_index(
      name: index_uid.gsub('_', ' ').capitalize,
      uid: index_uid,
      schema: schema
    )
    puts 'Done!'
    if settings
      puts 'Adding settings...'
      index.add_settings(settings)
      puts 'Done!'
    end
  end
  index
end

def feed_meilisearch_with(index_uid, schema, settings, documents)
  index = get_or_create_index(index_uid, schema, settings)
  puts 'Adding documents...'
  documents.each_slice(1800).with_index do |slice, i|
    # puts "Adding slice #{i}"
    index.add_documents(slice)
  end
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

  index_uid_basic = 'gems_basic'
  schema_basic = {
    id:              ['identifier'],
    name:            ['indexed', 'displayed'],
    summary:         ['indexed', 'displayed'],
    description:     ['indexed', 'displayed'],
    version:         ['indexed', 'displayed'],
    total_downloads: ['indexed', 'displayed']
  }

  feed_meilisearch_with(index_uid, schema, settings, documents)
  # feed_meilisearch_with(index_uid_with_desc, schema_with_desc, settings_with_desc, documents)
  # feed_meilisearch_with(index_uid_basic, schema_basic, nil, documents)

end
