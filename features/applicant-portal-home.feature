@dcc-56 @applicant-homepage
Feature: Applicant Portal Home Page
  As an Applicant
  I want to view the home page of the I-589 Applicant Portal
  So that I can be directed to the login page or other pages

  @acceptance @accessibility
  Scenario: Applicant Portal home page for applicant account
    Given I am on the Applicant Portal Home page
    Then I see the applicant portal home page

  @acceptance @accessibility
  Scenario: Applicant Portal access notice for applicant account
    Given I am on the Applicant Portal Home page
    When I select Get Started
    Then I see the access notice page
