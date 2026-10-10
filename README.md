# mi-framework-karate

Proyecto base del curso **Automatización de APIs con Karate DSL** (Karate **2.1.3**, Java 21).
Apunta a la **Novus Fintech Demo API** (cuentas y transferencias): <https://novus-fintech-demo-api.onrender.com/docs>

## Requisitos

| Herramienta | Versión | Verificar |
|---|---|---|
| Java (JDK) | 21 o superior | `java -version` |
| Maven | 3.9 o superior | `mvn -v` |
| Git | cualquiera reciente | `git --version` |
| VS Code + extensión Karate | `karatelabs.karate` | — |

## Credenciales

Te las da el instructor (`alumno01`, `alumno02`…). Se leen de **variables de entorno**; nunca las escribas en el código ni las subas a Git.

```bash
# Windows (PowerShell, para la sesión actual)
$env:NOVUS_USER = "alumno01"
$env:NOVUS_PASS = "tu-clave"

# Windows (permanente; cierra y abre la terminal después)
setx NOVUS_USER "alumno01"
setx NOVUS_PASS "tu-clave"

# macOS / Linux
export NOVUS_USER=alumno01
export NOVUS_PASS=tu-clave
```

## Ejecutar

```bash
mvn test                                         # todos los runners
mvn test -Dtest=HealthTest                       # un solo runner
mvn test -Dkarate.env=qa                         # ambiente qa (por defecto: dev)
mvn test -Dtest=ParallelTest                     # toda la suite en paralelo (CI)
mvn test -Dtest=ParallelTest -Dkarate.options="--tags @smoke"
```

Reporte HTML: `target/karate-reports/karate-summary.html` (empieza aquí).

> La primera llamada puede tardar hasta un minuto: el servidor gratuito se duerme tras un rato sin uso. El timeout por defecto es de 60 s (`-Dtimeout=...` para cambiarlo).

## Estructura

```
mi-framework-karate/
├── pom.xml
├── azure-pipelines.yml            # sesión 3
└── src/test/java/
    ├── karate-config.js           # ambiente, URL base, timeouts y credenciales
    ├── logback-test.xml
    ├── features/
    │   ├── health/                # ya incluido: health.feature + HealthTest.java
    │   ├── accounts/              # tus features de cuentas (labs 1 y 2)
    │   └── transfers/             # tus features de transferencias (lab 3)
    ├── common/                    # auth.feature (login), reset.feature (POST /me/reset)
    ├── data/                      # account.json (cuerpo base para crear cuentas)
    ├── schemas/                   # account.json y contact.json (contratos)
    └── runners/
        └── ParallelTest.java      # ejecución paralela para CI
```

## Cómo avanzar por sesión

1. **Sesión 1:** ejecuta `HealthTest`. Crea `features/accounts/accounts.feature` con el login en el `Background` (`path 'auth', 'login'`, `configure headers`). Para correr un feature nuevo, copia `HealthTest.java` a su carpeta y cambia el nombre del feature.
2. **Sesión 2:** en `karate-config.js` descomenta el bloque de `callSingle` (login una sola vez) y quita el login de tus `Background`.
3. **Sesión 3:** ejecuta `ParallelTest`, etiqueta con `@smoke` / `@regression` y adapta `azure-pipelines.yml` (Variable Group `novus-secrets` con `NOVUS_USER`, `NOVUS_PASS` y `API_URL`).

## Ayuda rápida

| Síntoma | Causa probable |
|---|---|
| `401 INVALID_CREDENTIALS` / `MISSING_CREDENTIALS` | `NOVUS_USER` o `NOVUS_PASS` no están definidas en la misma terminal que ejecuta Maven |
| `No tests found` | El `.feature` y su runner `.java` no están en la misma carpeta |
| Error de versión de Java | `JAVA_HOME` apunta a un JDK anterior a 21 |
| Timeout en la primera llamada | Arranque en frío del servidor: espera y reintenta |
| Datos raros en tus cuentas | `POST /me/reset` (o `common/reset.feature`) restaura tus datos iniciales |
