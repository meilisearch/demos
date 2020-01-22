def stats_on_download_number(array, number_in_million)
  len = array.length
  result = array.count { |e| e['total_downloads'].to_i > number_in_million}
  puts "> #{number_in_million / 1000000.0}M downloads: #{result} -> #{(result / len.to_f * 100.0).round(2)}%"
end

def stats_on_decile(array, percent)
  len = array.length
  print "#{percent}% (= #{(len / 100 * percent).to_i}th): "
  elem = array[(len / 100.0 * percent.to_f).round]
  puts "name: #{elem['name']} - total_downloads: #{elem['total_downloads']}"
end

def stats(array)
  sorted = array.sort_by { |elem| elem['total_downloads'].to_i }.reverse
  puts 'STATS:'
  # puts '1st quartile:'
  # puts sorted[(len / 4.0).round]
  # puts 'Median:'
  # puts sorted[(len / 2.0).round]
  # puts '3rd quartile:'
  # puts sorted[(len / 4.0).round * 3]
  stats_on_decile(sorted, 2)
  stats_on_decile(sorted, 1)
  stats_on_decile(sorted, 0.5)
  stats_on_decile(sorted, 0.1)
  stats_on_download_number(sorted, 100_000)
  stats_on_download_number(sorted, 500_000)
  stats_on_download_number(sorted, 1_000_000)
  stats_on_download_number(sorted, 2_000_000)
  stats_on_download_number(sorted, 3_000_000)
  stats_on_download_number(sorted, 5_000_000)
  stats_on_download_number(sorted, 10_000_000)
  stats_on_download_number(sorted, 20_000_000)
  stats_on_download_number(sorted, 30_000_000)
  stats_on_download_number(sorted, 50_000_000)
end
