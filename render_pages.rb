#!/usr/bin/env ruby

require 'erb'
require './lib/accounts'
require 'fileutils'



DEST = "public"


Template = Struct.new(:title, :flickr_id, :mapbox_id) do
  def build(file)
    b = binding
    return ERB.new(File.read(file)).result(b)
  end
end

def render_all

  accounts = Accounts.new

  accounts.each do |account|
    puts account['title']
    templates = %w(index stats uncoded)

    templates.each do |template|
      dest_file = File.join(DEST, account['flickr_id'],"#{template}.html")
      template_file = File.join("templates", "#{template}.erb")
      template = Template.new(account['title'], account['flickr_id'], account['mapbox_id'])
      FileUtils.mkdir_p(File.dirname(dest_file))
      File.open(dest_file, 'wb') do |file|
        file.write(template.build(template_file))
      end


    end


  end
end