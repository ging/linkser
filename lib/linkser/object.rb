require 'net/http'
require 'net/https'

module Linkser
  class Object
    extend ActiveSupport::Memoizable

    attr_reader :url, :last_url, :head
    def initialize url, last_url, head, options={}
      @url = url
      @last_url = last_url
      @head = head
      @options = options
    end

    def body
      uri = URI.parse last_url
      if uri.scheme and (uri.scheme.eql? "http" or uri.scheme.eql? "https")
        http = Net::HTTP.new uri.host, uri.port
        if uri.scheme.eql? "https"
          unless @options[:ssl_verify]==true
           http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          end
          http.use_ssl = true
        end
      else
      raise 'URI ' + uri.to_s + ' is not supported by Linkser'
      end
      http.start do |agent|
        request = Net::HTTP::Get.new uri.request_uri
        response = http.request request
        return response.body
      end
    end

    memoize :body

  end
end

require 'linkser/objects/html'
