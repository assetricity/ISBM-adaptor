# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "isbm/version"

Gem::Specification.new do |s|
  s.name        = "isbm"
  s.version     = Isbm::VERSION
  s.authors     = ["Brandon Mathis"]
  s.email       = ["Brandon@KeysetTS.com"]
  s.homepage    = "http://www.assetricity.com"
  s.summary     = %q{OpenO&M ISBM adaptor}
  s.description = %q{OpenO&M ISBM adaptor}
  s.license     = ""

  s.rubyforge_project = "isbm"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec", "2.11.0"
  s.add_development_dependency "rspec-given", "1.5.0"
  s.add_development_dependency "rake", "0.9.2.2"
  s.add_runtime_dependency "savon", "1.1.0"
end
