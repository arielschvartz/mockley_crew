$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "mockley_crew/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "mockley_crew"
  s.version     = MockleyCrew::VERSION
  s.authors     = ["Ariel Schvartz"]
  s.email       = ["ari.shh@gmail.com"]
  s.homepage    = "https://github.com/arielschvartz"
  s.summary     = "Rock your API integration tests by mocking data into multiple SQLite3 instances"
  s.description = "With Mockley Crew, you can create fake databases to use from your API consumer. This way, you can isolate the consumer tests by having multiple data scenarios built on your API."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.bindir        = "exe"
  # s.executables   = ["crew"]
  
  s.add_dependency "rails", "~> 5.2.0"
  s.add_dependency "factory_bot_rails"
  
  s.add_development_dependency "sqlite3"

  s.add_development_dependency "pry-rails"
  s.add_development_dependency "timecop"

  s.add_development_dependency "rspec-rails", "~> 3.2"
end
