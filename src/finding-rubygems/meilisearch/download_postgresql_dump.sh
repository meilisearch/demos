#!/bin/sh

# Inspired by the "load-pg-dump script" (https://github.com/rubygems/rubygems.org/tree/master/script/load-pg-dump)
# from https://rubygems.org website

if [ -z "$1" ]; then
  echo 'Should pass a name of destination file as argument.'
  echo 'Usage: ./download_postgresql_dump.sh <filename>'
  exit 1
fi

base_url='https://s3-us-west-2.amazonaws.com/rubygems-dumps/'
prefix='production/public_postgresql'
public_tar='rubygems_data.tar'
dump_file_gz='public_postgresql/databases/PostgreSQL.sql.gz'
final_dump_file="$1"

key=$(curl -s "${base_url}?prefix=${prefix}" | sed -ne 's/.*<Key>\(.*\)<\/Key>.*/\1/p')
latest_url="${base_url}${key}"
echo "Downloading ${latest_url} to ${public_tar}"
rm -rf "$public_tar"
curl "$latest_url" > "$public_tar"

rm -f "$dump_file_gz"
rm -f "$final_dump_file"
tar xf "$public_tar" "$dump_file_gz"
gunzip -c "$dump_file_gz" > "$final_dump_file"

exit 0
