
Feature: Accounts-Lab

Background:
  * url baseUrl
#   * def user = karate.sysenv('NOVUS_USER')
#   * def pass = karate.sysenv('NOVUS_PASS')
#     Given path 'auth', 'login'
#     And request { username: '#(user)', password: '#(pass)' }
#     When method post
#     Then status 200
#     And match response.tokenType == 'Bearer'
#   * def token = response.token
#   * configure headers = { Authorization: '#("Bearer " + token)' }

    Scenario: Listar cuenta con pageSize 10
        Given path 'accounts'
        And param pageSize = 10
        When method get
        Then status 200
        And match response.items == '#[10]'

    Scenario: Verificar cuenta inexistente
        Given path 'accounts', 'acc-999'
        When method get
        Then status 404
        And match response.code == 'ACCOUNT_NOT_FOUND'
        And match response.message == 'No existe la cuenta acc-999'

    Scenario: Filtrar por query params
        Given path 'accounts'
        And param currency = 'USD'
        When method get
        Then status 200
        * print response
        And match each response.items contains { currency: 'USD' }
    
    
    Scenario: Listar cuenta por pageSize 5
        Given path 'accounts'
        And param pageSize = 5
        When method get
        Then status 200
        And match response.items == '#[5]'

    Scenario: Validar datos de una cuenta
        Given path 'accounts', 'acc-001'
        When method get
        Then status 200
        And match response contains
        """
        {id: '#string', accountNumber: '#string', holderName: '#string', 
        currency: '#string', balance: '#number', active: '#boolean',
        contact: '#object', tags: '#array', createdAt: '#string'
        }
        """

    