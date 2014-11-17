require 'rake'
require './fetch'
require './render_pages'


desc "fetch all accounts"
task :fetch_all => [:render_all] do
  fetch_all
end

desc "render all templates"
task :render_all do
  render_all
end

task :default => [:fetch_all]