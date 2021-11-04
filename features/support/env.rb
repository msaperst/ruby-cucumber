# frozen_string_literal: true

require 'selenium-webdriver'
require 'webdrivers'
require_relative '../utils/utils'
require_relative './update'

Before do |scenario|
  browser, url, capabilities = Utils.driver(scenario)
  @driver_old = Selenium::WebDriver.for(browser, url: url, desired_capabilities: capabilities)
  @driver_old.manage.window.maximize
  @wait = Selenium::WebDriver::Wait.new(timeout: 10)
  @driver = Page.new(@driver_old, @wait, true)
end

After do |scenario|
  screenshot = "reports/#{scenario.name}.png"
  @driver.save_screenshot(screenshot)
  attach screenshot, 'image/jpg'
  Update.sauce(scenario, @driver.session_id) if Utils.sauce
  Update.jira(scenario) if ENV['JIRA']
  @driver.quit
end
