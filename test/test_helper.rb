if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start do
    add_filter 'test'
    command_name 'Mintest'
  end
end

gem "minitest"
require "minitest/autorun"
require "minitest/pride"
