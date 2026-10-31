@ignore
Feature: Complete CRUD Accounts

Background:
    #Obtiene las credenciales desde las variables de entorno
    # * def user = karate.sysenv('NOVUS_USER')
    # * def pass = karate.sysenv('NOVUS_PASS')

    #Configura la URL base y accede al endpoint de login
    * url baseUrl
    # And path 'auth', 'login'

    # #Envia las credenciales para iniciar sesión
    # And request { username: '#(user)', password: '#(pass)' }
    # When method post

    # #Valida el login y el tipo de token recibido
    # Then status 200
    # And match response.tokenType == 'Bearer'

    # #Guarda el token y lo utiliza para las siguientes peticiones
    # * def token = response.token
    # * configure headers = { Authorization: '#("Bearer " + token)' }


Scenario: Crear una cuenta
    # Lee los datos de la cuenta desde el archivo JSON
    * def body = read('classpath:data/account.json')

    # Envía el POST para crear una cuenta
    Given path 'accounts'
    And request body
    When method post

    # Valida que se creó correctamente y que los datos coinciden
    Then status 201
    And match response.id == '#string'
    And match response.holderName == body.holderName

    # Guarda el ID generado y valida que aparezca en Location
    * def id = response.id
    And match header location contains response.id 


Scenario: Crear y consultar la cuenta
    # Lee los datos y crea una cuenta nueva
    * def body = read('classpath:data/account.json')
    Given path 'accounts'
    And request body
    When method post
    Then status 201

    # Guarda el ID generado por la API
    * def id = response.id

    # Consulta la cuenta creada mediante su ID
    Given path 'accounts', id
    When method get
    Then status 200

    # Comprueba que el ID y el titular sean correctos
    And match response.id == id
    And match response.holderName == body.holderName


Scenario: PUT reemplaza los campos mutables
    # Crea una cuenta para probar la actualización
    * def body = read('classpath:data/account.json')
    Given path 'accounts'
    And request body
    When method post
    Then status 201

    # Guarda el ID de la cuenta creada
    * def id = response.id

    # Define los campos que se enviarán en el PUT
    * def changes =
    """
    {
      holderName: 'Mauricio Carrasquel',
      active: true,
      contact: {
        email: 'mauriiciio1d@gmail.com',
        phone: '+51987370653'
      }
    }
    """

    # Actualiza la cuenta con PUT
    Given path 'accounts', id
    And request changes
    When method put
    Then status 200

    # Valida los campos devueltos después de actualizar
    And match response.holderName == 'Mauricio Carrasquel'
    And match response.alias == null
    And match response.tags == []
    And match response.updatedAt == '#string'

    # Consulta nuevamente la cuenta para verificar el cambio
    Given path 'accounts', id
    When method get
    Then status 200
    And match response.holderName == 'Mauricio Carrasquel'


Scenario: PATCH solo cambia lo enviado
    # Crea una cuenta para probar el PATCH
    * def body = read('classpath:data/account.json')
    Given path 'accounts'
    And request body
    When method post
    Then status 201

    # Guarda el ID generado
    * def id = response.id

    # Consulta la cuenta y guarda el titular original
    Given path 'accounts', id
    When method get
    Then status 200
    * def originalHolder = response.holderName

    # Modifica únicamente el campo active
    Given path 'accounts', id
    And request { active: false }
    When method patch
    Then status 200

    # Verifica el cambio y que el titular no haya cambiado
    And match response.active == false
    And match response.holderName == originalHolder

    # Consulta nuevamente para confirmar que los cambios persistieron
    Given path 'accounts', id
    When method get
    Then status 200
    And match response.active == false
    And match response.holderName == originalHolder


Scenario: Eliminar y confirmar que ya no existe
    # Crea una cuenta para probar la eliminación
    * def body = read('classpath:data/account.json')
    Given path 'accounts'
    And request body
    When method post
    Then status 201

    # Guarda el ID de la cuenta creada
    * def id = response.id

    # Elimina la cuenta
    Given path 'accounts', id
    When method delete
    Then status 204

    # Consulta la cuenta eliminada y valida el error 404
    Given path 'accounts', id
    When method get
    Then status 404
    And match response.code == 'ACCOUNT_NOT_FOUND'


Scenario: PATCH negativo con balance
    # Crea una cuenta para probar el envío de un campo no permitido
    * def body = read('classpath:data/account.json')
    Given path 'accounts'
    And request body
    When method post
    Then status 201

    # Guarda el ID generado
    * def id = response.id

    # Intenta modificar balance mediante PATCH
    Given path 'accounts', id
    And request { balance: 5 }
    When method patch

    # Valida el error esperado y el campo que lo provoca
    Then status 400
    And match response.code == 'IMMUTABLE_FIELD'
    And match response.field == 'balance'
