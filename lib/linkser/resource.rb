module Linkser
  class Resource    
    attr_accessor :type, :url, :width, :height
    
    def initialize obj
      case obj       
      when OpenGraph::Object
        @type = obj["type"].split(".")[0] if obj["type"]
        if @type
          @url = obj[@type] if obj[@type]
          @url = obj[@type + ":url"] if @url.nil? and obj[@type + ":url"]
          @width = obj[@type + ":width"] if obj[@type + ":width"]
          @height = obj[@type + ":height"] if obj[@type + ":height"]
        end
      when Hash
        @type = obj[:type] if obj[:type]
        @url = obj[:url] if obj[:url]
        @width = obj[:width] if obj[:width]
        @height = obj[:height] if obj[:height]
      else
        raise 'Error creating the Linkser::Resource. Expecting Hash or OpenGraph::Object but got ' + obj.class.to_s
      end
    end
  end
end
