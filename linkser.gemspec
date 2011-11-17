# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "linkser/version"

Gem::Specification.new do |s|
  s.name        = "linkser"
  s.version     = Linkser::VERSION
  s.authors     = ["Eduardo Casanova"]
  s.email       = ["ecasanovac@gmail.com"]
  s.homepage    = "https://github.com/ging/linkser"
  s.summary     = "TODO"
  s.description = "TODO"

  s.rubyforge_project = "linkser"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # Gem dependencies
  #
  s.add_runtime_dependency('rake')
  s.add_runtime_dependency('nokogiri', '~> 1.4.2')
  s.add_runtime_dependency('rmagick', '~> 2.13.1')
  s.add_runtime_dependency('ruby-imagespec', "~> 0.2.0")  
  
  # Development Gem dependencies
  #
  # Debugging
  if RUBY_VERSION < '1.9'
    s.add_development_dependency('ruby-debug', '>= 0.10.3')
  end
  # Specs
  s.add_development_dependency('rspec', '>= 2.7.0')
end
