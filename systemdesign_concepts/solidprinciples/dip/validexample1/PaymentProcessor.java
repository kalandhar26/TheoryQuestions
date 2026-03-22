package solidprinciples.dip.validexample1;

// Abstraction that both high-level and low-level modules depend on
public interface PaymentProcessor {
    void processPayment(PaymentGateway gateway, double amount);
    void refundPayment(PaymentGateway gateway, String transactionId);
}
