require_relative 'feed_meilisearch'
require_relative 'parse_dump_file'
require_relative 'stats'

DOWNLOAD_SCRIPT = "#{Dir.pwd}/app/meilisearch/download_postgresql_dump.sh"
DUMP_FILE_NAME = "#{Dir.pwd}/postgresql_dump_file.sql"

# DOWNLOADING POSTGRESQL DUMP FILE
puts 'Launching script to download the latest rubygems data...'
ret = system("#{DOWNLOAD_SCRIPT} #{DUMP_FILE_NAME}")
if ret == false
  puts 'Error when downloading'
  exit 1
end

# GETTING INFORMATION FORM FILES AND FILLING HASH TABLES
documents = create_documents_from(DUMP_FILE_NAME)

# STATS
stats(documents)

# FEEDING MEILISEARCH WITH DATA
load_data_into_meilisearch(documents)
