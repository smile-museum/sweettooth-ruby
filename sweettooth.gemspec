$:.unshift(File.join(File.dirname(__FILE__), 'lib'))

require 'sweettooth/version'

spec = Gem::Specification.new do |s|
  s.name = 'sweettooth'
  s.version = SweetTooth::VERSION
  s.summary = 'Ruby bindings for the Sweet Tooth API'
  s.description = 'Sweet Tooth is the easiest way to create powerful customer loyalty programs for your business.  See https://www.sweettoothrewards.com for details.'
  s.authors = ['Bill Curtis']
  s.email = ['wcurtis@sweettoothhq.com']
  s.homepage = 'https://www.sweettoothrewards.com/api'

  s.add_dependency('rest-client', '~> 1.4')
  s.add_dependency('mime-types', '~> 1.25')
  s.add_dependency('multi_json', '>= 1.0.4', '< 2')

  s.add_development_dependency('mocha', '~> 0.13.2')
  s.add_development_dependency('shoulda', '~> 3.4.0')
  s.add_development_dependency('test-unit')
  s.add_development_dependency('rake')

  s.files = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.require_paths = ['lib']
end
