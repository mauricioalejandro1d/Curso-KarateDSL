
Feature: Transfers

Background:
    # Configura la URL base
    * url baseUrl

Scenario: Crear una transferencia y verificar el debito
    # Consulta el saldo inicial de la cuenta origen
    Given path 'accounts', 'acc-003'
    When method get
    Then status 200
    * def before = response.balance

    # Consulta el saldo inicial de la cuenta destino
    Given path 'accounts', 'acc-004'
    When method get
    Then status 200
    * def beforeDestination = response.balance

    # Crea la transferencia entre ambas cuentas
    Given path 'transfers'
    And request { fromAccountId: 'acc-003', toAccountId: 'acc-004', amount: 350.50, currency: 'PEN' }
    When method post
    Then status 201
    And match response.status == 'pending'
    * def transferId = response.id

    # Comprueba el debito de la cuenta origen
    Given path 'accounts', 'acc-003'
    When method get
    Then status 200
    And match response.balance == before - 350.50

    # Consulta repetidamente hasta que la transferencia este completada.
    Given path 'transfers', transferId
    And retry until response.status == 'completed'
    When method get
    Then status 200
    And match response.status == 'completed'

    # Comprueba el abono en la cuenta destino
    Given path 'accounts', 'acc-004'
    When method get
    Then status 200
    And match response.balance == beforeDestination + 350.50


Scenario Outline: Transferencia invalida - <code>
    # Ejecuta solicitudes con datos que incumplen reglas de negocio
    Given path 'transfers'
    And request { fromAccountId: '<from>', toAccountId: '<to>', amount: <amount>, currency: 'PEN' }
    When method post
    Then status <status>
    And match response.code == '<code>'

    # Datos para los seis casos negativos
    Examples:
      | from    | to      | amount | status | code                |
      | acc-008 | acc-001 | 500    | 422    | INSUFFICIENT_FUNDS  |
      | acc-007 | acc-001 | 10     | 422    | ACCOUNT_INACTIVE    |
      | acc-001 | acc-009 | 10     | 422    | CURRENCY_MISMATCH   |
      | acc-001 | acc-001 | 10     | 400    | SAME_ACCOUNT        |
      | acc-001 | acc-002 | 1.234  | 400    | INVALID_AMOUNT      |
      | acc-999 | acc-002 | 10     | 404    | ACCOUNT_NOT_FOUND   |


Scenario: Reintento idempotente de una transferencia
    # Define una clave para identificar la solicitud
    * def idempotencyKey = 'transfer-test-001'

    # Primera solicitud: crea la transferencia
    Given path 'transfers'
    And header Idempotency-Key = idempotencyKey
    And request { fromAccountId: 'acc-003', toAccountId: 'acc-004', amount: 10, currency: 'PEN' }
    When method post
    Then status 200
    * def originalId = response.id

    # Segunda solicitud: repite la misma operación
    Given path 'transfers'
    And header Idempotency-Key = idempotencyKey
    And request { fromAccountId: 'acc-003', toAccountId: 'acc-004', amount: 10, currency: 'PEN' }
    When method post
    Then status 200
    And match response.id == originalId
    And match header idempotent-replay == 'true'


Scenario: Listar transferencias
    # Consulta el listado de transferencias
    Given path 'transfers'
    When method get
    Then status 200
    And match response.items == '#array'
