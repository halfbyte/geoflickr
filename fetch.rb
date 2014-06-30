#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'faraday'
require 'json'

PER_PAGE = 500
FLICKR_API_KEY = ENV['FLICKR_API_KEY']
FLICKR_USER = "122072174@N05"

BASE_URI = "https://api.flickr.com/services/rest/"

CALL_BASE_CONFIG = {
  method: "flickr.people.getPublicPhotos",
  api_key: FLICKR_API_KEY,
  user_id: FLICKR_USER,
  per_page: PER_PAGE,
  format: 'json',
  nojsoncallback: 1,
  extras: 'geo,url_m'
}

page = 1
pages = 200

connection = Faraday::Connection.new(url: "https://api.flickr.com/services/rest/")

points = []

while(page < pages) do
  result = connection.get("", CALL_BASE_CONFIG.merge(page: page))
  if result.status == 200
    data = JSON.parse(result.body)
    puts data.inspect
    pages = data['photos']['pages']
    data['photos']['photo'].each do |photo|
      lat = photo['latitude']
      lon = photo['longitude']
      if (lat && lon && lat != 0 && lon != 0)
        
        points << {
          type: 'Feature',
          properties: {
            caption: photo['title'],
            imgsrc: photo['url_m'], 
            entryurl: "https://www.flickr.com/photos/{FLICKR_USER}/{photo['id']}",
            tags: photo['tags'],
            source: "Flickr"
          },
          geometry: {
            type: 'Point',
            coordinates: [lon, lat]
          }
        }   
      end
    end
  else
    puts "result_status: #{result.status}, message: #{result.body}"
    break
  end
end

geojson = {
  type: 'FeatureCollection',
  features: points
}

puts geojson.to_json

File.open("#{FLICKR_USER}.geojson", 'wb') do |f|
  f.write(geojson.to_json)
end
