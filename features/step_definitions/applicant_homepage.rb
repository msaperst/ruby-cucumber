# frozen_string_literal: true

require_relative '../utils/utils'

Given('I am on the Applicant Portal Home page') do
  @driver.get(Utils.env_picker('applicant-ui'))
end

When('I select Get Started') do
  # scrolling to bottom of the screen, as on small screens, the footer covers this button
  @driver.execute_script('window.scrollTo(0, document.body.scrollHeight)')
  # clicks the login button
  @driver.getting_started_button.click
  @driver.await(:accept_and_login)
end

Then('I see the applicant portal home page') do
  @driver.await(:application_name, :application_name_header, :card_body, :getting_started_button)
  expect(@driver.application_name_header.text).to eq('Application Name')
  expect(@driver.application_name.text).to eq('App Name!')
  expect(@driver.find_element(:tag_name, 'h3').text).to eq('Main page heading')
  expect(@driver.card_body.displayed?).to eq(true)
  expect(@driver.getting_started_button.displayed?).to eq(true)
end

Then('I see the access notice page') do
  @driver.await(:application_name_header, :accept_and_login)
  expect(@driver.application_name_header.text).to eq('Application Name')
  expect(@driver.find_element(:tag_name, 'h1').text).to eq('Notice')
  expect(@driver.accept_and_login.displayed?).to eq(true)
end
