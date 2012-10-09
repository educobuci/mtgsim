# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "mtgsim"
  s.version     = "0.0.1"
  s.authors     = ["dudurockx"]
  s.homepage    = ""
  s.summary     = %q{Mtg Sim}
  s.description = %q{Mtg Sim}

  # dependences
  # s.add_dependency "libxml-ruby"
  # s.add_dependency "fog"
  # s.add_dependency "activesupport", "~> 3.0.9"
  # s.add_dependency "i18n"
  # s.add_development_dependency "rspec"
  # s.add_development_dependency "rake"
  
  # paths
  s.files         = `git ls-files`.split("\n")
#  s.test_files    = `git ls-files -- {test,spec,features,assets}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
