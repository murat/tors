# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tors/version'

Gem::Specification.new do |spec|
  spec.name          = 'tors'
  spec.version       = TorS::VERSION
  spec.authors       = ['Murat Bastas']
  spec.email         = ['muratbsts@gmail.com']

  spec.summary       = 'Yet another torrent searching application for your command line.'
  spec.description   = 'Yet another torrent searching application for your command line. But this has an option for automatically download the best torrent.'
  spec.homepage      = 'https://github.com/muratbsts/tors'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'nokogiri', '~> 1.8', '>= 1.8.0'
  spec.add_dependency 'colorize', '~> 0.8.1'
  spec.add_dependency 'tty-table', '~> 0.8.0'
  spec.add_dependency 'tty-prompt', '~> 0.13.1'

  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
