# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'athena-utils'
  s.version     = '0.2.0'
  s.licenses    = ['MIT']
  s.summary     = 'Athena Utils'
  s.description = 'Tools for querying AWS Athena'
  s.authors     = ['Doug Youch']
  s.email       = 'dougyouch@gmail.com'
  s.homepage    = 'https://github.com/dougyouch/athena-utils'
  s.files       = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.bindir      = 'bin'
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }

  s.add_runtime_dependency 'aws-sdk-athena'
  s.add_runtime_dependency 'aws-sdk-s3'
end
