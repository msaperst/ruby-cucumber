# frozen_string_literal: true

require_relative '../../../features/utils/utils'

# mock scenario
class Scenario
  def name
    'my name'
  end
end

RSpec.describe Utils do
  it 'successfully identifies the applicant user' do
    actual_user = described_class.get_user_info('applicant')
    expect(actual_user).to eq(%w[applicant password])
  end

  it 'successfully identifies the applicant user is case insensative' do
    actual_user = described_class.get_user_info('Applicant')
    expect(actual_user).to eq(%w[applicant password])
  end

  it 'successfully identifies the supervisor user' do
    actual_user = described_class.get_user_info('supervisor')
    expect(actual_user).to eq(%w[supervisor password])
  end

  it 'successfully identifies the nonexistent user' do
    actual_user = described_class.get_user_info('nonexistent')
    expect(actual_user).to eq(['baduser', 'password'])
  end

  it 'unsuccessfully identifies an unknown user' do
    expect { described_class.get_user_info('unknown') }.to raise_error(RuntimeError, 'No such user')
  end

  it 'returns applicant site for local testing by default' do
    actual_site = described_class.env_picker('app1')
    expect(actual_site).to eq('http://localhost:8000')
  end

  it 'returns admin site for local testing by default' do
    actual_site = described_class.env_picker('app2')
    expect(actual_site).to eq('http://localhost:8001')
  end

  it 'returns applicant site for local testing when provided' do
    env = ENV['ENVIRONMENT']
    ENV['ENVIRONMENT'] = 'local'
    actual_site = described_class.env_picker('app1')
    ENV['ENVIRONMENT'] = env
    expect(actual_site).to eq('http://localhost:8000')
  end

  it 'returns admin site for local testing when provided' do
    env = ENV['ENVIRONMENT']
    ENV['ENVIRONMENT'] = 'LOCAL'
    actual_site = described_class.env_picker('app2')
    ENV['ENVIRONMENT'] = env
    expect(actual_site).to eq('http://localhost:8001')
  end

  it 'throws an unknown app error for local testing when provided' do
    env = ENV['ENVIRONMENT']
    ENV['ENVIRONMENT'] = 'lOcAl'
    begin
      expect do
        described_class.env_picker('my-site')
      end.to raise_error(RuntimeError, 'No local port found for application: my-site')
    ensure
      ENV['ENVIRONMENT'] = env
    end
  end

  it 'returns applicant site for qa testing when provided' do
    env = ENV['ENVIRONMENT']
    ENV['ENVIRONMENT'] = 'qa'
    actual_site = described_class.env_picker('app1')
    ENV['ENVIRONMENT'] = env
    expect(actual_site).to eq('https://app1-qa.mysite.net')
  end

  it 'returns admin site for staging testing when provided' do
    env = ENV['ENVIRONMENT']
    ENV['ENVIRONMENT'] = 'staging'
    actual_site = described_class.env_picker('admin-ui')
    ENV['ENVIRONMENT'] = env
    expect(actual_site).to eq('https://app2-staging.app2.net')
  end

  it 'return nil when no proxy is provided' do
    env = ENV['PROXY']
    ENV['PROXY'] = nil
    actual_proxy = described_class.proxy
    ENV['PROXY'] = env
    expect(actual_proxy).to eq(nil)
  end

  it 'return proxy when proxy is provided' do
    env = ENV['PROXY']
    ENV['PROXY'] = 'localhost:1234'
    actual_proxy = described_class.proxy
    ENV['PROXY'] = env
    expect(actual_proxy).to eq(Selenium::WebDriver::Proxy.new(http: 'localhost:1234', ssl: 'localhost:1234'))
  end

  it 'returns any when no platform is provided' do
    env = ENV['PLATFORM']
    ENV['PLATFORM'] = nil
    actual_platform = described_class.platform
    ENV['PLATFORM'] = env
    expect(actual_platform).to eq(:any)
  end

  it 'returns platform when platform is provided' do
    env = ENV['PLATFORM']
    ENV['PLATFORM'] = 'windows 10'
    actual_platform = described_class.platform
    ENV['PLATFORM'] = env
    expect(actual_platform).to eq(:'windows 10')
  end

  it 'returns nil when jenkins url is not provided' do
    env = ENV['BUILD_URL']
    ENV['BUILD_URL'] = nil
    actual_build = described_class.build
    ENV['BUILD_URL'] = env
    expect(actual_build).to eq(nil)
  end

  it 'returns bad build when jenkins url is provided' do
    url = ENV['BUILD_URL']
    name = ENV['BRANCH_NAME']
    number = ENV['BUILD_NUMBER']
    test_type = ENV['TEST_TYPE']
    ENV['BUILD_URL'] = '12'
    ENV['BRANCH_NAME'] = '123'
    ENV['BUILD_NUMBER'] = '1234'
    ENV['TEST_TYPE'] = nil
    actual_build = described_class.build
    ENV['BUILD_URL'] = url
    ENV['BRANCH_NAME'] = name
    ENV['BUILD_NUMBER'] = number
    ENV['TEST_TYPE'] = test_type
    expect(actual_build).to eq(' for 123 Build 1234')
  end

  it 'returns build when jenkins url is provided' do
    url = ENV['BUILD_URL']
    name = ENV['BRANCH_NAME']
    number = ENV['BUILD_NUMBER']
    test_type = ENV['TEST_TYPE']
    ENV['BUILD_URL'] = '12'
    ENV['BRANCH_NAME'] = '123'
    ENV['BUILD_NUMBER'] = '1234'
    ENV['TEST_TYPE'] = 'Compatibility Test'
    actual_build = described_class.build
    ENV['BUILD_URL'] = url
    ENV['BRANCH_NAME'] = name
    ENV['BUILD_NUMBER'] = number
    ENV['TEST_TYPE'] = test_type
    expect(actual_build).to eq('Compatibility Test for 123 Build 1234')
  end

  it 'return basic empty capabilities' do
    proxy = ENV['PROXY']
    version = ENV['VERSION']
    platform = ENV['PLATFORM']
    url = ENV['BUILD_URL']
    resolution = ENV['RESOLUTION']
    ENV['PROXY'] = nil
    ENV['VERSION'] = nil
    ENV['PLATFORM'] = nil
    ENV['BUILD_URL'] = nil
    ENV['RESOLUTION'] = nil
    actual_basic_capabilities = described_class.basic_capabilities(Scenario.new)
    ENV['PROXY'] = proxy
    ENV['VERSION'] = version
    ENV['PLATFORM'] = platform
    ENV['BUILD_URL'] = url
    ENV['RESOLUTION'] = resolution
    expect(actual_basic_capabilities).to eq({ accept_insecure_certs: true, browser_version: nil, platform_name: :any,
                                              proxy: nil, 'sauce:options': { build: nil, name: 'my name', screen_resolution: nil } })
  end

  it 'return basic full capabilities' do
    proxy = ENV['PROXY']
    version = ENV['VERSION']
    platform = ENV['PLATFORM']
    url = ENV['BUILD_URL']
    name = ENV['BRANCH_NAME']
    number = ENV['BUILD_NUMBER']
    resolution = ENV['RESOLUTION']
    ENV['PROXY'] = 'localhost:1234'
    ENV['VERSION'] = 'latest'
    ENV['PLATFORM'] = 'high sierra'
    ENV['BUILD_URL'] = 'https://1234'
    ENV['BRANCH_NAME'] = 'my branch'
    ENV['BUILD_NUMBER'] = '4'
    ENV['RESOLUTION'] = '800x600'
    actual_basic_capabilities = described_class.basic_capabilities(Scenario.new)
    ENV['PROXY'] = proxy
    ENV['VERSION'] = version
    ENV['PLATFORM'] = platform
    ENV['BUILD_URL'] = url
    ENV['BRANCH_NAME'] = name
    ENV['BUILD_NUMBER'] = number
    ENV['RESOLUTION'] = resolution
    expect(actual_basic_capabilities).to eq({ accept_insecure_certs: true, browser_version: 'latest',
                                              platform_name: :'high sierra', proxy: Selenium::WebDriver::Proxy.new(http: 'localhost:1234', ssl: 'localhost:1234'), 'sauce:options': { build: ' for my branch Build 4', name: 'my name', screen_resolution: '800x600' } })
  end

  it 'return chrome when unknown browser is provided' do
    proxy = ENV['PROXY']
    version = ENV['VERSION']
    platform = ENV['PLATFORM']
    url = ENV['BUILD_URL']
    name = ENV['BRANCH_NAME']
    number = ENV['BUILD_NUMBER']
    resolution = ENV['RESOLUTION']
    ENV['PROXY'] = nil
    ENV['VERSION'] = nil
    ENV['PLATFORM'] = nil
    ENV['BUILD_URL'] = nil
    ENV['BRANCH_NAME'] = nil
    ENV['BUILD_NUMBER'] = nil
    ENV['RESOLUTION'] = nil
    actual_capabilities = described_class.capabilities(Scenario.new, 'my browser')
    ENV['PROXY'] = proxy
    ENV['VERSION'] = version
    ENV['PLATFORM'] = platform
    ENV['BUILD_URL'] = url
    ENV['BRANCH_NAME'] = name
    ENV['BUILD_NUMBER'] = number
    ENV['RESOLUTION'] = resolution
    expect(actual_capabilities).to eq(Selenium::WebDriver::Remote::Capabilities.chrome({ accept_insecure_certs: true,
                                                                                         browser_version: nil, platform_name: :any, proxy: nil, 'sauce:options': { build: nil, name: 'my name', screen_resolution: nil } }))
  end

  it 'return firefox when firefox browser is provided' do
    proxy = ENV['PROXY']
    version = ENV['VERSION']
    platform = ENV['PLATFORM']
    url = ENV['BUILD_URL']
    name = ENV['BRANCH_NAME']
    number = ENV['BUILD_NUMBER']
    resolution = ENV['RESOLUTION']
    ENV['PROXY'] = nil
    ENV['VERSION'] = nil
    ENV['PLATFORM'] = nil
    ENV['BUILD_URL'] = nil
    ENV['BRANCH_NAME'] = nil
    ENV['BUILD_NUMBER'] = nil
    ENV['RESOLUTION'] = nil
    actual_capabilities = described_class.capabilities(Scenario.new, 'firefox')
    ENV['PROXY'] = proxy
    ENV['VERSION'] = version
    ENV['PLATFORM'] = platform
    ENV['BUILD_URL'] = url
    ENV['BRANCH_NAME'] = name
    ENV['BUILD_NUMBER'] = number
    ENV['RESOLUTION'] = resolution
    expect(actual_capabilities).to eq(Selenium::WebDriver::Remote::Capabilities.firefox({ accept_insecure_certs: true,
                                                                                          browser_version: nil, platform_name: :any, proxy: nil, 'sauce:options': { build: nil, name: 'my name', screen_resolution: nil } }))
  end

  it 'return edge when edge browser is provided' do
    proxy = ENV['PROXY']
    version = ENV['VERSION']
    platform = ENV['PLATFORM']
    url = ENV['BUILD_URL']
    name = ENV['BRANCH_NAME']
    number = ENV['BUILD_NUMBER']
    resolution = ENV['RESOLUTION']
    ENV['PROXY'] = nil
    ENV['VERSION'] = nil
    ENV['PLATFORM'] = nil
    ENV['BUILD_URL'] = nil
    ENV['BRANCH_NAME'] = nil
    ENV['BUILD_NUMBER'] = nil
    ENV['RESOLUTION'] = nil
    actual_capabilities = described_class.capabilities(Scenario.new, 'edge')
    ENV['PROXY'] = proxy
    ENV['VERSION'] = version
    ENV['PLATFORM'] = platform
    ENV['BUILD_URL'] = url
    ENV['BRANCH_NAME'] = name
    ENV['BUILD_NUMBER'] = number
    ENV['RESOLUTION'] = resolution
    expect(actual_capabilities).to eq(Selenium::WebDriver::Remote::Capabilities.edge({ accept_insecure_certs: true,
                                                                                       browser_version: nil, platform_name: :any, proxy: nil, 'sauce:options': { build: nil, name: 'my name', screen_resolution: nil } }))
  end

  it 'return safari when safari browser is provided' do
    proxy = ENV['PROXY']
    version = ENV['VERSION']
    platform = ENV['PLATFORM']
    url = ENV['BUILD_URL']
    name = ENV['BRANCH_NAME']
    number = ENV['BUILD_NUMBER']
    resolution = ENV['RESOLUTION']
    ENV['PROXY'] = nil
    ENV['VERSION'] = nil
    ENV['PLATFORM'] = nil
    ENV['BUILD_URL'] = nil
    ENV['BRANCH_NAME'] = nil
    ENV['BUILD_NUMBER'] = nil
    ENV['RESOLUTION'] = nil
    actual_capabilities = described_class.capabilities(Scenario.new, 'safari')
    ENV['PROXY'] = proxy
    ENV['VERSION'] = version
    ENV['PLATFORM'] = platform
    ENV['BUILD_URL'] = url
    ENV['BRANCH_NAME'] = name
    ENV['BUILD_NUMBER'] = number
    ENV['RESOLUTION'] = resolution
    expect(actual_capabilities).to eq(Selenium::WebDriver::Remote::Capabilities.safari({ accept_insecure_certs: false,
                                                                                         browser_version: nil, platform_name: :any, proxy: nil, 'sauce:options': { build: nil, name: 'my name', screen_resolution: nil } }))
  end

  it 'return ie when ie browser is provided' do
    proxy = ENV['PROXY']
    version = ENV['VERSION']
    platform = ENV['PLATFORM']
    url = ENV['BUILD_URL']
    name = ENV['BRANCH_NAME']
    number = ENV['BUILD_NUMBER']
    resolution = ENV['RESOLUTION']
    ENV['PROXY'] = nil
    ENV['VERSION'] = nil
    ENV['PLATFORM'] = nil
    ENV['BUILD_URL'] = nil
    ENV['BRANCH_NAME'] = nil
    ENV['BUILD_NUMBER'] = nil
    ENV['RESOLUTION'] = nil
    actual_capabilities = described_class.capabilities(Scenario.new, 'ie')
    ENV['PROXY'] = proxy
    ENV['VERSION'] = version
    ENV['PLATFORM'] = platform
    ENV['BUILD_URL'] = url
    ENV['BRANCH_NAME'] = name
    ENV['BUILD_NUMBER'] = number
    ENV['RESOLUTION'] = resolution
    expect(actual_capabilities).to eq(Selenium::WebDriver::Remote::Capabilities.internet_explorer({
                                                                                                    accept_insecure_certs: false, browser_version: nil, platform_name: :any, proxy: nil, 'sauce:options': {
                                                                                                      build: nil, name: 'my name', screen_resolution: nil
                                                                                                    }
                                                                                                  }))
  end

  it 'return chrome when chrome browser is provided' do
    proxy = ENV['PROXY']
    version = ENV['VERSION']
    platform = ENV['PLATFORM']
    url = ENV['BUILD_URL']
    name = ENV['BRANCH_NAME']
    number = ENV['BUILD_NUMBER']
    resolution = ENV['RESOLUTION']
    ENV['PROXY'] = nil
    ENV['VERSION'] = nil
    ENV['PLATFORM'] = nil
    ENV['BUILD_URL'] = nil
    ENV['BRANCH_NAME'] = nil
    ENV['BUILD_NUMBER'] = nil
    ENV['RESOLUTION'] = nil
    actual_capabilities = described_class.capabilities(Scenario.new, 'chrome')
    ENV['PROXY'] = proxy
    ENV['VERSION'] = version
    ENV['PLATFORM'] = platform
    ENV['BUILD_URL'] = url
    ENV['BRANCH_NAME'] = name
    ENV['BUILD_NUMBER'] = number
    ENV['RESOLUTION'] = resolution
    expect(actual_capabilities).to eq(Selenium::WebDriver::Remote::Capabilities.chrome({ accept_insecure_certs: true,
                                                                                         browser_version: nil, platform_name: :any, proxy: nil, 'sauce:options': { build: nil, name: 'my name', screen_resolution: nil } }))
  end

  it 'returns chrome when no browser is provided' do
    env = ENV['BROWSER']
    ENV['BROWSER'] = nil
    actual_browser, _actual_url, _actual_capabilities = described_class.driver(Scenario.new)
    ENV['ENVIRONMENT'] = env
    expect(actual_browser).to eq(:chrome)
  end

  it 'returns chrome when chrome is provided' do
    env = ENV['BROWSER']
    ENV['BROWSER'] = 'ChRoMe'
    actual_browser, _actual_url, _actual_capabilities = described_class.driver(Scenario.new)
    ENV['ENVIRONMENT'] = env
    expect(actual_browser).to eq(:chrome)
  end

  it 'returns firefox when firefox is provided' do
    env = ENV['BROWSER']
    ENV['BROWSER'] = 'fireFOX'
    actual_browser, _actual_url, _actual_capabilities = described_class.driver(Scenario.new)
    ENV['ENVIRONMENT'] = env
    expect(actual_browser).to eq(:firefox)
  end

  it 'returns remote when url is provided' do
    env = ENV['REMOTE']
    ENV['REMOTE'] = 'https://someaddress:1234'
    actual_browser, _actual_url, _actual_capabilities = described_class.driver(Scenario.new)
    ENV['REMOTE'] = env
    expect(actual_browser).to eq(:remote)
  end

  it 'returns nil when no url is provided' do
    env = ENV['REMOTE']
    ENV['REMOTE'] = nil
    _actual_browser, actual_url, _actual_capabilities = described_class.driver(Scenario.new)
    ENV['REMOTE'] = env
    expect(actual_url).to eq(nil)
  end

  it 'returns url when url is provided' do
    env = ENV['REMOTE']
    ENV['REMOTE'] = 'http://some-url.com'
    _actual_browser, actual_url, _actual_capabilities = described_class.driver(Scenario.new)
    ENV['REMOTE'] = env
    expect(actual_url).to eq('http://some-url.com')
  end

  it 'return false when no remote is provided' do
    env = ENV['REMOTE']
    ENV['REMOTE'] = nil
    is_sauce = described_class.sauce
    ENV['REMOTE'] = env
    expect(is_sauce).to eq(nil)
  end

  it 'return false when a local instance is provided' do
    env = ENV['REMOTE']
    ENV['REMOTE'] = 'http://localhost:4444'
    is_sauce = described_class.sauce
    ENV['REMOTE'] = env
    expect(is_sauce).to eq(false)
  end

  it 'return true when a sauce instance is provided' do
    env = ENV['REMOTE']
    ENV['REMOTE'] = 'https://msaperstone:1234567890@ondemand.us-west-1.saucelabs.com:443/wd/hub'
    is_sauce = described_class.sauce
    ENV['REMOTE'] = env
    expect(is_sauce).to eq(true)
  end

  it 'return no username when no sauce username is provided' do
    env = ENV['REMOTE']
    ENV['REMOTE'] = 'https://ondemand.us-west-1.saucelabs.com:443/wd/hub'
    username, _password = described_class.sauce_credentials
    ENV['REMOTE'] = env
    expect(username).to eq(nil)
  end

  it 'return no password when no sauce password is provided' do
    env = ENV['REMOTE']
    ENV['REMOTE'] = 'https://ondemand.us-west-1.saucelabs.com:443/wd/hub'
    _username, password = described_class.sauce_credentials
    ENV['REMOTE'] = env
    expect(password).to eq(nil)
  end

  it 'return username when sauce username is provided' do
    env = ENV['REMOTE']
    ENV['REMOTE'] = 'https://msaperstone:1234567890@ondemand.us-west-1.saucelabs.com:443/wd/hub'
    username, _password = described_class.sauce_credentials
    ENV['REMOTE'] = env
    expect(username).to eq('msaperstone')
  end

  it 'return password when sauce password is provided' do
    env = ENV['REMOTE']
    ENV['REMOTE'] = 'https://msaperstone:1234567890@ondemand.us-west-1.saucelabs.com:443/wd/hub'
    _username, password = described_class.sauce_credentials
    ENV['REMOTE'] = env
    expect(password).to eq('1234567890')
  end
end
