# frozen_string_literal: true

require 'selenium-webdriver'

# basic utiities class that returns pertinent information about our users and environments
class Utils
  def self.get_user_info(user)
    case user.downcase
    when 'applicant'
      %w[applicant password]
    when 'supervisor'
      %w[supervisor password]
    when 'nonexistent'
      %w[baduser password]
    else
      raise 'No such user'
    end
  end

  def self.env_picker(application)
    env = (ENV['ENVIRONMENT'] || 'local').downcase
    case env
    when 'local'
      localhost_ports(application)
    else
      "https://#{application}-#{env}.mysite.net"
    end
  end

  def self.localhost_ports(application)
    case application.downcase
    when 'app1'
      'http://localhost:8000'
    when 'app2'
      'http://localhost:8001'
    else
      raise "No local port found for application: #{application}"
    end
  end

  def self.proxy
    ENV['PROXY'] ? Selenium::WebDriver::Proxy.new(http: ENV['PROXY'], ssl: ENV['PROXY']) : nil
  end

  def self.platform
    (ENV['PLATFORM'] || 'any').to_sym
  end

  def self.build
    ENV['BUILD_URL'] ? "#{ENV['TEST_TYPE']} for #{ENV['BRANCH_NAME']} Build #{ENV['BUILD_NUMBER']}" : nil
  end

  def self.basic_capabilities(scenario)
    {
      proxy: proxy,
      accept_insecure_certs: true,
      browser_version: ENV['VERSION'],
      platform_name: platform,
      'sauce:options': {
        name: scenario.name.to_s,
        build: build,
        screen_resolution: ENV['RESOLUTION']
      }
    }
  end

  def self.capabilities(scenario, browser)
    caps = basic_capabilities(scenario)
    case browser
    when 'firefox'
      Selenium::WebDriver::Remote::Capabilities.firefox(caps)
    when 'edge'
      Selenium::WebDriver::Remote::Capabilities.edge(caps)
    when 'safari'
      caps[:accept_insecure_certs] = false
      Selenium::WebDriver::Remote::Capabilities.safari(caps)
    when 'ie'
      caps[:accept_insecure_certs] = false
      Selenium::WebDriver::Remote::Capabilities.internet_explorer(caps)
    else
      Selenium::WebDriver::Remote::Capabilities.chrome(caps)
    end
  end

  def self.driver(scenario)
    browser = (ENV['BROWSER'] || 'chrome').downcase
    url = ENV['REMOTE']
    capabilities = capabilities(scenario, browser)
    browser = (url ? 'remote' : browser).to_sym
    [browser, url, capabilities]
  end

  def self.sauce
    ENV['REMOTE']&.include? 'saucelabs.com'
  end

  def self.sauce_credentials
    username = ENV['SAUCE_USERNAME'] || URI.parse(ENV['REMOTE']).user
    password = ENV['SAUCE_PASSWORD'] || URI.parse(ENV['REMOTE']).password
    [username, password]
  end
end
