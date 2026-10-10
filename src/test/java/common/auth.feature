@ignore
Feature: Autenticación (login Bearer)

  Scenario:
    Given url baseUrl
    And path 'auth', 'login'
    And request { username: '#(user)', password: '#(pass)' }
    When method post
    Then status 200
    And match response.tokenType == 'Bearer'
    * def token = response.token
