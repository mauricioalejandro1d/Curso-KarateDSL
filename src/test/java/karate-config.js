function fn() {
  // Ambiente: -Dkarate.env=dev (por defecto) o -Dkarate.env=qa
  var env = karate.env || 'dev';
  if (env !== 'dev' && env !== 'qa') {
    karate.fail('Ambiente no valido: ' + env + ' (usa dev o qa)');
  }
  karate.log('Entorno:', env);

  // La API publica dos ambientes bajo los prefijos /dev y /qa
  var host = karate.sysprop('host', 'https://novus-fintech-demo-api.onrender.com');

  var config = {
    env: env,
    baseUrl: host + '/' + env,
    // Credenciales: SOLO desde variables de entorno (nunca en el codigo)
    user: karate.sysenv('NOVUS_USER'),
    pass: karate.sysenv('NOVUS_PASS'),
    // 60 s por el arranque en frio del servidor (el plan gratuito de Render se duerme)
    timeout: karate.sysprop('timeout', '60000')
  };

  karate.configure('connectTimeout', Number(config.timeout));
  karate.configure('readTimeout', Number(config.timeout));

  // ---------------------------------------------------------------------------
  // SESION 2 - Login una sola vez para toda la suite.
  // Descomenta estas lineas cuando llegues a callSingle (ver common/auth.feature).
  // En la sesion 1 el login va en el Background de cada feature.
  //
  // if (!config.user || !config.pass) karate.fail('Faltan NOVUS_USER y NOVUS_PASS');
  // var auth = karate.callSingle('classpath:common/auth.feature', config);
  // karate.configure('headers', { Authorization: 'Bearer ' + auth.token });
  // ---------------------------------------------------------------------------

  return config;
}
