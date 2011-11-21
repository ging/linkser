require 'open-uri'
require 'net/http'

module Linkser
  module Parser
    def self.parse url, options={}
      head = get_head url

      case head.content_type
      when "text/html"
        Linkser::Objects::HTML.new url, head
      else
      raise "I have no idea on how to parse a '" + head.content_type + "'"
      end
    end

    private

    def self.get_head url, limit = 10
      raise 'Too many HTTP redirects. URL was not reacheable within the HTTP redirects limit' if (limit==0)
      uri = URI.parse url
      http = Net::HTTP.start uri.host, uri.port
      response = http.head uri.request_uri
      case response
      when Net::HTTPSuccess then
        return response
      when Net::HTTPRedirection then
        location = response['location']
        warn "Redirecting to #{location}"
        return get_head location, limit - 1
      else
      raise 'The HTTP request has a ' + response.code + ' code'
      end
    end
  end
end

