require 'meilisearch'

def strip_html_tag(document)
  document.each do |_, value|
    value.gsub!(/<\/?[^>]*>/, "") if value.is_a? String
  end
end

def clean_sql_field(str)
  str.gsub('\N', '').gsub('\n', '').delete("\n")
end

DOWNLOAD_SCRIPT = "#{Dir.pwd}/app/meilisearch/download_postgresql_dump.sh"
DUMP_FILE_NAME = "#{Dir.pwd}/postgresql_dump_file.sql"
MAIN_TABLE = 'versions'
FIELDS = [
  'description',
  'summary',
  'number',
  'rubygem_id',
  'full_name',
  'position',
  'indexed'
]
DOWNLOAD_TABLE = 'gem_downloads'
URL = ENV['MEILISEARCH_URL']
API_KEY = ENV['MEILISEARCH_API_KEY']

# DOWNLOADING POSTGRESQL DUMP FILE
puts 'Launching script to download the latest rubygems data...'
ret = system("#{DOWNLOAD_SCRIPT} #{DUMP_FILE_NAME}")
if ret == false
  puts 'Error when downloading'
  exit 1
end

# GETTING INFORMATION FORM FILES AND FILLING HASH TABLES
puts 'Parsing PostgreSQL dump file...'
main_parsing = false
download_parsing = false
main_result = {}
download_result = {}
titles = []
titles_len = 0
File.open(DUMP_FILE_NAME, 'r') do |file|
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
puts "Main table length: #{main_result.length}"
puts "Download table length: #{download_result.length}"

# CREATING DOCUMENTS FOR MEILISEARCH
documents = main_result.map do |_, elem|
  document = {}
  document['id'] = elem['rubygem_id']
  document['version'] = elem['number']
  document['name'] = elem['full_name'].split("-#{document['version']}").first
  document['description'] = clean_sql_field(elem['description'])
  document['summary'] = clean_sql_field(elem['summary'])
  if download_result.has_key?(elem['rubygem_id'])
    document['total_downloads'] = download_result[elem['rubygem_id']]['count'].delete_suffix("\n")
  else
    document['total_downloads'] = 0
  end
  strip_html_tag(document)
end
puts "Documents number: #{documents.length}"

# FILLING MEILISEARCH
def feed_meilisearch(index_uid, schema, settings, documents)
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

index_uid = 'gems'
schema = {
  id:              ['identifier'],
  name:            ['indexed', 'displayed'],
  description:     ['indexed', 'displayed'],
  summary:         [           'displayed'],
  version:         ['indexed', 'displayed'],
  total_downloads: ['indexed', 'displayed', 'ranked'],
}
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

# index_uid_without_name = 'gems_without_name'
# schema_without_name = {
#   id:              ['identifier'],
#   name:            ['displayed'],
#   summary:         ['indexed', 'displayed'],
#   description:     ['indexed', 'displayed'],
#   version:         ['indexed', 'displayed'],
#   total_downloads: ['indexed', 'displayed', 'ranked'],
# }
# settings_without_name = {
#   rankingOrder: [
#     '_sum_of_typos',
#     '_number_of_words',
#     '_word_proximity',
#     '_sum_of_words_attribute',
#     '_sum_of_words_position',
#     '_exact',
#     'total_downloads',
#   ],
#   distinctField: nil,
#   rankingRules: { total_downloads: 'dsc' }
# }

feed_meilisearch(index_uid, schema, settings, documents)
# feed_meilisearch(index_uid_without_name, schema_without_name, settings_without_name, documents)
