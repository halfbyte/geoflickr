# GEOflickr

A simple tool to create Maps and Stats from flickr photo streams.

(c) Jan 'halfbyte' Krutisch (jan@krutisch.de)

## Setup

* Run $ bundle install to install all needed ruby libraries (gems)
* Replace flickr_accounts.yml with your own data:
  * Get a map_id and a public acces token from mapbox.
  * Get your flickr account id
* You probably also want to change the public/index.html. Feel free to credit me.

## Running

Just run the fetch_all rake task.

The Flickr-API key needs to be set as an Environment Variable during the run, for example like this:

    $ FLICKR_API_KEY=asdhjk32h4jk1h34khasdasd rake fetch_all

## Serving

The

## License

Licensed under the MIT License, see [LICENSE](LICENSE)
