#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'faraday'
require 'json'
require 'time'

PER_PAGE = 500
FLICKR_API_KEY = ENV['FLICKR_API_KEY']
FLICKR_USER = ENV['FLICKR_USER'] || "122072174@N05"

BASE_URI = "https://api.flickr.com/services/rest/"

SYMBOLS = {
  'car' => 'car',
  'trashcan' => 'waste-basket',
  'signage' => 'roadblock'
  
}


CALL_BASE_CONFIG = {
  method: "flickr.people.getPublicPhotos",
  api_key: FLICKR_API_KEY,
  user_id: FLICKR_USER,
  per_page: PER_PAGE,
  format: 'json',
  nojsoncallback: 1,
  extras: 'geo,url_m,tags,date_taken'
}

page = 1
pages = 200

connection = Faraday::Connection.new(url: "https://api.flickr.com/services/rest/")

points = []

def tags_to_symbol(tags)
  tag = tags.first
  return SYMBOLS[tag] || 'circle'  
end

TIME = Time.now

def age_to_color(age)
  return "#ccc" if age.nil?
  blue = 200 + (55 - ([age,1.0].min * 55))
  "#c8c8#{blue.to_s(16)}"
end

while(page < pages) do
  result = connection.get("", CALL_BASE_CONFIG.merge(page: page))
  if result.status == 200
    data = JSON.parse(result.body)
    puts data.inspect
    pages = data['photos']['pages']
    data['photos']['photo'].each do |photo|
      lat = photo['latitude']
      lon = photo['longitude']
      age = nil
      
      begin
        date_taken = Time.parse(photo['date_taken'])      
        age = Time.now - date_taken / (3600.0 * 24.0 * 365.0)
      rescue TypeError
        # puts "ERROR: #{photo['date_taken']}"
      end
      
      
      if (lat && lon && lat != 0 && lon != 0)
        
        entryurl = "https://www.flickr.com/photos/#{FLICKR_USER}/#{photo['id']}"
        
        points << {
          type: 'Feature',
          properties: {
            title: photo['title'],
            description: "<p><a target='_blank' href='#{entryurl}'><img src='#{photo['url_m']}' style='width: 100%;'/></a></p><p>#{photo['title']}</p><p class='source'>Quelle: Flickr</p>",
            "marker-size" => "medium",
            "marker-symbol" => tags_to_symbol(photo['tags'].split(" ")),
            "marker-color" => age_to_color(age)
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
