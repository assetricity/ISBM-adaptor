# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "isbm/version"

Gem::Specification.new do |s|
  s.name        = "isbm"
  s.version     = Isbm::VERSION
  s.authors     = ["Brandon Mathis"]
  s.email       = ["Brandon@KeysetTS.com"]
  s.homepage    = ""
  s.summary     = %q{ISBM adaptor for ruby}
  s.description = %q{ISBM adaptor for ruby}

  s.rubyforge_project = "isbm"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rspec"
  s.add_development_dependency "rspec-given"
  s.add_development_dependency "rake"
  if RUBY_PLATFORM =~ /java/
    s.add_development_dependency "jruby-openssl"
  end
  s.add_runtime_dependency "savon"
  s.add_runtime_dependency "savon_model"
  s.add_runtime_dependency "term-ansicolor"
end
