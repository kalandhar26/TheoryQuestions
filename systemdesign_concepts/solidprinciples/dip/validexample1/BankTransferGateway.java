package solidprinciples.dip.validexample1;

public class BankTransferGateway implements PaymentGateway {
    @Override
    public void processPayment(double amount) {
        System.out.println("Processing bank transfer: $" + amount);
        // Bank transfer specific logic
    }

    @Override
    public void refundPayment(String transactionId) {
        System.out.println("Refunding bank transfer: " + transactionId);
        // Bank transfer refund logic
    }
}
