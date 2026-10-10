@ignore
Feature: Helper - reiniciar mis datos (POST /me/reset)

  Scenario:
    Given url baseUrl
    And path 'me', 'reset'
    When method post
    Then status 200
    And match response.accounts == '#number'
