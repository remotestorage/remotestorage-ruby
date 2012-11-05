
RAILS_ENV ||= 'test'

require File.expand_path('../../config/boot.rb', __FILE__)
require File.expand_path('../../config/environment.rb', __FILE__)

RemoteStorage::HOSTNAME = 'test.host'

require 'rspec/rails'
require 'database_cleaner'

RSpec.configure do |config|

  require 'support/launch_helper'

  config.include LaunchHelper

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end
