source :rubygems

gemspec

gem 'activesupport'
gem 'i18n'
gem 'tzinfo'
gem 'rake',       '~> 0.8.7'

group :development do
  gem 'ore-core',   '~> 0.1.0'
  gem 'rspec',      '~> 2.5.0'
  case RUBY_PLATFORM
  when 'java'
    gem 'maruku'
  else
    gem 'bluecloth',  '>= 2.0.0'
  end
  gem 'yard',         '~> 0.6.0'
  gem 'guard',        '~> 0.3.0'
  gem 'guard-rspec',  '~> 0.2.0'
  gem 'ci_reporter',  '~> 1.6.4'
  gem 'rcov',         '~> 0.9.9'
  gem 'flog',         '~> 2.5.0'
  gem 'yardstick'
  # install separately so that we can do a bundle install --deployment --without development
  # when packaging to .exe
  #gem 'rawr',         :git => 'https://github.com/sundbp/rawr.git'
end
