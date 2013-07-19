
RAILS_ENV ||= 'test'

require File.expand_path('../../config/boot.rb', __FILE__)
require File.expand_path('../../config/environment.rb', __FILE__)

RemoteStorage::HOSTNAME = 'test.host'

require 'rspec/rails'
require 'database_cleaner'

RSpec.configure do |config|

  BINARY_CHARSET = RUBY_VERSION >= '1.9.3' ? 'ASCII-8BIT' : 'US-ASCII'

  require 'support/launch_helper'

  config.include LaunchHelper

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end
