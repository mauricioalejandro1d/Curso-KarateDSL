package runners;

import io.karatelabs.core.Runner;
import io.karatelabs.core.SuiteResult;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;

/**
 * Runner para CI: ejecuta TODOS los features en paralelo.
 * Uso: mvn test -Dtest=ParallelTest -Dkarate.env=qa -Dkarate.options="--tags @smoke"
 */
class ParallelTest {

    @Test
    void testParallel() {
        SuiteResult result = Runner.path("classpath:features")
                .tags("~@ignore")
                .outputJunitXml(true)       // para Azure DevOps
                .outputCucumberJson(true)   // para dashboards
                .parallel(5);
        assertFalse(result.isFailed(), "Hay escenarios fallidos: revisa el reporte");
    }
}
