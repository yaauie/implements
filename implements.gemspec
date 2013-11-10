# encoding: utf-8
require 'english'

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'implements/version'

Gem::Specification.new do |spec|
  spec.name          = 'implements'
  spec.version       = Implements::VERSION
  spec.authors       = ['Ryan Biesemeyer']
  spec.email         = ['ryan@simplymeasured.com']
  spec.summary       = 'A tool for building and implementing interfaces.'
  spec.description   = <<-EODESC.gsub(/^[\w]+/, ' ').squeeze
    Implements is a tool for building modular libraries and tools as
    interfaces, for implementing those interfaces, and ensuring that
    consumers are able to load the best available implementation at
    runtime.
  EODESC
  spec.homepage      = 'https://github.com/yaauie/implements'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(/^bin\//) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(/^(test|spec|features)\//)
  spec.require_paths = ['lib']

  spec.add_runtime_dependency     'activesupport'

  spec.add_development_dependency 'bundler', '~> 1.4.0.rc.1'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 2.14'


  # code quality
  spec.add_development_dependency 'ruby-appraiser-reek'
  spec.add_development_dependency 'ruby-appraiser-rubocop'
end
