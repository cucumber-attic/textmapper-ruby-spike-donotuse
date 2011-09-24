Gem::Specification.new do |s|
  s.name        = 'cucumber-text_mapper'
  s.version     = '0.1.0'
  s.authors     = ["Mike Sassak"]
  s.description = "Cucumber TextMapper"
  s.summary     = "cucumber-text_mapper #{s.version}"
  s.email       = "msassak@gmail.com"
  s.homepage    = "https://github.com/cucumber/cucumber-text_mapper"

  s.add_development_dependency 'rspec'

  s.rubygems_version   = "1.3.7"
  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {spec,features}/*`.split("\n")
  s.extra_rdoc_files = ["LICENSE", "README.md"]
  s.rdoc_options     = ["--charset=UTF-8"]
  s.require_path     = "lib"
end
