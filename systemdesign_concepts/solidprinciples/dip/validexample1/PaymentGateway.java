package solidprinciples.dip.validexample1;

// Abstraction that both high-level and low-level modules depend on
public interface PaymentGateway {
    void processPayment(double amount);
    void refundPayment(String transactionId);
}
