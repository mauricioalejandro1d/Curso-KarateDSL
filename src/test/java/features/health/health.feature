@smoke
Feature: Estado de la API

  Background:
    * url baseUrl

  Scenario: El servicio está disponible
    Given path 'health'
    When method get
    Then status 200
    And match response.status == 'ok'
    And match response.uptimeSeconds == '#number'
    And match response.environments contains 'dev'
    * print 'Versión de la API:', response.version

  Scenario: Sin token no hay acceso
    Given path 'accounts'
    When method get
    Then status 401
    And match response.code == 'MISSING_TOKEN'
