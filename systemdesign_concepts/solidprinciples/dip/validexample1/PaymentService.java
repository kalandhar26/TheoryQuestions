package solidprinciples.dip.validexample1;

// High-level module depends on abstraction, not concrete implementations
public class PaymentService implements PaymentProcessor {

    @Override
    public void processPayment(PaymentGateway gateway, double amount) {
        // Business logic validation
        if (amount <= 0) {
            throw new IllegalArgumentException("Amount must be positive");
        }

        // Logging, analytics, etc.
        System.out.println("Initiating payment processing...");

        // Delegate to the specific gateway
        /* The JVM uses runtime polymorphism to determine which actual implementation to execute:
        At compile time: The compiler only knows gateway is a PaymentGateway
        At runtime: The JVM looks at the actual object type and calls its specific implementation */
        gateway.processPayment(amount);

        // Post-processing logic
        System.out.println("Payment completed successfully");
    }

    @Override
    public void refundPayment(PaymentGateway gateway, String transactionId) {
        // Business logic for refunds
        System.out.println("Initiating refund process...");

        gateway.refundPayment(transactionId);

        System.out.println("Refund completed successfully");
    }
}
