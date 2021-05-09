$:.unshift File.join(File.dirname(__FILE__), 'lib')
require 'ohey/version'

Gem::Specification.new do |s|
  s.name     = 'ohey'
  s.version  = ::Ohey::VERSION
  s.authors  = ['Cameron Dutro']
  s.email    = ['camertron@gmail.com']
  s.homepage = 'http://github.com/camertron/ohey'

  s.description = s.summary = 'A rewrite of the platform detection logic in ohai, '\
    'but with fewer dependencies and 100% less metaprogramming.'
  s.platform = Gem::Platform::RUBY

  s.add_dependency 'wmi-lite', '~> 1.0'

  s.require_path = 'lib'
  s.files = Dir['{lib,spec}/**/*', 'Gemfile', 'CHANGELOG.md', 'README.md', 'Rakefile', 'ohey.gemspec']
end
