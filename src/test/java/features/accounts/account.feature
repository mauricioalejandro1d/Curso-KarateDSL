Feature: Accounts

Background:
    Given url baseUrl
  * def user = karate.sysenv('NOVUS_USER')
  * def pass = karate.sysenv('NOVUS_PASS')
    Given path 'auth', 'login'
    And request { username: '#(user)', password: '#(pass)' }
    When method post
    Then status 200
    And match response.tokenType == 'Bearer'
  * def token = response.token
  * configure headers = { Authorization: '#("Bearer " + token)' }

Scenario: Detalle de una cuenta (path)
    Given path 'accounts', 'acc-001'
    When method get
    Then status 200
    And match response.currency == 'PEN'

Scenario: Filtrar por query param
    Given path 'accounts'
    And param currency = 'USD'
    When method get
    Then status 200
    And match each response.items contains { currency: 'USD' }

Scenario: Paginar con varios params
    Given path 'accounts'
    And params { page: 2, pageSize: 5 }
    When method get
    Then status 200
    And match response.page == 2
    And match response.items == '#[5]'

