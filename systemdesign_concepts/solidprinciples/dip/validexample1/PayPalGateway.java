package solidprinciples.dip.validexample1;

public class PayPalGateway implements PaymentGateway {
    @Override
    public void processPayment(double amount) {
        System.out.println("Processing PayPal payment: $" + amount);
        // PayPal-specific implementation
    }

    @Override
    public void refundPayment(String transactionId) {
        System.out.println("Refunding PayPal transaction: " + transactionId);
        // PayPal-specific refund logic
    }
}