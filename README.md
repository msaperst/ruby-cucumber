# Test Automation Framework for Ruby

## Getting Started
1. Ensure Ruby is installed on your machine
2. Install the required gems
```shell
bundle install
```
3. Run the cucumber tests
```shell
cucumber
```
4. Reports are in the `reports` folder
   
### Parallel Exeuction
By default, the tests run single threaded. To run in parallel,
execute using the `parallel_cucumber` command instead. To do this,
you need to specify the tests, number of threads and how to group
the tests.

For example, to run 4 tests in parallel, parallelizing the scenarios:
```shell
parallel_cucumber -n 4 features/[feature file] --group-by scenarios
```
Reports are in the same directory, but are split up, listed from 
`report_`, `report_2`, and so on for each thread

### Run Parameters
By default, all tests run on chrome. In order to run on another browser,
ensure the browser is installed locally, and then provide the browser
parameter to your cucumber execution command.

For example, to run on firefox, use the below command:
```shell
BROWSER=firefox cucumber
```

Additionally, all tests run on localhost by default. To change this,
provide the environment parameter, which will then build out the 
appropriate URLs.

For example, to test on QA 
(app1-qa.mysite.net), use the below command:
```shell
ENVIRONMENT=qa cucumber
```

If you want to pass the data through a proxy, such as ZAP or JMeter, once the
proxy is up/running, simply provide the proxy address to the run parameters.

For example, to pass traffic through `localhost:8888`:

```shell
PROXY=localhost:8888 cucumber
```

### Running Remote
If you want to run on a hub, instead of locally, you can launch 
selenium hub docker. To do this, you'll need to create a 
docker-compose file such as 
`https://github.com/SeleniumHQ/docker-selenium/blob/trunk/docker-compose-v3.yml` 
and run it to ensure that browser matches the browser you want to 
test with. For example:
```shell
docker-compose up -d firefox
```

Then execute your tests, however, you'll need to specify the site, 
as `localhost` won't work in the docker container. If you've built 
the site locally, pass in your IP address as the site. If you're 
running the application in docker you can just provide the docker 
app location (defaults to `default`). You'll also want to specify that 
you're running with a hub, by providing the `REMOTE` parameter. The 
command might look like:

```shell
BROWSER=firefox REMOTE=http://localhost:4444/wd/hub ENVIRONMENT=qa cucumber
```

If you wanted to scale up your tests using the power of selenium 
hub, you'll just need to scale up your docker container setup, and 
then up your threading.

```shell
docker-compose up -d chrome
docker-compose scale chrome=10

BROWSER=chrome REMOTE=http://localhost:4444/wd/hub SITE=192.168.3.2 parallel_cucumber -n 4 features/[feature file] --group-by scenarios
```

### 508 Testing
In order to run 508 acceptance testing, simple add this then to any/all tests

`Then the page should be axe clean`

All tests tagged with `@accessibility` get run in the 508 testing section of the pipeline, and
will automatically have the above Then added to them.

### Traceability
When tests run, if the JIRA environment parameter is provided, the framework
will try to update the associated Jira ticket with a comment as to the test's
status. The JIRA variable should be set to the Jira project, so that the 
framework can identify the Jira tag from all of the other provided tags. Jira
username and token are also required to be provided as parameters, so that the 
framework can authenticate. To indicate the type of test being run, provide 
the `TEST_TYPE` parameter as well. An example is below:

```shell
JIRA_USERNAME=max.saperstone@steampunk.com JIRA_TOKEN=securejiratoken TEST_TYPE='Acceptance Test' JIRA=dcc ENVIRONMENT=qa cucumber
```

In order to create a JIRA token, [follow these 
instructions](https://support.siteimprove.com/hc/en-gb/articles/360004317332-How-to-create-an-API-token-from-your-Atlassian-account).
Ensure you authenitcate with your JIRA email, not your username, and the
token, not the password.

To ensure the test execution gets properly reported, each test needs to be
tagged with a Jira story. These can be done at the feature level if all
tests are for the same Jira story, or at the scenario level. One of more
tags need to be provided, and should look like the below:

```gherkin
@dcc-41 @applicant-login
Feature: Applicant Portal Login
...
  @acceptance @accessibility
  Scenario: Applicant Portal home page for applicant account
...
  @dcc-42 @acceptance @accessibility
  Scenario: Applicant Portal access notice for applicant account
...
```

## Reports
To generate a common report, even from parallel tests, run the below command
```shell
report_builder -s reports -o report
```