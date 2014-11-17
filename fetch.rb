#!/usr/bin/env ruby

require 'rubygems'
require 'bundler/setup'
require 'faraday'
require 'json'
require 'time'
require './lib/accounts'

PER_PAGE = 500
FLICKR_API_KEY = ENV['FLICKR_API_KEY']

BASE_URI = "https://api.flickr.com/services/rest/"


# This maps certain flickr tags to mapbox maki icons: https://www.mapbox.com/maki/
SYMBOLS = {
  'car' => 'car',
  'trashcan' => 'waste-basket',
  'trash' => 'waste-basket',
  'signage' => 'roadblock',
  'plants' => 'park2',
  'truck' => 'car',
  'animal' => 'dog-park',
  'bike' => 'bicycle',
  'motorcycle' => 'scooter',
  'policecar' => 'police',
  'hoarding' => 'prison',
  'shoppingcart' => 'grocery',
  'people' => 'school',
  'obstacle' => 'roadblock',
  'hydrant' => 'water',
  'lamppost' => 'lighthouse',
  'construction' => 'oil-well'

}


CALL_BASE_CONFIG = {
  method: "flickr.people.getPublicPhotos",
  api_key: FLICKR_API_KEY,
  per_page: PER_PAGE,
  format: 'json',
  nojsoncallback: 1,
  extras: 'geo,url_m,url_o,tags,date_taken'
}


def tags_to_symbol(tags)
  tags.each do |tag|
    return SYMBOLS[tag] if SYMBOLS[tag]
  end
  return 'circle'
end

TIME = Time.now

def merge_tags(tag_stats, tagstring)
  tags_merged = false
  tags = tagstring.split(" ")
  tags.each do |tag|
    tag = tag.downcase.strip
    if SYMBOLS[tag]
      tags_merged = true
      tag_stats[tag] = (tag_stats[tag] || 0) + 1
    end
  end
  return tags_merged
end

def age_to_color(age)
  return "#ccc" if age.nil?
  blue = 200 + (55 - ([age,1.0].min * 55))
  grey = 200 - (100 - ([age,1.0].min * 100))
  "##{grey.to_i.to_s(16)}#{grey.to_i.to_s(16)}#{blue.to_i.to_s(16)}"
end



def fetch_all

  connection = Faraday::Connection.new(url: "https://api.flickr.com/services/rest/")
  accounts = Accounts.new

  accounts.each do |account|

    page = 1
    pages = 200

    points = []
    tag_stats = {}
    all = 0
    geocoded = 0
    tagged = 0

    non_geocoded_entries = []

    puts "account: #{account['flickr_id']}"

    while(page <= pages) do
      result = connection.get("", CALL_BASE_CONFIG.merge(page: page, user_id: account['flickr_id']))
      if result.status == 200
        puts "new page #{page}"
        page += 1
        data = JSON.parse(result.body)
        # puts data.inspect
        pages = data['photos']['pages']
        puts pages
        data['photos']['photo'].each do |photo|
          lat = photo['latitude']
          lon = photo['longitude']
          date_taken = nil
          age = nil
          all += 1
          begin
            date_taken = Time.parse(photo['datetaken'])
            age = (Time.now - date_taken) / (3600.0 * 24.0 * 365.0)
          rescue TypeError
            # puts "ERROR: #{photo['date_taken']}"
          end

          if merge_tags(tag_stats, photo['tags'])
            tagged += 1
          end

          entryurl = "https://www.flickr.com/photos/#{FLICKR_USER}/#{photo['id']}"

          if (lat && lon && lat != 0 && lon != 0)
            geocoded += 1


            points << {
              type: 'Feature',
              properties: {
                title: photo['title'],
                description: "<div>#{date_taken ? date_taken.strftime("%d.%m.%Y %H:%M") : ''}</div><p><a target='_blank' href='#{entryurl}'><img src='#{photo['url_m']}' style='width: 100%;'/></a></p><p>#{photo['title']}</p><p class='source'>Quelle: Flickr</p>",
                "marker-size" => "medium",
                "marker-symbol" => tags_to_symbol(photo['tags'].split(" ")),
                "marker-color" => age_to_color(age)
              },
              geometry: {
                type: 'Point',
                coordinates: [lon, lat]
              }
            }
          else
            non_geocoded_entries << {
              entry_url: entryurl,
              photo_url: photo['url_m'],
              original_url: photo['url_o'],
              tags: photo['tags'],
              title: photo['title'],
              id: photo['id']
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


    converted_tag_stats = tag_stats.map { |k, v|
      tag_stats[k] = {tag: k, count: v, icon: SYMBOLS[k]}
    }.sort_by {|s| s[:count] }.reverse

    stats = {
      tags: converted_tag_stats,
      all: all,
      geocoded: geocoded,
      tagged: tagged
    }

    # puts geojson.to_json

    File.open(File.join("public" , account['flickr_id'], "map.geojson"), 'wb') do |f|
      f.write(geojson.to_json)
    end

    File.open(File.join("public" , account['flickr_id'], "stats.json"), 'wb') do |f|
      f.write(stats.to_json)
    end

    File.open(File.join("public" , account['flickr_id'], "uncoded.json"), 'wb') do |f|
      f.write(non_geocoded_entries.to_json)
    end
  end
end
