lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require './lib/rwordnet/version'

Gem::Specification.new do |s|
  s.name = "rwordnet"
  s.version = WordNet::VERSION
  s.summary = "A pure Ruby interface to the WordNet database"
  s.authors = ["Trevor Fountain", "Wolfram Sieber", "Michael Grosser"]
  s.email = "trevor@texasexpat.net"
  s.homepage = "https://github.com/doches/rwordnet"
  s.license = "MIT"
  
  s.files         = `git ls-files -z`.split("\x0")
  s.require_paths = ['lib']
  
  s.required_ruby_version = '>= 2.4.0'
end
