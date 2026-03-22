package solidprinciples.dip.badexample1;

// Low-level module (specific implementation)
public class PayPalPaymentGateway {
    public void processPayPalPayment(double amount) {
        System.out.println("Processing PayPal payment: $" + amount);
        // PayPal-specific API calls
    }

    public void refundPayPalPayment(String transactionId) {
        System.out.println("Refunding PayPal transaction: " + transactionId);
        // PayPal-specific refund logic
    }
}
