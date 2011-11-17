require 'open-uri'
require 'net/http'

module Linkser
  module Parser
    def self.parse url, options={}
      if !is_valid_url? url
      raise "Invalid URL"
      end
      head = get_head url
      case head.content_type
      when "text/html"
        Linkser::Parser::HTML.new.parse url
      else
      raise "I have no idea on how to parse a '" + head.content_type + "'"
      end
    end

    #private

    def self.get_head url, limit = 10
      if (limit==0)
      raise 'Too many HTTP redirects. URL was not reacheable within the HTTP redirects limit'
      end
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
      raise 'The HTTP responded with an ' + response.code + ' code'
      end
    end

    def self.is_valid_url? url
      begin
        uri = URI.parse(url)
        if [:scheme, :host].any? { |i| uri.send(i).blank? }
        raise(URI::InvalidURIError)
        end
        return true
      rescue URI::InvalidURIError => e
      return false
      end
    end
  end
end

