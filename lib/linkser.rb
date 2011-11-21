require 'linkser/version'

module Linkser
  autoload :Parser, 'linkser/parser'
  autoload :Object, 'linkser/object'
  module Objects
    autoload :HTML, 'linkser/objects/html'
  end
end

