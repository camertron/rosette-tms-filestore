$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'rosette/tms/filestore-tms/version'

Gem::Specification.new do |s|
  s.name     = 'rosette-tms-filestore'
  s.version  = ::Rosette::Tms::FilestoreTms::VERSION
  s.authors  = ['Cameron Dutro']
  s.email    = ['camertron@gmail.com']
  s.homepage = 'http://github.com/camertron'

  s.description = s.summary = 'A Rosette TMS that stores translations to disk (as opposed to a 3rd-party service).'

  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true

  s.require_path = 'lib'
  s.files = Dir["{lib,spec}/**/*", 'Gemfile', 'History.txt', 'README.md', 'Rakefile', 'rosette-tms-filestore.gemspec']
end
