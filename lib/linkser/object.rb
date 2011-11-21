module Linkser
  class Object
    extend ActiveSupport::Memoizable

    attr_reader :url, :head
    
    def initialize url, head, options={}
      @url = url
      @heade = head
    end

    def body
      open(url)
    end

    memoize :body


  end
end

require 'linkser/objects/html'
