# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

# class to handle updating third party resources with status of our tests
class Update
  def self.jira(scenario)
    tags = scenario.source_tag_names
    tags.each do |tag|
      next unless tag.start_with?("@#{ENV['JIRA']}")

      uri = URI.parse("https://myjirainstance/rest/api/2/issue/#{tag[1..].upcase}/comment")
      request_params = { body: "#{ENV['TEST_TYPE']} '#{scenario.name}' #{scenario.status}" }

      http_call('post', uri, request_params, ENV['JIRA_USERNAME'], ENV['JIRA_TOKEN'])
    end
  end

  def self.sauce(scenario, session)
    username, password = Utils.sauce_credentials

    uri = URI.parse("https://saucelabs.com/rest/v1/#{username}/jobs/#{session}")
    request_params = { passed: scenario.status.to_s == 'passed' }

    http_call('put', uri, request_params, username, password)
  end

  def self.http_call(call, uri, params, username, password)
    header = { 'Content-Type': 'application/json' }
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = case call
              when 'post'
                Net::HTTP::Post.new(uri.request_uri, header)
              when 'put'
                Net::HTTP::Put.new(uri.request_uri, header)
              else
                raise 'Method'
              end
    request.basic_auth username, password
    request.body = params.to_json

    http.request request
  end
end
