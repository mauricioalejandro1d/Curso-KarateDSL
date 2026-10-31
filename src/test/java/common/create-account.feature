@ignore
Feature: Helper - crear cuenta

Scenario:
    * def body = read('classpath:data/account.json')
    * def name = karate.get('holderName', 'Humberto Ramos')
    * set body.holderName = name
    * set body.alias = 'qa- ' + karate.uuid().substring(0,8)

    Given url baseUrl
    And path 'accounts'
    And request body
    When method post
    Then status 201
    * def id = response.id
    * def account = response