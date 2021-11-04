# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.3'

group :test do
  gem 'axe-core-cucumber'
  gem 'cucumber', '~> 6.1.0'
  gem 'cuke_modeler'
  gem 'parallel_tests'
  gem 'report_builder'
  gem 'rspec', '~> 3.10.0'
  gem 'selenium-webdriver', '~> 3.141.59'
  gem 'test-unit', '~> 3.1', '>= 3.1.8'
  gem 'webdrivers', '~> 4.0', require: false

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
end
