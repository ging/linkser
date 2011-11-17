require 'linkser/version'

module Linkser
  autoload :Parser, 'linkser/parser'
  module Parser
    autoload :HTML, 'linkser/parser/html'
  end
end

