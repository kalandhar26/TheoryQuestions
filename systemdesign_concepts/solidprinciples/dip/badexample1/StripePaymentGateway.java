package solidprinciples.dip.badexample1;

// Low-level module (specific implementation)
public class StripePaymentGateway {
    public void processStripePayment(double amount) {
        System.out.println("Processing Stripe payment: $" + amount);
        // Stripe-specific API calls
    }

    public void refundStripePayment(String transactionId) {
        System.out.println("Refunding Stripe transaction: " + transactionId);
        // Stripe-specific refund logic
    }
}
