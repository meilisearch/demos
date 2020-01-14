require 'meilisearch'
require 'byebug'

URL = ENV['MEILISEARCH_URL']
API_KEY = ENV['MEILISEARCH_API_KEY']
INDEX_UID = ENV['MEILISEARCH_INDEX_UID']
MAIN_TABLE = 'versions'
FIELDS = [
  'authors',
  'description',
  'number',
  'rubygem_id',
  'summary',
  'full_name',
  'position',
  'indexed'
]
DOWNLOAD_TABLE = 'gem_downloads'

# GETTING INFORMATION FORM FILES AND FILLING HASH TABLES
puts 'Parsing PostgreSQL dump file...'
main_parsing = false
download_parsing = false
main_result = {}
download_result = {}
titles = []
titles_len = 0
File.open("#{Dir.pwd}/PostgreSQL.sql", 'r') do |file|
  file.each_line.with_index do |line, index|

    if main_parsing
      main_parsing = false if line == "\\.\n"
      content = line.split("\t")
      new_elem = {}
      titles_len.times do |i|
        if FIELDS.include?(titles[i])
          new_elem[titles[i]] = content[i]
        end
      end
      if new_elem['position'] == '0' && new_elem['indexed'] == 't' && !main_result.has_key?(new_elem['rubygem_id'])
        main_result[new_elem['rubygem_id']] = new_elem
      end
    end

    if download_parsing
      download_parsing = false if line == "\\.\n"
      content = line.split("\t")
      new_elem = {}
      titles_len.times do |i|
        new_elem[titles[i]] = content[i]
      end
      if new_elem['version_id'] == '0'
        download_result[new_elem['rubygem_id']] = new_elem
      end
    end

    if line.start_with?("COPY public.#{MAIN_TABLE}")
      titles = line.delete_prefix!("COPY public.#{MAIN_TABLE} (").delete_suffix!(") FROM stdin;\n").split(', ') # keep only titles from the entire line
      titles.map! { |title| title.delete_prefix('"').delete_suffix('"') } # trim double quotes
      titles_len = titles.length
      main_parsing = true
    end

    if line.start_with?("COPY public.#{DOWNLOAD_TABLE}")
      titles = line.delete_prefix!("COPY public.#{DOWNLOAD_TABLE} (").delete_suffix!(") FROM stdin;\n").split(', ') # keep only titles from the entire line
      titles_len = titles.length
      download_parsing = true
    end

  end
end
puts 'Results:'
puts "main table length: #{main_result.length}"
puts "download table length: #{download_result.length}"

# CREATING DOCUMENTS FOR MEILISEARCH
documents = main_result.map do |_, elem|
  document = {}
  document['id'] = elem['rubygem_id']
  document['version'] = elem['number']
  document['name'] = elem['full_name'].split("-#{document['version']}").first
  document['authors'] = elem['authors']
  elem['description'].delete!("\N")
  elem['description'].delete!("\n")
  elem['summary'].delete!("\N")
  elem['summary'].delete!("\n")
  document['summary'] = elem['summary'].empty? ? elem['description'] : elem['summary']
  if download_result.has_key?(elem['rubygem_id'])
    document['total_downloads'] = download_result[elem['rubygem_id']]['count'].delete_suffix("\n")
  else
    document['total_downloads'] = 0
  end
  document
end
puts "Documents number: #{documents.length}"

# FILLING MEILISEARCH
schema = {
  id:              ['identifier'],
  name:            ['indexed', 'displayed'],
  version:         ['indexed', 'displayed'],
  authors:         ['indexed', 'displayed'],
  summary:         ['indexed', 'displayed'],
  total_downloads: ['indexed', 'displayed', 'ranked'],
}
client = MeiliSearch::Client.new(URL, API_KEY)
puts "\nDeleting old index..."
begin
  client.delete_index(INDEX_UID)
  puts 'Done!'
rescue MeiliSearch::HTTPError => e
  puts 'No index to delete.'
end
puts 'Creating a new index...'
index = client.create_index(name: 'Gems', uid: INDEX_UID, schema: schema)
# index = client.index(INDEX_UID)
puts 'Done!'
puts 'Adding documents...'
documents.each_slice(1800).with_index do |slice, i|
  # puts "Adding slice #{i}"
  index.add_documents(slice)
end
puts 'Done!'
puts 'Adding settings...'
settings = {
  rankingOrder: [
    '_sum_of_typos',
    '_number_of_words',
    '_word_proximity',
    '_sum_of_words_attribute',
    '_sum_of_words_position',
    '_exact',
    'total_downloads'
  ],
  distinctField: nil,
  rankingRules: { total_downloads: 'dsc' }
}
index.add_settings(settings)
puts 'Done!'
