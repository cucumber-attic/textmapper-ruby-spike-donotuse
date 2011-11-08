Gem::Specification.new do |s|
  s.name        = 'textmapper'
  s.version     = '0.1.0'
  s.authors     = ["Mike Sassak"]
  s.description = "Dispatch Ruby with patterns built from plain text"
  s.summary     = "textmapper #{s.version}"
  s.email       = "msassak@gmail.com"
  s.homepage    = "https://github.com/cucumber/textmapper-ruby"

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'simplecov'

  s.rubygems_version   = "1.3.7"
  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {spec,features}/*`.split("\n")
  s.extra_rdoc_files = ["LICENSE", "README.md"]
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"
end
