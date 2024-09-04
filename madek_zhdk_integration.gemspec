
$:.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'madek_zhdk_integration/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'madek_zhdk_integration'
  s.version     = MadekZhdkIntegration::VERSION
  s.authors     = ['Thomas Schank']
  s.email       = ['DrTom@Schank.ch']
  s.homepage    = 'https://github.com/zhdk'
  s.summary     = 'Summary of MadekZhdkIntegration.'
  s.description = 'Description of MadekZhdkIntegration.'
  s.license     = 'GPL'

  s.files = Dir['{app,config,db,lib}/**/*', \
                'MIT-LICENSE', 'Rakefile', 'README.rdoc']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'rails', '~> 7.0.0'

end
