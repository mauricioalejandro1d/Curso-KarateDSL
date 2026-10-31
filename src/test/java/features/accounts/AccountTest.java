package features.accounts;

import io.karatelabs.junit6.Karate;
import org.junit.jupiter.api.DynamicNode;

class AccountTest {

    @Karate.Test
    Iterable<DynamicNode> testAccount() {
        return Karate.run().relativeTo(getClass());
    }
}
