require 'yaml'

class Accounts
  def initialize
    @data = YAML.load_file("flickr_accounts.yml")
    @accounts = @data['accounts']
  end

  def each &block
    @accounts.each &block
  end

end