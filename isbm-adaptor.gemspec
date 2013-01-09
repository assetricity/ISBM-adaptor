# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "isbm-adaptor/version"

Gem::Specification.new do |s|
  s.name        = "isbm-adaptor"
  s.version     = IsbmAdaptor::VERSION
  s.authors     = ["Assetricity"]
  s.email       = ["info@assetricity.com"]
  s.homepage    = "http://www.assetricity.com"
  s.summary     = %q{OpenO&M ISBM adaptor}
  s.description = %q{OpenO&M ISBM adaptor based on Savon}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec", "~> 2.12.0"
  s.add_development_dependency "rake", "~> 0.9.2.2"
  s.add_development_dependency "vcr", "~> 2.3.0"
  s.add_development_dependency "fakeweb", "~> 1.3.0"
  s.add_runtime_dependency "savon", "~> 1.2.0"
end
