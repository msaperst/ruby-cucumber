# frozen_string_literal: true

require_relative './page'
require 'selenium-webdriver'

# page object model for dealing with the applicant dashboard
class ApplicantHomepage < Page
  def getting_started_button
    seek('getStarted')
  end

  def application_name_header
    seek('applicationNameHeader')
  end

  def application_name
    seek('applicationName')
  end

  def card_body
    seek('cardbody')
  end
end
