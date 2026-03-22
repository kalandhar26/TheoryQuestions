package solidprinciples.dip.badexample1;

// High-level module (business logic) - VIOLATES DIP
public class PaymentService {
    private final StripePaymentGateway stripeGateway;
    private final PayPalPaymentGateway paypalGateway;

    public PaymentService() {
        this.stripeGateway = new StripePaymentGateway(); // Tight coupling
        this.paypalGateway = new PayPalPaymentGateway(); // Tight coupling
    }

    public void processPayment(String gatewayType, double amount) {
        if ("stripe".equalsIgnoreCase(gatewayType)) {
            stripeGateway.processStripePayment(amount);
        } else if ("paypal".equalsIgnoreCase(gatewayType)) {
            paypalGateway.processPayPalPayment(amount);
        }
    }
}

/*
Tight coupling: PaymentService directly depends on concrete implementations
Hard to test: Can't easily mock payment gateways for testing
Hard to extend: Adding a new payment gateway requires modifying the high-level class
Violates Open/Closed Principle: Code isn't open for extension but closed for modification
 */
