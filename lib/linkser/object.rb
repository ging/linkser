module Linkser
  class Object
    attr_reader :url, :head
    
    def initialize url, head, options={}
      @url = url
      @heade = head
    end
  end
end
