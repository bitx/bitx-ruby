require 'faraday'
require 'json'
require 'bigdecimal'
require_relative 'public_api'
require_relative 'private_api'
require_relative 'version'

module BitX
  class Configuration
    attr_accessor :api_key_id, :api_key_secret
  end

  def self.configuration
    @configuration ||=  Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
  end

  class Error < StandardError
  end

  extend PublicApi
  extend PrivateApi

protected

  def self.conn
    conn = Faraday.new(url: 'https://mybitx.com')
    conn.headers[:user_agent] = "bitx-ruby/#{BitX::VERSION::STRING}"
    conn
  end

  def self.get(url, params)
    r = self.conn.get(url, params)
    if r.status != 200
      raise Error.new("BitX error: #{r.status}")
    end
    t = JSON.parse r.body
    if t['error']
      raise Error.new('BitX error: ' + t['error'])
    end
    t
  end
end
