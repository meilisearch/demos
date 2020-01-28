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

LEVEL_7_LIMIT = 50_000_000
LEVEL_6_LIMIT = 30_000_000
LEVEL_5_LIMIT = 10_000_000
LEVEL_4_LIMIT = 5_000_000
LEVEL_3_LIMIT = 1_000_000
LEVEL_2_LIMIT = 500_000
LEVEL_1_LIMIT = 100_000

def strip_html_tag(document)
  document.each do |_, value|
    value.gsub!(/<\/?[^>]*>/, "") if value.is_a? String
  end
end

def clean_sql_field(str)
  str.gsub('\N', '').gsub('\n', '').delete("\n")
end

def create_documents_from(dump_file_name)
  LOGGER.info 'Parsing PostgreSQL dump file...'
  main_parsing = false
  download_parsing = false
  main_result = {}
  download_result = {}
  titles = []
  titles_len = 0
  File.open(dump_file_name, 'r') do |file|
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
  LOGGER.info 'Results:'
  LOGGER.info "Main table length: #{main_result.length}"
  LOGGER.info "Download table length: #{download_result.length}"

  # Creating documents hash table
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
      document['total_downloads'] = '0'
    end
    strip_html_tag(document)
  end
  LOGGER.info "Documents number: #{documents.length}"

  documents_sorted = documents.sort_by { |elem| elem['total_downloads'].to_i }.reverse
  len = documents_sorted.length
  documents.map! do |doc|
    if doc['total_downloads'].to_i >= LEVEL_7_LIMIT
      doc.merge('fame' => '7')
    elsif doc['total_downloads'].to_i >= LEVEL_6_LIMIT
      doc.merge('fame' => '6')
    elsif doc['total_downloads'].to_i >= LEVEL_5_LIMIT
      doc.merge('fame' => '5')
    elsif doc['total_downloads'].to_i >= LEVEL_4_LIMIT
      doc.merge('fame' => '4')
    elsif doc['total_downloads'].to_i >= LEVEL_3_LIMIT
      doc.merge('fame' => '3')
    elsif doc['total_downloads'].to_i >= LEVEL_2_LIMIT
      doc.merge('fame' => '2')
    elsif doc['total_downloads'].to_i >= LEVEL_1_LIMIT
      doc.merge('fame' => '1')
    else
      doc.merge('fame' => '0')
    end
  end

  documents
end
