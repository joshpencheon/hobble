Gem::Specification.new do |gem|
  gem.name        = 'hobble'
  gem.summary     = 'Debt-based scheduling'
  gem.description = 'A ruby debt-based scheduling implementation'
  gem.authors     = ['Josh Pencheon']
  gem.homepage    = 'http://rubygems.org/gems/hobble'
  gem.license     = 'MIT'

  gem.version     = '0.1.0'
  gem.date        = '2014-08-04'
  gem.files       = ['lib/hobble.rb', 'lib/hobble/scheduler.rb', 'lib/hobble/collection.rb']

  gem.add_development_dependency 'minitest', '~> 5.4'
  gem.add_development_dependency 'rake'
end
