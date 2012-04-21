Gem::Specification.new do |s|

  s.name             = 'grizzled-rails-logger'
  s.version          = '0.1.2'
  s.date             = '2012-04-21'
  s.summary          = 'A custom Rails 3 logger'
  s.authors          = ['Brian M. Clapper']
  s.license          = 'BSD'
  s.email            = 'bmc@clapper.org'
  s.homepage         = 'http://software.clapper.org/grizzled-rails-logger'

  s.description      = <<-ENDDESC
A custom Rails 3 logger
ENDDESC

  s.require_paths    = ['lib']

  s.add_dependency('term-ansicolor', '>= 1.0.7')

  # = MANIFEST =
  s.files            = Dir.glob('[A-Z]*')
  s.files           += Dir.glob('*.gemspec')
  s.files           += Dir.glob('lib/**/*')
  s.files           += Dir.glob('rdoc/**/*')

  # = MANIFEST =
  s.test_files       = Dir.glob('test/**/tc_*.rb')
end


