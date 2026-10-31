
Feature: CRUD Accounts

    Background:
      * url baseUrl
    #   * def user = karate.sysenv('NOVUS_USER')
    #   * def pass = karate.sysenv('NOVUS_PASS')
    #   Given path 'auth', 'login'
    #   And request { username: '#(user)', password: '#(pass)' }
    #   When method post
    #   Then status 200
    #   And match response.tokenType == 'Bearer'
    #   * def token = response.token
    #   * configure headers = { Authorization: '#("Bearer " + token)' }

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


    Scenario: Filtrar por moneda (query param)
      Given path 'accounts'
      And param currency = 'USD'
      When method get
      Then status 200
      And match each response.items contains { currency: 'USD' }

      
    Scenario: Crear una cuenta
      * def body =
        """
            {
            holderName: 'Humberto Ramos', currency: 'PEN',
            initialBalance: 1000,
            contact: {email: 'humberto.ramos@novusdemo.pe'}
            }
        """
      Given path 'accounts'
      And request body
      When method post
      Then status 201
      And match response.id == '#string'
      And match response.balance == 1000
      And match response.holderName == body.holderName
      And match header Location contains response.id


    Scenario: Crear y consultar la cuenta
      #1. Crear
      Given path 'accounts'
      And request read('classpath:data/account.json')
      When method post
      Then status 201
      * def id = response.id

      #2. Consultar usando el id capturado
      Given path 'accounts', id
      When method get
      Then status 200
      And match response.holderName == 'Ana Rojas'
      
    # Scenario: PUT reemplaza los campos mutables
    #   * def changes = 
    #          """
    #         {
    #         holderName: 'Humberto Ramos',
    #         active: true,
    #         contact: {email: 'humberto.ramos@novusdemo.pe'}
    #         }
    #     """
    #   Given path 'accounts', 'acc-003'
    #   And request changes
    #   When method put
    #   Then status 200
    #   And match response.alias == null
    #   And match response.tags == []
    #   And match response.updatedAt == '#string'

    # Scenario: PATCH solo cambia lo enviado
    #   Given path 'accounts', 'acc-003'
    #   And request { active: false }
    #   When method patch
    #   Then status 200
    #   And match response.active == false
    #   And match response.holderName == '#string'

    # Scenario: Eliminar y confirmar que ya no existe
    #   Given path 'accounts', 'acc-17bf39bd'
    #   When method delete
    #   Then status 204


    #   Given path 'accounts', 'acc-17bf39bd'
    #   When method get
    #   Then status 404
    #   And match response.code == 'ACCOUNT_NOT_FOUND'
  

    Scenario: Contrato de una cuenta
* def schema = read('classpath:schemas/account.json')
Given path 'accounts', 'acc-006'
When method get
Then status 200
And match response == schema


    Scenario: Crear una cuenta con datos generados
* def body = read('classpath:data/account.json')
* def ref = karate.uuid()
* set body.alias = 'qa-' + ref.substring(0, 8)
* set body.holderName = 'QA' + karate.faker.firstName()
* set body.contact.email = karate.faker.email()
* print 'Datos usados: ', body
Given path 'accounts'
And request body
And method post
Then status 201
And match response.alias == body.alias


Scenario: Crear una cuenta con datos generados

* def body =  read('classpath:data/account.json')
* def name = karate.get('holderName', 'Mauricio Carrasquel')
* set body.holderName = name
* set body.alias = 'qa- ' + karate.uuid().substring(0, 8)

Given url baseUrl
And path 'accounts'
And request body
When method post
Then status 201
* def id = response.id
 * def account = response


Scenario: Actualizar una cuenta existente

* def helper = 'classpath:common/create-account.feature'
* def created = call read(helper)
* def changes = { holderName: 'Nuevo', active: true }
* set changes.contact = created.account.contact

Given path 'accounts', created.id
And request changes
When method put
Then status 200

