# frozen_string_literal: true

require_relative './lib/alex'
Gem::Specification.new do |s|
  s.name        = Alex::NAME
  s.version     = Alex::VERSION
  s.date        = Time.now.strftime('%F')
  s.summary     = 'Proof of concept for preference learning algorithms.'
  s.description = 'An agent that learns preferences from a user. '\
    '(Proof of concept)'
  s.author      = 'Maxine Michalski'
  s.email       = 'maxine@furfind.net'
  s.files       = Dir['lib/**/*.rb']
  s.homepage    = 'https://github.com/maxine-red/alex'
  s.license     = 'GPL-3.0'
  s.required_ruby_version = '~> 2.3'
  s.add_development_dependency 'rspec', '~> 3.6'
  s.add_development_dependency 'rubocop', '= 0.54.0'
  s.add_development_dependency 'simplecov', '~> 0.16.0'
  s.add_development_dependency 'yard', '~> 0.9.12'
  s.add_runtime_dependency 'json', '~> 2.0'
  s.add_runtime_dependency 'pg', '~> 1.0'
  s.add_runtime_dependency 'ruby-fann', '~> 1.2'
  s.add_runtime_dependency 'rubyhexagon', '~> 1.6'
end
