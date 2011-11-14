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

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
