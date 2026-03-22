package solidprinciples.dip.validexample1;

// Low-level modules depend on abstraction (implement interface)
public class StripeGateway implements PaymentGateway {
    @Override
    public void processPayment(double amount) {
        System.out.println("Processing Stripe payment: $" + amount);
        // Stripe-specific implementation
    }

    @Override
    public void refundPayment(String transactionId) {
        System.out.println("Refunding Stripe transaction: " + transactionId);
        // Stripe-specific refund logic
    }
}
