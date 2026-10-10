package features.health;

import io.karatelabs.junit6.Karate;
import org.junit.jupiter.api.DynamicNode;

class HealthTest {

    @Karate.Test
    Iterable<DynamicNode> testHealth() {
        return Karate.run("health").relativeTo(getClass());
    }
}
